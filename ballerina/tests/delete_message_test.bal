import ballerina/test;

@test:Config {
    groups: ["deleteMessage"]
}
isolated function testDeleteMessage() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";

    // Receive the message to get receiptHandle
    Message[]|error receiveResult = sqsClient->receiveMessage(queueUrl);
    if receiveResult is error {
        test:assertFail("Failed to receive message: " + receiveResult.toString());
    }
    if receiveResult.length() == 0 {
        test:assertFail("Expected to receive at least one message but got none.");
    }

    Message message = receiveResult[0];
    string receiptHandle = check message.receiptHandle.ensureType();

    // Delete the message using the latest receipt handle
    Error? deleteResult = sqsClient->deleteMessage(queueUrl, receiptHandle);
    if deleteResult is error {
        test:assertFail("Failed to delete message: " + deleteResult.toString());
    }
}

@test:Config {
    groups: ["deleteMessage"]
}
isolated function testDeleteMessageWithInvalidReceiptHandle() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    string fakeReceiptHandle = "InvalidReceiptHandle123";

    Error? deleteResult = sqsClient->deleteMessage(queueUrl, fakeReceiptHandle);
    
    test:assertTrue(deleteResult is Error);
    if deleteResult is error {
        ErrorDetails details = deleteResult.detail();
        test:assertEquals(details.httpStatusCode, 404);
        test:assertEquals(details.errorCode, "ReceiptHandleIsInvalid");
    }
}







