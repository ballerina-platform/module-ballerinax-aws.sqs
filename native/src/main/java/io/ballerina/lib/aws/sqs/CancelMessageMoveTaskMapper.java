package io.ballerina.lib.aws.sqs;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.services.sqs.model.CancelMessageMoveTaskResponse;

public class CancelMessageMoveTaskMapper {
    private static final String CANCEL_MESSAGE_MOVE_TASK_RESPONSE = "CancelMessageMoveTaskResponse";
    private static final BString APPROX_NUM_MOVED = StringUtils.fromString("approximateNumberOfMessagesMoved");

    private CancelMessageMoveTaskMapper() {
    }

    public static BMap<BString, Object> getNativeCancelMessageMoveTaskResponse(CancelMessageMoveTaskResponse response) {
        BMap<BString, Object> result = ValueCreator.createRecordValue(ModuleUtils.getModule(),
                CANCEL_MESSAGE_MOVE_TASK_RESPONSE);
        result.put(APPROX_NUM_MOVED, response.approximateNumberOfMessagesMoved());
        return result;
    }
}