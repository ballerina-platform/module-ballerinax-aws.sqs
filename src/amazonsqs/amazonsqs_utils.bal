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

import ballerina/http;
import ballerinax/java;
import ballerinax/java.arrays as jarrays;

# Handles the HTTP response.
#
# + httpResponse - Http response or error
# + return - If successful returns `json` response. Else returns error.
function handleResponse(http:Response|error httpResponse) returns @untainted xml|ResponseHandleFailed {
    if (httpResponse is http:Response) {
        if (httpResponse.statusCode == http:STATUS_NO_CONTENT){
            //If status 204, then no response body. So returns json boolean true.
            return error(ERROR_SERVER, message = NO_CONTENT_SET_WITH_RESPONSE_MSG, errorCode = RESPONSE_HANDLE_FAILED);
        }
        var xmlResponse = httpResponse.getXmlPayload();
        if (xmlResponse is xml) {
            if (httpResponse.statusCode == http:STATUS_OK) {
                //If status is 200, request is successful. Returns resulting payload.
                return xmlResponse;
            } else {
                //If status is not 200 or 204, request is unsuccessful. Returns error.
                xmlns "http://queue.amazonaws.com/doc/2012-11-05/" as ns;
                string xmlResponseErrorCode = httpResponse.statusCode.toString();
                string responseErrorMessage = xmlResponse[ns:'error][ns:message].getTextValue();
                string errorMsg = STATUS_CODE + COLON_SYMBOL + xmlResponseErrorCode + 
                    SEMICOLON_SYMBOL + WHITE_SPACE + MESSAGE + COLON_SYMBOL + WHITE_SPACE + 
                    responseErrorMessage;
                return error(ERROR_SERVER, message = errorMsg, errorCode = RESPONSE_HANDLE_FAILED);
            }
        } else {
                return error(ERROR_SERVER, message = RESPONSE_PAYLOAD_IS_NOT_XML_MSG, errorCode = RESPONSE_HANDLE_FAILED);
        }
    } else {
        return error(ERROR_CLIENT, message = ERROR_OCCURRED_WHILE_INVOKING_REST_API_MSG,
            errorCode = RESPONSE_HANDLE_FAILED, cause = httpResponse);
    }
}

public function splitString(string str, string delimeter, int arrIndex) returns string {
    handle rec = java:fromString(str);
    handle del = java:fromString(delimeter);
    handle arr = split(rec, del);
    handle arrEle =  jarrays:get(arr, arrIndex);
    return arrEle.toString();
}

function split(handle receiver, handle delimeter) returns handle = @java:Method {
    class: "java.lang.String"
} external;
