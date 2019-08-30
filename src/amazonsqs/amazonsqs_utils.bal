// Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/io;
import ballerina/log;
import ballerina/system;
import ballerina/time;
import ballerinax/java;

# Handles the HTTP response.
#
# + httpResponse - Http response or error
# + return - If successful returns `json` response. Else returns error.
function handleResponse(http:Response|error httpResponse) returns @untainted xml|ResponseHandleFailed {
    if (httpResponse is http:Response) {
        if (httpResponse.statusCode == http:STATUS_NO_CONTENT){
            //If status 204, then no response body. So returns json boolean true.
            return error(RESPONSE_HANDLE_FAILED, message = NO_CONTENT_SET_WITH_RESPONSE_MSG);
        }
        var xmlResponse = httpResponse.getXmlPayload();
        if (xmlResponse is xml) {
            if (httpResponse.statusCode == http:STATUS_OK) {
                //If status is 200, request is successful. Returns resulting payload.
                return xmlResponse;
            } else {
                //If status is not 200 or 204, request is unsuccessful. Returns error.
                xmlns "http://queue.amazonaws.com/doc/2012-11-05/" as ns1;
                string xmlResponseErrorCode = httpResponse.statusCode.toString();
                string responseErrorMessage = xmlResponse[ns1:'error][ns1:message].getTextValue();
                string errorMsg = STATUS_CODE + COLON_SYMBOL + xmlResponseErrorCode + 
                    SEMICOLON_SYMBOL + WHITE_SPACE + MESSAGE + COLON_SYMBOL + WHITE_SPACE + 
                    responseErrorMessage;
                return error(RESPONSE_HANDLE_FAILED, message = errorMsg);
            }
        } else {
                return error(RESPONSE_HANDLE_FAILED, message = RESPONSE_PAYLOAD_IS_NOT_XML_MSG);
        }
    } else {
        return error(RESPONSE_HANDLE_FAILED, message = ERROR_OCCURRED_WHILE_INVOKING_REST_API_MSG, cause = httpResponse);
    }
}

function generatePOSTRequest(string accessKeyId, string secretAccessKey, string host, string amzTarget, 
    string canonicalUri, string region, string payload) returns http:Request|GeneratePOSTRequestFailed {
    
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
            string canonicalHeaders = "content-type:" + contentType + "\n" + "host:" + host + "\n" 
                + "x-amz-date:" + amzDate + "\n" + "x-amz-target:" + amzTarget + "\n";
            string signedHeaders = "content-type;host;x-amz-date;x-amz-target";
            string payloadHash = encoding:encodeHex(crypto:hashSha256(requestParameters.toBytes())).toLowerAscii();
            string canonicalRequest = POST + "\n" + canonicalUri + "\n" + canonicalQuerystring + "\n" 
                + canonicalHeaders + "\n" + signedHeaders + "\n" + payloadHash;
            string algorithm = "AWS4-HMAC-SHA256";
            string credentialScope = dateStamp + "/" + region + "/" + SQS_SERVICE_NAME + "/" + "aws4_request";
            string stringToSign = algorithm + "\n" +  amzDate + "\n" +  credentialScope + "\n" 
                +  encoding:encodeHex(crypto:hashSha256(canonicalRequest.toBytes())).toLowerAscii();
            byte[] signingKey = getSignatureKey(secretAccessKey, dateStamp, region, SQS_SERVICE_NAME);
            string signature = encoding:encodeHex(crypto:hmacSha256(stringToSign
                .toBytes(), signingKey)).toLowerAscii();
            string authorizationHeader = algorithm + " " + "Credential=" + accessKeyId + "/" 
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
                return error(GENERATE_POST_REQUEST_FAILED, message = GENERATE_POST_REQUEST_FAILED_MSG, cause = amzDate);
            } else if (dateStamp is error) {
                return error(GENERATE_POST_REQUEST_FAILED, message = GENERATE_POST_REQUEST_FAILED_MSG, cause = dateStamp);
            } else {
                return error(GENERATE_POST_REQUEST_FAILED, message = GENERATE_POST_REQUEST_FAILED_MSG);
            }
        }
    } else {
        return error(GENERATE_POST_REQUEST_FAILED, message = GENERATE_POST_REQUEST_FAILED_MSG, cause = time);
    }

}

function sign(byte[] key, string msg) returns byte[] {
    return crypto:hmacSha256(msg.toBytes(), key);
}

function getSignatureKey(string secretKey, string datestamp, string region, string serviceName)  returns byte[] {
    string awskey = ("AWS4" + secretKey);
    byte[] kDate = sign(awskey.toBytes(), datestamp);
    byte[] kRegion = sign(kDate, region);
    byte[] kService = sign(kRegion, serviceName);
    byte[] kSigning = sign(kService, "aws4_request");
    return kSigning;
}

public function splitString(string str, string delimeter, int arrIndex) returns string {
    handle rec = java:fromString(str);
    handle del = java:fromString(delimeter);
    handle arr = split(rec, del);
    handle arrEle =  java:getArrayElement(arr, arrIndex);
    return arrEle.toString();
}

function split(handle receiver, handle delimeter) returns handle = @java:Method {
    class: "java.lang.String"
} external;
