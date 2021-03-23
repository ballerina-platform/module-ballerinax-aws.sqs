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

import ballerina/crypto;
import ballerina/encoding;
import ballerina/http;
import ballerina/lang.array;
import ballerina/time;
import ballerina/io;

# Object to initialize the connection with Amazon SQS.
#
# + accessKey - The Amazon API access key
# + secretKey - The Amazon API secret key
# + region - The Amazon API Region
# + acctNum - The account number of the SQS service
@display {label: "Amazon SQS Client", iconPath: "AmazonSQSLogo.png"}
public client class Client {

    http:Client clientEp;
    string accessKey;
    string secretKey;
    string region;
    string acctNum;
    string host;

    public function init(Configuration config) returns error? {
        self.accessKey = config.accessKey;
        self.secretKey = config.secretKey;
        self.acctNum = config.accountNumber;
        self.region = config.region;
        self.host = SQS_SERVICE_NAME + "." + self.region + "." + AMAZON_HOST;
        http:ClientSecureSocket? clientSecureSocket = config?.secureSocketConfig;
        if (clientSecureSocket is http:ClientSecureSocket) {
            self.clientEp = check new ("https://" + self.host, {secureSocket: clientSecureSocket});
        } else {
            self.clientEp = check new ("https://" + self.host, {});
        }
    }

    # Creates a new queue in SQS
    #
    # + queueName - Name of the queue to be created 
    # + attributes - Other attribute parameters 
    # + return - If success, URL of the created queue, else returns error
    @display {label: "Create queue"}
    remote function createQueue(@display {label: "Queue name"} string queueName, 
                                @display {label: "Map of attributes"} map<string> attributes)
                                returns @tainted @display {label: "Url of created queue"} string|OperationError{
        string amzTarget = AMAZON_SQS_API_VERSION + "." + ACTION_CREATE_QUEUE;
        string endpoint = "/";
        string payload;
        map<string> parameters = {};
        parameters[PAYLOAD_PARAM_ACTION] = ACTION_CREATE_QUEUE;
        parameters[PAYLOAD_PARAM_VERSION] = SQS_VERSION;
        parameters[PAYLOAD_PARAM_QUEUE_NAME] = queueName;
        int attributeNumber = 1;
        foreach var [key, value] in attributes.entries() {
            parameters["Attribute." + attributeNumber.toString() + ".Name"] = key;
            parameters["Attribute." + attributeNumber.toString() + ".Value"] = value;
            attributeNumber = attributeNumber + 1;
        }
        http:Request|error request = self.generatePOSTRequest(amzTarget,
            endpoint, self.buildPayload(parameters));
        if (request is http:Request) {
            var httpResponse = self.clientEp->post(endpoint, request);
            xml|ResponseHandleFailed response = handleResponse(httpResponse);
            if (response is xml){
                return xmlToCreatedQueueUrl(response);
            } else {
                 return error OperationError(OPERATION_ERROR_MSG, response);
            }
        } else {
            return error OperationError(OPERATION_ERROR_MSG, request);
        }
    }

    # Send a new message to a SQS queue
    #
    # + messageBody - Message body string to be sent 
    # + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo
    # + attributes - Non-mandatory parameters for sending a message 
    # + return - If success, details of the sent message, else returns error
    @display {label: "Send message in queue"}
    remote function sendMessage(@display {label: "Message body to send"} string messageBody, 
                                @display {label: "Resource path to queue"} string queueResourcePath, 
                                @display {label: "Map of attributes"} map<string> attributes) 
                                returns @tainted @display {label: "Message detail"} OutboundMessage|OperationError {
        string|error msgbody = encoding:encodeUriComponent(messageBody, UTF_8);
        if (msgbody is string) {
            string amzTarget = AMAZON_SQS_API_VERSION + "." + ACTION_SEND_MESSAGE;
            map<string> parameters = {};
            parameters[PAYLOAD_PARAM_ACTION] = ACTION_SEND_MESSAGE;
            parameters[PAYLOAD_PARAM_MESSAGE_BODY] = msgbody;
            foreach var [key, value] in attributes.entries() {
                parameters[key] = value;
            }
            http:Request|error request = self.generatePOSTRequest(amzTarget,
                queueResourcePath, self.buildPayload(parameters));
            if (request is http:Request) {
                var httpResponse = self.clientEp->post(queueResourcePath, request);
                xml|ResponseHandleFailed response = handleResponse(httpResponse);
                if (response is xml){
                    OutboundMessage|DataMappingError result = xmlToOutboundMessage(response);
                    if (result is OutboundMessage) {
                        return result;
                    } else {
                        return error OperationError(OPERATION_ERROR_MSG, result);
                    }
                } else {
                    return error OperationError(OPERATION_ERROR_MSG, response);
                }
            } else {
                return error OperationError(OPERATION_ERROR_MSG, request);
            }
        } else {
            return error OperationError(OPERATION_ERROR_MSG, msgbody);
        }
    }

    # Receive message(s) from the queue
    #
    # + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo 
    # + attributes - Non-mandatory parameters for receiving a message
    # + return - If success, details of the received message, else returns error
    @display {label: "Receive message in queue"}
    remote function receiveMessage(@display {label: "Resource path to queue"} string queueResourcePath, 
                                  @display {label: "Map of attributes"} map<string> attributes) 
                                  returns @tainted @display {label: "Message detail"} InboundMessage[]|OperationError {
        string amzTarget = AMAZON_SQS_API_VERSION + "." + ACTION_RECEIVE_MESSAGE;
        map<string> parameters = {};
        parameters[PAYLOAD_PARAM_ACTION] = ACTION_RECEIVE_MESSAGE;
        foreach var [key, value] in attributes.entries() {
            parameters[key] = value;
        }
        http:Request|error request = self.generatePOSTRequest(amzTarget,
            queueResourcePath, self.buildPayload(parameters));
        if (request is http:Request) {
            var httpResponse = self.clientEp->post(queueResourcePath, request);
            xml|ResponseHandleFailed response = handleResponse(httpResponse);
            if (response is xml){
                InboundMessage[]|DataMappingError result = xmlToInboundMessages(response);
                if (result is InboundMessage[]) {
                    return result;
                } else {
                    return error OperationError(OPERATION_ERROR_MSG, result);
                }
            } else {
                return error OperationError(OPERATION_ERROR_MSG, response);
            }
        } else {
            return error OperationError(OPERATION_ERROR_MSG, request);
        }
    }

    # Delete message(s) from the queue for a given receiptHandle
    #
    # + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo
    # + receiptHandle - Receipt Handle parameter for the message(s) to be deleted
    # + return - Whether the message(s) were successfully deleted or whether an error occurred
    @display {label: "Delete message in queue"}
    remote function deleteMessage(@display {label: "Resource path to queue"} string queueResourcePath, 
                                  @display {label: "Receipt handle parameter"} string receiptHandle)
                                  returns @tainted @display {label: "Delete status"} boolean|OperationError {
        string amzTarget = AMAZON_SQS_API_VERSION + "." + ACTION_DELETE_MESSAGE;
        string|error receiptHandleEncoded = encoding:encodeUriComponent(receiptHandle, UTF_8);
        if (receiptHandleEncoded is string) {
            map<string> parameters = {};
            parameters[PAYLOAD_PARAM_ACTION] = ACTION_DELETE_MESSAGE;
            parameters[PAYLOAD_PARAM_RECEIPT_HANDLE] = receiptHandleEncoded;
            http:Request|error request = self.generatePOSTRequest(amzTarget, queueResourcePath, self.buildPayload(parameters));
            if (request is http:Request) {
                var httpResponse = self.clientEp->post(queueResourcePath, request);
                xml|ResponseHandleFailed response = handleResponse(httpResponse);
                if (response is xml) {
                    return isXmlDeleteResponse(response);
                } else {
                    return error OperationError(OPERATION_ERROR_MSG, response);
                }
            } else {
                return error OperationError(OPERATION_ERROR_MSG, request);
            }
        } else {
            return error OperationError(OPERATION_ERROR_MSG, receiptHandleEncoded);
        }
    }

    # Delete queue(s)
    #
    # + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo
    # + return - Whether the queue(s) were successfully deleted or whether an error occurred
    @display {label: "Delete the queue"}
    remote function deleteQueue(@display {label: "Resource path to queue"} string queueResourcePath)
                                  returns @tainted @display {label: "Delete status"} boolean|OperationError {
        string amzTarget = AMAZON_SQS_API_VERSION + "." + ACTION_DELETE_QUEUE;
        map<string> parameters = {};
        parameters[PAYLOAD_PARAM_ACTION] = ACTION_DELETE_QUEUE;
        http:Request|error request = self.generatePOSTRequest(amzTarget, queueResourcePath, self.buildPayload(parameters));
        if (request is http:Request) {
            var httpResponse = self.clientEp->post(queueResourcePath, request);
            io:println(httpResponse);
            xml|ResponseHandleFailed response = handleResponse(httpResponse);
            io:println(response);
            if (response is xml) {
                return isXmlDeleteQueueResponse(response);
            } else {
                return error OperationError(OPERATION_ERROR_MSG, response);
            }
        } else {
            return error OperationError(OPERATION_ERROR_MSG, request);
        }
    }

    private isolated function buildPayload(map<string> parameters) returns string {
        string payload = "";
        int parameterNumber = 1;
        foreach var [key, value] in parameters.entries() {
            if (parameterNumber > 1) {
                payload = payload + "&";
            }
            payload = payload + key + "=" + value;
            parameterNumber = parameterNumber + 1;
        }
        return payload;
    }

    private isolated function generatePOSTRequest(string amzTarget, string canonicalUri, string payload)
            returns http:Request|error {
        time:Time|error time = time:toTimeZone(time:currentTime(), "GMT");
        string|error amzDate;
        string|error dateStamp;
        if (time is time:Time) {
            amzDate = time:format(time, ISO8601_BASIC_DATE_FORMAT);
            dateStamp = time:format(time, SHORT_DATE_FORMAT);
            if (amzDate is string && dateStamp is string) {
                string contentType = "application/x-www-form-urlencoded";
                string requestParameters =  payload;
                string canonicalQuerystring = "";
                string canonicalHeaders = "content-type:" + contentType + "\n" + "host:" + self.host + "\n"
                    + "x-amz-date:" + amzDate + "\n" + "x-amz-target:" + amzTarget + "\n";
                string signedHeaders = "content-type;host;x-amz-date;x-amz-target";
                string payloadHash = array:toBase16(crypto:hashSha256(requestParameters.toBytes())).toLowerAscii();
                string canonicalRequest = POST + "\n" + canonicalUri + "\n" + canonicalQuerystring + "\n"
                    + canonicalHeaders + "\n" + signedHeaders + "\n" + payloadHash;
                string algorithm = "AWS4-HMAC-SHA256";
                string credentialScope = dateStamp + "/" + self.region + "/" + SQS_SERVICE_NAME + "/" + "aws4_request";
                string stringToSign = algorithm + "\n" +  amzDate + "\n" +  credentialScope + "\n"
                    +  array:toBase16(crypto:hashSha256(canonicalRequest.toBytes())).toLowerAscii();
                byte[] signingKey = check self.getSignatureKey(self.secretKey, dateStamp, self.region, SQS_SERVICE_NAME);
                string signature = array:toBase16(check crypto:hmacSha256(stringToSign
                    .toBytes(), signingKey)).toLowerAscii();
                string authorizationHeader = algorithm + " " + "Credential=" + self.accessKey + "/"
                    + credentialScope + ", " +  "SignedHeaders=" + signedHeaders + ", " + "Signature=" + signature;

                map<string> headers = {};
                headers["Content-Type"] = contentType;
                headers["X-Amz-Date"] = amzDate;
                headers["X-Amz-Target"] = amzTarget;
                headers["Authorization"] = authorizationHeader;

                string msgBody = requestParameters;
                http:Request request = new;
                request.setTextPayload(msgBody);
                foreach var [k,v] in headers.entries() {
                    request.setHeader(k, v);
                }
                return request;
            } else {
                if (amzDate is error) {
                    return error GeneratePOSTRequestFailed(GENERATE_POST_REQUEST_FAILED_MSG, amzDate);
                } else if (dateStamp is error) {
                    return error GeneratePOSTRequestFailed(GENERATE_POST_REQUEST_FAILED_MSG, dateStamp);
                } else {
                    return error GeneratePOSTRequestFailed(GENERATE_POST_REQUEST_FAILED_MSG);
                }
            }
        } else {
            return error GeneratePOSTRequestFailed(GENERATE_POST_REQUEST_FAILED_MSG);
        }

    }

    private isolated function sign(byte[] key, string msg) returns byte[]|error {
        return check crypto:hmacSha256(msg.toBytes(), key);
    }

    private isolated function getSignatureKey(string secretKey, string datestamp, string region, string serviceName)  returns byte[]|error {
        string awskey = ("AWS4" + secretKey);
        byte[] kDate = check self.sign(awskey.toBytes(), datestamp);
        byte[] kRegion = check self.sign(kDate, region);
        byte[] kService = check self.sign(kRegion, serviceName);
        byte[] kSigning = check self.sign(kService, "aws4_request");
        return kSigning;
    }

}

# Configuration provided for the client
#
# + accessKey - accessKey of Amazon Account 
# + secretKey - secretKey of Amazon Account
# + region - region of SQS Queue
# + accountNumber - account number of the SQS queue
# + secureSocketConfig - HTTP client configuration
public type Configuration record {
    string accessKey;
    string secretKey;
    string region;
    string accountNumber;
    http:ClientSecureSocket secureSocketConfig?;
};
