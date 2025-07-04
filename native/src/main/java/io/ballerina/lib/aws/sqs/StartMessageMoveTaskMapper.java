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

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.creators.ValueCreator;
import software.amazon.awssdk.services.sqs.model.StartMessageMoveTaskRequest;
import software.amazon.awssdk.services.sqs.model.StartMessageMoveTaskResponse;

public final class StartMessageMoveTaskMapper {
    private static final BString DESTINATION_ARN = StringUtils.fromString("destinationARN");
    private static final BString MAX_MESSAGES_PER_SECOND = StringUtils.fromString("maxNumberOfMessagesPerSecond");
    private static final String START_MESSAGE_MOVE_TASK_RESPONSE = "StartMessageMoveTaskResponse";
    private static final BString TASK_HANDLE = StringUtils.fromString("taskHandle");

    private StartMessageMoveTaskMapper() {
    }

    public static StartMessageMoveTaskRequest getNativeStartMessageMoveTaskRequest(BString sourceArn,
                    BMap<BString, Object> bConfig) {
        StartMessageMoveTaskRequest.Builder builder = StartMessageMoveTaskRequest.builder()
                        .sourceArn(sourceArn.getValue());
        if (bConfig != null) {
            if (bConfig.containsKey(DESTINATION_ARN)) {
                Object destArn = bConfig.get(DESTINATION_ARN);
                if (destArn != null) {
                    builder.destinationArn(destArn.toString());
                }
            }
            if (bConfig.containsKey(MAX_MESSAGES_PER_SECOND)) {
                Object maxMsgs = bConfig.get(MAX_MESSAGES_PER_SECOND);
                if (maxMsgs != null) {
                    builder.maxNumberOfMessagesPerSecond(Integer.parseInt(maxMsgs.toString()));
                }
            }
        }
        return builder.build();
    }

    public static BMap<BString, Object> getNativeStartMessageMoveTaskResponse(StartMessageMoveTaskResponse response) {
        BMap<BString, Object> result = ValueCreator.createRecordValue(ModuleUtils.getModule(),
                        START_MESSAGE_MOVE_TASK_RESPONSE);
        result.put(TASK_HANDLE, StringUtils.fromString(response.taskHandle()));
        return result;
    }
}
