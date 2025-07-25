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

configurable string fifoQueueName = ?;
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
            fifoQueue: true,
            contentBasedDeduplication: true
        }
    };
    string queueUrl = check sqsClient->createQueue(fifoQueueName, queueConfig);
    io:println("FIFO Queue created successfully. URL: " + queueUrl);
    sqs:SendMessageBatchEntry[] entries = [
        {
            id: "msg1",
            body: "I am Harry Potter!",
            messageGroupId: "gryffindor"
        },
        {
            id: "msg3",
            body: "I am Draco Malfoy!",
            messageGroupId: "slytherin"
        },
        {
            id: "msg5",
            body: "I am Luna Lovegood!",
            messageGroupId: "ravenclaw"
        },
        {
            id: "msg6",
            body: "I am Cedric Diggory!",
            messageGroupId: "hufflepuff"
        },
        {
            id: "msg7",
            body: "I am Neville Longbottom!",
            messageGroupId: "gryffindor"
        },
        {
            id: "msg8",
            body: "I am Ginny Weasley!",
            messageGroupId: "gryffindor"
        },
        {
            id: "msg9",
            body: "I am Helena Ravenclaw!",
            messageGroupId: "ravenclaw"
        }
    ];
    sqs:SendMessageBatchResponse _ = check sqsClient->sendMessageBatch(queueUrl, entries);
    sqs:ReceiveMessageConfig receiveConfig = {
        maxNumberOfMessages: 10,
        waitTimeSeconds: 20,
        messageSystemAttributeNames: ["MessageGroupId"]
    };

    sqs:Message[] messages = check sqsClient->receiveMessage(queueUrl, receiveConfig);
    map<string[]> groupedMessages = {};

    foreach sqs:Message msg in messages {
        string groupId = msg.messageSystemAttributes?.messageGroupId ?: "unknown";
        string body = msg.body ?: "";
        groupedMessages[groupId] = [...(groupedMessages[groupId] ?: []), body];
    }

    foreach var [groupId, bodies] in groupedMessages.entries() {
        io:println("Messages for group " + groupId);
        foreach string body in bodies {
            io:println("    - " + body);
        }
    }
    check sqsClient->deleteQueue(queueUrl);
    io:println("FIFO Queue deleted successfully.");
}
