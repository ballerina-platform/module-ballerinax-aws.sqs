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

import ballerinax/aws.sqs;
import ballerina/io;

configurable string queueName = ?;
configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;

public function main() returns error? {
    sqs:Client sqsClient = check new ({
        region: sqs:US_EAST_2,
        auth: {
            accessKeyId,
            secretAccessKey
        }
    });
    sqs:CreateQueueConfig queueConfig = {
        queueAttributes: {
            delaySeconds: 0,
            maximumMessageSize: 128000,
            messageRetentionPeriod: 345600,
            receiveMessageWaitTimeSeconds: 20,
            visibilityTimeout: 30
        }
    };
    string queueUrl = check sqsClient->createQueue(queueName, queueConfig);
    io:println("Queue created successfully. URL: " + queueUrl);

    sqs:SendMessageBatchEntry[] entries = [
        {
            id: "msg1",
            body: "I am Harry Potter!",
            messageAttributes: {
                "Name": {dataType: "String", stringValue: "Harry Potter"},
                "House": {dataType: "String", stringValue: "Gryffindor"},
                "Year": {dataType: "Number", stringValue: "1"}
            }
        },
        {
            id: "msg2",
            body: "I am Hermione Granger!",
            messageAttributes: {
                "Name": {dataType: "String", stringValue: "Hermione Granger"},
                "House": {dataType: "String", stringValue: "Gryffindor"},
                "Year": {dataType: "Number", stringValue: "1"}
            }
        },
        {
            id: "msg3",
            body: "I am Ron Weasley!",
            messageAttributes: {
                "Name": {dataType: "String", stringValue: "Ron Weasley"},
                "House": {dataType: "String", stringValue: "Gryffindor"},
                "Year": {dataType: "Number", stringValue: "1"}
            }
        },
        {
            id: "msg4",
            body: "I am Draco Malfoy!",
            messageAttributes: {
                "Name": {dataType: "String", stringValue: "Draco Malfoy"},
                "House": {dataType: "String", stringValue: "Slytherin"},
                "Year": {dataType: "Number", stringValue: "1"}
            }
        }
    ];
    sqs:SendMessageBatchResponse batchResponse = check sqsClient->sendMessageBatch(queueUrl, entries);
    foreach var successful in batchResponse.successful {
        io:println("Message sent successfully. MessageId: " + successful.messageId + " Id: " + successful.id);
    }
    if batchResponse.failed.length() > 0 {
        io:println("Some messages failed to send:");
        foreach var failed in batchResponse.failed {
            io:println("Failed to send message. Id: " + failed.id.toString() + " Code: " + failed.code + " Message: " + failed.message.toString());
        }
    }
    sqs:ReceiveMessageConfig receiveConfig = {
        maxNumberOfMessages: 10,
        messageAttributeNames: ["All"],
        waitTimeSeconds: 20
    };
    sqs:Message[] messages = check sqsClient->receiveMessage(queueUrl, receiveConfig);
    foreach sqs:Message message in messages {
        io:println("Received message. Body: " + (message.body ?: "") + " MessageId: " + message.messageId.toString());
        map<sqs:MessageAttributeValue>? attributes = message.messageAttributes;
        if attributes is map<sqs:MessageAttributeValue> {
            foreach string key in attributes.keys() {
                sqs:MessageAttributeValue attr = attributes.get(key);
                io:println("Message attribute - " + key + ": " + attr.stringValue.toString() + " Type: " + attr.dataType);
            }
        }
        string receiptHandle = message.receiptHandle ?: "";
        check sqsClient->deleteMessage(queueUrl, receiptHandle);
        io:println("Message deleted successfully. MessageId: " + message.messageId.toString());
    }
    check sqsClient->deleteQueue(queueUrl);
    io:println("Queue deleted successfully");
}
