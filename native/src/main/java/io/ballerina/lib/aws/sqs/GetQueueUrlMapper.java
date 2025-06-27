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
