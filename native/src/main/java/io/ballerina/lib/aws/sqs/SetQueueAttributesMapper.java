package io.ballerina.lib.aws.sqs;

import java.util.HashMap;
import java.util.Map;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.QueueAttributeName;
import software.amazon.awssdk.services.sqs.model.SetQueueAttributesRequest;

public class SetQueueAttributesMapper {
    public static final BString QUEUE_ATTRIBUTES = StringUtils.fromString("queueAttributes");

    private SetQueueAttributesMapper() {
    }

    public static SetQueueAttributesRequest getNativeSetQueueAttributesRequest(BString queueUrl,
            BMap<BString, Object> attrs) {
        SetQueueAttributesRequest.Builder builder = SetQueueAttributesRequest.builder().queueUrl(queueUrl.getValue());

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

        if (attrs != null && !attrs.isEmpty()) {
            Map<String, String> attrMap = new HashMap<>();
            for (Object key : attrs.getKeys()) {
                BString attrkey = (BString) key;
                Object value = attrs.get(attrkey);
                String awsAttrName = ATTRIBUTE_NAME_MAP.get(attrkey.getValue());
                if (awsAttrName != null && value != null) {
                    attrMap.put(awsAttrName, value.toString());
                }
            }
            if (!attrMap.isEmpty()) {
                Map<QueueAttributeName, String> queueAttrMap = new HashMap<>();
                for (Map.Entry<String, String> entry : attrMap.entrySet()) {
                    queueAttrMap.put(QueueAttributeName.fromValue(entry.getKey()), entry.getValue());
                }
                builder.attributes(queueAttrMap);
            }

        }
        return builder.build();

    }
}