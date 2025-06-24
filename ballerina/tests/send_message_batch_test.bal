import ballerina/test;

@test:Config {
    groups: ["sendMessageBatch"]
}
isolated function testSendMessageBatchSuccess() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    SendMessageBatchEntry[] entries = [
        {messageId: "id1", body: "Hello A"},
        {messageId: "id2", body: "Hello B"}
    ];

    SendMessageBatchResponse|Error result = sqsClient->sendMessageBatch(queueUrl, entries);
    if result is SendMessageBatchResponse {
        test:assertEquals(result.failed.length(), 0, msg = "All messages should succeed");
        test:assertEquals(result.successful.length(), 2);
    } else {
        test:assertFail("Expected batch send to succeed, got: " + result.toString());
    }
}