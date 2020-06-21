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

# Holds the details of an AWS SQS error
#
# + message - Specific error message for the error
# + cause - Cause of the error; If this error occurred due to another error (Probably from another module)
public type ErrorDetail record {
    string message;
    error cause?;
};

// Ballerina AWS SQS Client Error Types

// AWS SQS Authenticator Error Types

public type GeneratePOSTRequestFailed distinct error;

// AWS SQS Connector Error Types

public type OperationError distinct error;

// AWS SQS Data Mappings Error Types

public type DataMappingError distinct error;

// AWS SQS Other Error Types

public type FileReadFailed distinct error;
public type ResponseHandleFailed distinct error;

// Error messages.

const string CONVERT_XML_TO_INBOUND_MESSAGES_FAILED_MSG = "Error while converting XML to Inbound Messages.";
const string CONVERT_XML_TO_INBOUND_MESSAGE_FAILED_MSG = "Error while converting XML to an Inbound Message.";
const string CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED_MSG = "Error while converting XML to an Inbound Message's Message Attributes.";
const string CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTE_FAILED_MSG = "Error while converting XML to an Inbound Message's Message Attribute.";
const string FILE_READ_FAILED_MSG = "Error while reading a file.";
const string CLOSE_CHARACTER_STREAM_FAILED_MSG = "Error occurred while closing character stream.";
const string GENERATE_POST_REQUEST_FAILED_MSG = "Error occurred while generating POST request.";
const string NO_CONTENT_SET_WITH_RESPONSE_MSG = "No Content was sent with the response.";
const string RESPONSE_PAYLOAD_IS_NOT_XML_MSG = "Response payload is not XML.";
const string ERROR_OCCURRED_WHILE_INVOKING_REST_API_MSG = "Error occurred while invoking the REST API.";
const string OUTBOUND_MESSAGE_RESPONSE_EMPTY_MSG = "Outbound Message response is empty.";
const string OPERATION_ERROR_MSG = "Error has occurred during an operation.";

