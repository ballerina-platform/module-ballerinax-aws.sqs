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

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.values.BObject;
import software.amazon.awssdk.services.sqs.SqsClient;

import static io.ballerina.lib.aws.sqs.ModuleUtils.getModule;

import io.ballerina.lib.aws.sqs.client.NativeClientAdaptor;

/**
 * Utility class for AWS SQS Listener operations.
 * Handles caller creation and message acknowledgment operations.
 */

public final class ListenerUtils {

    static final String NATIVE_QUEUE_URL = "native.queue.url";
    static final String NATIVE_ACK_MESSAGES = "native.ack.messages";

    /**
     * Creates a new Caller object for handling message acknowledgments.
     * Links the caller to the listener's SQS client and message context.
     *
     * @param env       The Ballerina runtime environment
     * @param bListener The parent listener object
     * @param queueUrl  The SQS queue URL
     * @param message   The received SQS message
     * @return A new Caller object configured for the given context
     */
    public static BObject createCaller(Environment env,
            BObject bListener,
            String queueUrl,
            AckMessage ackMessage) {
        BObject caller = ValueCreator.createObjectValue(getModule(), "Caller");
        // copy the SqsClient from the listener onto the caller
        SqsClient sqsClient = (SqsClient) bListener.getNativeData(NativeClientAdaptor.NATIVE_SQS_CLIENT);
        caller.addNativeData(NativeClientAdaptor.NATIVE_SQS_CLIENT, sqsClient);
        // add the queue URL and the raw message
        caller.addNativeData(NATIVE_QUEUE_URL, queueUrl);
        caller.addNativeData(NATIVE_ACK_MESSAGES, ackMessage);
        return caller;
    }

    /**
     * Extracts the queue name from an SQS queue URL.
     *
     * @param queueUrl The full SQS queue URL
     * @return The queue name (last part after the final '/')
     */
    public static String extractQueueName(String queueUrl) {
        if (queueUrl != null && queueUrl.contains("/")) {
            String[] parts = queueUrl.split("/");
            return parts[parts.length - 1];
        }
        return queueUrl;
    }

}
