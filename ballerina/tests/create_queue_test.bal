import ballerina/test;

@test:Config {
    groups: ["createQueue"]
}

isolated function testCreateStandardQueue() returns error? {
    string queueName = "standard-test-queue";
    string|error result = sqsClient->createQueue(queueName);
    if result is string {
        test:assertTrue(result.endsWith(queueName));
    } else {
        test:assertFail("Queue creation failed: " + result.toString());
    }
}
