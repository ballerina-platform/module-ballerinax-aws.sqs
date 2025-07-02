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