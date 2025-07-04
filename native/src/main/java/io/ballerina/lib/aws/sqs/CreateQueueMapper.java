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

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.CreateQueueRequest;
import software.amazon.awssdk.services.sqs.model.QueueAttributeName;

public final class CreateQueueMapper {

    public static final BString QUEUE_ATTRIBUTES = StringUtils.fromString("queueAttributes");
    public static final BString TAGS = StringUtils.fromString("tags");

    private CreateQueueMapper() {
    }

    @SuppressWarnings("unchecked")
    public static CreateQueueRequest getNativeCreateQueueRequest(BString queueName, BMap<BString, Object> bConfig) {
        CreateQueueRequest.Builder builder = CreateQueueRequest.builder().queueName(queueName.getValue());

        final Map<String, String> ATTRIBUTE_NAME_MAP = Map.ofEntries(
                        Map.entry("delaySeconds", "DelaySeconds"),
                        Map.entry("maximumMessageSize", "MaximumMessageSize"),
                        Map.entry("messageRetentionPeriod", "MessageRetentionPeriod"),
                        Map.entry("policy", "Policy"),
                        Map.entry("receiveMessageWaitTimeSeconds", "ReceiveMessageWaitTimeSeconds"),
                        Map.entry("visibilityTimeout", "VisibilityTimeout"),
                        Map.entry("redrivePolicy", "RedrivePolicy"),
                        Map.entry("redriveAllowPolicy", "RedriveAllowPolicy"),
                        Map.entry("kmsMasterKeyId", "KmsMasterKeyId"),
                        Map.entry("kmsDataKeyReusePeriodSeconds", "KmsDataKeyReusePeriodSeconds"),
                        Map.entry("sqsManagedSseEnabled", "SqsManagedSseEnabled"),
                        Map.entry("fifoQueue", "FifoQueue"),
                        Map.entry("contentBasedDeduplication", "ContentBasedDeduplication"),
                        Map.entry("deduplicationScope", "DeduplicationScope"),
                        Map.entry("fifoThroughputLimit", "FifoThroughputLimit"));

        if (bConfig != null) {
            if (bConfig.containsKey(QUEUE_ATTRIBUTES)) {
                BMap<BString, Object> attrs = (BMap<BString, Object>) bConfig.get(QUEUE_ATTRIBUTES);
                if (attrs != null) {
                    Map<QueueAttributeName, String> attrMap = new HashMap<>();
                    for (Object key : attrs.getKeys()) {
                        BString attrkey = (BString) key;
                        Object value = attrs.get(attrkey);
                        String awsAttrName = ATTRIBUTE_NAME_MAP.get(attrkey.getValue());
                        if (awsAttrName != null && value != null) {
                            attrMap.put(QueueAttributeName.fromValue(awsAttrName), value.toString());
                        }
                    }
                    builder.attributes(attrMap);
                }
            }

            if (bConfig.containsKey(TAGS)) {
                BMap<BString, Object> tags = (BMap<BString, Object>) bConfig.get(TAGS);
                if (tags != null) {
                    Map<String, String> tagMap = new HashMap<>();
                    for (Object key : tags.getKeys()) {
                        BString tagKey = (BString) key;
                        Object value = tags.get(tagKey);
                        tagMap.put(tagKey.getValue(), value.toString());
                    }
                    builder.tags(tagMap);
                }
            }
        }

        return builder.build();

    }
}
