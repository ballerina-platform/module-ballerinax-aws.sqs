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

package io.ballerina.lib.aws.sqs.mappers;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.ballerina.lib.aws.sqs.ModuleUtils;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.MapType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.Message;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageResponse;
import software.amazon.awssdk.services.sqs.model.MessageAttributeValue;

public final class ReceiveMessageMapper {

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
    private static final BString MESSAGE_ID = StringUtils.fromString("messageId");
    private static final BString MD5_OF_BODY = StringUtils.fromString("md5OfMessageBody");
    private static final String MESSAGE_ATTRIBUTE_VALUE = "MessageAttributeValue";
    private static final BString MESSAGE_ATTRIBUTES = StringUtils.fromString("messageAttributes");
    private static final BString MESSAGE_SYSTEM_ATTRIBUTES = StringUtils.fromString("messageSystemAttributes");
    private static final BString MESSAGE_GROUP_ID = StringUtils.fromString("messageGroupId");
    private static final BString SENDER_ID = StringUtils.fromString("senderId");
    private static final BString SENT_TIMESTAMP = StringUtils.fromString("sentTimestamp");
    private static final BString SEQUENCE_NUMBER = StringUtils.fromString("sequenceNumber");
    private static final BString APPROXIMATE_RECEIVE_COUNT = StringUtils.fromString("approximateReceiveCount");
    private static final BString APPROXIMATE_FIRST_RECEIVE_TIMESTAMP = StringUtils
            .fromString("approximateFirstReceiveTimestamp");
    private static final BString AWS_TRACE_HEADER = StringUtils.fromString("awsTraceHeader");
    private static final BString MESSAGE_DEDUPLICATION_ID = StringUtils.fromString("messageDeduplicationId");
    private static final BString DEAD_LETTER_QUEUE_SOURCE_ARN = StringUtils.fromString("deadLetterQueueSourceArn");
    private static final BString DATA_TYPE = StringUtils.fromString("dataType");
    private static final BString STRING_VALUE = StringUtils.fromString("stringValue");
    private static final BString BINARY_VALUE = StringUtils.fromString("binaryValue");

    private ReceiveMessageMapper() {
    }

