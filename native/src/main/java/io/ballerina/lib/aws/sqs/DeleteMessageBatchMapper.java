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
import software.amazon.awssdk.services.sqs.model.BatchResultErrorEntry;
import software.amazon.awssdk.services.sqs.model.DeleteMessageBatchRequest;
import software.amazon.awssdk.services.sqs.model.DeleteMessageBatchRequestEntry;
import software.amazon.awssdk.services.sqs.model.DeleteMessageBatchResponse;
import software.amazon.awssdk.services.sqs.model.DeleteMessageBatchResultEntry;

public final class DeleteMessageBatchMapper {

        private static final BString ID = StringUtils.fromString("id");
        private static final BString RECEIPT_HANDLE = StringUtils.fromString("receiptHandle");
        private static final String DELETE_MESSAGE_BATCH_RESPONSE = "DeleteMessageBatchResponse";
        private static final BString SUCCESSFUL = StringUtils.fromString("successful");
        private static final BString FAILED = StringUtils.fromString("failed");
        private static final BString CODE = StringUtils.fromString("code");
        private static final BString SENDER_FAULT = StringUtils.fromString("senderFault");
        private static final BString MESSAGE = StringUtils.fromString("message");

        private DeleteMessageBatchMapper() {

        }

        @SuppressWarnings("unchecked")
        public static DeleteMessageBatchRequest getNativeDeleteMessageBatchRequest(BString queueurl, BArray bEntries) {
                List<DeleteMessageBatchRequestEntry> entries = new ArrayList<>();
                for (int i = 0; i < bEntries.size(); i++) {
                        BMap<BString, Object> entry = (BMap<BString, Object>) bEntries.get(i);
                        DeleteMessageBatchRequestEntry.Builder builder = DeleteMessageBatchRequestEntry.builder()
                                        .id(entry.getStringValue(ID).getValue())
                                        .receiptHandle(entry.getStringValue(RECEIPT_HANDLE).getValue());
                        entries.add(builder.build());
                }
                return DeleteMessageBatchRequest.builder()
                                .queueUrl(queueurl.getValue())
                                .entries(entries)
                                .build();
        }

        public static BMap<BString, Object> getNativeDeleteMessageBatchResponse(DeleteMessageBatchResponse response) {
                Type deleteMessageBatchResultEntryType = ValueCreator
                                .createRecordValue(ModuleUtils.getModule(), "DeleteMessageBatchResultEntry")
                                .getType();
                BArray successfulArr = ValueCreator
                                .createArrayValue(TypeCreator.createArrayType(
                                                deleteMessageBatchResultEntryType));
                for (DeleteMessageBatchResultEntry entry : response.successful()) {
                        BMap<BString, Object> entryRecord = ValueCreator.createRecordValue(ModuleUtils.getModule(),
                                        "DeleteMessageBatchResultEntry");
                        entryRecord.put(ID, StringUtils.fromString(entry.id()));
                        successfulArr.append(entryRecord);
                }

                Type batchResultErrorEntryType = ValueCreator
                                .createRecordValue(ModuleUtils.getModule(), "BatchResultErrorEntry")
                                .getType();
                BArray failedArr = ValueCreator.createArrayValue(TypeCreator.createArrayType(
                                batchResultErrorEntryType));

                for (BatchResultErrorEntry entry : response.failed()) {
                        BMap<BString, Object> entryRecord = ValueCreator.createRecordValue(ModuleUtils.getModule(),
                                        "BatchResultErrorEntry");
                        entryRecord.put(ID, StringUtils.fromString(entry.id()));
                        entryRecord.put(CODE, StringUtils.fromString(entry.code()));
                        entryRecord.put(SENDER_FAULT, entry.senderFault());
                        if (entry.message() != null) {
                                entryRecord.put(MESSAGE, StringUtils.fromString(entry.message()));
                        }
                        failedArr.append(entryRecord);
                }

                BMap<BString, Object> result = ValueCreator.createRecordValue(ModuleUtils.getModule(),
                                DELETE_MESSAGE_BATCH_RESPONSE);
                result.put(SUCCESSFUL, successfulArr);
                result.put(FAILED, failedArr);
                return result;
        }
}
