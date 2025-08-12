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

import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BObject;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.DeleteMessageRequest;

import static io.ballerina.lib.aws.sqs.CommonUtils.createError;
import io.ballerina.lib.aws.sqs.client.NativeClientAdaptor;

/**
 * Native implementation of the Ballerina AWS SQS Caller object.
 * Handles message acknowledgment and negative acknowledgment operations.
 */
public final class Caller {

    static final String NATIVE_QUEUE_URL = "native.queue.url";
    static final String NATIVE_ACK_MESSAGES = "native.ack.messages";

    private Caller() {
    }

    /**
     * Acknowledges one or more messages, removing them from the queue.
     *
     * @param callerObj The Ballerina Caller object containing SQS client and
     *                  message information
     * @return null on success, Error on failure
     */
    public static Object delete(BObject callerObj) {
        try {
            // Extract the SQS client, queue URL, and messages from the caller object
            SqsClient client = (SqsClient) callerObj.getNativeData(NativeClientAdaptor.NATIVE_SQS_CLIENT);
            String queueUrl = (String) callerObj.getNativeData(NATIVE_QUEUE_URL);
            AckMessage ackMessage = (AckMessage) callerObj.getNativeData(NATIVE_ACK_MESSAGES);

            if (ackMessage != null) {
                DeleteMessageRequest req = DeleteMessageRequest.builder()
                        .queueUrl(queueUrl)
                        .receiptHandle(ackMessage.receiptHandle())
                        .build();
                client.deleteMessage(req);
            }
        } catch (BError e) {
            return e;
        } catch (Throwable e) {
            return createError("Failed to acknowledge message(s): " + e.getMessage(), e);
        }
        return null;
    }
}
