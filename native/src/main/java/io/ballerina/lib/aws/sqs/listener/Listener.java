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

import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.QueueDoesNotExistException;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;

import static io.ballerina.lib.aws.sqs.listener.ListenerUtils.extractQueueName;

/**
 * Native implementation of the Ballerina AWS SQS Listener.
 * Manages the lifecycle of SQS message polling and service invocation.
 */
public final class Listener {

    static final String NATIVE_POLLING_CONFIG = "native.polling.config";
    static final String NATIVE_SERVICES = "native.services";
    static final String NATIVE_STOPPED = "native.stopped";
    static final String NATIVE_SERVICE = "native.service";
    static final String NATIVE_RECEIVER = "native.receiver";

    private Listener() {
    }

    /**
     * Initializes the SQS listener with the given configuration.
     * Sets up the SQS client and required native data.
     */
    public static Object init(Environment env,
            BObject bListener,
            BMap<BString, Object> connectionConfig,
            BMap<BString, Object> pollingConfig) {
        try {
            // create the native SQS client
            SqsClient nativeSqsClient = NativeClientAdaptor.createSqsClient(connectionConfig);
            // set the native client as native data in the listener object
            bListener.addNativeData(NativeClientAdaptor.NATIVE_SQS_CLIENT, nativeSqsClient);

            // parse and store polling configuration
            PollingConfig pollingCfg = new PollingConfig(pollingConfig);
            bListener.addNativeData(NATIVE_POLLING_CONFIG, pollingCfg);

            // initialize empty service registry
            Map<String, Service> services = new ConcurrentHashMap<>();
            bListener.addNativeData(NATIVE_SERVICES, services);

            // initialize listener state (initially stopped)
            AtomicBoolean listenerStopped = new AtomicBoolean(true);
            bListener.addNativeData(NATIVE_STOPPED, listenerStopped);
        } catch (BError e) {
            return CommonUtils.createError("Failed to initialize SQS listener: " + e.getMessage(), e);
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
            ServiceConfig cfg = nativeService.getServiceConfig();

            PollingConfig pollingConfig = (PollingConfig) bListener.getNativeData(NATIVE_POLLING_CONFIG);
            PollingConfig effectiveConfig = cfg.pollingConfig() != null ? cfg.pollingConfig() : pollingConfig;

            MessageDispatcher dispatcher = new MessageDispatcher(env, nativeService);
            MessageReceiver receiver = new MessageReceiver(
                    (SqsClient) bListener.getNativeData(NativeClientAdaptor.NATIVE_SQS_CLIENT),
                    cfg.queueUrl(),
                    effectiveConfig,
                    dispatcher,
                    bListener,
                    cfg.autoDelete());

            Map<String, Service> services = getServices(bListener);
            services.put(cfg.queueUrl(), nativeService);
            bService.addNativeData(NATIVE_SERVICE, nativeService);
            bService.addNativeData(NATIVE_RECEIVER, receiver);
        } catch (BError e) {
            return CommonUtils.createError(e.getMessage(), e);
        } catch (Exception e) {
            return CommonUtils.createError(e.getMessage(), e);
        }
        return null;
    }

    /**
     * Detaches a service from this listener.
     * Stops message polling for the associated queue.
     */
    public static Object detach(Environment env, BObject bListener, BObject bService) {
        try {
            Service nativeService = (Service) bService.getNativeData(NATIVE_SERVICE);
            if (nativeService != null) {
                String queueUrl = nativeService.getServiceConfig().queueUrl();
                getServices(bListener).remove(queueUrl);
            }
        } catch (BError e) {
            return CommonUtils.createError(e.getMessage(), e);
        } catch (Exception e) {
            return CommonUtils.createError(e.getMessage(), e);
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
        SqsClient sqsClient = (SqsClient) bListener.getNativeData(NativeClientAdaptor.NATIVE_SQS_CLIENT);
        Map<String, Service> services = getServices(bListener);
        try {
            for (Service service : services.values()) {
                ServiceConfig cfg = service.getServiceConfig();
                String queueName = extractQueueName(cfg.queueUrl());
                sqsClient.getQueueUrl(builder -> builder.queueName(queueName));
            }
        } catch (QueueDoesNotExistException qex) {
            stopped.set(true);
            return CommonUtils.createError("Queue does not exist before polling", qex);
        } catch (Exception ex) {
            stopped.set(true);
            return CommonUtils.createError("Failed to validate queue: ", ex);
        }
        try {
            for (Service service : services.values()) {
                BObject bService = service.getConsumerService();
                MessageReceiver receiver = (MessageReceiver) bService.getNativeData(NATIVE_RECEIVER);
                receiver.consume();
            }
        } catch (Exception e) {
            stopAllReceivers(services);
            stopped.set(true);
            return CommonUtils
                    .createError("Error occurred while starting the Ballerina AWS SQS listener" + e.getMessage(), e);
        }
        return null;
    }

    /**
     * Gracefully stops the listener.
     */
    public static Object gracefulStop(Environment env, BObject bListener) {
        AtomicBoolean stopped = (AtomicBoolean) bListener.getNativeData(NATIVE_STOPPED);
        if (stopped.get()) {
            return null;
        }
        stopped.set(true);

        Map<String, Service> services = getServices(bListener);
        try {
            for (Service service : services.values()) {
                BObject bService = service.getConsumerService();
                MessageReceiver receiver = (MessageReceiver) bService.getNativeData(NATIVE_RECEIVER);
                if (receiver != null) {
                    receiver.stop();
                }
            }
            SqsClient client = (SqsClient) bListener.getNativeData(NativeClientAdaptor.NATIVE_SQS_CLIENT);
            if (client != null) {
                client.close();
            }
        } catch (Exception e) {
            return CommonUtils.createError("Error occurred while gracefully stopping the Ballerina AWS SQS listener", e);
        }
        return null;
    }

    /**
     * Immediately stops the listener.
     */
    public static Object immediateStop(Environment env, BObject bListener) {
        AtomicBoolean stopped = (AtomicBoolean) bListener.getNativeData(NATIVE_STOPPED);
        stopped.set(true);

        Map<String, Service> services = getServices(bListener);
        try {
            for (Service service : services.values()) {
                BObject bService = service.getConsumerService();
                MessageReceiver receiver = (MessageReceiver) bService.getNativeData(NATIVE_RECEIVER);
                if (receiver != null) {
                    receiver.stop();
                }
            }
            SqsClient client = (SqsClient) bListener.getNativeData(NativeClientAdaptor.NATIVE_SQS_CLIENT);
            if (client != null) {
                client.close();
            }
        } catch (Exception e) {
            return CommonUtils.createError("Error occurred while immediately stopping the Ballerina AWS SQS listener",
                    e);
        }
        return null;
    }

    /**
     * Retrieves the services map from listener's native data.
     */
    @SuppressWarnings("unchecked")
    private static Map<String, Service> getServices(BObject bListener) {
        return (Map<String, Service>) bListener.getNativeData(NATIVE_SERVICES);
    }

    private static void stopAllReceivers(Map<String, Service> services) {
        for (Service service : services.values()) {
            try {
                BObject bService = service.getConsumerService();
                MessageReceiver receiver = (MessageReceiver) bService.getNativeData(NATIVE_RECEIVER);
                if (receiver != null) {
                    receiver.stop();
                }
            } catch (Exception e) {
            }
        }
    }
}
