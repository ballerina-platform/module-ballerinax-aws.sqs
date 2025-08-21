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

import io.ballerina.lib.aws.sqs.ModuleUtils;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.CancelMessageMoveTaskResponse;

public final class CancelMessageMoveTaskMapper {
    private static final String CANCEL_MESSAGE_MOVE_TASK_RESPONSE = "CancelMessageMoveTaskResponse";
    private static final BString APPROX_NUM_MOVED = StringUtils.fromString("approximateNumberOfMessagesMoved");

    private CancelMessageMoveTaskMapper() {
    }

    public static BMap<BString, Object> getNativeCancelMessageMoveTaskResponse(CancelMessageMoveTaskResponse response) {
        BMap<BString, Object> result = ValueCreator.createRecordValue(ModuleUtils.getModule(),
                CANCEL_MESSAGE_MOVE_TASK_RESPONSE);
        result.put(APPROX_NUM_MOVED, response.approximateNumberOfMessagesMoved());
        return result;
    }
}
