package io.ballerina.lib.aws.sqs;

import java.util.HashMap;
import java.util.Map;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.CreateQueueRequest;
import software.amazon.awssdk.services.sqs.model.QueueAttributeName;


public class CreateQueueMapper {

    public static final BString QUEUE_ATTRIBUTES = StringUtils.fromString("queueAttributes");
    public static final BString TAGS = StringUtils.fromString("tags");

    private  CreateQueueMapper(){

    }

    @SuppressWarnings("unchecked")
    public static CreateQueueRequest getNativeCreateQueueRequest(BString queueName, BMap<BString, Object> bConfig) {
        CreateQueueRequest.Builder builder = CreateQueueRequest.builder().queueName(queueName.getValue());

        if (bConfig != null) {
            if (bConfig.containsKey(QUEUE_ATTRIBUTES));
            BMap<BString, Object> attrs = (BMap<BString, Object>) bConfig.get(QUEUE_ATTRIBUTES);
            Map<QueueAttributeName, String> attrMap = new HashMap<>();
            for (Object key : attrs.getKeys()) {
                BString attrkey = (BString) key;
                Object value = attrs.get(attrkey);
                QueueAttributeName attributeName = QueueAttributeName.fromValue(attrkey.getValue());
                attrMap.put(attributeName, value.toString());
            }
            builder.attributes(attrMap);
        }

        if (bConfig.containsKey(TAGS)) {
            BMap<BString, Object> tags = (BMap<BString, Object>) bConfig.get(TAGS);
            Map<String, String> tagMap = new HashMap<>();
            for (Object key : tags.getKeys()) {
                    BString tagKey = (BString) key;
                    Object value = tags.get(tagKey);
                    tagMap.put(tagKey.getValue(), value.toString());
            }
            builder.tags(tagMap);
        }

        return builder.build();

    }

    
    
}
