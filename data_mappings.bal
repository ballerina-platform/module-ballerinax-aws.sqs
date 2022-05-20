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

import ballerina/io;
import ballerina/lang.'xml as xmllib;

xmlns "http://queue.amazonaws.com/doc/2012-11-05/" as ns;

isolated function xmlToCreatedQueueUrl(xml response) returns string {
    string|error queueUrl = (response/<ns:CreateQueueResult>/<ns:QueueUrl>/*).toString();
    if (queueUrl is string) {
        return queueUrl != "" ? queueUrl.toString() : EMPTY_STRING;
    } else {
        return "";
    }
}

isolated function xmlToCreatedQueue(xml response) returns CreateQueueResponse|error {
    xml createdQueueResponse = response/<ns:CreateQueueResult>;
    xml responseMeta = response/<ns:ResponseMetadata>;
    if (createdQueueResponse.toString() != "") {
        CreateQueueResult createQueue = {
            queueUrl : (createdQueueResponse/<ns:QueueUrl>/*).toString()
        };
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<ns:RequestId>/*).toString()
        };
        CreateQueueResponse createQueueResponse = {
            createQueueResult : createQueue,
            responseMetadata : responseMetadata 
        };
        return createQueueResponse;
    } else {
        return error(response.toString());
    }
}

isolated function xmlToSendMessageResponse(xml response) returns SendMessageResponse|error {
    xml sentMessageResponse = response/<ns:SendMessageResult>;
    xml responseMeta = response/<ns:ResponseMetadata>;
    if (sentMessageResponse.toString() != "") {
        SendMessageResult sendMessage = {
            md5OfMessageAttributes: (sentMessageResponse/<ns:MD5OfMessageAttributes>/*).toString(),
            md5OfMessageBody: (sentMessageResponse/<ns:MD5OfMessageBody>/*).toString(),
            messageId: (sentMessageResponse/<ns:MessageId>/*).toString(),
            sequenceNumber: (sentMessageResponse/<ns:SequenceNumber>/*).toString()
        };
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<ns:RequestId>/*).toString()
        };
        SendMessageResponse sendMessageResponse = {
            sendMessageResult : sendMessage,
            responseMetadata : responseMetadata 
        };
        return sendMessageResponse;
    } else {
        return error(response.toString());
    }
}

isolated function xmlToReceiveMessageResponse(xml response) returns ReceiveMessageResponse|error {
    xml responseMeta = response/<ns:ResponseMetadata>;
    string requestId = (responseMeta/<ns:RequestId>/*).toString();
    InboundMessage[]|DataMappingError receivedMessages = xmlToInboundMessages(response);
    if (receivedMessages is InboundMessage[]) {
        ReceiveMessageResponse receiveMessageResponse = {
            receiveMessageResult : {
                message : receivedMessages
            },
            responseMetadata : {
                requestId: requestId
            }
        };
        return receiveMessageResponse;
    } else {
        return error DataMappingError(CONVERT_XML_TO_INBOUND_MESSAGES_FAILED_MSG, receivedMessages);
    }
}

isolated function xmlToDeleteMessageResponse(xml response) returns DeleteMessageResponse|error {
    xml responseMeta = response/<ns:ResponseMetadata>;
    if (responseMeta.toString() != "") {
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<ns:RequestId>/*).toString()
        };
        DeleteMessageResponse deleteMessageResponse = {
            responseMetadata : responseMetadata 
        };
        return deleteMessageResponse;
    } else {
        return error(response.toString());
    }
}

isolated function xmlToDeleteQueueResponse(xml response) returns DeleteQueueResponse|error {
    xml responseMeta = response/<ns:ResponseMetadata>;
    if (responseMeta.toString() != "") {
        ResponseMetadata responseMetadata = {
            requestId: (responseMeta/<ns:RequestId>/*).toString()
        };
        DeleteQueueResponse deleteQueueResponse = {
            responseMetadata : responseMetadata 
        };
        return deleteQueueResponse;
    } else {
        return error(response.toString());
    }
}

isolated function xmlToOutboundMessage(xml response) returns OutboundMessage|DataMappingError {
    xml msgSource = response/<ns:SendMessageResult>;
    if (msgSource.toString() != "") {
        OutboundMessage sentMessage = {
            md5OfMessageAttributes: (msgSource/<ns:MD5OfMessageAttributes>/*).toString(),
            md5OfMessageBody: (msgSource/<ns:MD5OfMessageBody>/*).toString(),
            messageId: (msgSource/<ns:MessageId>/*).toString(),
            sequenceNumber: (msgSource/<ns:SequenceNumber>/*).toString()
        };
        return sentMessage;
    } else {
        return error DataMappingError(OUTBOUND_MESSAGE_RESPONSE_EMPTY_MSG);
    }
}

isolated function xmlToInboundMessages(xml response) returns InboundMessage[]|DataMappingError {
    xml messages = response/<ns:ReceiveMessageResult>/<ns:Message>;
    InboundMessage[] receivedMessages = [];
    if (messages.elements().length() != 1) {
        int i = 0;
        foreach var b in messages.elements() {
            InboundMessage|DataMappingError receivedMsg = xmlToInboundMessage(b.elements());
            if (receivedMsg is InboundMessage) {
                receivedMessages[i] = receivedMsg;
            } else {
                return error DataMappingError(CONVERT_XML_TO_INBOUND_MESSAGES_FAILED_MSG, receivedMsg);
            }
            i = i + 1;
        }
        return receivedMessages;
    } else {
        InboundMessage|DataMappingError receivedMsg = xmlToInboundMessage(messages);
        if (receivedMsg is InboundMessage) {
            return [receivedMsg]; 
        } else {
            return error DataMappingError(CONVERT_XML_TO_INBOUND_MESSAGES_FAILED_MSG, receivedMsg);
        }
    }
}

isolated function xmlToInboundMessage(xml message) returns InboundMessage|DataMappingError {
    xml attribute = message/<ns:Attribute>;
    xml msgAttribute = message/<ns:MessageAttribute>;

    map<MessageAttributeValue>|DataMappingError messageAttributes = xmlToInboundMessageMessageAttributes(msgAttribute);
    if (messageAttributes is map<MessageAttributeValue>) {
        InboundMessage receivedMessage = {
            attributes: xmlToInboundMessageAttributes(attribute),
            body: (message/<ns:Body>/*).toString(),
            md5OfBody: (message/<ns:MD5OfBody>/*).toString(),
            md5OfMessageAttributes: (message/<ns:MD5OfMessageAttributes>/*).toString(),
            messageAttributes: messageAttributes,
            messageId: (message/<ns:MessageId>/*).toString(),
            receiptHandle: (message/<ns:ReceiptHandle>/*).toString()
        };
        return receivedMessage;
    } else {
        return error DataMappingError(CONVERT_XML_TO_INBOUND_MESSAGE_FAILED_MSG, messageAttributes);
    }
}

isolated function xmlToInboundMessageAttributes(xml attribute) returns map<string> {
    map<string> attributes = {};
    if (attribute.elements().length() != 1) {
        int i = 0;
        foreach var b in attribute.elements() {
            string attName = (b/<ns:Name>/*).toString();
            string attValue = (b/<ns:Value>/*).toString();
            attributes[attName] = attValue;
            i = i + 1;
        }
    } else {
        string attName = (attribute/<ns:Name>/*).toString();
        string attValue = (attribute/<ns:Value>/*).toString();
        attributes[attName] = attValue;
    }
    return attributes;
}

isolated function xmlToInboundMessageMessageAttributes(xml msgAttributes) 
        returns map<MessageAttributeValue>|DataMappingError {
    map<MessageAttributeValue> messageAttributes = {};
    string messageAttributeName = "";
    MessageAttributeValue messageAttributeValue;
    if (msgAttributes.elements().length() != 1) {
        int i = 0;
        foreach var b in msgAttributes.elements() {
            [string, MessageAttributeValue]|DataMappingError resXml =
                xmlToInboundMessageMessageAttribute(b.elements());
            if (resXml is [string, MessageAttributeValue]) {
                [messageAttributeName, messageAttributeValue] = resXml;
            } else {
                return error DataMappingError(CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED_MSG, resXml);
            }
            messageAttributes[messageAttributeName] = messageAttributeValue;
            i = i + 1;
        }
    } else {
        [string, MessageAttributeValue]|DataMappingError resXml = xmlToInboundMessageMessageAttribute(msgAttributes);
        if (resXml is [string, MessageAttributeValue]) {
            [messageAttributeName, messageAttributeValue] = resXml;
        } else {
            return error DataMappingError(CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED_MSG, resXml);
        }
        messageAttributes[messageAttributeName] = messageAttributeValue;
    }
    return messageAttributes;
}

isolated function xmlToInboundMessageMessageAttribute(xml msgAttribute) 
        returns ([string, MessageAttributeValue]|DataMappingError) {
    string msgAttributeName = (msgAttribute/<ns:Name>/*).toString();
    xml msgAttributeValue = msgAttribute/<ns:Value>;
    string[] binaryListValues; 
    string[] stringListValues;
    [string[], string[]]|error strListVals = xmlMessageAttributeValueToListValues(msgAttributeValue);
    if (strListVals is [string[], string[]]) {
        [binaryListValues, stringListValues] = strListVals;
        MessageAttributeValue messageAttributeValue = {
            binaryListValues: binaryListValues,
            binaryValue: (msgAttributeValue/<ns:BinaryValue>/*).toString(),
            dataType: (msgAttributeValue/<ns:DataType>/*).toString(),
            stringListValues: stringListValues,
            stringValue: (msgAttributeValue/<ns:StringValue>/*).toString()
        };
        return [msgAttributeName, messageAttributeValue];
    } else {
        return error DataMappingError(CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTE_FAILED_MSG, strListVals);
    }
}

isolated function xmlMessageAttributeValueToListValues(xml msgAttributeVal) 
        returns ([string[], string[]]|DataMappingError) {
    string[] binaryListValues = [];
    string[] stringListValues = [];

    // BinaryListValue.N and StringListValue.N arrays for MessageAttributeValue
    // are not yet implemented in the Amazon SQS specification in, 
    // https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_MessageAttributeValue.html
    // This method has to be implemented once the Amazon SQS specification implements them.

    return [binaryListValues, stringListValues];
}

isolated function isXmlDeleteResponse(xml response) returns OperationError? {
    xmllib:Element topElement = <xmllib:Element> response;
    string topElementName = topElement.getName();
    if (topElementName.endsWith("DeleteMessageResponse")) {
        return ();
    } else {
        return error OperationError(OPERATION_ERROR_MSG);
    }
}

isolated function isXmlDeleteQueueResponse(xml response) returns OperationError? {
    xmllib:Element topElement = <xmllib:Element> response;
    string topElementName = topElement.getName();
    if (topElementName.endsWith("DeleteQueueResponse")) {
        return ();
    } else {
        return error OperationError(OPERATION_ERROR_MSG);
    }
}

isolated function read(string path) returns @tainted json|FileReadFailed {
    io:ReadableByteChannel|error readableByteChannel = io:openReadableFile(path);
    if (readableByteChannel is io:ReadableByteChannel) {
        io:ReadableCharacterChannel readableChannel = new(readableByteChannel, "UTF8");
        var result = readableChannel.readJson();
        if (result is error) {
            FileReadFailed? err = closeReadableChannel(readableChannel);
            return error FileReadFailed(FILE_READ_FAILED_MSG, result);
        } else {
            FileReadFailed? err = closeReadableChannel(readableChannel);
            if (err is error) {
                return error FileReadFailed(FILE_READ_FAILED_MSG, err);
            } else {
                return result;
            }
        }
    } else {
        return error FileReadFailed(FILE_READ_FAILED_MSG, readableByteChannel);
    }
}

isolated function closeReadableChannel(io:ReadableCharacterChannel readableChannel) returns FileReadFailed? {
    var result = readableChannel.close();
    if (result is error) {
        return error FileReadFailed(CLOSE_CHARACTER_STREAM_FAILED_MSG, result);
    }
}
