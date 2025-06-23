import ballerina/test;

@test:Config {
    groups: ["receiveMessage"]
}
isolated function testReceiveMessageDefaultConfig() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    Message[]|Error result = sqsClient->receiveMessage(queueUrl);

    if result is error {
        test:assertFail("Expected to receive messages or empty array, but got error: " + result.toString());
    } else {
        test:assertNotEquals(result, (), msg = "Expected an array (maybe empty), got ()");
        test:assertTrue(result.length() >= 0, msg = "Expected 0 or more messages");
    }
}

@test:Config {
    groups: ["receiveMessage"]
}
isolated function testReceiveMessageInvalidQueueUrl() returns error? {
    string queueUrl = "https://sqs.eu-fake-99.amazonaws.com/111111111111/BadQueue";
    Message[]|Error result = sqsClient->receiveMessage(queueUrl);

    test:assertTrue(result is error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.httpStatusCode, 404);
        test:assertEquals(details.errorCode, "InvalidAddress");
    }
}

@test:Config {
    groups: ["receiveMessage"]
}
isolated function testReceiveMessageInvalidMaxMessages() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    ReceiveMessageConfig config = {
        maxNumberOfMessages: 20
    };
    Message[]|Error result = sqsClient->receiveMessage(queueUrl, config);
    test:assertTrue(result is error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorCode, "InvalidParameterValue");
    }
}

@test:Config {
    groups: ["receiveMessage"]
}
isolated function testReceiveMessageWithAllOptionalConfigs() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    ReceiveMessageConfig config = {
        waitTimeSeconds: 5,
        visibilityTimeout: 10,
        maxNumberOfMessages: 2,
        receiveRequestAttemptId: "attempt-001",
        messageAttributeNames: ["All"],
        messageSystemAttributeNames: ["All"]
    };
    Message[]|error result = sqsClient->receiveMessage(queueUrl, config);
    if result is error {
        test:assertFail("Unexpected error: " + result.toString());
    } else {
        test:assertTrue(result.length() >= 0);
    }
}






