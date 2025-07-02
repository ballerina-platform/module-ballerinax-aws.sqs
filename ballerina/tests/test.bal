import ballerina/io;
import ballerina/test;

string standardQueueUrl = "";
string fifoQueueUrl = "";
string attrQueueurl = "";

@test:Config {
    groups: ["init"]
}
isolated function testInitUsingStaticAuth() returns error? {
    ConnectionConfig connectionConfig = {
        region: awsRegion,
        auth: staticAuth
    };
    Client sqsClient = check new (connectionConfig);
    check sqsClient->close();
}

@test:Config {
    groups: ["init"]
}
isolated function testInitUsingProfileAuth() returns error? {
    ConnectionConfig connectionConfig = {
        region: awsRegion,
        auth: profileAuth
    };
    Client sqsClient = check new (connectionConfig);
    check sqsClient->close();
}

@test:Config {
    groups: ["createQueue"]
}
function testCreateStandardQueue() returns error? {
    string queueName = "test-queue";
    string|Error result = sqsClient->createQueue(queueName);
    if result is string {
        test:assertTrue(result.endsWith(queueName));
        standardQueueUrl = result.toString();
    } else {
        test:assertFail("Standard Queue creation failed: " + result.toString());
    }
}

@test:Config {
    groups: ["createQueue"]
}
function testCreateFifoQueue() returns error? {
    string queueName = "test-fifi-queue.fifo";
    CreateQueueConfig config = {
        queueAttributes: {
            fifoQueue: true
        }
    };
    string|Error result = sqsClient->createQueue(queueName, config);
    if result is string {
        test:assertTrue(result.endsWith(queueName));
        fifoQueueUrl = result.toString();
    } else {
        test:assertFail("Queue creation failed: " + result.toString());
    }
}

@test:Config {
    groups: ["createQueue"]
}
function testCreateQueueWithAttributes() returns error? {
    string queueName = "test-queue-with-attrs";
    CreateQueueConfig config = {
        queueAttributes: {
            delaySeconds: 5,
            maximumMessageSize: 2048,
            messageRetentionPeriod: 86400,
            receiveMessageWaitTimeSeconds: 10,
            visibilityTimeout: 30,
            sqsManagedSseEnabled: true,
            redriveAllowPolicy: {
                redrivePermission: ALLOW_ALL
            }
        }
    };
    string|Error result = sqsClient->createQueue(queueName, config);
    if result is string {
        test:assertTrue(result.endsWith(queueName));
        attrQueueurl = result.toString();
    } else {
        test:assertFail("Queue creation with attributes failed: " + result.toString());
    }
}

@test:Config {
    groups: ["createQueue"]
}
function testCreateQueueWithTags() returns error? {
    string queueName = "test-queue-with-tags";
    CreateQueueConfig config = {
        tags: {
            "env": "dev",
            "project": "sqs"
        }
    };
    string|Error result = sqsClient->createQueue(queueName, config);
    if result is string {
        test:assertTrue(result.endsWith(queueName));
    } else {
        test:assertFail("Queue creation with tags failed: " + result.toString());
    }
}

@test:Config {
    groups: ["createQueue"]
}
function testCreateQueueWithInvalidName() returns error? {
    string queueName = "invalid/name";
    string|Error result = sqsClient->createQueue(queueName);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "InvalidParameterValue");
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorMessage, "Can only include alphanumeric characters, hyphens, or underscores. 1 to 80 in length");
    }
}

@test:Config {
    groups: ["createQueue"]
}
function testCreateQueueWithInvalidAttributes() returns error? {
    string queueName = "test-invalid-attrs-queue";
    CreateQueueConfig config = {
        queueAttributes: {
            delaySeconds: 901
        }
    };
    string|Error result = sqsClient->createQueue(queueName, config);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "InvalidAttributeValue");
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorMessage, "Invalid value for the parameter DelaySeconds.");

    }

}

