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

import ballerina/crypto;
import ballerina/encoding;
import ballerina/http;
import ballerina/internal;
import ballerina/io;
import ballerina/system;
import ballerina/time;
import wso2/amazoncommons;
import ballerina/log;

# Object to initialize the connection with Amazon SQS.
#
# + accessKey - The Amazon API access key
# + secretKey - The Amazon API secret key
# + region - The Amazon API Region
# + acctNum - The account number of the SQS service
public type Client client object {

    http:Client clientEp;
    string accessKey;
    string secretKey;
    string region;
    string acctNum;
    string host;

    public function __init(Configuration config) {
        self.accessKey = config.accessKey;
        self.secretKey = config.secretKey;
        self.acctNum = config.accountNumber;
        self.region = config.region;
        self.host = SQS_SERVICE_NAME + "." + self.region + "." + AMAZON_HOST;
        self.clientEp = new("https://" + self.host);
    }

    public remote function createQueue(string queueName, map<string> attributes) returns string|error;

    public remote function sendMessage(string messageBody, string queueResourcePath, map<string> attributes) 
        returns OutboundMessage|error;

    public remote function receiveMessage(string queueResourcePath, map<string> attributes) 
        returns InboundMessage[]|error;

    public remote function deleteMessage(string queueResourcePath, string receiptHandle) returns boolean|error;
    
};

# Creates a new queue in SQS
#
# + queueName - Name of the queue to be created 
# + attributes - Other attribute parameters 
# + return - If success, URL of the created queue, else returns error
public remote function Client.createQueue(string queueName, map<string> attributes) returns string|error{

    string amzTarget = "AmazonSQSv20121105.CreateQueue";
    string endpoint = "/";
    string payload =  "";
    payload = payload + "Action=CreateQueue";
    payload = payload + "&Version=2012-11-05";
    payload = payload + "&QueueName=" + queueName;
    int attributeNumber = 1;
    foreach var (k, v) in attributes {
        payload = payload + "&Attribute." + attributeNumber + ".Name=" + k;
        payload = payload + "&Attribute." + attributeNumber + ".Value=" + v;
        attributeNumber = attributeNumber + 1;
    }

    http:Request request = check generatePOSTRequest(self.accessKey, self.secretKey, self.host, amzTarget, 
        endpoint, self.region, payload);
    var httpResponse = self.clientEp->post(endpoint, request);
    json|error response = handleResponse(httpResponse);
    if(response is json){
        return jsonToCreatedQueueUrl(response);
    } else {
        return response;
    }

}

# Send a new message to a SQS queue
#
# + messageBody - Message body string to be sent 
# + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo
# + attributes - Non-mandatory parameters for sending a message 
# + return - If success, details of the sent message, else returns error
public remote function Client.sendMessage(string messageBody, string queueResourcePath, map<string> attributes) 
    returns OutboundMessage|error {

    string amzTarget = "AmazonSQSv20121105.SendMessage";
    string payload =  "";
    payload = payload + "Action=SendMessage";
    payload = payload + "&MessageBody=" + check http:encode(messageBody, "UTF-8");

    int attributeNumber = 1;
    foreach var (k, v) in attributes {
        payload = payload + "&" + k + "=" + v;
        attributeNumber = attributeNumber + 1;
    }

    http:Request request = check generatePOSTRequest(self.accessKey, self.secretKey, self.host, amzTarget, 
        queueResourcePath, self.region, payload);
    var httpResponse = self.clientEp->post(queueResourcePath, request);
    json|error response = handleResponse(httpResponse);
    if(response is json){
        return jsonToOutboundMessage(response);
    } else {
        return response;
    }

}

# Receive message(s) from the queue
#
# + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo 
# + attributes - Non-mandatory parameters for receiving a message
# + return - If success, details of the received message, else returns error
public remote function Client.receiveMessage(string queueResourcePath, map<string> attributes) 
    returns InboundMessage[]|error {

    string amzTarget = "AmazonSQSv20121105.ReceiveMessage";
    string payload =  "";
    payload = payload + "&Action=ReceiveMessage";
    int attributeNumber = 1;
    foreach var (k, v) in attributes {
        payload = payload + "&" + k + "=" + v;
        attributeNumber = attributeNumber + 1;
    }

    http:Request request = check generatePOSTRequest(self.accessKey, self.secretKey, self.host, amzTarget, 
        queueResourcePath, self.region, payload);
    var httpResponse = self.clientEp->post(queueResourcePath, request);
    json|error response = handleResponse(httpResponse);
    if(response is json){
        return jsonToInboundMessages(response);
    } else {
        return response;
    }
    
}

# Delete the message(s) from the queue for the given receiptHandle
#
# + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo
# + receiptHandle - Receipt Handle parameter for the message(s) to be deleted
# + return - Whether the message(s) were successfully deleted or whether an error occurred
public remote function Client.deleteMessage(string queueResourcePath, string receiptHandle) returns boolean|error {

    string amzTarget = "AmazonSQSv20121105.DeleteMessage";
    string receiptHandleEncoded = check http:encode(receiptHandle, "UTF-8");
    string payload =  "";
    payload = payload + "Action=DeleteMessage";
    payload = payload + "&ReceiptHandle=" + receiptHandleEncoded;

    http:Request request = check generatePOSTRequest(self.accessKey, self.secretKey, self.host, 
        amzTarget, queueResourcePath, self.region, payload);
    var httpResponse = self.clientEp->post(queueResourcePath, request);
    json|error response = handleResponse(httpResponse);
    if (response is json) {
        if (response.DeleteMessageResponse != null) {
            return true;
        } else {
            return false;
        }
    } else {
        return response;
    }

}

# Configuration provided for the client
#
# + accessKey - accessKey of Amazon Account 
# + secretKey - secretKey of Amazon Account
# + region - region of SQS Queue
# + accountNumber - account number of the SQS queue
public type Configuration record {
    string accessKey;
    string secretKey;
    string region;
    string accountNumber;
};
