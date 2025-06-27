package io.ballerina.lib.aws.sqs;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.GetQueueAttributesRequest;
import software.amazon.awssdk.services.sqs.model.GetQueueAttributesResponse;
import software.amazon.awssdk.services.sqs.model.QueueAttributeName;

public class GetQueueAttributesMapper {

    private static final BString ATTRIBUTE_NAMES = StringUtils.fromString("attributeNames");
    private static final String GET_QUEUE_ATTRIBUTES_RESPONSE = "GetQueueAttributesResponse";
    private static final BString QUEUE_ATTRIBUTES = StringUtils.fromString("queueAttributes");

    private GetQueueAttributesMapper() {
    }

    public static GetQueueAttributesRequest getNativeGetQueueAttributesRequest(BString queueUrl,
            BMap<BString, Object> bGetQueueAttributesConfig) {
        GetQueueAttributesRequest.Builder builder = GetQueueAttributesRequest.builder().queueUrl(queueUrl.getValue());

        if (bGetQueueAttributesConfig != null && bGetQueueAttributesConfig.containsKey(ATTRIBUTE_NAMES)) {
            BArray attributenamesArray = (BArray) bGetQueueAttributesConfig.get(ATTRIBUTE_NAMES);

            if (attributenamesArray != null) {
                List<QueueAttributeName> attrNames = new ArrayList<>();
                for (int i = 0; i < attributenamesArray.size(); i++) {
                    Object val = attributenamesArray.get(i);
                    if (val instanceof BString) {
                        String attrNameStr = ((BString) val).getValue();
                        try {
                            attrNames.add(QueueAttributeName.fromValue(attrNameStr));
                        } catch (IllegalArgumentException e) {
                        }
                    }
                }
                if (!attrNames.isEmpty()) {
                    builder.attributeNames(attrNames);
                }
            }
        }
        return builder.build();
    }

    public static BMap<BString, Object> getNativeGetQueueAttributesResponse(GetQueueAttributesResponse response) {
        BMap<BString, Object> result = ValueCreator.createRecordValue(ModuleUtils.getModule(),
                GET_QUEUE_ATTRIBUTES_RESPONSE);
        Map<QueueAttributeName, String> attrs = response.attributes();
        BMap<BString, Object> attrMap = ValueCreator.createMapValue();
        if (attrs != null) {
            for (Entry<QueueAttributeName, String> entry : attrs.entrySet()) {
                attrMap.put(StringUtils.fromString(entry.getKey().toString()),
                        StringUtils.fromString(entry.getValue()));
            }
        }
        result.put(QUEUE_ATTRIBUTES, attrMap);
        return result;
    }

}
