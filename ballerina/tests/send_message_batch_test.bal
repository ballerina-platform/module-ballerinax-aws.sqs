import ballerina/test;
import ballerina/io;


@test:Config {
    groups: ["sendMessageBatch"]
}
isolated function testSendMessageBatchSuccess() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    SendMessageBatchEntry[] entries = [
        {id: "5", body: "Hello A1"},
        {id: "6", body: "Hello B1"}
    ];

    SendMessageBatchResponse|Error result = sqsClient->sendMessageBatch(queueUrl, entries);
    if result is SendMessageBatchResponse {
        io:println(result.successful);
        test:assertEquals(result.failed.length(), 0, msg = "All messages should succeed");
        test:assertEquals(result.successful.length(), 2);
    } else {
        test:assertFail("Expected batch send to succeed, got: " + result.toString());
    }
}

// @test:Config {
//     groups: ["sendMessageBatch"]
// }
// isolated function testSendMessageBatchWithDuplicatemessageId() returns error? {
//     string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
//     SendMessageBatchEntry[] entries = [
//         {messageId: "id1", body: "Hello A"},
//         {messageId: "id1", body: "Hello B"}
//     ];
//     SendMessageBatchResponse|Error result = sqsClient->sendMessageBatch(queueUrl, entries);
//     if result is SendMessageBatchResponse {
//         io:println(result.successful);
//     }
//     test:assertTrue(result is Error);
//     if result is error {
//         ErrorDetails details = result.detail();
//         test:assertEquals(details.httpStatusCode, 403);
//         test:assertEquals(details.errorCode, "InvalidClientTokenId");
//         test:assertEquals(details.errorMessage, "The security token included in the request is invalid.");
//     }
// }

@test:Config {
    groups: ["sendMessageBatch"]
}
isolated function testSendMessageBatchWithDuplicatemessageId() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    SendMessageBatchEntry[] entries = [
        {messageId: "id1", body: "Hello A"},
        {messageId: "id1", body: "Hello B"}
    ];
    SendMessageBatchResponse|Error result = sqsClient->sendMessageBatch(queueUrl, entries);
    if result is SendMessageBatchResponse {
        io:println(result.successful);
    }
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.httpStatusCode, 403);
        test:assertEquals(details.errorCode, "InvalidClientTokenId");
        test:assertEquals(details.errorMessage, "The security token included in the request is invalid.");
    }
}