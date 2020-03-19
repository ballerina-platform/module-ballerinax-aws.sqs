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

import ballerina/test;
import ballerina/log;
import ballerina/math;
import ballerina/system;
import ballerina/config;

Configuration configuration = {
    accessKey: getConfigValue("ACCESS_KEY_ID"),
    secretKey: getConfigValue("SECRET_ACCESS_KEY"),
    region: getConfigValue("REGION"),
    accountNumber: getConfigValue("ACCOUNT_NUMBER")
};

Client sqs = new(configuration);
string fifoQueueResourcePath = "";
string standardQueueResourcePath = "";
string receivedReceiptHandler = "";
string standardQueueReceivedReceiptHandler = "";

@test:Config {
    groups: ["group1"]
}
function testCreateFIFOQueue() {
    map<string> attributes = {};
    attributes["VisibilityTimeout"] = "400";
    attributes["FifoQueue"] = "true";
    string|error response = sqs->createQueue(genRandQueueName(true), attributes);
    if (response is string) {
        if (response.startsWith("https://sqs.")) {
            string|error queueResourcePathAny = splitString(response, AMAZON_HOST, 1);
            if (queueResourcePathAny is string) {
                fifoQueueResourcePath = queueResourcePathAny;
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
    groups: ["group2"]
}
function testCreateStandardQueue() {
    string|error response = sqs->createQueue(genRandQueueName(false), {});
    if (response is string) {
        if (response.startsWith("https://sqs.")) {
            string|error queueResourcePathAny = splitString(response, AMAZON_HOST, 1);
            if (queueResourcePathAny is string) {
                standardQueueResourcePath = queueResourcePathAny;
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
    dependsOn: ["testCreateFIFOQueue"],
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
    OutboundMessage|error response = sqs->sendMessage("New Message Text", fifoQueueResourcePath,
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
    InboundMessage[]|error response = sqs->receiveMessage(fifoQueueResourcePath, attributes);
    if (response is InboundMessage[]) {
        if (response[0].receiptHandle != "") {
            receivedReceiptHandler = <@untainted>response[0].receiptHandle;
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
    boolean|error response = sqs->deleteMessage(fifoQueueResourcePath, receiptHandler);
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

@test:Config {
    dependsOn: ["testCreateStandardQueue"],
    groups: ["group2"]
}
function testCRUDOperationsForMultipleMessages() {
    log:printInfo("Test, testCRUDOperationsForMultipleMessages is started ...");
    int msgCnt = 0;

    // Send 2 messages to the queue
    while (msgCnt < 2) {
        string queueUrl = "";
        log:printInfo("standardQueueResourcePath " + standardQueueResourcePath);
        OutboundMessage|error response1 = sqs->sendMessage("There is a tree", standardQueueResourcePath, {});
        if (response1 is OutboundMessage) {
            log:printInfo("Sent an alert to the queue. MessageID: " + response1.messageId);
        } else {
            log:printError("Error occurred while trying to send an alert to the SQS queue!");
            test:assertTrue(false);
        }
        msgCnt = msgCnt + 1;
    }

    // Receive and delete the 2 messages from the queue
    map<string> attributes = {};
    attributes["MaxNumberOfMessages"] = "10";
    attributes["VisibilityTimeout"] = "2";
    attributes["WaitTimeSeconds"] = "1";
    msgCnt = 0;
    int processesMsgCnt = 0;
    while(msgCnt < 2) {
        InboundMessage[]|error response2 = sqs->receiveMessage(standardQueueResourcePath, attributes);
        if (response2 is InboundMessage[]) {
            if (response2.length() > 0) {
                int deleteMssageCount = response2.length();
                foreach var eachResponse in response2 {
                    standardQueueReceivedReceiptHandler = <@untainted>eachResponse.receiptHandle;
                    boolean|error deleteResponse = sqs->deleteMessage(standardQueueResourcePath, standardQueueReceivedReceiptHandler);
                    if (deleteResponse is boolean && deleteResponse) {
                        if (deleteResponse) {
                            processesMsgCnt = processesMsgCnt + 1;
                            log:printInfo("Deleted the fire alert \"" + eachResponse.body + "\" from the queue.");
                        }
                    } else {
                        log:printError("Error occurred while deleting a message.");
                        test:assertTrue(false);
                    }
                }
            } else {
                log:printInfo("Queue is empty. No messages to be deleted.");
            }
        } else {
            log:printError("Error occurred while receiving a message.");
            test:assertTrue(false);
        }
        msgCnt = msgCnt + 1;
    }
    if (processesMsgCnt == 2) {
        log:printInfo("Successfully deleted all the messages from the queue!");
        test:assertTrue(true);
    } else {
        log:printInfo("Error occurred while processing the messages.");
        test:assertTrue(false);
    }
}

function genRandQueueName(boolean isFifo = false) returns string {
    float ranNumFloat = math:random()*10000000;
    anydata ranNumInt = math:round(ranNumFloat);
    string queueName = "testQueue" + ranNumInt.toString();
    if (isFifo) {
        return queueName + ".fifo";
    } else {
        return queueName;
    }
}

function getConfigValue(string key) returns string {
    return (system:getEnv(key) != "") ? system:getEnv(key) : config:getAsString(key);
}
