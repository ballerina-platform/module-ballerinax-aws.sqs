/*
 * Copyright (c) 2025, WSO2 LLC. (http://www.wso2.org).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
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

package io.ballerina.lib.aws.sqs;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import software.amazon.awssdk.awscore.exception.AwsErrorDetails;
import software.amazon.awssdk.awscore.exception.AwsServiceException;
import software.amazon.awssdk.http.SdkHttpResponse;
import software.amazon.awssdk.services.sqs.model.BatchResultErrorEntry;
import software.amazon.awssdk.services.sqs.model.Message;
import software.amazon.awssdk.services.sqs.model.MessageAttributeValue;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageResponse;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchRequestEntry;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchResponse;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchResultEntry;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageResponse;


 /**
 * {@code CommonUtils} Contains the common utility functions for the Ballerina AWS SQS Client
 */

public final class CommonUtils {

    // Constants related to `Error`
    private static final String ERROR = "Error";
    private static final String ERROR_DETAILS = "ErrorDetails";
    private static final BString ERROR_DETAILS_HTTP_STATUS_CODE = StringUtils.fromString("httpStatusCode");
    private static final BString ERROR_DETAILS_HTTP_STATUS_TEXT = StringUtils.fromString("httpStatusText");
    private static final BString ERROR_DETAILS_ERROR_CODE = StringUtils.fromString("errorCode");
    private static final BString ERROR_DETAILS_ERROR_MESSAGE = StringUtils.fromString("errorMessage");

    //Constants related to `SendmessageResponse`
    private static final String SEND_MESSAGE_RESPONSE = "SendMessageResponse";
    private static final BString MESSAGE_ID = StringUtils.fromString("messageId");
    private static final BString MD5_OF_BODY = StringUtils.fromString("md5OfMessageBody");
    private static final BString MD5_OF_ATTRIBUTES = StringUtils.fromString("md5OfMessageAttributes");
    private static final BString MD5_OF_SYS_ATTRIBUTES = StringUtils.fromString("md5OfMessageSystemAttributes");
    private static final BString SEQUENCE_NUMBER = StringUtils.fromString("sequenceNumber");

    // Constants related to `SendmessageConfig`
    private static final BString DELAY_SECONDS = StringUtils.fromString("delaySeconds");
    private static final BString MESSAGE_ATTRIBUTES = StringUtils.fromString("messageAttributes");
    private static final BString AWS_TRACE_HEADER = StringUtils.fromString("awsTraceHeader");
    private static final BString MESSAGE_DEDUPLICATION_ID = StringUtils.fromString("messageDeduplicationId");
    private static final BString MESSAGE_GROUP_ID = StringUtils.fromString("messageGroupId");

    // Constants related to `ReceiveMessageConfig` and `Message`
    private static final BString WAIT_TIME_SECONDS = StringUtils.fromString("waitTimeSeconds");
    private static final BString VISIBILITY_TIMEOUT = StringUtils.fromString("visibilityTimeout");
    private static final BString MAX_NUMBER_OF_MESSAGES = StringUtils.fromString("maxNumberOfMessages");
    private static final BString RECEIVE_REQUEST_ATTEMPT_ID = StringUtils.fromString("receiveRequestAttemptId");
    private static final BString MESSAGE_ATTRIBUTE_NAMES = StringUtils.fromString("messageAttributeNames");
    private static final BString MESSAGE_SYSTEM_ATTRIBUTE_NAMES = StringUtils.fromString("messageSystemAttributeNames");

    private static final String MESSAGE_RECORD = "Message";
    private static final BString BODY = StringUtils.fromString("body");
    private static final BString MD5_OF_MESSAGE_ATTRIBUTES = StringUtils.fromString("md5OfMessageAttributes");
    private static final BString RECEIPT_HANDLE = StringUtils.fromString("receiptHandle");

    // Constants related to SendMessageBatch
    private static final String SEND_MESSAGE_BATCH_RESPONSE = "SendMessageBatchResponse";
    private static final BString SUCCESSFUL = StringUtils.fromString("successful");
    private static final BString FAILED = StringUtils.fromString("failed");
    private static final BString ID = StringUtils.fromString("id");
    private static final BString CODE = StringUtils.fromString("code");
    private static final BString SENDER_FAULT = StringUtils.fromString("senderFault");
    private static final BString MESSAGE = StringUtils.fromString("message");
    




