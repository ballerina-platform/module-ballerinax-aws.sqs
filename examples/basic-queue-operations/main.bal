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

import ballerina/io;
import ballerinax/aws.sqs;

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

    string queueUrl = check sqsClient->createQueue(queueName);
    io:println("Queue created successfully URL: " + queueUrl);

    string messageBody = "I am Harry Potter!.";
    sqs:SendMessageResponse response = check sqsClient->sendMessage(queueUrl, messageBody);
    io:println("Message sent successfully. MessageId: " + response.messageId);

    sqs:Message[] messages = check sqsClient->receiveMessage(queueUrl);
    sqs:Message message = messages[0];
    io:println("Received message. Body: " + (message.body ?: ""));
    string receiptHandle = message.receiptHandle ?: "";

    check sqsClient->deleteMessage(queueUrl, receiptHandle);
    io:println("Message deleted successfully.");

    check sqsClient->deleteQueue(queueUrl);
    io:println("Queue deleted successfully");
}
