// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

package io.ballerina.lib.aws.sqs.listener;

import io.ballerina.lib.aws.sqs.CommonUtils;
import io.ballerina.lib.aws.sqs.client.NativeClientAdaptor;
import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.core.exception.AbortedException;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.QueueDoesNotExistException;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageResponse;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Native implementation of the Ballerina AWS SQS Listener.
 * Manages the lifecycle of SQS message polling and service invocation.
 */
public final class Listener {

    public static final String NATIVE_SQS_CLIENT = "nativeClient";
    private static final String NATIVE_POLLING_CONFIG = "native.polling.config";
    private static final String NATIVE_SERVICES = "native.services";
    private static final String NATIVE_STOPPED = "native.stopped";
    private static final String NATIVE_POLLING_THREAD = "native.polling.thread";

    private Listener() {
    }

    /**
     * Initializes the SQS listener with the given configuration.
     *
     * Sets up the SQS client and required native data.
     */
    public static Object init(Environment env,
            BObject bListener,
            BMap<BString, Object> connectionConfig,
            BMap<BString, Object> pollingConfig) {
        try {
            // Initialize the SQS client
            NativeClientAdaptor.init(bListener, connectionConfig);
            // Store polling config, an empty service map and the stopped flag
            bListener.addNativeData(NATIVE_POLLING_CONFIG, new PollingConfig(pollingConfig));
            bListener.addNativeData(NATIVE_SERVICES, new ConcurrentHashMap<String, Service>());
            bListener.addNativeData(NATIVE_STOPPED, new AtomicBoolean(true));
        } catch (BError e) {
            return e;
        } catch (Exception e) {
            return CommonUtils.createError("Failed to initialize SQS listener: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Attaches an SQS service to this listener.
     * Each service is mapped to a specific queue URL.
     */
    public static Object attach(Environment env, BObject bListener, BObject bService, Object name) {
        try {
            Service.validateService(bService);
            Service nativeService = new Service(bService);
            String queueUrl = nativeService.getServiceConfig().queueUrl;
            Map<String, Service> services = getServices(bListener);
            services.put(queueUrl, nativeService);
            bService.addNativeData("native.service", nativeService);
        } catch (BError e) {
            return e;
        } catch (Exception e) {
            return CommonUtils.createError("Failed to attach service: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Detaches a service from this listener.
     * Stops message polling for the associated queue.
     */
    public static Object detach(Environment env, BObject bListener, BObject bService) {
        try {
            Service nativeService = (Service) bService.getNativeData("native.service");
            if (nativeService != null) {
                String queueUrl = nativeService.getServiceConfig().queueUrl;
                getServices(bListener).remove(queueUrl);
            }
        } catch (BError e) {
            return e;
        } catch (Exception e) {
            return CommonUtils.createError("Failed to detach service: " + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Starts the listener and begins polling for messages.
     * Creates a virtual thread for each service to poll independently.
     */
    public static Object start(Environment env, BObject bListener) {
        AtomicBoolean stopped = (AtomicBoolean) bListener.getNativeData(NATIVE_STOPPED);
        if (!stopped.compareAndSet(true, false)) {
            return null;
        }

        SqsClient sqsClient = (SqsClient) bListener.getNativeData(NATIVE_SQS_CLIENT);
        PollingConfig pollingConfig = (PollingConfig) bListener.getNativeData(NATIVE_POLLING_CONFIG);
        Map<String, Service> services = getServices(bListener);

        for (Service svc : services.values()) {
            ServiceConfig cfg = svc.getServiceConfig();
            String queueName = extractQueueName(cfg.queueUrl);
            try {
                sqsClient.getQueueUrl(builder -> builder.queueName(queueName));
            } catch (QueueDoesNotExistException qex) {
                sqsClient.close();
                return CommonUtils.createError("Configured queue does not exist: " + cfg.queueUrl, qex);
            }
        }
        Map<String, ReceiveMessageRequest> receiveRequests = new ConcurrentHashMap<>();
        for (Service svc : services.values()) {
            ServiceConfig cfg = svc.getServiceConfig();
            PollingConfig effectivePollingConfig = cfg.pollingConfig != null ? cfg.pollingConfig : pollingConfig;
            ReceiveMessageRequest req = ReceiveMessageRequest.builder()
                    .queueUrl(cfg.queueUrl)
                    .maxNumberOfMessages(1)
                    .waitTimeSeconds(effectivePollingConfig.waitTime())
                    .visibilityTimeout(effectivePollingConfig.visibilityTimeout())
                    .build();
            receiveRequests.put(cfg.queueUrl, req);
        }

        Thread pollingThread = Thread.startVirtualThread(() -> {
            while (!stopped.get()) {
                for (Service svc : services.values()) {
                    try {
                        ServiceConfig cfg = svc.getServiceConfig();
                        ReceiveMessageRequest req = receiveRequests.get(cfg.queueUrl);
                        ReceiveMessageResponse resp = sqsClient.receiveMessage(req);
                        if (resp.hasMessages()) {
                            new MessageDispatcher(env, svc)
                                    .dispatch(resp.messages(), bListener, cfg.queueUrl, cfg.autoDelete);
                        }
                        long sleep = pollingConfig.pollIntervalInMillis();
                        if (sleep > 0) {
                            Thread.sleep(sleep);
                        }
                    } catch (InterruptedException ie) {
                        stopped.set(true);
                        Thread.currentThread().interrupt();
                    } catch (AbortedException ae) {
                        stopped.set(true);
                    } catch (QueueDoesNotExistException qex) {
                        stopped.set(true);
                        throw CommonUtils.createError(
                                "Queue deleted during polling: " + qex.awsErrorDetails().errorMessage(), qex);
                    } catch (Exception e) {
                        stopped.set(true);
                        throw CommonUtils.createError("Error polling messages from SQS: " + e.getMessage(), e);
                    }
                }
            }
        });
        bListener.addNativeData(NATIVE_POLLING_THREAD, pollingThread);
        return null;
    }

    /**
     * Gracefully stops the listener.
     */
    public static Object gracefulStop(Environment env, BObject bListener) {
        ((AtomicBoolean) bListener.getNativeData(NATIVE_STOPPED)).set(true);
        Thread pollingThread = (Thread) bListener.getNativeData(NATIVE_POLLING_THREAD);
        if (pollingThread != null) {
            try {
                pollingThread.join();
            } catch (InterruptedException ignored) {
                Thread.currentThread().interrupt();
            }
        }
        ((SqsClient) bListener.getNativeData(NATIVE_SQS_CLIENT)).close();
        return null;
    }

    /**
     * Immediately stops the listener.
     */
    public static Object immediateStop(Environment env, BObject bListener) {
        ((AtomicBoolean) bListener.getNativeData(NATIVE_STOPPED)).set(true);
        Thread pollingThread = (Thread) bListener.getNativeData(NATIVE_POLLING_THREAD);
        if (pollingThread != null) {
            pollingThread.interrupt(); // Interrupt the thread immediately
            try {
                pollingThread.join(); // Wait for it to finish
            } catch (InterruptedException ignored) {
                Thread.currentThread().interrupt();
            }
        }
        ((SqsClient) bListener.getNativeData(NATIVE_SQS_CLIENT)).close();
        return null;
    }

    /**
     * Retrieves the services map from listener's native data.
     */
    @SuppressWarnings("unchecked")
    private static Map<String, Service> getServices(BObject bListener) {
        return (Map<String, Service>) bListener.getNativeData(NATIVE_SERVICES);
    }

    private static String extractQueueName(String queueUrl) {
        if (queueUrl == null || queueUrl.isEmpty()) {
            return "";
        }
        String[] parts = queueUrl.split("/");
        return parts[parts.length - 1];
    }
}
