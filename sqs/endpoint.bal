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

# Ballerina Amazon SQS connector provides the capability to access Amazon SQS API.
# This connector lets you to perform operations related to manage queues, send and receive messages. 
#
# + clientEp - Connector HTTP endpoint
# + accessKey - Amazon API access key
# + secretKey - Amazon API secret key
# + region - Amazon API Region
# + host - Amazon host
@display {label: "Amazon SQS Client", iconPath: "icon.png"}
public isolated client class Client {

    final http:Client clientEp;
    final string accessKey;
    final string secretKey;
    final string region;
    final string host;

    # Initializes the connector. During initialization you have to pass API credentials.
    # Create a [AWS account](https://aws.amazon.com) and obtain tokens following [this guide](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/). 
    #
    # + config - Configuration for the connector
    # + httpClientConfig - HTTP Configuration
    # + return - `http:Error` in case of failure to initialize or `null` if successfully initialized  
    public isolated function init(ConnectionConfig config, http:ClientConfiguration httpClientConfig = {}) returns error? {
        self.accessKey = config.accessKey;
        self.secretKey = config.secretKey;
        self.region = config.region;
        self.host = SQS_SERVICE_NAME + FULL_STOP + self.region + FULL_STOP + AMAZON_HOST;
        self.clientEp = check new ("https://" + self.host, httpClientConfig);
    }

    # Creates a new queue in SQS.
    #
    # + queueName - Name of the queue to be created 
    # + attributes - Queue related attribute parameters 
    # + tags - Cost allocation tag parameters 
    # + return - If success, URL of the created queue, else returns error
    @display {label: "Create Queue"}
    remote isolated function createQueue(@display {label: "Queue Name"} string queueName, 
                                @display {label: "Attributes"} QueueAttributes? attributes = (), 
                                @display {label: "Tags"} map<string>? tags = ())
                                returns @tainted @display {label: "Created Queue URL"} CreateQueueResponse|error {
        string amzTarget = AMAZON_SQS_API_VERSION + FULL_STOP + ACTION_CREATE_QUEUE;
        string endpoint = FORWARD_SLASH;
        map<string> parameters = {};
        parameters[PAYLOAD_PARAM_ACTION] = ACTION_CREATE_QUEUE;
        parameters[PAYLOAD_PARAM_VERSION] = SQS_VERSION;
        parameters[PAYLOAD_PARAM_QUEUE_NAME] = queueName;
        parameters = check addQueueOptionalParameters(parameters, attributes, tags);
        http:Request request = check self.generatePOSTRequest(amzTarget, endpoint, 
                                     self.buildPayload(parameters));
        http:Response httpResponse = check self.clientEp->post(endpoint, request);
        xml response = check handleResponse(httpResponse);
        return xmlToCreatedQueue(response);
    }

    # Send a new message to a SQS queue.
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
                                         @display {label: "Message Attributes"} MessageAttribute[]? messageAttributes = (),
                                         @display {label: "Message Group Tag"} string? messageGroupId = (),
                                         @display {label: "Message DeduplicationId ID"} string? messageDeduplicationId = (),
                                         @display {label: "Time Delay For Message"} int? delaySeconds = ()) 
                                         returns @tainted @display {label: "Message Detail"} SendMessageResponse|error {
        string|error msgbody = url:encode(messageBody, UTF_8);
        if (msgbody is string) {
            string amzTarget = AMAZON_SQS_API_VERSION + FULL_STOP + ACTION_SEND_MESSAGE;
            map<string> parameters = {};
            parameters[PAYLOAD_PARAM_ACTION] = ACTION_SEND_MESSAGE;
            parameters[PAYLOAD_PARAM_MESSAGE_BODY] = msgbody;
            if(messageAttributes is MessageAttribute[]){
                parameters = setMessageAttributes(parameters, messageAttributes);
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
            http:Request request = check self.generatePOSTRequest(amzTarget, queueResourcePath,
                                         self.buildPayload(parameters));
            http:Response httpResponse = check self.clientEp->post(queueResourcePath, request);
            xml response = check handleResponse(httpResponse);
            SendMessageResponse result = check xmlToSendMessageResponse(response);
            return result;
        } else {
            return error OperationError(OPERATION_ERROR_MSG, msgbody);
        }
    }

    # Receive message(s) from the queue.
    #
    # + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo 
    # + maxNumberOfMessages - Maximum number of messages returned. Possible values are 1-10. Default is 1
    # + visibilityTimeout - Duration (in seconds) that messages are hidden from subsequent requests
    # + waitTimeSeconds -  Wait time in seconds
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
                                  returns @tainted @display {label: "Message Detail"} ReceiveMessageResponse|error {
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
        http:Request request = check self.generatePOSTRequest(amzTarget, queueResourcePath,
                                     self.buildPayload(parameters));
        http:Response httpResponse =  check self.clientEp->post(queueResourcePath, request);
        xml response = check handleResponse(httpResponse);
        ReceiveMessageResponse result = check xmlToReceiveMessageResponse(response);
        return result;
    }

    # Delete message(s) from the queue for a given receiptHandle.
    #
    # + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo
    # + receiptHandle - Receipt Handle parameter for the message(s) to be deleted
    # + return - Details of the deleted message when the message(s) were successfully deleted or whether an error occurred
    @display {label: "Delete Message"}
    remote isolated function deleteMessage(@display {label: "Queue Resource Path"} string queueResourcePath, 
                                           @display {label: "Receipt Handle Parameter"} string receiptHandle)
                                           returns @tainted @display {label: "Delete Status"} DeleteMessageResponse|error {
        string amzTarget = AMAZON_SQS_API_VERSION + FULL_STOP + ACTION_DELETE_MESSAGE;
        string|error receiptHandleEncoded = url:encode(receiptHandle, UTF_8);
        if (receiptHandleEncoded is string) {
            map<string> parameters = {};
            parameters[PAYLOAD_PARAM_ACTION] = ACTION_DELETE_MESSAGE;
            parameters[PAYLOAD_PARAM_RECEIPT_HANDLE] = receiptHandleEncoded;
            http:Request request = check self.generatePOSTRequest(amzTarget, queueResourcePath, 
                                         self.buildPayload(parameters));
            http:Response httpResponse = check self.clientEp->post(queueResourcePath, request);
            xml response = check handleResponse(httpResponse);
            return xmlToDeleteMessageResponse(response);
        } else {
            return error OperationError(OPERATION_ERROR_MSG, receiptHandleEncoded);
        }
    }

    # Delete queue(s).
    #
    # + queueResourcePath - Resource path to the queue from the host address. e.g.: /610968236798/myQueue.fifo
    # + return - Details of the deleted queue when the queue(s) were successfully deleted or whether an error occurred
    @display {label: "Delete Queue"}
    remote isolated function deleteQueue(@display {label: "Queue Resource Path"} string queueResourcePath)
                                         returns @tainted @display {label: "Delete Status"} DeleteQueueResponse|error {
        string amzTarget = AMAZON_SQS_API_VERSION + FULL_STOP + ACTION_DELETE_QUEUE;
        map<string> parameters = {};
        parameters[PAYLOAD_PARAM_ACTION] = ACTION_DELETE_QUEUE;
        http:Request request = check self.generatePOSTRequest(amzTarget, queueResourcePath, 
                                     self.buildPayload(parameters));
        http:Response httpResponse = check self.clientEp->post(queueResourcePath, request);
        xml response = check handleResponse(httpResponse);
        return xmlToDeleteQueueResponse(response);
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

# Configuration provided for the client.
#
# + accessKey - AccessKey of Amazon Account 
# + secretKey - SecretKey of Amazon Account
# + region - Region of SQS Queue
@display{label: "Connection Config"} 
public type ConnectionConfig record {
    @display{label: "Access Key"} 
    string accessKey;
    @display{label: "Secret Key"} 
    string secretKey;
    @display{label: "Region"} 
    string region;
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
