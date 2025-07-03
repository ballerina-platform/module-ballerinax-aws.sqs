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

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.ListQueueTagsResponse;

import java.util.Map;

public class ListQueueTagsMapper {
    private static final String LIST_QUEUE_TAGS_RESPONSE = "ListQueueTagsResponse";
    private static final BString TAGS = StringUtils.fromString("tags");

    private ListQueueTagsMapper() {
    }

    public static BMap<BString, Object> getNativeListQueueTagsResponse(ListQueueTagsResponse response) {
        BMap<BString, Object> result = ValueCreator.createRecordValue(ModuleUtils.getModule(),
                LIST_QUEUE_TAGS_RESPONSE);
        Map<String, String> tags = response.tags();
        BMap<BString, Object> tagMap = ValueCreator.createMapValue();
        if (tags != null) {
            for (Map.Entry<String, String> entry : tags.entrySet()) {
                tagMap.put(StringUtils.fromString(entry.getKey()), StringUtils.fromString(entry.getValue()));
            }
        }
        result.put(TAGS, tagMap);
        return result;
    }
}
