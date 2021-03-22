// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/random;
import ballerina/lang.'float;
import ballerina/os;

configurable string accessKeyId = os:getEnv("ACCESS_KEY_ID");
configurable string secretAccessKey = os:getEnv("SECRET_ACCESS_KEY");
configurable string region = os:getEnv("REGION");
configurable string accountNumber = os:getEnv("ACCOUNT_NUMBER");

Configuration configuration = {
    accessKey: accessKeyId,
    secretKey: secretAccessKey,
    region: region,
    accountNumber: accountNumber
};

Client sqs = check new (configuration);
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
                log:print("SQS queue was created. Queue URL: " + response);
                test:assertTrue(true);
            } else {
                log:print("Queue URL is not Amazon!");
                test:assertTrue(false);
            }
        } else {
            log:print("Error while creating the queue.");
            test:assertTrue(false);
        }
    } else {
        log:print("Error while creating the queue.");
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
                log:print("SQS queue was created. Queue URL: " + response);
                test:assertTrue(true);
            } else {
                log:print("Queue URL is not Amazon!");
                test:assertTrue(false);
            }
        } else {
            log:print("Error while creating the queue.");
            test:assertTrue(false);
        }
    } else {
        log:print("Error while creating the queue.");
        test:assertTrue(false);
    }
}

@test:Config {
    dependsOn: [testCreateFIFOQueue],
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
            log:print("Sent message to SQS. MessageID: " + response.messageId);
            test:assertTrue(true);
        } else {
            log:print("Error while sending the message to the queue.");
            test:assertTrue(false);
        }
    } else {
        log:print("Error while sending the message to the queue.");
        test:assertTrue(false);
    }
}

@test:Config {
    dependsOn: [testSendMessage],
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
            log:print("Successfully received the message. Receipt Handle: " + response[0].receiptHandle);
            test:assertTrue(true);
        } else {
            log:print("Error occurred while receiving the message.");
            test:assertTrue(false);
        }
    } else {
        log:print("Error occurred while receiving the message.");
        test:assertTrue(false);
    }
}

@test:Config {
    dependsOn: [testReceiveMessage],
    groups: ["group1"]
}
function testDeleteMessage() {
    string receiptHandler = receivedReceiptHandler;
    boolean|error response = sqs->deleteMessage(fifoQueueResourcePath, receiptHandler);
    if (response is boolean) {
        if (response) {
            log:print("Successfully deleted the message from the queue.");
            test:assertTrue(true);
        } else {
            log:print("Error occurred while deleting the message.");
            test:assertTrue(false);
        }
    } else {
        log:print("Error occurred while deleting the message.");
        test:assertTrue(false);
    }
}

@test:Config {
    dependsOn: [testCreateStandardQueue],
    groups: ["group2"]
}
function testCRUDOperationsForMultipleMessages() {
    log:print("Test, testCRUDOperationsForMultipleMessages is started ...");
    int msgCnt = 0;

    // Send 2 messages to the queue
    while (msgCnt < 2) {
        string queueUrl = "";
        log:print("standardQueueResourcePath " + standardQueueResourcePath);
        OutboundMessage|error response1 = sqs->sendMessage("There is a tree", standardQueueResourcePath, {});
        if (response1 is OutboundMessage) {
            log:print("Sent an alert to the queue. MessageID: " + response1.messageId);
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
                            log:print("Deleted the fire alert \"" + eachResponse.body + "\" from the queue.");
                        }
                    } else {
                        log:printError("Error occurred while deleting a message.");
                        test:assertTrue(false);
                    }
                }
            } else {
                log:print("Queue is empty. No messages to be deleted.");
            }
        } else {
            log:printError("Error occurred while receiving a message.");
            test:assertTrue(false);
        }
        msgCnt = msgCnt + 1;
    }
    if (processesMsgCnt == 2) {
        log:print("Successfully deleted all the messages from the queue!");
        test:assertTrue(true);
    } else {
        log:print("Error occurred while processing the messages.");
        test:assertTrue(false);
    }
}

isolated function genRandQueueName(boolean isFifo = false) returns string {
    float ranNumFloat = random:createDecimal()*10000000;
    anydata ranNumInt = <int> float:round(ranNumFloat);
    string queueName = "testQueue" + ranNumInt.toString();
    if (isFifo) {
        return queueName + ".fifo";
    } else {
        return queueName;
    }
}
