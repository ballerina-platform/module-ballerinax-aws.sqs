import ballerina/test;

@test:Config {
    groups: ["deleteQueue"]
}

isolated function testDeleteQueue() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/Secondtest.fifo";
    Error? result = sqsClient->deleteQueue(queueUrl);
    test:assertFalse(result is Error, msg = "Expected successful deletion, but got an error");
}

@test:Config {
    groups: ["deleteQueue"]
}
isolated function testDeleteNonExistentQueue() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/Secondtest";
    Error? result = sqsClient->deleteQueue(queueUrl);
    test:assertTrue(result is Error, msg = "Expected uncessfull deletion.");
    if result is error {
        ErrorDetails detais = result.detail();
        test:assertEquals(detais.errorCode, "AWS.SimpleQueueService.NonExistentQueue");
        test:assertEquals(detais.httpStatusCode, 400);
        test:assertEquals(detais.errorMessage,"The specified queue does not exist.");
    }
}