    public static ReceiveMessageRequest getNativeReceiveMessageRequest(BString queueUrl,
            BMap<BString, Object> receiveMessageConfig) {
        ReceiveMessageRequest.Builder builder = ReceiveMessageRequest.builder()
                .queueUrl(queueUrl.getValue());

        if (receiveMessageConfig.containsKey(WAIT_TIME_SECONDS)) {
            builder.waitTimeSeconds(receiveMessageConfig.getIntValue(WAIT_TIME_SECONDS).intValue());
        }
        if (receiveMessageConfig.containsKey(VISIBILITY_TIMEOUT)) {
            builder.visibilityTimeout(receiveMessageConfig.getIntValue(VISIBILITY_TIMEOUT).intValue());
        }
        if (receiveMessageConfig.containsKey(MAX_NUMBER_OF_MESSAGES)) {
            builder.maxNumberOfMessages(receiveMessageConfig.getIntValue(MAX_NUMBER_OF_MESSAGES).intValue());
        }
        if (receiveMessageConfig.containsKey(RECEIVE_REQUEST_ATTEMPT_ID)) {
            builder.receiveRequestAttemptId(receiveMessageConfig.getStringValue(RECEIVE_REQUEST_ATTEMPT_ID).getValue());
        }
        if (receiveMessageConfig.containsKey(MESSAGE_ATTRIBUTE_NAMES)) {
            BArray attrNamesArr = receiveMessageConfig.getArrayValue(MESSAGE_ATTRIBUTE_NAMES);
            List<String> attrNames = new ArrayList<>(attrNamesArr.size());
            for (int i = 0; i < attrNamesArr.size(); i++) {
                attrNames.add(attrNamesArr.getBString(i).getValue());
            }
            builder.messageAttributeNames(attrNames);
        }
        if (receiveMessageConfig.containsKey(MESSAGE_SYSTEM_ATTRIBUTE_NAMES)) {
            BArray sysAttrNamesArr = receiveMessageConfig.getArrayValue(MESSAGE_SYSTEM_ATTRIBUTE_NAMES);
            List<String> sysAttrNames = new ArrayList<>(sysAttrNamesArr.size());
            for (int i = 0; i < sysAttrNamesArr.size(); i++) {
                sysAttrNames.add(sysAttrNamesArr.getBString(i).getValue());
            }
            builder.messageSystemAttributeNamesWithStrings(sysAttrNames);
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

            Map<String, MessageAttributeValue> messageAttributes = msg
                    .messageAttributes();
            if (!messageAttributes.isEmpty()) {
                Type attrRecordType = ValueCreator.createRecordValue(ModuleUtils.getModule(), MESSAGE_ATTRIBUTE_VALUE)
                        .getType();
                Type mapType = TypeCreator.createMapType(attrRecordType);
                BMap<BString, Object> msgAttributes = ValueCreator.createMapValue((MapType) mapType);

                for (Map.Entry<String, software.amazon.awssdk.services.sqs.model.MessageAttributeValue> entry : messageAttributes
                        .entrySet()) {
                    software.amazon.awssdk.services.sqs.model.MessageAttributeValue attrVal = entry.getValue();
                    BMap<BString, Object> attrRecord = ValueCreator.createRecordValue(ModuleUtils.getModule(),
                            MESSAGE_ATTRIBUTE_VALUE);
                    attrRecord.put(DATA_TYPE, StringUtils.fromString(attrVal.dataType()));
                    if (attrVal.stringValue() != null) {
                        attrRecord.put(STRING_VALUE,
                                StringUtils.fromString(attrVal.stringValue()));
                    }
                    if (attrVal.binaryValue() != null) {
                        attrRecord.put(BINARY_VALUE,
                                ValueCreator.createArrayValue(attrVal.binaryValue().asByteArray()));
                    }
                    msgAttributes.put(StringUtils.fromString(entry.getKey()), attrRecord);
                }
                msgRecord.put(MESSAGE_ATTRIBUTES, msgAttributes);
            }
            Map<String, String> systemAttrs = msg.attributesAsStrings();
            if (!systemAttrs.isEmpty()) {
                BMap<BString, Object> msgSystemAttributes = ValueCreator.createRecordValue(
                        ModuleUtils.getModule(), "MessageAttributes");
                if (systemAttrs.containsKey("MessageGroupId")) {
                    msgSystemAttributes.put(MESSAGE_GROUP_ID,
                            StringUtils.fromString(systemAttrs.get("MessageGroupId")));
                }
                if (systemAttrs.containsKey("SenderId")) {
                    msgSystemAttributes.put(SENDER_ID,
                            StringUtils.fromString(systemAttrs.get("SenderId")));
                }
                if (systemAttrs.containsKey("SentTimestamp")) {
                    msgSystemAttributes.put(SENT_TIMESTAMP,
                            Long.parseLong(systemAttrs.get("SentTimestamp")));
                }
                if (systemAttrs.containsKey("SequenceNumber")) {
                    msgSystemAttributes.put(SEQUENCE_NUMBER,
                            StringUtils.fromString(systemAttrs.get("SequenceNumber")));
                }
                if (systemAttrs.containsKey("ApproximateReceiveCount")) {
                    msgSystemAttributes.put(APPROXIMATE_RECEIVE_COUNT,
                            Integer.parseInt(systemAttrs.get("ApproximateReceiveCount")));
                }
                if (systemAttrs.containsKey("ApproximateFirstReceiveTimestamp")) {
                    msgSystemAttributes.put(APPROXIMATE_FIRST_RECEIVE_TIMESTAMP,
                            Long.parseLong(systemAttrs.get("ApproximateFirstReceiveTimestamp")));
                }
                if (systemAttrs.containsKey("AWSTraceHeader")) {
                    msgSystemAttributes.put(AWS_TRACE_HEADER,
                            StringUtils.fromString(systemAttrs.get("AWSTraceHeader")));
                }
                if (systemAttrs.containsKey("MessageDeduplicationId")) {
                    msgSystemAttributes.put(MESSAGE_DEDUPLICATION_ID,
                            StringUtils.fromString(systemAttrs.get("MessageDeduplicationId")));
                }
                if (systemAttrs.containsKey("DeadLetterQueueSourceArn")) {
                    msgSystemAttributes.put(DEAD_LETTER_QUEUE_SOURCE_ARN,
                            StringUtils.fromString(systemAttrs.get("DeadLetterQueueSourceArn")));
                }
                msgRecord.put(MESSAGE_SYSTEM_ATTRIBUTES, msgSystemAttributes);
            }
            resultArr.add(i++, msgRecord);
        }
        return resultArr;
    }