    private CommonUtils() {
    }

    
    public static BError createError(String message, Throwable exception) {
        BError cause = ErrorCreator.createError(exception);
        BMap<BString, Object> errorDetails = ValueCreator.createRecordValue(
                ModuleUtils.getModule(), ERROR_DETAILS);
        if (exception instanceof AwsServiceException awsServiceException &&
                Objects.nonNull(awsServiceException.awsErrorDetails())) {
            AwsErrorDetails awsErrorDetails = awsServiceException.awsErrorDetails();
            SdkHttpResponse sdkResponse = awsErrorDetails.sdkHttpResponse();
            if (Objects.nonNull(sdkResponse)) {
                errorDetails.put(ERROR_DETAILS_HTTP_STATUS_CODE, sdkResponse.statusCode());
                sdkResponse.statusText().ifPresent(httpStatusTxt -> errorDetails.put(
                        ERROR_DETAILS_HTTP_STATUS_TEXT, StringUtils.fromString(httpStatusTxt)));
            }
            errorDetails.put(ERROR_DETAILS_ERROR_CODE, StringUtils.fromString(awsErrorDetails.errorCode()));
            errorDetails.put(ERROR_DETAILS_ERROR_MESSAGE, StringUtils.fromString(awsErrorDetails.errorMessage()));
        }
        return ErrorCreator.createError(
                ModuleUtils.getModule(), ERROR, StringUtils.fromString(message), cause, errorDetails);
    }

    @SuppressWarnings("unchecked")
    public static SendMessageRequest getNativeSendMessageRequest(BString queueUrl, BString messageBody, 
        BMap<BString, Object> sendMessageConfig) throws Exception {

    SendMessageRequest.Builder builder = SendMessageRequest.builder()
            .queueUrl(queueUrl.getValue())
            .messageBody(messageBody.getValue());
    
    if (sendMessageConfig.containsKey(DELAY_SECONDS)) {
            builder.delaySeconds(((Long) sendMessageConfig.get(DELAY_SECONDS)).intValue());
        }
    if (sendMessageConfig.containsKey(MESSAGE_DEDUPLICATION_ID)) {
            builder.messageDeduplicationId(sendMessageConfig.getStringValue(MESSAGE_DEDUPLICATION_ID).getValue());
        }
    if (sendMessageConfig.containsKey(MESSAGE_GROUP_ID)) {
            builder.messageGroupId(sendMessageConfig.getStringValue(MESSAGE_GROUP_ID).getValue());
        }
    if (sendMessageConfig.containsKey(AWS_TRACE_HEADER)) {
            builder.messageAttributes(Map.of("AWSTraceHeader",
                    MessageAttributeValue.builder()
                            .dataType("String")
                            .stringValue(sendMessageConfig.getStringValue(AWS_TRACE_HEADER).getValue())
                            .build()));
        }
    if (sendMessageConfig.containsKey(MESSAGE_ATTRIBUTES)) {
            BMap<BString, Object> attrs = (BMap<BString, Object>) sendMessageConfig.get(MESSAGE_ATTRIBUTES);
            Map<String, MessageAttributeValue> attrMap = new HashMap<>();
            for (Object key : attrs.getKeys()) {
                BString attrKey = (BString) key;
                BMap<BString, Object> attrVal = (BMap<BString, Object>) attrs.get(attrKey);
                MessageAttributeValue mav = MessageAttributeValue.builder()
                        .dataType(attrVal.getStringValue(StringUtils.fromString("dataType")).getValue())
                        .stringValue(attrVal.getStringValue(StringUtils.fromString("stringValue")).getValue())
                        .build();
                attrMap.put(attrKey.getValue(), mav);
            }
            builder.messageAttributes(attrMap);
        }
        return builder.build();
    
}


public static BMap<BString, Object> getNativeSendMessageResponse(SendMessageResponse response) {
        BMap<BString, Object> result = ValueCreator.createRecordValue(
                ModuleUtils.getModule(), SEND_MESSAGE_RESPONSE);
        result.put(MESSAGE_ID, StringUtils.fromString(response.messageId()));
        result.put(MD5_OF_BODY, StringUtils.fromString(response.md5OfMessageBody()));
        if (response.md5OfMessageAttributes() != null) {
            result.put(MD5_OF_ATTRIBUTES, StringUtils.fromString(response.md5OfMessageAttributes()));
        }
        if (response.md5OfMessageSystemAttributes() != null) {
            result.put(MD5_OF_SYS_ATTRIBUTES, StringUtils.fromString(response.md5OfMessageSystemAttributes()));
        }
        if (response.sequenceNumber() != null) {
            result.put(SEQUENCE_NUMBER, StringUtils.fromString(response.sequenceNumber()));
        }
        return result;
    }

