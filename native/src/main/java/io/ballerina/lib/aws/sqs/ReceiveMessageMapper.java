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

import java.util.ArrayList;
import java.util.List;

import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.Message;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageResponse;

public class ReceiveMessageMapper {

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

    private ReceiveMessageMapper() {
    }

    public static ReceiveMessageRequest getNativeReceiveMessageRequest(BString queueUrl,
                    BMap<BString, Object> receiveMessageConfig) {
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

}
