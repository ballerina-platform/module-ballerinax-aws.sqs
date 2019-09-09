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

import ballerina/encoding;
import ballerina/http;

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
    string trustStore;
    string trustStorePassword;

    public function __init(Configuration config) {
        self.accessKey = config.accessKey;
        self.secretKey = config.secretKey;
        self.acctNum = config.accountNumber;
        self.region = config.region;
        self.trustStore = config.trustStore;
        self.trustStorePassword = config.trustStorePassword;
        self.host = SQS_SERVICE_NAME + "." + self.region + "." + AMAZON_HOST;
        self.clientEp = new("https://" + self.host, 
            {
                secureSocket: {
                    trustStore: {
                        path: config.trustStore,
                        password: config.trustStorePassword
                    }
                }
            }
        );
    }

    # Creates a new queue in SQS
    #
    # + queueName - Name of the queue to be created 
    # + attributes - Other attribute parameters 
    # + return - If success, URL of the created queue, else returns error
    public remote function createQueue(string queueName, map<string> attributes) returns @tainted string|OperationError{
        string amzTarget = "AmazonSQSv20121105.CreateQueue";
        string endpoint = "/";
        string payload =  "";
        payload = payload + "Action=CreateQueue";
        payload = payload + "&Version=2012-11-05";
        payload = payload + "&QueueName=" + queueName;
        int attributeNumber = 1;
        foreach var [k, v] in attributes.entries() {
            payload = payload + "&Attribute." + attributeNumber.toString() + ".Name=" + k;
            payload = payload + "&Attribute." + attributeNumber.toString() + ".Value=" + v;
            attributeNumber = attributeNumber + 1;
        }
        http:Request|GeneratePOSTRequestFailed request = generatePOSTRequest(self.accessKey, 
            self.secretKey, self.host, amzTarget, 
            endpoint, self.region, payload);
        if (request is http:Request) {
            var httpResponse = self.clientEp->post(endpoint, request);
            xml|ResponseHandleFailed response = handleResponse(httpResponse);
            if (response is xml){
                return xmlToCreatedQueueUrl(response);
            } else {
                return error(OPERATION_ERROR, message = OPERATION_ERROR_MSG, errorCode = OPERATION_ERROR, cause = response);
            }
        } else {
            return error(OPERATION_ERROR, message = OPERATION_ERROR_MSG, errorCode = OPERATION_ERROR, cause = request);
        }
    }

    # Send a new message to a SQS queue
    #
    # + messageBody - Message body string to be sent 
    # + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo
    # + attributes - Non-mandatory parameters for sending a message 
    # + return - If success, details of the sent message, else returns error
    public remote function sendMessage(string messageBody, string queueResourcePath, map<string> attributes) 
        returns @tainted OutboundMessage|OperationError {
        string|error msgbody = encoding:encodeUriComponent(messageBody, "UTF-8");
        if (msgbody is string) {
            string amzTarget = "AmazonSQSv20121105.SendMessage";
            string payload =  "";
            payload = payload + "Action=SendMessage";
            payload = payload + "&MessageBody=" + msgbody;
            int attributeNumber = 1;
            foreach var [k, v] in attributes.entries() {
                payload = payload + "&" + k + "=" + v;
                attributeNumber = attributeNumber + 1;
            }
            http:Request|GeneratePOSTRequestFailed request = generatePOSTRequest(self.accessKey, self.secretKey, self.host, amzTarget, 
                queueResourcePath, self.region, payload);
            if (request is http:Request) {
                var httpResponse = self.clientEp->post(queueResourcePath, request);
                xml|ResponseHandleFailed response = handleResponse(httpResponse);
                if (response is xml){
                    OutboundMessage|DataMappingError result = xmlToOutboundMessage(response);
                    if (result is OutboundMessage) {
                        return result;
                    } else {
                        return error(OPERATION_ERROR, message = OPERATION_ERROR_MSG, errorCode = OPERATION_ERROR, cause = result);
                    }
                } else {
                    return error(OPERATION_ERROR, message = OPERATION_ERROR_MSG, errorCode = OPERATION_ERROR, cause = response);
                }
            } else {
                return error(OPERATION_ERROR, message = OPERATION_ERROR_MSG, errorCode = OPERATION_ERROR, cause = request);
            }
        } else {
            return error(OPERATION_ERROR, message = OPERATION_ERROR_MSG, errorCode = OPERATION_ERROR, cause = msgbody);
        }
    }

    # Receive message(s) from the queue
    #
    # + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo 
    # + attributes - Non-mandatory parameters for receiving a message
    # + return - If success, details of the received message, else returns error
    public remote function receiveMessage(string queueResourcePath, map<string> attributes) 
        returns @tainted InboundMessage[]|OperationError {
        string amzTarget = "AmazonSQSv20121105.ReceiveMessage";
        string payload =  "";
        payload = payload + "&Action=ReceiveMessage";
        int attributeNumber = 1;
        foreach var [k, v] in attributes.entries() {
            payload = payload + "&" + k + "=" + v;
            attributeNumber = attributeNumber + 1;
        }
        http:Request|GeneratePOSTRequestFailed request = generatePOSTRequest(self.accessKey, self.secretKey, self.host, amzTarget, 
            queueResourcePath, self.region, payload);
        if (request is http:Request) {
            var httpResponse = self.clientEp->post(queueResourcePath, request);
            xml|ResponseHandleFailed response = handleResponse(httpResponse);
            if (response is xml){
                InboundMessage[]|DataMappingError result = xmlToInboundMessages(response);
                if (result is InboundMessage[]) {
                    return result;
                } else {
                    return error(OPERATION_ERROR, message = OPERATION_ERROR_MSG, errorCode = OPERATION_ERROR, cause = result);
                }
            } else {
                return error(OPERATION_ERROR, message = OPERATION_ERROR_MSG, errorCode = OPERATION_ERROR, cause = response);
            }
        } else {
            return error(OPERATION_ERROR, message = OPERATION_ERROR_MSG, errorCode = OPERATION_ERROR, cause = request);
        }
    }

    # Delete message(s) from the queue for a given receiptHandle
    #
    # + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo
    # + receiptHandle - Receipt Handle parameter for the message(s) to be deleted
    # + return - Whether the message(s) were successfully deleted or whether an error occurred
    public remote function deleteMessage(string queueResourcePath, string receiptHandle) returns @tainted boolean|OperationError {
        string amzTarget = "AmazonSQSv20121105.DeleteMessage";
        string|error receiptHandleEncoded = encoding:encodeUriComponent(receiptHandle, "UTF-8");
        if (receiptHandleEncoded is string) {
            string payload =  "";
            payload = payload + "Action=DeleteMessage";
            payload = payload + "&ReceiptHandle=" + receiptHandleEncoded;
            http:Request|GeneratePOSTRequestFailed request = generatePOSTRequest(self.accessKey, self.secretKey, self.host, 
                amzTarget, queueResourcePath, self.region, payload);
            if (request is http:Request) {
                var httpResponse = self.clientEp->post(queueResourcePath, request);
                xml|ResponseHandleFailed response = handleResponse(httpResponse);
                if (response is xml) {
                    return isXmlDeleteResponse(response);
                } else {
                    return error(OPERATION_ERROR, message = OPERATION_ERROR_MSG, errorCode = OPERATION_ERROR, cause = response);
                }
            } else {
                return error(OPERATION_ERROR, message = OPERATION_ERROR_MSG, errorCode = OPERATION_ERROR, cause = request);
            }
        } else {
            return error(OPERATION_ERROR, message = OPERATION_ERROR_MSG, errorCode = OPERATION_ERROR, cause = receiptHandleEncoded);
        }
    }
};

# Configuration provided for the client
#
# + accessKey - accessKey of Amazon Account 
# + secretKey - secretKey of Amazon Account
# + region - region of SQS Queue
# + accountNumber - account number of the SQS queue
# + trustStore - trust store file path to establish TLS connections
# + trustStorePassword - trust store password to open the trust store
public type Configuration record {
    string accessKey;
    string secretKey;
    string region;
    string accountNumber;
    string trustStore;
    string trustStorePassword;
};
