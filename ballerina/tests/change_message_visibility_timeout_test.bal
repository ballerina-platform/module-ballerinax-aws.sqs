import ballerina/test;

@test:Config {
    groups: ["changeMessageVisibility"]
}
isolated function testChangeMessageVisibility() returns error? {

    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";

    ReceiveMessageConfig receiveConfig = {
        maxNumberOfMessages: 1,
        waitTimeSeconds: 1
    };
    Message[] receivedMessages = check sqsClient->receiveMessage(queueUrl, receiveConfig);

    test:assertEquals(receivedMessages.length(), 1, msg = "Expected to receive 1 message");

    string? receiptHandle = receivedMessages[0].receiptHandle;
    int newVisibilityTimeout = 60;

    Error? result = sqsClient->changeMessageVisibility(queueUrl, <string>receiptHandle, newVisibilityTimeout);
    test:assertFalse(result is error, msg = "changeMessageVisibility should not return error");
}
