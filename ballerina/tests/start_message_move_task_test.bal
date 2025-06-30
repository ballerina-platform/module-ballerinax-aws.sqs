import ballerina/test;

@test:Config {
    groups: ["startMessageMoveTask"]
}

isolated function testStartMessageMoveTask() returns error? {
    string sourceARN = "arn:aws:sqs:eu-north-1:284495578152:testDLQ";
    StartMessageMoveTaskResponse|Error result = sqsClient->startMessageMoveTask(sourceARN);
    test:assertTrue(result is StartMessageMoveTaskResponse);

}

