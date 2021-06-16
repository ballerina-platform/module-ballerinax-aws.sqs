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
import ballerina/url;
import ballerina/http;
import ballerina/jballerina.java;
import ballerina/lang.array;
import ballerina/time;

# Amazon SQS connector client endpoint.
#
# + accessKey - Amazon API access key
# + secretKey - Amazon API secret key
# + region - Amazon API Region
# + acctNum - Account number of the SQS service
@display {label: "Amazon SQS Client", iconPath: "AmazonSQSLogo.png"}
public client class Client {

    http:Client clientEp;
    string accessKey;
    string secretKey;
    string region;
    string acctNum;
    string host;

    # Initializes the Amazon SQS connector client endpoint.
    #
    # + config - Configurations required to initialize the `Client` endpoint
    public isolated function init(Configuration config) returns error? {
        self.accessKey = config.accessKey;
        self.secretKey = config.secretKey;
        self.acctNum = config.accountNumber;
        self.region = config.region;
        self.host = SQS_SERVICE_NAME + FULL_STOP + self.region + FULL_STOP + AMAZON_HOST;
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
    # + attributes - Queue related attribute parameters 
    # + tags - Cost allocation tag parameters 
    # + return - If success, URL of the created queue, else returns error
    @display {label: "Create Queue"}
    remote isolated function createQueue(@display {label: "Queue Name"} string queueName, 
                                @display {label: "Attributes"} map<string>? attributes = (), 
                                @display {label: "Tags"} map<string>? tags = ())
                                returns @tainted @display {label: "Created Queue URL"} string|OperationError {
        string amzTarget = AMAZON_SQS_API_VERSION + FULL_STOP + ACTION_CREATE_QUEUE;
        string endpoint = FORWARD_SLASH;
        string payload;
        map<string> parameters = {};
        parameters[PAYLOAD_PARAM_ACTION] = ACTION_CREATE_QUEUE;
        parameters[PAYLOAD_PARAM_VERSION] = SQS_VERSION;
        parameters[PAYLOAD_PARAM_QUEUE_NAME] = queueName;
        int attributeNumber = 1;
        if(attributes is map<string>){
            foreach var [key, value] in attributes.entries() {
                parameters["Attribute." + attributeNumber.toString() + ".Name"] = key;
                parameters["Attribute." + attributeNumber.toString() + ".Value"] = value;
                attributeNumber = attributeNumber + 1;
            }
        }
        int tagNumber = 1;
        if(tags is map<string>){
            foreach var [key, value] in tags.entries() {
                parameters["Tag." + tagNumber.toString() + ".Key"] = key;
                parameters["Tag." + tagNumber.toString() + ".Value"] = value;
                tagNumber = tagNumber + 1;
            }
        }
        http:Request|error request = self.generatePOSTRequest(amzTarget, endpoint, 
                                     self.buildPayload(parameters));
        if (request is http:Request) {
            http:Response|error httpResponse = self.clientEp->post(endpoint, request);
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
    # + messageAttributes - Message attributes for sending a message 
    # + messageGroupId - Message group which a message belongs. only applicable to FIFO queues
    # + messageDeduplicationId - Message deduplicationId ID. only applicable to FIFO queues
    # + delaySeconds - Length of time for which to delay a specific message. On FIFO queue can't set for a message
    # + return - If success, details of the sent message, else returns error
    @display {label: "Send Message"}
    remote isolated function sendMessage(@display {label: "Message Body"} string messageBody, 
                                         @display {label: "Queue Resource Path"} string queueResourcePath, 
                                         @display {label: "Message Attributes"} map<string>? messageAttributes = (),
                                         @display {label: "Message Group Tag"} string? messageGroupId = (),
                                         @display {label: "Message DeduplicationId ID"} string? messageDeduplicationId = (),
                                         @display {label: "Time Delay For Message"} int? delaySeconds = ()) 
                                         returns @tainted @display {label: "Message Detail"} OutboundMessage|OperationError {
            string|error msgbody = url:encode(messageBody, UTF_8);
            if (msgbody is string) {
            string amzTarget = AMAZON_SQS_API_VERSION + FULL_STOP + ACTION_SEND_MESSAGE;
            map<string> parameters = {};
            parameters[PAYLOAD_PARAM_ACTION] = ACTION_SEND_MESSAGE;
            parameters[PAYLOAD_PARAM_MESSAGE_BODY] = msgbody;
            if(messageAttributes is map<string>){
            foreach var [key, value] in messageAttributes.entries() {
            parameters[key] = value;
            }
            }
            if(delaySeconds is int){
            parameters["DelaySeconds"] = delaySeconds.toString();
            }
            if(messageGroupId is string){
            parameters["MessageGroupId"] = messageGroupId;
            }
            if(messageDeduplicationId is string){
            parameters["MessageDeduplicationId"] = messageDeduplicationId;
            }
            http:Request|error request = self.generatePOSTRequest(amzTarget, queueResourcePath,
                                         self.buildPayload(parameters));
            if (request is http:Request) {
                http:Response|error httpResponse = self.clientEp->post(queueResourcePath, request);
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
    # + maxNumberOfMessages - Maximum number of messages returned. Possible values are 1-10. Default is 1
    # + visibilityTimeout - Duration (in seconds) that messages are hidden from subsequent requests
    # + waitTimeSeconds - Wait time in seconds
    # + attributeNames - List of attributes that need to be returned along with each message
    # + messageAttributeNames - Name of the message attribute
    # + receiveRequestAttemptId - Deduplication token of receive message calls. only applicable to FIFO queues
    # + return - If success, details of the received message, else returns error
    @display {label: "Receive Message"}
    remote isolated function receiveMessage(@display {label: "Queue Resource Path"} string queueResourcePath, 
                                  @display {label: "Maximum Number Of Messages"} int? maxNumberOfMessages = (),
                                  @display {label: "Visibility Timeout"} int? visibilityTimeout = (),
                                  @display {label: "Wait Time(s)"} int? waitTimeSeconds = (),
                                  @display {label: "Attribute Names"} string[]? attributeNames = (),
                                  @display {label: "Message Attribute Names"} string[]? messageAttributeNames = (),
                                  @display {label: "Receive Request Attempt ID"} string? receiveRequestAttemptId = ()) 
                                  returns @tainted @display {label: "Message Detail"} InboundMessage[]|OperationError {
        string amzTarget = AMAZON_SQS_API_VERSION + FULL_STOP + ACTION_RECEIVE_MESSAGE;
        map<string> parameters = {};
        parameters[PAYLOAD_PARAM_ACTION] = ACTION_RECEIVE_MESSAGE;
        if(maxNumberOfMessages is int){
            parameters["MaxNumberOfMessages"] = maxNumberOfMessages.toString();
        }
        if(visibilityTimeout is int){
            parameters["VisibilityTimeout"] = visibilityTimeout.toString();
        }
        if(waitTimeSeconds is int){
            parameters["WaitTimeSeconds"] = waitTimeSeconds.toString();
        }
        int attributeNameNumber = 1;
        if(attributeNames is string[]){
            foreach var attributeName in attributeNames {
                parameters["AttributeName." + attributeNameNumber.toString()] = attributeName;
                attributeNameNumber = attributeNameNumber + 1;
            }
        }
        int messageAttributeNameNumber = 1;
        if(messageAttributeNames is string[]){
            foreach var messageAttributeName in messageAttributeNames {
                parameters["MessageAttributeName." + messageAttributeNameNumber.toString()] = messageAttributeName;
                messageAttributeNameNumber = messageAttributeNameNumber + 1;
            }
        }
        http:Request|error request = self.generatePOSTRequest(amzTarget, queueResourcePath,
                                     self.buildPayload(parameters));
        if (request is http:Request) {
            http:Response|error httpResponse = self.clientEp->post(queueResourcePath, request);
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
    # + return - Null when the message(s) were successfully deleted or whether an error occurred
    @display {label: "Delete Message"}
    remote isolated function deleteMessage(@display {label: "Queue Resource Path"} string queueResourcePath, 
                                           @display {label: "Receipt Handle Parameter"} string receiptHandle)
                                           returns @tainted @display {label: "Delete Status"} OperationError? {
        string amzTarget = AMAZON_SQS_API_VERSION + FULL_STOP + ACTION_DELETE_MESSAGE;
        string|error receiptHandleEncoded = url:encode(receiptHandle, UTF_8);
        if (receiptHandleEncoded is string) {
            map<string> parameters = {};
            parameters[PAYLOAD_PARAM_ACTION] = ACTION_DELETE_MESSAGE;
            parameters[PAYLOAD_PARAM_RECEIPT_HANDLE] = receiptHandleEncoded;
            http:Request|error request = self.generatePOSTRequest(amzTarget, queueResourcePath, 
                                         self.buildPayload(parameters));
            if (request is http:Request) {
                http:Response|error httpResponse = self.clientEp->post(queueResourcePath, request);
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
    # + return - Null when the queue(s) were successfully deleted or whether an error occurred
    @display {label: "Delete Queue"}
    remote isolated function deleteQueue(@display {label: "Queue Resource Path"} string queueResourcePath)
                                         returns @tainted @display {label: "Delete Status"} OperationError? {
        string amzTarget = AMAZON_SQS_API_VERSION + FULL_STOP + ACTION_DELETE_QUEUE;
        map<string> parameters = {};
        parameters[PAYLOAD_PARAM_ACTION] = ACTION_DELETE_QUEUE;
        http:Request|error request = self.generatePOSTRequest(amzTarget, queueResourcePath, 
                                     self.buildPayload(parameters));
        if (request is http:Request) {
            http:Response|error httpResponse = self.clientEp->post(queueResourcePath, request);
            xml|ResponseHandleFailed response = handleResponse(httpResponse);
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
        string payload = EMPTY_STRING;
        int parameterNumber = 1;
        foreach var [key, value] in parameters.entries() {
            if (parameterNumber > 1) {
                payload = payload + AMBERSAND;
            }
            payload = payload + key + EQUAL + value;
            parameterNumber = parameterNumber + 1;
        }
        return payload;
    }

    private isolated function generatePOSTRequest(string amzTarget, string canonicalUri, string payload)
            returns http:Request|error {
            [int, decimal] & readonly currentTime = time:utcNow();
            string|error amzDate = utcToString(currentTime, ISO8601_BASIC_DATE_FORMAT);
            string|error dateStamp = utcToString(currentTime, SHORT_DATE_FORMAT);
            if (amzDate is string && dateStamp is string) {
                string contentType = "application/x-www-form-urlencoded";
                string requestParameters =  payload;
                string canonicalQuerystring = EMPTY_STRING;
                string canonicalHeaders = "content-type:" + contentType + NEW_LINE + "host:" + self.host + NEW_LINE
                    + "x-amz-date:" + amzDate + NEW_LINE + "x-amz-target:" + amzTarget + NEW_LINE;
                string signedHeaders = "content-type;host;x-amz-date;x-amz-target";
                string payloadHash = array:toBase16(crypto:hashSha256(requestParameters.toBytes())).toLowerAscii();
                string canonicalRequest = POST + NEW_LINE + canonicalUri + NEW_LINE + canonicalQuerystring + NEW_LINE
                    + canonicalHeaders + NEW_LINE + signedHeaders + NEW_LINE + payloadHash;
                string algorithm = "AWS4-HMAC-SHA256";
                string credentialScope = dateStamp + FORWARD_SLASH + self.region + FORWARD_SLASH + SQS_SERVICE_NAME 
                    + FORWARD_SLASH + "aws4_request";
                string stringToSign = algorithm + NEW_LINE +  amzDate + NEW_LINE +  credentialScope + NEW_LINE
                    +  array:toBase16(crypto:hashSha256(canonicalRequest.toBytes())).toLowerAscii();
                byte[] signingKey = check self.getSignatureKey(self.secretKey, dateStamp, self.region, SQS_SERVICE_NAME);
                string signature = array:toBase16(check crypto:hmacSha256(stringToSign
                    .toBytes(), signingKey)).toLowerAscii();
                string authorizationHeader = algorithm + " " + "Credential=" + self.accessKey + FORWARD_SLASH
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
    }

    private isolated function sign(byte[] key, string msg) returns byte[]|error {
        return check crypto:hmacSha256(msg.toBytes(), key);
    }

    private isolated function getSignatureKey(string secretKey, string datestamp, string region, string serviceName)  
                                              returns byte[]|error {
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
# + accessKey - AccessKey of Amazon Account 
# + secretKey - SecretKey of Amazon Account
# + region - Region of SQS Queue
# + accountNumber - Account number of the SQS queue
# + secureSocketConfig - HTTP client configuration
@display{label: "Connection Config"} 
public type Configuration record {
    @display{label: "Access Key"} 
    string accessKey;
    @display{label: "Secret Key"} 
    string secretKey;
    @display{label: "Region"} 
    string region;
    @display{label: "Account Number"} 
    string accountNumber;
    http:ClientSecureSocket secureSocketConfig?;
};

isolated function utcToString(time:Utc utc, string pattern) returns string|error {
    [int, decimal][epochSeconds, lastSecondFraction] = utc;
    int nanoAdjustments = (<int>lastSecondFraction * 1000000000);
    var instant = ofEpochSecond(epochSeconds, nanoAdjustments);
    var zoneId = getZoneId(java:fromString("Z"));
    var zonedDateTime = atZone(instant, zoneId);
    var dateTimeFormatter = ofPattern(java:fromString(pattern));
    handle formatString = format(zonedDateTime, dateTimeFormatter);
    return formatString.toBalString();
}
