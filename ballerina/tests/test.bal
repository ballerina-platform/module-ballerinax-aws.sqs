// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/lang.runtime;
import ballerina/test;

string standardQueueUrl = "";
string fifoQueueUrl = "";
string attrQueueurl = "";
string testAttributesQueueUrl = "";

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
    enable: false,
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
    string result = check sqsClient->createQueue(queueName);
    test:assertTrue(result.endsWith(queueName));
    standardQueueUrl = result;
}

@test:Config {
    groups: ["createQueue"]
}
function testCreateQueueForAttributeTest() returns error? {
    string queueName = "test-attributesqueue";
    string result = check sqsClient->createQueue(queueName);
    test:assertTrue(result.endsWith(queueName));
    testAttributesQueueUrl = result;
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
    string result = check sqsClient->createQueue(queueName, config);
    test:assertTrue(result.endsWith(queueName));
    fifoQueueUrl = result;
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
    string result = check sqsClient->createQueue(queueName, config);
    test:assertTrue(result.endsWith(queueName));
    attrQueueurl = result;
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
    string result = check sqsClient->createQueue(queueName, config);
    test:assertTrue(result.endsWith(queueName));
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

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["sendMessage"]
}
function testBasicSendMessage() returns error? {
    string queueurl = standardQueueUrl;
    string message = "Hello from Ballerina SQS test!";
    SendMessageResponse result = check sqsClient->sendMessage(queueurl, message);
    test:assertNotEquals(result.messageId, "", "MessageId should not be empty");
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
    SendMessageResponse result = check sqsClient->sendMessage(testAttributesQueueUrl, message, sendMessageConfig);
    test:assertNotEquals(result.messageId, "", "MessageId should not be empty");
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
    SendMessageResponse result = check sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    test:assertNotEquals(result.messageId, "", "MessageId should not be empty");
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
    SendMessageResponse result = check sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    test:assertNotEquals(result.messageId, "", "MessageId should not be empty");
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
    SendMessageResponse result = check sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    test:assertNotEquals(result.messageId, "", "MessageId should not be empty");
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
        string? errorMessage = details.errorMessage;
        if errorMessage is () {
            test:assertFail("Expecting an error message, but found none");
        }
        test:assertTrue(errorMessage.includes("The specified queue does not exist"),
                "Error message should mention that the queue does not exist.");
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
    SendMessageResponse result = check sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    test:assertNotEquals(result.messageId, "", "MessageId should not be empty");
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
    SendMessageResponse result = check sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    test:assertNotEquals(result.messageId, "", "MessageId should not be empty");
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
    SendMessageBatchResponse result = check sqsClient->sendMessageBatch(queueUrl, entries);
    test:assertEquals(result.failed.length(), 0, "All messages should succeed");
    test:assertEquals(result.successful.length(), 5);
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
        test:assertFail("Expected error for duplicate message IDs, but got a successful response: " + result.toString());
    } else {
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
    if result is error {
        test:assertFail("Expected partial success, but got full error: " + result.toString());
    } else {
        test:assertEquals(result.successful.length(), 1, "Expected one message to succeed");
        test:assertEquals(result.failed.length(), 1, "Expected one message to fail");
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
    string largeBody = "";
    int i = 0;
    while i < 104858 {
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
        test:assertEquals(details.errorMessage, "Batch requests cannot be longer than 1048576 bytes. You have sent 1048580 bytes.");
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["receiveMessage"]
}
function testBasicReceiveMessage() returns error? {
    string queueUrl = standardQueueUrl;
    Message[] result = check sqsClient->receiveMessage(queueUrl);
    test:assertTrue(result.length() >= 0, "Expected 0 or more messages");

}

@test:Config {
    dependsOn: [testSendMessageWithAttributes],
    groups: ["receiveMessage"]
}
function testReceiveMessageWithAttributes() returns error? {
    runtime:sleep(30);
    Message[] result = check sqsClient->receiveMessage(testAttributesQueueUrl, {
        maxNumberOfMessages: 1,
        messageAttributeNames: ["All"],
        messageSystemAttributeNames: ["All"]
    });
    test:assertTrue(result.length() > 0, "Expected at least one message");
    Message msg = result[0];
    test:assertNotEquals(msg.messageAttributes, (), "Message attributes should not be nil");
    test:assertNotEquals(msg.messageSystemAttributes, (), "System attributes should not be nil");
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
    Message[] result = check sqsClient->receiveMessage(queueUrl, config);
    test:assertTrue(result.length() >= 0, "Expected 0 or more messages");
}

@test:Config {
    groups: ["receiveMessage"]
}
isolated function testReceiveMessageInvalidQueueUrl() returns error? {
    string queueUrl = "https://sqs.eu-fake-99.amazonaws.com/111111111111/BadQueue";
    Message[]|Error result = sqsClient->receiveMessage(queueUrl);
    test:assertTrue(result is Error);
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
    test:assertTrue(result is Error);
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
    Message[] result = check sqsClient->receiveMessage(queueUrl, config);
    test:assertTrue(result.length() >= 0);
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["deleteMessage"]
}
function testDeleteMessage() returns error? {
    string queueUrl = standardQueueUrl;
    SendMessageResponse _ = check sqsClient->sendMessage(queueUrl, messageBody = "test-delete-msg");
    Message[] received = check sqsClient->receiveMessage(queueUrl, waitTimeSeconds = 20);
    test:assertTrue(received.length() > 0, "Expected at least one message");
    Message message = received[0];
    string receiptHandle = check message.receiptHandle.ensureType();
    check sqsClient->deleteMessage(queueUrl, receiptHandle);
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
        {id: "id-b", body: "Message B"},
        {id: "id-c", body: "Message C"},
        {id: "id-d", body: "Message D"}
    ];
    _ = check sqsClient->sendMessageBatch(queueUrl, batch);
    runtime:sleep(2);
    Message[] received = [];
    int retryCount = 0;
    int maxRetries = 10;
    while received.length() < 2 && retryCount < maxRetries {
        received = check sqsClient->receiveMessage(queueUrl, maxNumberOfMessages = 5, waitTimeSeconds = 20);
        if received.length() < 2 {
            runtime:sleep(3);
            retryCount+=1;
        }
    }
    DeleteMessageBatchEntry[] deleteBatch = [
        {id: "msg-id-1", receiptHandle: check received[0].receiptHandle.ensureType()},
        {id: "msg-id-2", receiptHandle: check received[1].receiptHandle.ensureType()}
    ];
    DeleteMessageBatchResponse deleteResult = check sqsClient->deleteMessageBatch(queueUrl, deleteBatch);
    test:assertEquals(deleteResult.successful.length(), 2);
    test:assertEquals(deleteResult.failed.length(), 0);
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["deleteMessageBatch"]
}
function testDeleteMessageBatchWithInvalidReceiptHandle() returns error? {
    string queueUrl = standardQueueUrl;
    SendMessageBatchEntry[] batch = [
        {id: "id1", body: "Message A"},
        {id: "id2", body: "Message B"},
        {id: "id3", body: "Message C"},
        {id: "id4", body: "Message D"},
        {id: "id5", body: "Message E"},
        {id: "id6", body: "Message F"}
    ];
    SendMessageBatchResponse|Error sendResult = sqsClient->sendMessageBatch(queueUrl, batch);
    if sendResult is error {
        test:assertFail("Failed to send batch messages: " + sendResult.toString());
    }
    runtime:sleep(2);
    Message[]|Error received = sqsClient->receiveMessage(queueUrl, maxNumberOfMessages = 5, waitTimeSeconds = 20);
    if received is error || received.length() < 2 {
        test:assertFail("Expected 2 messages, but received fewer");
    }
    DeleteMessageBatchEntry[] entries = [
        {id: "id-1", receiptHandle: "invalid-receipt-handle"},
        {id: "id-2", receiptHandle: check received[1].receiptHandle.ensureType()}
    ];
    DeleteMessageBatchResponse result = check sqsClient->deleteMessageBatch(queueUrl, entries);
    test:assertEquals(result.successful.length(), 1);
    test:assertEquals(result.failed.length(), 1);
    test:assertEquals(result.failed[0].id, "id-1");
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
        {id: "id3", body: "Message C"},
        {id: "id4", body: "Message D"},
        {id: "id5", body: "Message E"},
        {id: "id6", body: "Message F"},
        {id: "id7", body: "Message G"},
        {id: "id8", body: "Message H"},
        {id: "id9", body: "Message I"},
        {id: "id10", body: "Message J"}
    ];
    SendMessageBatchResponse|Error sendResult = sqsClient->sendMessageBatch(queueUrl, batch);
    if sendResult is error {
        test:assertFail("Failed to send batch messages: " + sendResult.toString());
    }
    runtime:sleep(2);
    ReceiveMessageConfig receiveConfig = {
        waitTimeSeconds: 20,
        maxNumberOfMessages: 5
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
    check sqsClient->setQueueAttributes(queueUrl, attributes);
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
    GetQueueAttributesResponse _ = check sqsClient->getQueueAttributes(queueUrl, config);
}

@test:Config {
    dependsOn: [testCreateQueueWithAttributes],
    groups: ["getQueueAttributes"]
}
function testGetQueueAttributesWithoutConfig() returns error? {
    string queueUrl = attrQueueurl;
    GetQueueAttributesResponse _ = check sqsClient->getQueueAttributes(queueUrl);
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
    test:assertEquals(receivedMessages.length(), 1, "Expected to receive 1 message");
    string? receiptHandle = receivedMessages[0].receiptHandle;
    int newVisibilityTimeout = 60;
    Error? result = sqsClient->changeMessageVisibility(queueUrl, <string>receiptHandle, newVisibilityTimeout);
    test:assertFalse(result is error, "changeMessageVisibility should not return error");
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
    ListQueuesResponse _ = check sqsClient->listQueues(config);
}

@test:Config {
    groups: ["listQueues"]
}
isolated function testListQueuesWithMaxResult() returns error? {
    ListQueuesConfig config = {
        maxResults: 2
    };
    ListQueuesResponse _ = check sqsClient->listQueues(config);
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
        test:assertEquals(firstPage.queueUrls.length(), 2, "Expected 2 queues in first page");
        test:assertNotEquals(firstPage.nextToken, (), "Expected nextToken in first page");
        if firstPage.nextToken is string {
            string? nextPageToken = firstPage.nextToken;
            ListQueuesConfig config2 = {
                maxResults: 10,
                nextToken: nextPageToken
            };
            ListQueuesResponse|Error secondPage = sqsClient->listQueues(config2);
            if secondPage is ListQueuesResponse {
                test:assertTrue(secondPage.queueUrls.length() > 0, "Expected at least 1 queue in second page");
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
    string result = check sqsClient->getQueueUrl(queueName);
    test:assertEquals(result, expectedQueueUrl, "Returned queue URL does not match the expected value.");
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
string moveTaskHandle = "";

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
    GetQueueAttributesResponse dlqArnresult = check sqsClient->getQueueAttributes(dlqUrl, config);
    map<string> attrs = dlqArnresult.queueAttributes;
    dlqARN = <string>attrs["QueueArn"];

    // Create Source Queue with redrivePolicy to DLQ
    CreateQueueConfig sourceQueueConfig = {
        queueAttributes: {
            redrivePolicy: {
                deadLetterTargetArn: dlqARN,
                maxReceiveCount: 2
            }
        }
    };
    string sourceQueueUrl = check sqsClient->createQueue("Source-Queue", sourceQueueConfig);

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
    StartMessageMoveTaskResponse moveTaskResult = check sqsClient->startMessageMoveTask(dlqARN, {maxNumberOfMessagesPerSecond: 1});
    moveTaskHandle = moveTaskResult.taskHandle;
    test:assertTrue(moveTaskHandle != "", "Task handle should not be empty");
}

@test:Config {
    dependsOn: [testStartMessageMoveTask],
    groups: ["cancelMessageMoveTask"]
}
function testCancelMessageMoveTask() returns error? {
    if moveTaskHandle == "" {
        test:assertFail("No move task handle available to cancel.");
    }
    foreach int attempts in 0 ..< 3 {
        CancelMessageMoveTaskResponse|error cancelResult = sqsClient->cancelMessageMoveTask(moveTaskHandle);
        if cancelResult is CancelMessageMoveTaskResponse {
            test:assertTrue(cancelResult.approximateNumberOfMessagesMoved >= 0,
                    "Approximate number of messages moved should be non-negative");
            return;
        } else {
            string errMsg = cancelResult.toString();
            if errMsg.startsWith("Failed") {
                // Retry after short delay if task already completed
                runtime:sleep(1);
            } else {
                // Unexpected error, fail immediately
                return cancelResult;
            }
        }
    }
    // If retries exhausted, fail test
    test:assertFail("Failed to cancel message move task");
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["purgeQueue"]
}
function testPurgeQueue() returns error? {
    string queueUrl = standardQueueUrl;
    Error? result = sqsClient->purgeQueue(queueUrl);
    test:assertTrue(result is ());
    test:assertFalse(result is error, "purgeQueue should not return an error");
}

@test:Config {
    dependsOn: [testCreateFifoQueue],
    groups: ["deleteQueue"]
}
function testDeleteQueue() returns error? {
    string queueUrl = fifoQueueUrl;
    Error? result = sqsClient->deleteQueue(queueUrl);
    test:assertTrue(result is ());
    test:assertFalse(result is Error, "Expected successful deletion, but got an error");
}

@test:Config {
    groups: ["deleteQueue"]
}
isolated function testDeleteNonExistentQueue() returns error? {
    string realQueueUrl = check sqsClient->createQueue("test-delete");
    string queueUrl = realQueueUrl + "-non-existent-queue";
    Error? result = sqsClient->deleteQueue(queueUrl);
    test:assertTrue(result is Error, "Expected unsuccessful deletion.");
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "AWS.SimpleQueueService.NonExistentQueue");
        test:assertEquals(details.httpStatusCode, 400);
        string? errorMessage = details.errorMessage;
        if errorMessage is () {
            test:assertFail("Expecting an error message, but found none");
        }
        test:assertTrue(errorMessage.includes("The specified queue does not exist"),
                "Error message should mention that the queue does not exist.");
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
    string result = check sqsClient->createQueue(queueName, config);
    test:assertTrue(result.endsWith(queueName));
    GetQueueAttributesConfig attrConfig = {
        attributeNames: [POLICY]
    };
    GetQueueAttributesResponse attrResult = check sqsClient->getQueueAttributes(result, attrConfig);
    string? returnedPolicy = attrResult.queueAttributes["Policy"];
    test:assertEquals(returnedPolicy, policy, "Policy should match the set value");
}

@test:AfterSuite {}
function testDeleteAllQueues() returns error? {
    ListQueuesResponse listResult = check sqsClient->listQueues();
    foreach string queueUrl in listResult.queueUrls {
        check sqsClient->deleteQueue(queueUrl);
    }
}
