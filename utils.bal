// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/jballerina.java as java;
import ballerina/jballerina.java.arrays as jarrays;

isolated function addQueueOptionalParameters(map<string> parameterMap, QueueAttributes? attributes = (), map<string>? tags = ()) returns @tainted map<string>|error {
    if (attributes is QueueAttributes) {
        _ = setQueueAttributes(parameterMap, attributes);
    }
    if (tags is map<string>) {
        _ = setTags(parameterMap, tags);
    }
    return parameterMap;
}

isolated function setQueueAttributes(map<string> parameters, QueueAttributes attributes) returns map<string> {
    int attributeNumber = 1;
    map<anydata> attributeMap = <map<anydata>>attributes;
    foreach var [key, value] in attributeMap.entries() {
        string attributeName = getAttributeName(key);
        parameters["Attribute." + attributeNumber.toString() + ".Name"] = attributeName.toString();
        parameters["Attribute." + attributeNumber.toString() + ".Value"] = value.toString();
        attributeNumber = attributeNumber + 1;
    }
    return parameters;
}

# Handles the HTTP response.
#
# + httpResponse - Http response or error
# + return - If successful returns `json` response. Else returns error.
isolated function handleResponse(http:Response|error httpResponse) returns @untainted xml|ResponseHandleFailed {
    if (httpResponse is http:Response) {
        if (httpResponse.statusCode == http:STATUS_NO_CONTENT){
            //If status 204, then no response body. So returns json boolean true.
            return error ResponseHandleFailed(NO_CONTENT_SET_WITH_RESPONSE_MSG);
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
                string responseErrorMessage = (xmlResponse/<ns:'error>/<ns:message>/*).toString();
                string errorMsg = STATUS_CODE + COLON_SYMBOL + xmlResponseErrorCode + 
                    SEMICOLON_SYMBOL + WHITE_SPACE + MESSAGE + COLON_SYMBOL + WHITE_SPACE + 
                    responseErrorMessage;
                return error ResponseHandleFailed(errorMsg);
            }
        } else {
                return error ResponseHandleFailed(RESPONSE_PAYLOAD_IS_NOT_XML_MSG);
        }
    } else {
        return error ResponseHandleFailed(ERROR_OCCURRED_WHILE_INVOKING_REST_API_MSG, httpResponse);
    }
}

# Set tags to a map of string to add as query parameters.
#
# + parameters - Parameter map
# + tags - Tags to convert to a map of string
# + return - If successful returns `map<string>` response. Else returns error
isolated function setTags(map<string> parameters, map<string> tags) returns map<string> {
    int tagNumber = 1;
    foreach var [key, value] in tags.entries() {
        parameters["Tag." + tagNumber.toString() + ".Key"] = key;
        parameters["Tag." + tagNumber.toString() + ".Value"] = value;
        tagNumber = tagNumber + 1;
    }
    return parameters;
}

# Set message attributes to a map of string to add as query parameters.
#
# + parameters - Parameter map
# + attributes - MessageAttribute to convert to a map of string
# + return - If successful returns `map<string>` response. Else returns error
isolated function setMessageAttributes(map<string> parameters, MessageAttribute[] attributes) returns map<string> {
    int attributeNumber = 1;
    foreach var attribute in attributes {
        parameters["MessageAttribute." + attributeNumber.toString() + ".Name"] = attribute.keyName.toString();
        parameters["MessageAttribute." + attributeNumber.toString() + ".Value.StringValue"] = attribute.value.stringValue.toString();
        parameters["MessageAttribute." + attributeNumber.toString() + ".Value.DataType"] = attribute.value.dataType.toString();
        attributeNumber = attributeNumber + 1;
    }
    return parameters;
}

# Get attribute name from field of record.
#
# + attribute - Field name of record
# + return - If successful returns attribute name string. Else returns error
isolated function getAttributeName(string attribute) returns string {
    string firstLetter = attribute.substring(0, 1);
    string otherLetters = attribute.substring(1);
    string upperCaseFirstLetter = firstLetter.toUpperAscii();
    string attributeName = upperCaseFirstLetter + otherLetters;
    return attributeName;
}

public isolated function splitString(string str, string delimeter, int arrIndex) returns string {
    handle rec = java:fromString(str);
    handle del = java:fromString(delimeter);
    handle arr = split(rec, del);
    handle arrEle = jarrays:get(arr, arrIndex);
    return arrEle.toString();
}
