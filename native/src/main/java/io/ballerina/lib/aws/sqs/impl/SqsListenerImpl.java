/*
 * Copyright (c) 2023, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.lib.aws.sqs.impl;

import io.ballerina.lib.aws.sqs.api.SqsListener;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import software.amazon.awssdk.services.sqs.model.Message;

/**
 * SQS message listener implementation.
 */
public class SqsListenerImpl implements SqsListener {

    private static final Logger logger = LoggerFactory.getLogger(SqsListenerImpl.class);

    private final BObject serviceObj;
    private final String resource;
    private final String moduleVersion;

    public SqsListenerImpl(BObject serviceObj, String resource, String moduleVersion) {
        this.serviceObj = serviceObj;
        this.resource = resource;
        this.moduleVersion = moduleVersion;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void onMessagesReceived(String queueUrl, SqsPollCycleFutureListener listener) {
        try {
            // Convert SQS messages to Ballerina objects
            BArray sqsMessagesObj = convertSqsMessagesToBArray(listener.getMessages());
            listener.setSqsMessagesObj(sqsMessagesObj);

            // Invoke the resource function in the service
            SqsResourceDispatcher.dispatchResource(serviceObj, resource, moduleVersion, listener);
        } catch (Exception e) {
            logger.error("Error dispatching SQS messages: " + e.getMessage(), e);
            listener.completeExceptionally(e);
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void onError(Throwable throwable) {
        logger.error("Error in SQS listener: " + throwable.getMessage(), throwable);
    }

    /**
     * Convert list of SQS messages to Ballerina array.
     *
     * @param messages List of SQS messages
     * @return Ballerina array of SQS messages
     */
    private BArray convertSqsMessagesToBArray(java.util.List<Message> messages) {
        BArray sqsMessagesArray = ValueCreator.createArrayValue(TypeCreator.createArrayType(PredefinedTypes.TYPE_STRING));

        for (Message message : messages) {
            BMap<BString, Object> sqsMessageObj = createSqsMessageObject(message);
            sqsMessagesArray.append(sqsMessageObj);
        }

        return sqsMessagesArray;
    }

    /**
     * Create a Ballerina SQS message object from AWS SDK message.
     *
     * @param message AWS SDK SQS message
     * @return Ballerina SQS message object
     */
    private BMap<BString, Object> createSqsMessageObject(Message message) {
        BMap<BString, Object> sqsMessageObj = ValueCreator.createMapValue();

        // Set message body
        sqsMessageObj.put(StringUtils.fromString("body"), StringUtils.fromString(message.body()));

        // Set message ID
        sqsMessageObj.put(StringUtils.fromString("messageId"), StringUtils.fromString(message.messageId()));

        // Set receipt handle
        sqsMessageObj.put(StringUtils.fromString("receiptHandle"), StringUtils.fromString(message.receiptHandle()));

        // Set MD5 of body
        sqsMessageObj.put(StringUtils.fromString("md5OfBody"), StringUtils.fromString(message.md5OfBody()));

        // Convert and set attributes
        BMap<BString, Object> attributes = ValueCreator.createMapValue();
        message.attributes().forEach((key, value) ->
                attributes.put(StringUtils.fromString(key), StringUtils.fromString(value)));
        sqsMessageObj.put(StringUtils.fromString("attributes"), attributes);

        // Convert and set message attributes
        BMap<BString, Object> messageAttributes = ValueCreator.createMapValue();
        message.messageAttributes().forEach((key, value) ->
                messageAttributes.put(StringUtils.fromString(key), StringUtils.fromString(value.stringValue())));
        sqsMessageObj.put(StringUtils.fromString("messageAttributes"), messageAttributes);

        return sqsMessageObj;
    }
}
