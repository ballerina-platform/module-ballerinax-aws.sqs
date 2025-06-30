import ballerina/test;


@test:Config {
    groups: ["cancelMessageMoveTask"]
}
isolated function testCancelMessageMoveTask() returns error? {
   
    string dlqArn = "arn:aws:sqs:eu-north-1:284495578152:testDLQ";
    string mainQueueArn = "arn:aws:sqs:eu-north-1:284495578152:TestQ";
    
    StartMessageMoveTaskConfig config = {
        destinationARN: mainQueueArn,
        maxNumberOfMessagesPerSecond: 1
    };

    StartMessageMoveTaskResponse|Error startResult = sqsClient->startMessageMoveTask(dlqArn, config);
    test:assertFalse(startResult is Error, msg = "startMessageMoveTask should not return error");

    if startResult is StartMessageMoveTaskResponse {
        string taskHandle = startResult.taskHandle;

        CancelMessageMoveTaskResponse|Error cancelResult = sqsClient->cancelMessageMoveTask(taskHandle);
        test:assertFalse(cancelResult is Error, msg = "cancelMessageMoveTask should not return error");

        if cancelResult is CancelMessageMoveTaskResponse {
            test:assertTrue(cancelResult.approximateNumberOfMessagesMoved >= 0,
                msg = "Approximate number of messages moved should be non-negative");
        }
    }
}

