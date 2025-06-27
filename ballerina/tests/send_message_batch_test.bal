import ballerina/io;
import ballerina/test;

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

@test:Config {
    groups: ["sendMessageBatch"]
}
isolated function testSendMessageBatchWithDuplicatemessageId() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    SendMessageBatchEntry[] entries = [
        {id: "id1", body: "Hello A"},
        {id: "id1", body: "Hello B"} //duplicate ID
    ];
    SendMessageBatchResponse|Error result = sqsClient->sendMessageBatch(queueUrl, entries);
    if result is SendMessageBatchResponse {
        io:println(result.successful);
    }
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorCode, "AWS.SimpleQueueService.BatchEntryIdsNotDistinct");
        test:assertEquals(details.errorMessage, "Id id1 repeated.");
    }
}

@test:Config {
    groups: ["sendMessageBatch"]
}
isolated function testSendMessageBatchPartialFailure() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";

    SendMessageBatchEntry[] entries = [
        {id: "1", body: "Valid message"},
        {id: "2", body: ""} // empty body
    ];
    SendMessageBatchResponse|Error result = sqsClient->sendMessageBatch(queueUrl, entries);
    if result is SendMessageBatchResponse {
        io:println("Failed entry list: ", result.failed);
        io:println("Successful list: ", result.successful);
    }

    if result is error {
        test:assertFail("Expected partial success, but got full error: " + result.toString());
    } else {
        test:assertEquals(result.successful.length(), 1, msg = "Expected one message to succeed");
        test:assertEquals(result.failed.length(), 1, msg = "Expected one message to fail");
        test:assertEquals(result.failed[0].id, "2");
        test:assertEquals(result.failed[0].code, "EmptyValue");
        test:assertTrue(result.failed[0].senderFault);
    }
}

@test:Config {
    groups: ["sendMessageBatch"]
}
isolated function testSendMessageBatchExceedsLimit() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    SendMessageBatchEntry[] entries = [];
    foreach int i in 1 ... 11 {
        entries.push({id: i.toString(), body: "body1" + i.toBalString()});
    }

    SendMessageBatchResponse|Error result = sqsClient->sendMessageBatch(queueUrl, entries);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorCode, "AWS.SimpleQueueService.TooManyEntriesInBatchRequest");
        test:assertEquals(details.errorMessage, "Maximum number of entries per request are 10. You have sent 11.");
    }
}

@test:Config {
    groups: ["sendMessageBatch"]
}
isolated function testSendMessageBatchWithEmptyList() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    SendMessageBatchEntry[] entries = [];

    SendMessageBatchResponse|Error result = sqsClient->sendMessageBatch(queueUrl, entries);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorCode, "AWS.SimpleQueueService.EmptyBatchRequest");
        test:assertEquals(details.errorMessage, "There should be at least one SendMessageBatchRequestEntry in the request.");
    }
}

@test:Config {
    groups: ["sendMessageBatch"]
}
isolated function testSendMessageBatchExceedsTotalSizeLimit() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";

    string largeBody = ""; // string with size ~26220 Bytes.
    int i = 0;
    while i < 26220 {
        largeBody += "A";
        i += 1;
    }

    SendMessageBatchEntry[] entries = [];
    foreach int j in 1 ... 10 {
        entries.push({
            id: "msg" + j.toString(),
            body: largeBody
        });
    }

    SendMessageBatchResponse|Error result = sqsClient->sendMessageBatch(queueUrl, entries);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorCode, "AWS.SimpleQueueService.BatchRequestTooLong");
        test:assertEquals(details.errorMessage, "Batch requests cannot be longer than 262144 bytes. You have sent 262200 bytes.");
    }
}

