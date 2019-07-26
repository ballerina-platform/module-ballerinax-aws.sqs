//
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
//

import ballerina/crypto;
import ballerina/encoding;
import ballerina/http;
import ballerina/system;
import ballerina/time;
import ballerina/log;

# Handles the HTTP response.
#
# + httpResponse - Http response or error
# + return - If successful returns `json` response. Else returns error.
function handleResponse(http:Response|error httpResponse) returns json|error {
    if (httpResponse is http:Response) {
        if (httpResponse.statusCode == http:NO_CONTENT_204){
            //If status 204, then no response body. So returns json boolean true.
            return true;
        }
        var xmlResponse = httpResponse.getXmlPayload();
        if (xmlResponse is xml) {
            var jsonResponse = xmlResponse.toJSON({ preserveNamespaces: false });
            if (httpResponse.statusCode == http:OK_200) {
                //If status is 200, request is successful. Returns resulting payload.
                return jsonResponse;
            } else {
                //If status is not 200 or 204, request is unsuccessful. Returns error.
                string errorMsg = STATUS_CODE + COLON_SYMBOL + jsonResponse["error"].code.toString()
                    + SEMICOLON_SYMBOL + WHITE_SPACE + MESSAGE + COLON_SYMBOL + WHITE_SPACE
                    + jsonResponse["error"]["message"].toString();
                error err = error(AMAZONSQS_ERROR_CODE, { message: errorMsg });
                return err;
            }
        } else {
                error err = error(AMAZONSQS_ERROR_CODE, { message: "Response payload is not XML" });
                return err;
        }
    } else {
        error err = error(AMAZONSQS_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

function generatePOSTRequest(string accessKeyId, string secretAccessKey, string host, string amzTarget, string canonicalUri,
                        string region, string payload) returns http:Request|error {
    time:Time time = check time:toTimeZone(time:currentTime(), "GMT");
    string amzDate = check time:format(time, ISO8601_BASIC_DATE_FORMAT);
    string dateStamp = check time:format(time, SHORT_DATE_FORMAT);
    string contentType = "application/x-www-form-urlencoded";
    string requestParameters =  payload;
    string canonicalQuerystring = "";
    string canonicalHeaders = "content-type:" + contentType + "\n" + "host:" + host + "\n" + "x-amz-date:" + amzDate + "\n" + "x-amz-target:" + amzTarget + "\n";
    string signedHeaders = "content-type;host;x-amz-date;x-amz-target";
    string payloadHash = encoding:encodeHex(crypto:hashSha256(requestParameters.toByteArray("UTF-8"))).toLower();
    string canonicalRequest = POST + "\n" + canonicalUri + "\n" + canonicalQuerystring + "\n" + canonicalHeaders + "\n" + signedHeaders + "\n" + payloadHash;
    string algorithm = "AWS4-HMAC-SHA256";
    string credentialScope = dateStamp + "/" + region + "/" + SQS_SERVICE_NAME + "/" + "aws4_request";
    string stringToSign = algorithm + "\n" +  amzDate + "\n" +  credentialScope + "\n" +  encoding:encodeHex(crypto:hashSha256(canonicalRequest.toByteArray("UTF-8"))).toLower();
    byte[] signingKey = getSignatureKey(secretAccessKey, dateStamp, region, SQS_SERVICE_NAME);
    string signature = encoding:encodeHex(crypto:hmacSha256(stringToSign.toByteArray("UTF-8"), signingKey)).toLower();
    string authorizationHeader = algorithm + " " + "Credential=" + accessKeyId + "/" + credentialScope + ", " +  "SignedHeaders=" + signedHeaders + ", " + "Signature=" + signature;

    map<string> headers = {};
    headers["Content-Type"] = contentType;
    headers["X-Amz-Date"] = amzDate;
    headers["X-Amz-Target"] = amzTarget;
    headers["Authorization"] = authorizationHeader;

    string msgBody = requestParameters;

    http:Request request = new;
    request.setTextPayload(msgBody);
    foreach var (k,v) in headers {
        request.setHeader(k, v);
    }

    return request;
}

function sign(byte[] key, string msg) returns byte[] {
    return crypto:hmacSha256(msg.toByteArray("UTF-8"), key);
}

function getSignatureKey(string secretKey, string datestamp, string region, string serviceName)  returns byte[] {
    string awskey = ("AWS4" + secretKey);
    byte[] kDate = sign(awskey.toByteArray("UTF-8"), datestamp);
    byte[] kRegion = sign(kDate, region);
    byte[] kService = sign(kRegion, serviceName);
    byte[] kSigning = sign(kService, "aws4_request");
    return kSigning;
}
