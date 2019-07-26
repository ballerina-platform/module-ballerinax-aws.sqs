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

Configuration configuration = {
    accessKey: config:getAsString("ACCESS_KEY_ID"),
    secretKey: config:getAsString("SECRET_ACCESS_KEY"),
    region: config:getAsString("REGION"),
    accountNumber: config:getAsString("ACCOUNT_NUMBER")
};

Client sqsClient = new(configuration);

@test:Config
function testCreateQueue() {

    map<string> attributes = {};
    attributes["VisibilityTimeout"] = "400";
    attributes["FifoQueue"] = "true";

    string|error response = sqsClient->createQueue("demox.fifo", attributes);
    if(response is string && response.hasPrefix("http")) {
        log:printInfo("Created queue: \n" + response);
        test:assertTrue(true);
    } else {
        test:assertTrue(false);
    }
}

@test:Config
function testSendMessage() {

    map<string> attributes = {};
    attributes["MessageDeduplicationId"] = "dupID2";
    attributes["MessageGroupId"] = "grpID1";
    attributes["MessageAttribute.1.Name"] = "N1";
    attributes["MessageAttribute.1.Value.StringValue"] = "V1";
    attributes["MessageAttribute.1.Value.DataType"] = "String";
    attributes["MessageAttribute.2.Name"] = "N2";
    attributes["MessageAttribute.2.Value.StringValue"] = "V2";
    attributes["MessageAttribute.2.Value.DataType"] = "String";

    string queueUrl = "";
    OutboundMessage|error response = sqsClient->sendMessage("New Message Text", "/610968236798/demox.fifo", attributes);
    if(response is OutboundMessage) {
        log:printInfo("Response from SQS: \n");
        test:assertTrue(true);
    } else {
        test:assertTrue(false);
    }
}

@test:Config
function testReceiveMessage() {

    map<string> attributes = {};
    attributes["MaxNumberOfMessages"] = "1";
    attributes["VisibilityTimeout"] = "600";
    attributes["WaitTimeSeconds"] = "2";
    attributes["AttributeName.1"] = "SenderId";
    attributes["MessageAttributeName.1"] = "N2";

    InboundMessage[]|error response = sqsClient->receiveMessage("/610968236798/demox.fifo", attributes);
    if(response is InboundMessage[]) {
        log:printInfo("Received from SQS: \n");
        test:assertTrue(true);
    } else {
        test:assertTrue(false);
    }
}

@test:Config
function testDeleteMessage() {

    string receiptHandler = "AQEBJZ19GVNiX950MD6GfK2T9aT1dmDPXo+hoy44/dp8QapBLerTkAA1bSMSK4MQSoKEGTk6VLRSAfx+6hpy2K9ZGxO++rQG6wlZgzdebxxGnjDt/7hif/98FGu/zsR/m91TiFHYiimCEgAV6tbOCubaXULXTqNBS7az8cnap8vDs+sR091w+HBAtise6wu85uZ27TesovRIq7uSoIgJOdEJdn6d+l7uC86w7PhtYlVnODG4ZIAwMrfAWdH5w9x00zULLBg2ctwNJoXxUD5o2lc2yg==";
    boolean|error response = sqsClient->deleteMessage("/610968236798/demo4.fifo", receiptHandler);
    if(response is boolean) {
        if (response) {
            log:printInfo("Deleted from Queue. \n");
        } else {
            log:printInfo("Deletion was not successful. \n");
        }
        
    }

}


