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

package io.ballerina.lib.aws.sqs;

import java.util.HashMap;
import java.util.Map;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.MessageAttributeValue;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageResponse;

public final class SendMessageMapper {

    private static final String SEND_MESSAGE_RESPONSE = "SendMessageResponse";
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

    private SendMessageMapper() {
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

}