//send message 
@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessage"]
}
function testBasicSendMessage() returns error? {
    string queueurl = standardQueueUrl;
    string message = "Hello from Ballerina SQS test!";
    SendMessageResponse|Error result = sqsClient->sendMessage(queueurl, message);
    if result is SendMessageResponse {
        test:assertNotEquals(result.messageId, "", msg = "MessageId should not be empty");
    } else {
        test:assertFail("sendMessage failed: " + result.toString());
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessage"]
}
function testSendMessageWithAttributes() returns error? {
    string message = "Test message with attributes";
    SendMessageConfig sendMessageConfig = {
        messageAttributes: {
            "payloadType": {
                dataType: "String",
                stringValue: "plain text"
            },
            "messageID": {
                dataType: "Number",
                stringValue: "123"
            }
        }
    };
    SendMessageResponse|Error result = sqsClient->sendMessage(standardQueueUrl, message, sendMessageConfig);
    if result is SendMessageResponse {
        test:assertNotEquals(result.messageId, "", msg = "MessageId should not be empty");
    } else {
        test:assertFail("sendMessage with attributes failed: " + result.toString());
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessage"]
}
function testSendMessageWithDelay() returns error? {
    string queueUrl = standardQueueUrl;
    string message = "Delayed message";
    SendMessageConfig sendMessageConfig = {
        delaySeconds: 10
    };
    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    if result is SendMessageResponse {
        test:assertNotEquals(result.messageId, "", msg = "MessageId should not be empty");
    } else {
        test:assertFail("sendMessage with delay failed: " + result.toString());
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessage"]
}
function testSendMessageWithSystemAttributes() returns error? {
    string queueUrl = standardQueueUrl;
    string message = "Message with system attributes";
    SendMessageConfig sendMessageConfig = {
        awsTraceHeader: "Root=1-678e1f8b2-1234567890abcdef12345678;Parent=1234567890abcdef;Sampled=1"
    };
    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    if result is SendMessageResponse {
        test:assertNotEquals(result.messageId, "", msg = "MessageId should not be empty");
    } else {
        test:assertFail("sendMessage with system attributes failed: " + result.toString());
    }
}

@test:Config {
    dependsOn: [testCreateFifoQueue],
    groups: ["sendMessage"]
}
function testSendMessageWithDeduplicationAndGroupId() returns error? {
    string queueUrl = fifoQueueUrl;
    string message = "Message for FIFO queue with deduplication and group ID";
    SendMessageConfig sendMessageConfig = {
        messageDeduplicationId: "dedup-id-123",
        messageGroupId: "group-id-456"
    };
    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    if result is SendMessageResponse {
        test:assertNotEquals(result.messageId, "", msg = "MessageId should not be empty");
    } else {
        test:assertFail("sendMessage with deduplication and group ID failed: " + result.toString());
    }
}

@test:Config {
    groups: ["sendMessage"]
}
function testSendMessageToNonexistentQueue() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/InvalidQueue";
    string message = "Hello, queue!";
    SendMessageConfig sendMessageConfig = {};

    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message, sendMessageConfig);

    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorCode, "AWS.SimpleQueueService.NonExistentQueue");
        test:assertEquals(details.errorMessage, "The specified queue does not exist.");
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessage"]
}
function testSendMessageWithEmptyMessageBody() returns error? {
    string queueUrl = standardQueueUrl;
    string message = "";
    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorCode, "MissingParameter");
        test:assertEquals(details.errorMessage, "The request must contain the parameter MessageBody.");
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessage"]
}
function testSendMessageWithInvalidDelay() returns error? {
    string queueUrl = standardQueueUrl;
    string message = "This should fail due to invalid delay";
    SendMessageConfig sendMessageConfig = {
        delaySeconds: -1
    };
    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorCode, "InvalidParameterValue");
        test:assertEquals(details.errorMessage, "Value -1 for parameter DelaySeconds is invalid. Reason: DelaySeconds must be >= 0 and <= 900.");
    }

}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessage"]
}
function testSendMessageWithExcessiveDelay() returns error? {
    string queueUrl = standardQueueUrl;
    string message = "This should fail due to excessive delay";
    SendMessageConfig sendMessageConfig = {
        delaySeconds: 1000
    };
    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorCode, "InvalidParameterValue");
        test:assertEquals(details.errorMessage, "Value 1000 for parameter DelaySeconds is invalid. Reason: DelaySeconds must be >= 0 and <= 900.");
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessage"]
}
function testSendMessageWithInvalidAttributes() returns error? {
    string queueUrl = standardQueueUrl;
    string message = "This should fail due to invalid attributes";
    SendMessageConfig sendMessageConfig = {
        messageAttributes: {
            "invalidAttribute": {
                dataType: "InvalidType",
                stringValue: "value"
            }
        }
    };
    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorCode, "InvalidParameterValue");
        test:assertEquals(details.errorMessage, "The type of message (user) attribute 'invalidAttribute' is invalid. " +
                "You must use only the following supported type prefixes: Binary, Number, String.");
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessage"]
}
function testSendMessageWithEmptyAttributes() returns error? {
    string queueUrl = standardQueueUrl;
    string message = "This should succeed with empty attributes";
    SendMessageConfig sendMessageConfig = {
        messageAttributes: {}
    };
    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    if result is SendMessageResponse {
        test:assertNotEquals(result.messageId, "", msg = "MessageId should not be empty");
    } else {
        test:assertFail("sendMessage with empty attributes failed: " + result.toString());
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessage"]
}
function testSendMessageWithNilAttributes() returns error? {
    string queueUrl = standardQueueUrl;
    string message = "This should succeed with null attributes";
    SendMessageConfig sendMessageConfig = {
        messageAttributes: ()
    };
    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    if result is SendMessageResponse {
        test:assertNotEquals(result.messageId, "", msg = "MessageId should not be empty");
    } else {
        test:assertFail("sendMessage with null attributes failed: " + result.toString());
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessageBatch"]
}
function testSendMessageBatchSuccess() returns error? {
    string queueUrl = standardQueueUrl;
    SendMessageBatchEntry[] entries = [
        {id: "id-1", body: "Hello A1"},
        {id: "id-2", body: "Hello A2"},
        {id: "id-3", body: "Hello A3"},
        {id: "id-4", body: "Hello A4"},
        {id: "id-5", body: "Hello A5"}
    ];

    SendMessageBatchResponse|Error result = sqsClient->sendMessageBatch(queueUrl, entries);
    if result is SendMessageBatchResponse {
        io:println(result.successful);
        test:assertEquals(result.failed.length(), 0, msg = "All messages should succeed");
        test:assertEquals(result.successful.length(), 5);
    } else {
        test:assertFail("Expected batch send to succeed, got: " + result.toString());
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessageBatch"]
}
function testSendMessageBatchWithDuplicatemessageId() returns error? {
    string queueUrl = standardQueueUrl;
    SendMessageBatchEntry[] entries = [
        {id: "idA", body: "Hello A"},
        {id: "idA", body: "Hello B"}
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
        test:assertEquals(details.errorMessage, "Id idA repeated.");
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessageBatch"]
}
function testSendMessageBatchPartialFailure() returns error? {
    string queueUrl = standardQueueUrl;

    SendMessageBatchEntry[] entries = [
        {id: "1", body: "Valid message"},
        {id: "2", body: ""}
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
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessageBatch"]
}
function testSendMessageBatchExceedsLimit() returns error? {
    string queueUrl = standardQueueUrl;
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
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessageBatch"]
}
function testSendMessageBatchWithEmptyList() returns error? {
    string queueUrl = standardQueueUrl;
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
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessageBatch"]
}
function testSendMessageBatchExceedsTotalSizeLimit() returns error? {
    string queueUrl = standardQueueUrl;

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

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["receiveMessage"]
}
function testBasicReceiveMessage() returns error? {
    string queueUrl = standardQueueUrl;
    Message[]|Error result = sqsClient->receiveMessage(queueUrl);
    if result is Error {
        test:assertFail("Expected to receive messages or empty array, but got error: " + result.toString());
    } else {
        test:assertNotEquals(result, (), msg = "Expected an array (maybe empty), got ()");
        test:assertTrue(result.length() >= 0, msg = "Expected 0 or more messages");
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["receiveMessage"]
}
function testReceiveMessageWithMultiplemessages() returns error? {
    string queueUrl = standardQueueUrl;
    ReceiveMessageConfig config = {
        maxNumberOfMessages: 5
    };
    Message[]|Error result = sqsClient->receiveMessage(queueUrl, config);
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
    dependsOn: [testCreateStandardQueue],
    groups: ["receiveMessage"]
}
function testReceiveMessageInvalidMaxMessages() returns error? {
    string queueUrl = standardQueueUrl;
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
    dependsOn: [testCreateStandardQueue],
    groups: ["receiveMessage"]
}
function testReceiveMessageWithAllOptionalConfigs() returns error? {
    string queueUrl = standardQueueUrl;
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

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["deleteMessage"]
}
function testDeleteMessage() returns error? {
    string queueUrl = standardQueueUrl;

    Message[]|error receiveResult = sqsClient->receiveMessage(queueUrl);
    if receiveResult is error {
        test:assertFail("Failed to receive message: " + receiveResult.toString());
    }
    if receiveResult.length() == 0 {
        test:assertFail("Expected to receive at least one message but got none.");
    }

    Message message = receiveResult[0];
    string receiptHandle = check message.receiptHandle.ensureType();

    Error? deleteResult = sqsClient->deleteMessage(queueUrl, receiptHandle);
    if deleteResult is error {
        test:assertFail("Failed to delete message: " + deleteResult.toString());
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["deleteMessage"]
}
function testDeleteMessageWithInvalidReceiptHandle() returns error? {
    string queueUrl = standardQueueUrl;
    string fakeReceiptHandle = "InvalidReceiptHandle123";

    Error? deleteResult = sqsClient->deleteMessage(queueUrl, fakeReceiptHandle);

    test:assertTrue(deleteResult is Error);
    if deleteResult is error {
        ErrorDetails details = deleteResult.detail();
        test:assertEquals(details.httpStatusCode, 404);
        test:assertEquals(details.errorCode, "ReceiptHandleIsInvalid");
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["deleteMessageBatch"]
}
function testDeleteMessageBatchSuccess() returns error? {
    string queueUrl = standardQueueUrl;

    SendMessageBatchEntry[] batch = [
        {id: "id-a", body: "Message A"},
        {id: "id-b", body: "Message B"}
    ];
    SendMessageBatchResponse|Error sendResult = sqsClient->sendMessageBatch(queueUrl, batch);
    if sendResult is error {
        test:assertFail("Failed to send batch messages: " + sendResult.toString());
    }

    Message[]|error received = sqsClient->receiveMessage(queueUrl, {maxNumberOfMessages: 2});
    if received is error || received.length() < 2 {
        test:assertFail("Expected 2 messages, but received fewer");
    }

    DeleteMessageBatchEntry[] deleteBatch = [
        {id: "msg-id-1", receiptHandle: check received[0].receiptHandle.ensureType()},
        {id: "msg-id-2", receiptHandle: check received[1].receiptHandle.ensureType()}
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
    dependsOn: [testCreateStandardQueue],
    groups: ["deleteMessageBatch"]
}
function testDeleteMessageBatchWithInvalidReceiptHandle() returns error? {
    string queueUrl = standardQueueUrl;

    SendMessageBatchEntry[] batch = [
        {id: "id1", body: "Message A"},
        {id: "id2", body: "Message B"}
    ];
    SendMessageBatchResponse|Error sendResult = sqsClient->sendMessageBatch(queueUrl, batch);
    if sendResult is error {
        test:assertFail("Failed to send batch messages: " + sendResult.toString());
    }

    Message[]|Error received = sqsClient->receiveMessage(queueUrl, {maxNumberOfMessages: 2});
    if received is error || received.length() < 2 {
        test:assertFail("Expected 2 messages, but received fewer");
    }

    DeleteMessageBatchEntry[] entries = [
        {id: "id-1", receiptHandle: "invalid-receipt-handle"},
        {id: "id-2", receiptHandle: check received[1].receiptHandle.ensureType()}

    ];

    DeleteMessageBatchResponse|Error result = sqsClient->deleteMessageBatch(queueUrl, entries);
    if result is DeleteMessageBatchResponse {
        test:assertEquals(result.successful.length(), 1);
        test:assertEquals(result.failed.length(), 1);
        test:assertEquals(result.failed[0].id, "id-1");
    } else {
        test:assertFail("Expected partial failure, got error: " + result.toString());
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["deleteMessageBatch"]
}
function testDeleteMessageBatchWithDuplicateIds() returns error? {
    string queueUrl = standardQueueUrl;

    SendMessageBatchEntry[] batch = [
        {id: "id1", body: "Message A"},
        {id: "id2", body: "Message B"},
        {id: "id3", body: "Message C"}
    ];
    SendMessageBatchResponse|Error sendResult = sqsClient->sendMessageBatch(queueUrl, batch);
    if sendResult is error {
        test:assertFail("Failed to send batch messages: " + sendResult.toString());
    }

    ReceiveMessageConfig receiveConfig = {
        waitTimeSeconds: 15,
        maxNumberOfMessages: 10
    };

    Message[]|Error received = sqsClient->receiveMessage(queueUrl, receiveConfig);
    if received is error || received.length() < 2 {
        test:assertFail("Expected 2 messages, but received fewer");
    }

    DeleteMessageBatchEntry[] entries = [
        {id: "dup-id", receiptHandle: check received[0].receiptHandle.ensureType()},
        {id: "dup-id", receiptHandle: check received[0].receiptHandle.ensureType()}
    ];

    DeleteMessageBatchResponse|Error result = sqsClient->deleteMessageBatch(queueUrl, entries);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "AWS.SimpleQueueService.BatchEntryIdsNotDistinct");
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorMessage, "Id dup-id repeated.");
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["setQueueAttributes"]
}

function testSetQueueAttribues() returns error? {
    string queueUrl = standardQueueUrl;
    QueueAttributes attributes = {
        delaySeconds: 78,
        visibilityTimeout: 13000,
        redriveAllowPolicy: {
            redrivePermission: DENY_ALL
        }
    };
    Error? result = sqsClient->setQueueAttributes(queueUrl, attributes);
    io:print(result);
    test:assertTrue(result is ());
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["setQueueAttributes"]
}
function testSetQueueAttribuesWithInvalidDelay() returns error? {
    string queueUrl = standardQueueUrl;
    QueueAttributes attributes = {
        delaySeconds: 901
    };
    Error? result = sqsClient->setQueueAttributes(queueUrl, attributes);
    io:print(result);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "InvalidAttributeValue");
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorMessage, "Invalid value for the parameter DelaySeconds.");
    }
}

@test:Config {
    dependsOn: [testCreateQueueWithAttributes],
    groups: ["getQueueAttributes"]
}

function testGetQueueAttributesAll() returns error? {
    string queueUrl = attrQueueurl;

    GetQueueAttributesConfig config = {
        attributeNames: ["All"]
    };
    GetQueueAttributesResponse|Error result = sqsClient->getQueueAttributes(queueUrl, config);
    test:assertTrue(result is GetQueueAttributesResponse);
}

@test:Config {
    dependsOn: [testCreateQueueWithAttributes],
    groups: ["getQueueAttributes"]
}
function testGetQueueAttributesWithoutConfig() returns error? {
    string queueUrl = attrQueueurl;

    GetQueueAttributesResponse|Error result = sqsClient->getQueueAttributes(queueUrl);
    test:assertTrue(result is GetQueueAttributesResponse);
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["getQueueAttributes"]
}
function testGetQueueAttributesWithSomeAttributes() returns error? {

    string queueUrl = standardQueueUrl;

    GetQueueAttributesConfig config = {
        attributeNames: [MAXIMUM_MESSAGE_SIZE, REDRIVE_ALLOW_POLICY, REDRIVE_POLICY]
    };
    GetQueueAttributesResponse|Error result = sqsClient->getQueueAttributes(queueUrl, config);

    test:assertTrue(result is GetQueueAttributesResponse);

    test:assertFalse(result is Error);
    if result is error {
        ErrorDetails detail = result.detail();
        test:assertEquals(detail.errorCode, "InvalidAttributeName");
        test:assertEquals(detail.errorMessage, "Unknown Attribute FifoQueue.");
        test:assertEquals(detail.httpStatusCode, 400);
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["changeMessageVisibility"]
}
function testChangeMessageVisibility() returns error? {

    string queueUrl = standardQueueUrl;

    ReceiveMessageConfig receiveConfig = {
        maxNumberOfMessages: 1,
        waitTimeSeconds: 10
    };
    Message[] receivedMessages = check sqsClient->receiveMessage(queueUrl, receiveConfig);

    test:assertEquals(receivedMessages.length(), 1, msg = "Expected to receive 1 message");

    string? receiptHandle = receivedMessages[0].receiptHandle;
    int newVisibilityTimeout = 60;

    Error? result = sqsClient->changeMessageVisibility(queueUrl, <string>receiptHandle, newVisibilityTimeout);
    test:assertFalse(result is error, msg = "changeMessageVisibility should not return error");
}

@test:Config {
    groups: ["listQueues"]
}
isolated function testListQueues() returns error? {
    ListQueuesResponse|Error result = sqsClient->listQueues();
    test:assertTrue(result is ListQueuesResponse);
}

@test:Config {
    groups: ["listQueues"]
}
isolated function testListQueuesWithPrefix() returns error? {

    ListQueuesConfig config = {
        queueNamePrefix: "test"
    };

    ListQueuesResponse|Error result = sqsClient->listQueues(config);
    test:assertTrue(result is ListQueuesResponse);
}

@test:Config {
    groups: ["listQueues"]
}
isolated function testListQueuesWithMaxResult() returns error? {

    ListQueuesConfig config = {
        maxResults: 2
    };

    ListQueuesResponse|Error result = sqsClient->listQueues(config);
    test:assertTrue(result is ListQueuesResponse);

}

@test:Config {
    groups: ["listQueues"]
}
isolated function testListQueuesPagination() returns error? {

    ListQueuesConfig config1 = {
        maxResults: 2
    };

    ListQueuesResponse|Error firstPage = sqsClient->listQueues(config1);

    if firstPage is ListQueuesResponse {
        test:assertEquals(firstPage.queueUrls.length(), 2, msg = "Expected 2 queues in first page");
        test:assertNotEquals(firstPage.nextToken, (), msg = "Expected nextToken in first page");

        if firstPage.nextToken is string {
            string? nextPageToken = firstPage.nextToken;

            ListQueuesConfig config2 = {
                maxResults: 10,
                nextToken: nextPageToken
            };

            ListQueuesResponse|Error secondPage = sqsClient->listQueues(config2);

            if secondPage is ListQueuesResponse {
                test:assertTrue(secondPage.queueUrls.length() > 0, msg = "Expected at least 1 queue in second page");
            }
        } else {
            test:assertFail("Expected nextToken to be present in first page");
        }
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["getQueueUrl"]
}
function testGetQueueUrl() returns error? {
    string queueName = "test-queue";
    string expectedQueueUrl = standardQueueUrl;

    string|Error? result = sqsClient->getQueueUrl(queueName);
    test:assertTrue(result is string);
    if result is string {
        test:assertEquals(result, expectedQueueUrl, msg = "Returned queue URL does not match the expected value.");
    }

}

@test:Config {
    groups: ["getQueueUrl"]
}
isolated function testGetNonExistentQueueUrl() returns error? {
    string queueName = "TestQueue2";

    string|Error? result = sqsClient->getQueueUrl(queueName);

    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "AWS.SimpleQueueService.NonExistentQueue");
        test:assertEquals(details.errorMessage, "The specified queue does not exist.");
        test:assertEquals(details.httpStatusCode, 400);

    }

}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["tagQueue"]
}

function testTagQueue() returns error? {
    string queueUrl = standardQueueUrl;
    map<string> tags = {
        "env": "dev",
        "version": "0.1.0"
    };
    Error? result = sqsClient->tagQueue(queueUrl, tags);
    test:assertTrue(result is ());
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["tagQueue"]
}

function testTagQueueWithEmptyTagKey() returns error? {
    string queueUrl = standardQueueUrl;
    map<string> tags = {
        "": "production"

    };
    Error? result = sqsClient->tagQueue(queueUrl, tags);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "InvalidParameterValue");
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorMessage, "Tag keys must be between 1 and 128 characters in length.");
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue, testTagQueue],
    groups: ["untagQueue"]
}

function testUntagQueue() returns error? {
    string queueUrl = standardQueueUrl;
    string[] tags = ["env", "version"];
    Error? result = sqsClient->untagQueue(queueUrl, tags);
    test:assertTrue(result is ());
}

@test:Config {
    dependsOn: [testCreateStandardQueue, testTagQueue],
    groups: ["listQueueTags"]
}

function testListQueueTags() returns error? {
    string queueurl = standardQueueUrl;
    ListQueueTagsResponse|Error result = sqsClient->listQueueTags(queueurl);
    test:assertTrue(result is ListQueueTagsResponse);
}

string dlqUrl = "";
string dlqARN = "";
string sourceQueueUrl = "";
string sourceARN = "";
string moveTaskHandle = ""; // <-- Store the task handle here

@test:Config {
    groups: ["startMessageMoveTask"]
}
function testStartMessageMoveTask() returns error? {

    // Create DLQ with redriveAllowPolicy
    CreateQueueConfig dlqConfig = {
        queueAttributes: {
            redriveAllowPolicy: {
                redrivePermission: ALLOW_ALL
            }
        }
    };

    string|Error dlqResult = sqsClient->createQueue("DLQueue", dlqConfig);
    if dlqResult is error {
        test:assertFail("Failed to create DLQ: " + dlqResult.toString());
    }
    dlqUrl = dlqResult.toString();

    // Get DLQ ARN
    GetQueueAttributesConfig config = {
        attributeNames: [QUEUE_ARN]
    };
    GetQueueAttributesResponse|Error dlqArnresult = sqsClient->getQueueAttributes(dlqUrl, config);
    if dlqArnresult is GetQueueAttributesResponse {
        map<string> attrs = dlqArnresult.queueAttributes;
        dlqARN = <string>attrs["QueueArn"];
        io:println("DLQ ARN: " + dlqARN);
        io:println("DLQArnResult :" + dlqArnresult.toString());
    } else {
        test:assertFail("Failed to get DLQ ARN: " + dlqArnresult.toString());
    }

    // Create Source Queue with redrivePolicy to DLQ
    CreateQueueConfig sourceQueueConfig = {
        queueAttributes: {
            redrivePolicy: {
                deadLetterTargetArn: dlqARN,
                maxReceiveCount: 2
            }
        }
    };

    string|Error sourceQueueResult = sqsClient->createQueue("Source-Queue", sourceQueueConfig);
    if sourceQueueResult is string {
        sourceQueueUrl = sourceQueueResult.toString();
        io:println("Source Queue URL: " + sourceQueueUrl);
    } else {
        test:assertFail("Failed to create Source Queue: " + sourceQueueResult.toString());
    }

    // Send messages to the source queue
    string testMsg = "MoveTaskTestMessage";
    int numMessages = 4;
    foreach int i in 1 ... numMessages {
        SendMessageResponse|Error sendResult = sqsClient->sendMessage(sourceQueueUrl, testMsg + i.toString());
        if sendResult is error {
            test:assertFail("Failed to send message to source queue: " + sendResult.toString());
        }
    }

    // Receive the messages more than maxReceiveCount times 
    int receiveAttempts = 3;
    foreach int attempt in 1 ... receiveAttempts {
        Message[]|Error received = sqsClient->receiveMessage(sourceQueueUrl, {maxNumberOfMessages: 10});
        if received is error {
            test:assertFail("Failed to receive message from source queue: " + received.toString());
        }
    }

    // Call startMessageMoveTask
    StartMessageMoveTaskResponse|Error moveTaskResult = sqsClient->startMessageMoveTask(dlqARN, {maxNumberOfMessagesPerSecond: 1});
    if moveTaskResult is StartMessageMoveTaskResponse {
        moveTaskHandle = moveTaskResult.taskHandle;
        io:println("Started message move task: " + moveTaskHandle);
        test:assertTrue(moveTaskHandle != "", msg = "Task handle should not be empty");
    } else {
        test:assertFail("Failed to start message move task: " + moveTaskResult.toString());
    }
}

@test:Config {
    dependsOn: [testStartMessageMoveTask],
    groups: ["cancelMessageMoveTask"]
}
function testCancelMessageMoveTask() returns error? {
    if moveTaskHandle == "" {
        test:assertFail("No move task handle available to cancel.");
    }
    CancelMessageMoveTaskResponse|Error cancelResult = sqsClient->cancelMessageMoveTask(moveTaskHandle);
    if cancelResult is CancelMessageMoveTaskResponse {
        io:println("Cancelled message move task. Approximate number of messages moved: " +
                cancelResult.approximateNumberOfMessagesMoved.toString());
        test:assertTrue(cancelResult.approximateNumberOfMessagesMoved >= 0,
                msg = "Approximate number of messages moved should be non-negative");
    } else {
        test:assertFail("Failed to cancel message move task: " + cancelResult.toString());
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["purgeQueue"]
}
function testPurgeQueue() returns error? {
    string queueUrl = standardQueueUrl;

    Error? result = sqsClient->purgeQueue(queueUrl);
    test:assertTrue(result is ());
    test:assertFalse(result is error, msg = "purgeQueue should not return an error");

}

@test:Config {
    dependsOn: [testCreateFifoQueue],
    groups: ["deleteQueue"]
}

function testDeleteQueue() returns error? {
    string queueUrl = fifoQueueUrl;
    Error? result = sqsClient->deleteQueue(queueUrl);
    test:assertTrue(result is ());
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
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "AWS.SimpleQueueService.NonExistentQueue");
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorMessage, "The specified queue does not exist.");
    }
}

