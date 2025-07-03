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
import software.amazon.awssdk.services.sqs.model.GetQueueUrlRequest;

public class GetQueueUrlMapper {
    private static final BString QUEUE_OWNER_AWS_ACCOUNT_ID = StringUtils.fromString("queueOwnerAWSAccountId");

    private GetQueueUrlMapper() {
    }

    public static GetQueueUrlRequest getNativeGetQueueUrlRequest(BString queueName, BMap<BString, Object> bConfig) {
        GetQueueUrlRequest.Builder builder = GetQueueUrlRequest.builder().queueName(queueName.getValue());
        if (bConfig != null && bConfig.containsKey(QUEUE_OWNER_AWS_ACCOUNT_ID)) {
            Object ownerId = bConfig.get(QUEUE_OWNER_AWS_ACCOUNT_ID);
            if (ownerId != null) {
                builder.queueOwnerAWSAccountId(ownerId.toString());
            }
        }
        return builder.build();
    }
}
