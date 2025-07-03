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

import java.util.List;

import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.PredefinedTypes;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.ListQueuesRequest;
import software.amazon.awssdk.services.sqs.model.ListQueuesResponse;

public class ListQueuesMapper {

    private static final BString MAX_RESULTS = StringUtils.fromString("maxResults");
    private static final BString NEXT_TOKEN = StringUtils.fromString("nextToken");
    private static final BString QUEUE_NAME_PREFIX = StringUtils.fromString("queueNamePrefix");
    private static final String LIST_QUEUES_RESPONSE = "ListQueuesResponse";
    private static final BString QUEUE_URLS = StringUtils.fromString("queueUrls");

    private ListQueuesMapper() {
    }

    public static ListQueuesRequest getNativeListQueuesRequest(BMap<BString, Object> listQueuesConfig)
            throws Exception {
        ListQueuesRequest.Builder builder = ListQueuesRequest.builder();
        if (listQueuesConfig != null) {
            if (listQueuesConfig.containsKey(MAX_RESULTS)) {
                builder.maxResults(((Long) listQueuesConfig.get(MAX_RESULTS)).intValue());
            }
            if (listQueuesConfig.containsKey(NEXT_TOKEN)) {
                builder.nextToken(listQueuesConfig.getStringValue(NEXT_TOKEN).getValue());
            }
            if (listQueuesConfig.containsKey(QUEUE_NAME_PREFIX)) {
                builder.queueNamePrefix(listQueuesConfig.getStringValue(QUEUE_NAME_PREFIX).getValue());
            }
        }
        return builder.build();
    }

    public static BMap<BString, Object> getNativeListQueuesResponse(ListQueuesResponse response) {
        BMap<BString, Object> result = ValueCreator.createRecordValue(ModuleUtils.getModule(), LIST_QUEUES_RESPONSE);
        List<String> queueUrls = response.queueUrls();
        BArray urlsArray = ValueCreator.createArrayValue(TypeCreator.createArrayType(PredefinedTypes.TYPE_STRING));
        if (queueUrls != null) {
            for (String url : queueUrls) {
                urlsArray.append(StringUtils.fromString(url));
            }
        }
        result.put(QUEUE_URLS, urlsArray);

        if (response.nextToken() != null) {
            result.put(NEXT_TOKEN, StringUtils.fromString(response.nextToken()));
        }
        return result;

    }

}