    public static ReceiveMessageRequest getNativeReceiveMessageRequest(BString queueUrl, BMap<BString, Object> receiveMessageConfig) {
    ReceiveMessageRequest.Builder builder = ReceiveMessageRequest.builder()
            .queueUrl(queueUrl.getValue());

    if (receiveMessageConfig.containsKey(WAIT_TIME_SECONDS)) {
        builder.waitTimeSeconds(((Long) receiveMessageConfig.get(WAIT_TIME_SECONDS)).intValue());
    }
    if (receiveMessageConfig.containsKey(VISIBILITY_TIMEOUT)) {
        builder.visibilityTimeout(((Long) receiveMessageConfig.get(VISIBILITY_TIMEOUT)).intValue());
    }
    if (receiveMessageConfig.containsKey(MAX_NUMBER_OF_MESSAGES)) {
        builder.maxNumberOfMessages(((Long) receiveMessageConfig.get(MAX_NUMBER_OF_MESSAGES)).intValue());
    }
    if (receiveMessageConfig.containsKey(RECEIVE_REQUEST_ATTEMPT_ID)) {
        builder.receiveRequestAttemptId(receiveMessageConfig.getStringValue(RECEIVE_REQUEST_ATTEMPT_ID).getValue());
    }
    if (receiveMessageConfig.containsKey(MESSAGE_ATTRIBUTE_NAMES)) {
        BArray attrNamesArr = (BArray) receiveMessageConfig.get(MESSAGE_ATTRIBUTE_NAMES);
        List<String> attrNames = new ArrayList<>();
        for (int i = 0; i < attrNamesArr.size(); i++) {
            attrNames.add(attrNamesArr.getBString(i).getValue());
        }
        builder.messageAttributeNames(attrNames);
    }
    if (receiveMessageConfig.containsKey(MESSAGE_SYSTEM_ATTRIBUTE_NAMES)) {
    BArray sysAttrNamesArr = (BArray) receiveMessageConfig.get(MESSAGE_SYSTEM_ATTRIBUTE_NAMES);
    List<String> sysAttrNames = new ArrayList<>();
    for (int i = 0; i < sysAttrNamesArr.size(); i++) {
        sysAttrNames.add(sysAttrNamesArr.getBString(i).getValue());
    }
    builder.messageAttributeNames(sysAttrNames);
}
    return builder.build();
}

public static BArray getNativeReceiveMessageResponse(ReceiveMessageResponse response) {
    List<Message> messages = response.messages();
    Type recordType = ValueCreator.createRecordValue(ModuleUtils.getModule(), MESSAGE_RECORD).getType();
    BArray resultArr = ValueCreator.createArrayValue(TypeCreator.createArrayType(recordType));

    int i = 0;
    for (Message msg : messages) {
        BMap<BString, Object> msgRecord = ValueCreator.createRecordValue(ModuleUtils.getModule(), MESSAGE_RECORD);
        msgRecord.put(BODY, StringUtils.fromString(msg.body()));
        msgRecord.put(MD5_OF_BODY, StringUtils.fromString(msg.md5OfBody()));
        msgRecord.put(MD5_OF_MESSAGE_ATTRIBUTES, StringUtils.fromString(msg.md5OfMessageAttributes()));
        msgRecord.put(MESSAGE_ID, StringUtils.fromString(msg.messageId()));
        msgRecord.put(RECEIPT_HANDLE, StringUtils.fromString(msg.receiptHandle()));
        resultArr.add(i++, msgRecord);
    }
    return resultArr;
}

@SuppressWarnings("unchecked")
public static SendMessageBatchRequest getNativeSendMessageBatchRequest(BString queueUrl, BArray bEntries) {
    List<SendMessageBatchRequestEntry> entries = new ArrayList<>();
    for (int i = 0; i < bEntries.size(); i++) {
        BMap<BString, Object> entry = (BMap<BString, Object>) bEntries.get(i);
        SendMessageBatchRequestEntry.Builder builder = SendMessageBatchRequestEntry.builder()
                .id(entry.getStringValue(ID).getValue())
                .messageBody(entry.getStringValue(BODY).getValue());
        // Optional SendMessageConfig fields
        if (entry.containsKey(DELAY_SECONDS)) {
            builder.delaySeconds(((Long) entry.get(DELAY_SECONDS)).intValue());
        }
        if (entry.containsKey(MESSAGE_DEDUPLICATION_ID)) {
            builder.messageDeduplicationId(entry.getStringValue(MESSAGE_DEDUPLICATION_ID).getValue());
        }
        if (entry.containsKey(MESSAGE_GROUP_ID)) {
            builder.messageGroupId(entry.getStringValue(MESSAGE_GROUP_ID).getValue());
        }
        if (entry.containsKey(AWS_TRACE_HEADER)) {
            builder.messageAttributes(Map.of("AWSTraceHeader",
                    MessageAttributeValue.builder()
                            .dataType("String")
                            .stringValue(entry.getStringValue(AWS_TRACE_HEADER).getValue())
                            .build()));
        }
        if (entry.containsKey(MESSAGE_ATTRIBUTES)) {
            BMap<BString, Object> attrs = (BMap<BString, Object>) entry.get(MESSAGE_ATTRIBUTES);
            Map<String, MessageAttributeValue> attrMap = new HashMap<>();
            for (Object key : attrs.getKeys()) {
                BString attrKey = (BString) key;
                BMap<BString, Object> attrVal = (BMap<BString, Object>) attrs.get(attrKey);
                MessageAttributeValue mav = MessageAttributeValue.builder()
                        .dataType(attrVal.getStringValue(StringUtils.fromString("dataType")).getValue())
                        .stringValue(attrVal.getStringValue(StringUtils.fromString("stringValue")).getValue())
                        .build();
                attrMap.put(attrKey.getValue(), mav);
            }
            builder.messageAttributes(attrMap);
        }
        entries.add(builder.build());
    }
    return SendMessageBatchRequest.builder()
            .queueUrl(queueUrl.getValue())
            .entries(entries)
            .build();
}

public static BMap<BString, Object> getNativeSendMessageBatchResponse(SendMessageBatchResponse response) {
    Type sendMessageBatchResultEntryType = ValueCreator.createRecordValue(ModuleUtils.getModule(), "SendMessageBatchResultEntry").getType();
    BArray successfulArr = ValueCreator.createArrayValue(TypeCreator.createArrayType(sendMessageBatchResultEntryType));
    for (SendMessageBatchResultEntry entry : response.successful()) {
        BMap<BString, Object> entryRecord = ValueCreator.createRecordValue(ModuleUtils.getModule(), "SendMessageBatchResultEntry");
        entryRecord.put(ID, StringUtils.fromString(entry.id()));
        entryRecord.put(MD5_OF_BODY, StringUtils.fromString(entry.md5OfMessageBody()));
        entryRecord.put(MESSAGE_ID, StringUtils.fromString(entry.messageId()));
        if (entry.md5OfMessageAttributes() != null) {
            entryRecord.put(MD5_OF_ATTRIBUTES, StringUtils.fromString(entry.md5OfMessageAttributes()));
        }
        if (entry.md5OfMessageSystemAttributes() != null) {
            entryRecord.put(MD5_OF_SYS_ATTRIBUTES, StringUtils.fromString(entry.md5OfMessageSystemAttributes()));
        }
        if (entry.sequenceNumber() != null) {
            entryRecord.put(SEQUENCE_NUMBER, StringUtils.fromString(entry.sequenceNumber()));
        }
        successfulArr.append(entryRecord);
    }

     Type batchResultErrorEntryType = ValueCreator.createRecordValue(ModuleUtils.getModule(), "BatchResultErrorEntry").getType();
    BArray failedArr = ValueCreator.createArrayValue(TypeCreator.createArrayType(batchResultErrorEntryType));

    for (BatchResultErrorEntry entry : response.failed()) {
        BMap<BString, Object> entryRecord = ValueCreator.createRecordValue(ModuleUtils.getModule(), "BatchResultErrorEntry");
        entryRecord.put(ID, StringUtils.fromString(entry.id()));
        entryRecord.put(CODE, StringUtils.fromString(entry.code()));
        entryRecord.put(SENDER_FAULT, entry.senderFault());
        if (entry.message() != null) {
            entryRecord.put(MESSAGE, StringUtils.fromString(entry.message()));
        }
        failedArr.append(entryRecord);
    }

    BMap<BString, Object> result = ValueCreator.createRecordValue(ModuleUtils.getModule(), SEND_MESSAGE_BATCH_RESPONSE);
    result.put(SUCCESSFUL, successfulArr);
    result.put(FAILED, failedArr);
    return result;
}






}

