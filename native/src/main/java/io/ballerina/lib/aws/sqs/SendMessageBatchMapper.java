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

import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.BatchResultErrorEntry;
import software.amazon.awssdk.services.sqs.model.MessageAttributeValue;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchRequestEntry;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchResponse;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchResultEntry;

public class SendMessageBatchMapper {

    private static final String SEND_MESSAGE_BATCH_RESPONSE = "SendMessageBatchResponse";
    private static final BString SUCCESSFUL = StringUtils.fromString("successful");
    private static final BString FAILED = StringUtils.fromString("failed");
    private static final BString ID = StringUtils.fromString("id");
    private static final BString CODE = StringUtils.fromString("code");
    private static final BString SENDER_FAULT = StringUtils.fromString("senderFault");
    private static final BString MESSAGE = StringUtils.fromString("message");
     private static final BString MESSAGE_ID = StringUtils.fromString("messageId");
    private static final BString MD5_OF_BODY = StringUtils.fromString("md5OfMessageBody");
    private static final BString MD5_OF_ATTRIBUTES = StringUtils.fromString("md5OfMessageAttributes");
    private static final BString MD5_OF_SYS_ATTRIBUTES = StringUtils.fromString("md5OfMessageSystemAttributes");
    private static final BString SEQUENCE_NUMBER = StringUtils.fromString("sequenceNumber");
    private static final BString DELAY_SECONDS = StringUtils.fromString("delaySeconds");
    private static final BString MESSAGE_ATTRIBUTES = StringUtils.fromString("messageAttributes");
    private static final BString AWS_TRACE_HEADER = StringUtils.fromString("awsTraceHeader");
    private static final BString MESSAGE_DEDUPLICATION_ID = StringUtils.fromString("messageDeduplicationId");
    private static final BString MESSAGE_GROUP_ID = StringUtils.fromString("messageGroupId");
    private static final BString BODY = StringUtils.fromString("body");

    private SendMessageBatchMapper(){
        
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
