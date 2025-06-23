import ballerina/test;

@test:Config {
    groups: ["sendMessage"]
}
isolated function testBasicSendMessage() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    string message = "Hello from Ballerina SQS test!";
    SendMessageConfig sendMessageConfig = {};
    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    if result is SendMessageResponse {
        test:assertNotEquals(result.messageId, "", msg = "MessageId should not be empty");
    } else {
        test:assertFail("sendMessage failed: " + result.toString());
    }
}

@test:Config {
    groups: ["sendMessage"]
}
isolated function testSendMessageWithAttributes() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
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
    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    if result is SendMessageResponse {
        test:assertNotEquals(result.messageId, "", msg = "MessageId should not be empty");   
    } else {
        test:assertFail("sendMessage with attributes failed: " + result.toString());
    }
}

@test:Config {
    groups: ["sendMessage"]
}
isolated function testSendMessageWithDelay() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
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
    groups: ["sendMessage"]
}
isolated function testSendMessageWithSystemAttributes() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
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
    groups: ["sendMessage"]
}
isolated function testSendMessageWithDeduplicationAndGroupId() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/testFifoQueue.fifo";
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
isolated function testSendMessageToNonexistentQueue() returns error? {
    QueueUrl queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/InvalidQueue"; 
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
    groups: ["sendMessage"]
}
isolated function testSendMessageWithEmptyMessageBody() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
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
    groups: ["sendMessage"]
}
isolated function testSendMessageWithInvalidDelay() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    string message = "This should fail due to invalid delay";
    SendMessageConfig sendMessageConfig = {
        delaySeconds: -1 // Invalid delay
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
    groups: ["sendMessage"]
}
isolated function testSendMessageWithExcessiveDelay() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    string message = "This should fail due to excessive delay";
    SendMessageConfig sendMessageConfig = {
        delaySeconds: 1000 // Invalid delay
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
    groups: ["sendMessage"]
}
isolated function testSendMessageWithInvalidAttributes() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    string message = "This should fail due to invalid attributes";
    SendMessageConfig sendMessageConfig = {
        messageAttributes: {
            "invalidAttribute": {
                dataType: "InvalidType", // Invalid data type
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
    groups: ["sendMessage"]
}
isolated function testSendMessageWithEmptyAttributes() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
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
    groups: ["sendMessage"]
}
isolated function testSendMessageWithNilAttributes() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    string message = "This should succeed with null attributes";
    SendMessageConfig sendMessageConfig = {
        messageAttributes: () // Nil attributes
    };
    SendMessageResponse|Error result = sqsClient->sendMessage(queueUrl, message, sendMessageConfig);
    if result is SendMessageResponse {
        test:assertNotEquals(result.messageId, "", msg = "MessageId should not be empty");
    } else {
        test:assertFail("sendMessage with null attributes failed: " + result.toString());
    }
}


        

