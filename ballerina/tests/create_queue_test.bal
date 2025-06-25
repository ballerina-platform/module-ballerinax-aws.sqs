import ballerina/test;

@test:Config {
    groups: ["createQueue"]
}

isolated function testCreateStandardQueue() returns error? {
    string queueName = "standard-test-queue";
    string|Error result = sqsClient->createQueue(queueName);
    if result is string {
        test:assertTrue(result.endsWith(queueName));
    } else {
        test:assertFail("Queue creation failed: " + result.toString());
    }
}

@test:Config {
    groups: ["createQueue"]
}
isolated function testCreateQueueWithInvalidName() returns error? {
    string queueName = "invalid/name";
    string|Error result = sqsClient->createQueue(queueName);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "InvalidParameterValue");
        test:assertEquals(details.httpStatusCode,400);
        test:assertEquals(details.errorMessage, "Can only include alphanumeric characters, hyphens, or underscores. 1 to 80 in length");
    }
}
