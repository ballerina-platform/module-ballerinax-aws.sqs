// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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

import ballerina/config;
import ballerina/test;
import ballerina/io;
import ballerina/log;
import ballerina/encoding;
import ballerina/math;

// TODO uncomment after fixing config issue related to tests
// Configuration configuration = {
//     accessKey: config:getAsString("ACCESS_KEY_ID"),
//     secretKey: config:getAsString("SECRET_ACCESS_KEY"),
//     region: config:getAsString("REGION"),
//     accountNumber: config:getAsString("ACCOUNT_NUMBER")
// };

// TODO remove after fixing config issue related to tests
Configuration configuration = {
    accessKey: "ACCESS_KEY_ID",
    secretKey: "SECRET_ACCESS_KEY",
    region: "REGION",
    accountNumber: "ACCOUNT_NUMBER"
};

Client sqsClient = new(configuration);
string queueResourcePath = "";
string receivedReceiptHandler = "";

@test:Config {
    groups: ["group1"]
}
function testCreateQueue() {
    map<string> attributes = {};
    attributes["VisibilityTimeout"] = "400";
    attributes["FifoQueue"] = "true";
    string|error response = sqsClient->createQueue(genRandQueueName(), attributes);
    if (response is string) {
        if (response.startsWith("https://sqs.")) {
            string|error queueResourcePathAny = splitString(response, AMAZON_HOST, 1);
            if (queueResourcePathAny is string) {
                queueResourcePath = queueResourcePathAny;
                log:printInfo("SQS queue was created. Queue URL: " + response);
                test:assertTrue(true);
            } else {
                log:printInfo("Queue URL is not Amazon!");
                test:assertTrue(false);
            }
        } else {
            log:printInfo("Error while creating the queue.");
            test:assertTrue(false);
        }
    } else {
        log:printInfo("Error while creating the queue.");
        test:assertTrue(false);
    }
}

@test:Config {
    dependsOn: ["testCreateQueue"],
    groups: ["group1"]
}
function testSendMessage() {
    map<string> attributes = {};
    attributes["MessageDeduplicationId"] = "dupID1";
    attributes["MessageGroupId"] = "grpID1";
    attributes["MessageAttribute.1.Name"] = "N1";
    attributes["MessageAttribute.1.Value.StringValue"] = "V1";
    attributes["MessageAttribute.1.Value.DataType"] = "String";
    attributes["MessageAttribute.2.Name"] = "N2";
    attributes["MessageAttribute.2.Value.StringValue"] = "V2";
    attributes["MessageAttribute.2.Value.DataType"] = "String";
    string queueUrl = "";
    OutboundMessage|error response = sqsClient->sendMessage("New Message Text", queueResourcePath,
        attributes);
    if (response is OutboundMessage) {
        if (response.messageId != "") {
            log:printInfo("Sent message to SQS. MessageID: " + response.messageId);
            test:assertTrue(true);
        } else {
            log:printInfo("Error while sending the message to the queue.");
            test:assertTrue(false);
        }
    } else {
        log:printInfo("Error while sending the message to the queue.");
        test:assertTrue(false);
    }
}

@test:Config {
    dependsOn: ["testSendMessage"],
    groups: ["group1"]
}
function testReceiveMessage() {
    map<string> attributes = {};
    attributes["MaxNumberOfMessages"] = "1";
    attributes["VisibilityTimeout"] = "600";
    attributes["WaitTimeSeconds"] = "2";
    attributes["AttributeName.1"] = "SenderId";
    attributes["MessageAttributeName.1"] = "N1";
    attributes["MessageAttributeName.2"] = "N2";
    InboundMessage[]|error response = sqsClient->receiveMessage(queueResourcePath, attributes);
    if (response is InboundMessage[]) {
        if (response[0].receiptHandle != "") {
            receivedReceiptHandler = response[0].receiptHandle;
            log:printInfo("Successfully received the message. Receipt Handle: " + response[0].receiptHandle);
            test:assertTrue(true);
        } else {
            log:printInfo("Error occurred while receiving the message.");
            test:assertTrue(false);
        }
    } else {
        log:printInfo("Error occurred while receiving the message.");
        test:assertTrue(false);
    }
}

@test:Config {
    dependsOn: ["testReceiveMessage"],
    groups: ["group1"]
}
function testDeleteMessage() {
    string receiptHandler = receivedReceiptHandler;
    boolean|error response = sqsClient->deleteMessage(queueResourcePath, receiptHandler);
    if (response is boolean) {
        if (response) {
            log:printInfo("Successfully deleted the message from the queue.");
            test:assertTrue(true);
        } else {
            log:printInfo("Error occurred while deleting the message.");
            test:assertTrue(false);
        }
    } else {
        log:printInfo("Error occurred while deleting the message.");
        test:assertTrue(false);
    }
}

function genRandQueueName() returns string {
    float ranNumFloat = math:random()*10000000;
    anydata ranNumInt = math:round(ranNumFloat);
    return "testQueue" + ranNumInt.toString() + ".fifo";
}
