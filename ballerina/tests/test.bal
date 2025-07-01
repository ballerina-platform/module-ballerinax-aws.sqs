import ballerina/test;
import ballerina/io;

string standardQueueUrl = "";
string fifoQueueUrl = "";

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

