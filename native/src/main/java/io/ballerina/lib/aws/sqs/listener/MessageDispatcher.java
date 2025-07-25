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
import io.ballerina.lib.aws.sqs.mappers.ReceiveMessageMapper;
import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.Runtime;
import io.ballerina.runtime.api.concurrent.StrandMetadata;
import io.ballerina.runtime.api.types.Parameter;
import io.ballerina.runtime.api.types.RemoteMethodType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.Message;

import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Handles the dispatching of received SQS messages to Ballerina services.
 */
public class MessageDispatcher {
    private static final String ON_MESSAGE_METHOD = "onMessage";
    private static final String ON_ERROR_METHOD = "onError";

    private final Runtime ballerinaRuntime;
    private final Service nativeService;
    private final Environment environment;
    private static final Logger logger = Logger.getLogger(MessageDispatcher.class.getName());

    /**
     * Creates a new message dispatcher.
     *
     * @param env           The Ballerina runtime environment
     * @param nativeService The native service implementation
     */
    public MessageDispatcher(Environment env, Service nativeService) {

        this.environment = env;
        this.ballerinaRuntime = env.getRuntime();
        this.nativeService = nativeService;
    }

    /**
     * Dispatches received messages to the appropriate service method.
     * Creates a virtual thread for async processing.
     *
     * @param messages   The received SQS messages
     * @param bListener  The listener instance
     * @param queueUrl   The source queue URL
     * @param autoDelete Whether to auto-delete messages
     */
    public void dispatch(List<Message> messages, BObject bListener, String queueUrl, boolean autoDelete) {
        Thread.startVirtualThread(() -> {
            for (Message msg : messages) {
                try {
                    // convert to Ballerina record (single message)
                    BMap<BString, Object> bMsg = ReceiveMessageMapper.getNativeMessage(msg);

                    // build args of length 1 or 2
                    Object[] args = getOnMessageParams(bMsg, bListener, queueUrl, msg);

                    // invoke onMessage
                    StrandMetadata meta = new StrandMetadata(
                            nativeService.isOnMessageMethodIsolated(), null);
                    if (args.length > 2 || args.length < 1) {
                        throw CommonUtils.createError(
                                "Invalid number of parameters for onMessage method. Expected 1 or 2, got "
                                        + args.length);
                    }
                    try {
                        ballerinaRuntime.callMethod(
                                nativeService.getConsumerService(),
                                ON_MESSAGE_METHOD,
                                meta,
                                args);
                    } catch (Throwable userErr) {
                        logger.log(Level.WARNING, "Error in user onMessage method", userErr);
                    }
                    // auto-ack if requested
                    if (autoDelete) {
                        BObject caller = ListenerUtils.createCaller(environment, bListener, queueUrl,
                                new AckMessage(msg.messageId(), msg.receiptHandle()));
                        Object err = Caller.delete(caller);
                        if (err instanceof BError) {
                            logger.warning("Failed to delete message: " + ((BError) err).getMessage());
                        }
                    }
                    // only framework errors
                } catch (Throwable e) {
                    logger.log(Level.SEVERE, "Framework error in dispatching messages", e);
                    BError err = CommonUtils.createError("Failed to dispatch messages", e);
                    invokeOnError(err, bListener);
                }
            }
        });
    }

    /**
     * Invokes the service's onError method if present.
     *
     * @param error     The error that occurred
     * @param bListener The listener instance
     */
    private void invokeOnError(BError error, BObject bListener) {
        if (nativeService.getOnErrorMethod() != null) {
            try {
                StrandMetadata meta = new StrandMetadata(
                        nativeService.getOnErrorMethod().isIsolated(), null);
                // onError(error, retry)
                ballerinaRuntime.callMethod(
                        nativeService.getConsumerService(),
                        ON_ERROR_METHOD,
                        meta,
                        error, true);
            } catch (Throwable t) {
                logger.log(Level.WARNING, "Error while invoking onError", t);
            }
        }
    }

    /**
     * Prepares parameters for the onMessage method call.
     */
    private Object[] getOnMessageParams(BMap<BString, Object> bMsg,
            BObject bListener,
            String queueUrl,
            Message msg) {
        RemoteMethodType onMsg = nativeService.getOnMessageMethod();
        Parameter[] params = onMsg.getParameters();
        Object[] args = new Object[params.length];

        // First parameter must be Message
        if (params.length > 0) {
            args[0] = bMsg;
        }
        // Second parameter (if present) must be Caller
        if (params.length == 2) {
            Type secondParamType = TypeUtils.getReferredType(params[1].type);
            if (secondParamType.getTag() == TypeTags.OBJECT_TYPE_TAG) {
                args[1] = ListenerUtils.createCaller(environment, bListener, queueUrl,
                        (new AckMessage(msg.messageId(), msg.receiptHandle())));
            } else {
                throw new RuntimeException("Second parameter must be Caller");
            }
        }
        return args;
    }
}
