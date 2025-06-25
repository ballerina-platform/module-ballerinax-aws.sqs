import ballerina/test;

@test:Config {
    groups: ["deleteMessageBatch"]
}
isolated function testDeleteMessageBatchSuccess() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";

    SendMessageBatchEntry[] batch = [
        { id: "id1", body: "Message A" },
        { id: "id2", body: "Message B" }
    ];
    SendMessageBatchResponse|Error sendResult = sqsClient->sendMessageBatch(queueUrl, batch);
    if sendResult is error {
        test:assertFail("Failed to send batch messages: " + sendResult.toString());
    }

    Message[]|error received = sqsClient->receiveMessage(queueUrl, { maxNumberOfMessages: 2 });
    if received is error || received.length() < 2 {
        test:assertFail("Expected 2 messages, but received fewer");
    }

    DeleteMessageBatchEntry[] deleteBatch = [
        { id: "msg-id-1", receiptHandle: check received[0].receiptHandle.ensureType() },
        { id: "msg-id-2", receiptHandle: check received[1].receiptHandle.ensureType() }
    ];

    DeleteMessageBatchResponse|Error deleteResult = sqsClient->deleteMessageBatch(queueUrl, deleteBatch);
    if deleteResult is DeleteMessageBatchResponse {
        test:assertEquals(deleteResult.successful.length(), 2);
        test:assertEquals(deleteResult.failed.length(), 0);
    } else {
        test:assertFail("Expected successful batch delete, got: " + deleteResult.toString());
    }
}

@test:Config {
    groups: ["deleteMessageBatch"]
}
isolated function testDeleteMessageBatchWithInvalidReceiptHandle() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";

    SendMessageBatchEntry[] batch = [
        { id: "id1", body: "Message A" },
        { id: "id2", body: "Message B" }
    ];
    SendMessageBatchResponse|Error sendResult = sqsClient->sendMessageBatch(queueUrl, batch);
    if sendResult is error {
        test:assertFail("Failed to send batch messages: " + sendResult.toString());
    }

    Message[]|Error received = sqsClient->receiveMessage(queueUrl, { maxNumberOfMessages: 2 });
    if received is error || received.length() < 2 {
        test:assertFail("Expected 2 messages, but received fewer");
    }

    DeleteMessageBatchEntry[] entries = [
        { id: "id-1", receiptHandle: "invalid-receipt-handle" },
        { id: "id-2", receiptHandle: check received[1].receiptHandle.ensureType() }

    ];

    DeleteMessageBatchResponse|Error result = sqsClient->deleteMessageBatch(queueUrl, entries);
    if result is DeleteMessageBatchResponse {
        test:assertEquals(result.successful.length(), 1);
        test:assertEquals(result.failed.length(), 1);
        test:assertEquals(result.failed[0].id, "id1");
    } else {
        test:assertFail("Expected partial failure, got error: " + result.toString());
    }
}

@test:Config {
    groups: ["deleteMessageBatch"]
}
isolated function testDeleteMessageBatchWithDuplicateIds() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";

    SendMessageBatchEntry[] batch = [
        { id: "id1", body: "Message A" },
        { id: "id2", body: "Message B" },
        { id: "id3", body: "Message C" }
    ];
    SendMessageBatchResponse|Error sendResult = sqsClient->sendMessageBatch(queueUrl, batch);
    if sendResult is error {
        test:assertFail("Failed to send batch messages: " + sendResult.toString());
    }

    Message[]|Error received = sqsClient->receiveMessage(queueUrl, {maxNumberOfMessages: 3});
    if received is error || received.length() < 2 {
        test:assertFail("Expected 2 messages, but received fewer");
    }

    DeleteMessageBatchEntry[] entries = [
        { id: "dup-id", receiptHandle: check received[0].receiptHandle.ensureType() },
        { id: "dup-id", receiptHandle: check received[0].receiptHandle.ensureType() }
    ];

    DeleteMessageBatchResponse|Error result = sqsClient->deleteMessageBatch(queueUrl, entries);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "AWS.SimpleQueueService.BatchEntryIdsNotDistinct");
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorMessage,"Id dup-id repeated.");
    }
}