    public static BMap<BString, Object> getNativeMessage(Message msg) {
        BMap<BString, Object> msgRecord = ValueCreator.createRecordValue(ModuleUtils.getModule(), MESSAGE_RECORD);
        msgRecord.put(BODY, StringUtils.fromString(msg.body()));
        msgRecord.put(MD5_OF_BODY, StringUtils.fromString(msg.md5OfBody()));
        msgRecord.put(MD5_OF_MESSAGE_ATTRIBUTES, StringUtils.fromString(msg.md5OfMessageAttributes()));
        msgRecord.put(MESSAGE_ID, StringUtils.fromString(msg.messageId()));
        msgRecord.put(RECEIPT_HANDLE, StringUtils.fromString(msg.receiptHandle()));

        Map<String, MessageAttributeValue> messageAttributes = msg.messageAttributes();
        if (!messageAttributes.isEmpty()) {
            Type attrRecordType = ValueCreator.createRecordValue(ModuleUtils.getModule(), MESSAGE_ATTRIBUTE_VALUE)
                    .getType();
            Type mapType = TypeCreator.createMapType(attrRecordType);
            BMap<BString, Object> msgAttributes = ValueCreator.createMapValue((MapType) mapType);

            for (Map.Entry<String, MessageAttributeValue> entry : messageAttributes.entrySet()) {
                MessageAttributeValue attrVal = entry.getValue();
                BMap<BString, Object> attrRecord = ValueCreator.createRecordValue(ModuleUtils.getModule(),
                        MESSAGE_ATTRIBUTE_VALUE);
                attrRecord.put(DATA_TYPE, StringUtils.fromString(attrVal.dataType()));
                if (attrVal.stringValue() != null) {
                    attrRecord.put(STRING_VALUE, StringUtils.fromString(attrVal.stringValue()));
                }
                if (attrVal.binaryValue() != null) {
                    attrRecord.put(BINARY_VALUE, ValueCreator.createArrayValue(attrVal.binaryValue().asByteArray()));
                }
                msgAttributes.put(StringUtils.fromString(entry.getKey()), attrRecord);
            }
            msgRecord.put(MESSAGE_ATTRIBUTES, msgAttributes);
        }
        Map<String, String> systemAttrs = msg.attributesAsStrings();
        if (!systemAttrs.isEmpty()) {
            BMap<BString, Object> msgSystemAttributes = ValueCreator.createRecordValue(
                    ModuleUtils.getModule(), "MessageAttributes");
            if (systemAttrs.containsKey("MessageGroupId")) {
                msgSystemAttributes.put(MESSAGE_GROUP_ID, StringUtils.fromString(systemAttrs.get("MessageGroupId")));
            }
            if (systemAttrs.containsKey("SenderId")) {
                msgSystemAttributes.put(SENDER_ID, StringUtils.fromString(systemAttrs.get("SenderId")));
            }
            if (systemAttrs.containsKey("SentTimestamp")) {
                msgSystemAttributes.put(SENT_TIMESTAMP, Long.parseLong(systemAttrs.get("SentTimestamp")));
            }
            if (systemAttrs.containsKey("SequenceNumber")) {
                msgSystemAttributes.put(SEQUENCE_NUMBER, StringUtils.fromString(systemAttrs.get("SequenceNumber")));
            }
            if (systemAttrs.containsKey("ApproximateReceiveCount")) {
                msgSystemAttributes.put(APPROXIMATE_RECEIVE_COUNT,
                        Integer.parseInt(systemAttrs.get("ApproximateReceiveCount")));
            }
            if (systemAttrs.containsKey("ApproximateFirstReceiveTimestamp")) {
                msgSystemAttributes.put(APPROXIMATE_FIRST_RECEIVE_TIMESTAMP,
                        Long.parseLong(systemAttrs.get("ApproximateFirstReceiveTimestamp")));
            }
            if (systemAttrs.containsKey("AWSTraceHeader")) {
                msgSystemAttributes.put(AWS_TRACE_HEADER, StringUtils.fromString(systemAttrs.get("AWSTraceHeader")));
            }
            if (systemAttrs.containsKey("MessageDeduplicationId")) {
                msgSystemAttributes.put(MESSAGE_DEDUPLICATION_ID,
                        StringUtils.fromString(systemAttrs.get("MessageDeduplicationId")));
            }
            if (systemAttrs.containsKey("DeadLetterQueueSourceArn")) {
                msgSystemAttributes.put(DEAD_LETTER_QUEUE_SOURCE_ARN,
                        StringUtils.fromString(systemAttrs.get("DeadLetterQueueSourceArn")));
            }
            msgRecord.put(MESSAGE_SYSTEM_ATTRIBUTES, msgSystemAttributes);
        }
        return msgRecord;
    }
}
