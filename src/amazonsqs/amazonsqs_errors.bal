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

# Holds the details of an AmazonSQS error
#
# + message - Specific error message for the error
# + cause - Cause of the error; If this error occurred due to another error (Probably from another module)
public type ErrorDetail record {
    string message;
    error cause?;
};

// Ballerina AmazonSQS Client Error Types

// Ballerina Basic Error Types

public const HTTP_CLIENT_POST_REQUEST_FAILED = "{wso2/amazonsqs}HTTPClientPOSTRequestFailed";
public type HTTPClientPOSTRequestFailed error<HTTP_CLIENT_POST_REQUEST_FAILED, ErrorDetail>;

// AmazonSQS Authenticator Error Types

public const GENERATE_POST_REQUEST_FAILED = "{wso2/amazonsqs}GeneratePOSTRequestFailed";
public type GeneratePOSTRequestFailed error<GENERATE_POST_REQUEST_FAILED, ErrorDetail>;

// AmazonSQS Connector Error Types

public const CREATE_QUEUE_FAILED = "{wso2/amazonsqs}CreateQueueFailed";
public type CreateQueueFailed error<CREATE_QUEUE_FAILED, ErrorDetail>;

public const SEND_MESSAGE_FAILED = "{wso2/amazonsqs}SendMessageFailed";
public type SendMessageFailed error<SEND_MESSAGE_FAILED, ErrorDetail>;

public const RECEIVE_MESSAGE_FAILED = "{wso2/amazonsqs}ReceiveMessageFailed";
public type ReceiveMessageFailed error<RECEIVE_MESSAGE_FAILED, ErrorDetail>;

public const DELETE_MESSAGE_FAILED = "{wso2/amazonsqs}DeleteMessageFailed";
public type DeleteMessageFailed error<DELETE_MESSAGE_FAILED, ErrorDetail>;

// AmazonSQS Data Mappings Error Types

public const CONVERT_XML_TO_OUTBOUND_MESSAGE_FAILED = "{wso2/amazonsqs}ConvertXmlToOutboundMessageFailed";
public type ConvertXmlToOutboundMessageFailed error<CONVERT_XML_TO_OUTBOUND_MESSAGE_FAILED, ErrorDetail>;

public const CONVERT_XML_TO_INBOUND_MESSAGES_FAILED = "{wso2/amazonsqs}ConvertXmlToInboundMessagesFailed";
public type ConvertXmlToInboundMessagesFailed error<CONVERT_XML_TO_INBOUND_MESSAGES_FAILED, ErrorDetail>;

public const CONVERT_XML_TO_INBOUND_MESSAGE_FAILED = "{wso2/amazonsqs}ConvertXmlToInboundMessageFailed";
public type ConvertXmlToInboundMessageFailed error<CONVERT_XML_TO_INBOUND_MESSAGE_FAILED, ErrorDetail>;

public const CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED = "{wso2/amazonsqs}ConvertXmlToInboundMessageMessageAttributesFailed";
public type ConvertXmlToInboundMessageMessageAttributesFailed error<CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED, ErrorDetail>;

public const CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTE_FAILED = "{wso2/amazonsqs}ConvertXmlToInboundMessageMessageAttributeFailed";
public type ConvertXmlToInboundMessageMessageAttributeFailed error<CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTE_FAILED, ErrorDetail>;

public const CONVERT_XML_MESSAGE_ATTRIBUTE_VALUE_TO_LIST_VALUES_FAILED = "{wso2/amazonsqs}ConvertXmlMessageAttributeValueToListValuesFailed";
public type ConvertXmlMessageAttributeValueToListValuesFailed error<CONVERT_XML_MESSAGE_ATTRIBUTE_VALUE_TO_LIST_VALUES_FAILED, ErrorDetail>;

// AmazonSQS Other Error Types

public const FILE_READ_FAILED = "{wso2/amazonsqs}FileReadFailed";
public type FileReadFailed error<FILE_READ_FAILED, ErrorDetail>;

public const RESPONSE_HANDLE_FAILED = "{wso2/amazonsqs}ResponseHandleFailed";
public type ResponseHandleFailed error<RESPONSE_HANDLE_FAILED, ErrorDetail>;

// AmazonSQS Client Error Types

public type ClientError CREATE_QUEUE_FAILED|SEND_MESSAGE_FAILED|RECEIVE_MESSAGE_FAILED;

// Error messages.

const string CREATE_QUEUE_FAILED_MSG = "Error while creating a queue.";
const string SEND_MESSAGE_FAILED_MSG = "Error while sending a message to the queue.";
const string RECEIVE_MESSAGE_FAILED_MSG = "Error while receiving a message from the queue.";
const string DELETE_MESSAGE_FAILED_MSG = "Error while deleting a message from the queue.";
const string CLIENT_CONFIG_INIT_FAILED_MSG = "Error occured while initializing client configurations.";
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