@test:AfterSuite {}

function testDeleteAllQueues() returns error? {
    ListQueuesResponse|Error listResult = sqsClient->listQueues();
    if listResult is ListQueuesResponse {
        foreach string queueUrl in listResult.queueUrls {

            Error? delResult = sqsClient->deleteQueue(queueUrl);
            if delResult is error {
                io:println("Failed to delete queue: " + queueUrl + " Error: " + delResult.toString());
            } else {
                io:println("Deleted queue: " + queueUrl);
            }
        }
    } else {
        test:assertFail("Failed to list queues: " + listResult.toString());
    }
}

@test:Config {
    groups: ["policy"]
}
function testCreateQueueWithPolicy() returns error? {
    string queueName = "test-policy-queue";

    string policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"sqs:SendMessage\",\"Resource\":\"*\"}]}";

    CreateQueueConfig config = {
        queueAttributes: {
            policy: policy
        }
    };
    string|Error result = sqsClient->createQueue(queueName, config);
    if result is string {
        test:assertTrue(result.endsWith(queueName));

        GetQueueAttributesConfig attrConfig = {
            attributeNames: [POLICY]
        };
        GetQueueAttributesResponse|Error attrResult = sqsClient->getQueueAttributes(result, attrConfig);
        if attrResult is GetQueueAttributesResponse {
            string? returnedPolicy = attrResult.queueAttributes["Policy"];
            test:assertEquals(returnedPolicy, policy, msg = "Policy should match the set value");
        } else {
            test:assertFail("Failed to get queue attributes: " + attrResult.toString());
        }
    } else {
        test:assertFail("Queue creation with policy failed: " + result.toString());
    }
}
