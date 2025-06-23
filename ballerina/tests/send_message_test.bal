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




        

