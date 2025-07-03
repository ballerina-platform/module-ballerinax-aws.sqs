package io.ballerina.lib.aws.sqs;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.creators.ValueCreator;
import software.amazon.awssdk.services.sqs.model.StartMessageMoveTaskRequest;
import software.amazon.awssdk.services.sqs.model.StartMessageMoveTaskResponse;

public class StartMessageMoveTaskMapper {
    private static final BString DESTINATION_ARN = StringUtils.fromString("destinationARN");
    private static final BString MAX_MESSAGES_PER_SECOND = StringUtils.fromString("maxNumberOfMessagesPerSecond");
    private static final String START_MESSAGE_MOVE_TASK_RESPONSE = "StartMessageMoveTaskResponse";
    private static final BString TASK_HANDLE = StringUtils.fromString("taskHandle");

    private StartMessageMoveTaskMapper() {
    }

    public static StartMessageMoveTaskRequest getNativeStartMessageMoveTaskRequest(BString sourceArn,
            BMap<BString, Object> bConfig) {
        StartMessageMoveTaskRequest.Builder builder = StartMessageMoveTaskRequest.builder()
                .sourceArn(sourceArn.getValue());
        if (bConfig != null) {
            if (bConfig.containsKey(DESTINATION_ARN)) {
                Object destArn = bConfig.get(DESTINATION_ARN);
                if (destArn != null) {
                    builder.destinationArn(destArn.toString());
                }
            }
            if (bConfig.containsKey(MAX_MESSAGES_PER_SECOND)) {
                Object maxMsgs = bConfig.get(MAX_MESSAGES_PER_SECOND);
                if (maxMsgs != null) {
                    builder.maxNumberOfMessagesPerSecond(Integer.parseInt(maxMsgs.toString()));
                }
            }
        }
        return builder.build();
    }

    public static BMap<BString, Object> getNativeStartMessageMoveTaskResponse(StartMessageMoveTaskResponse response) {
        BMap<BString, Object> result = ValueCreator.createRecordValue(ModuleUtils.getModule(),
                START_MESSAGE_MOVE_TASK_RESPONSE);
        result.put(TASK_HANDLE, StringUtils.fromString(response.taskHandle()));
        return result;
    }
}
