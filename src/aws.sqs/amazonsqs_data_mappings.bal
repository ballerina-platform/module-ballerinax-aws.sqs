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

import ballerina/io;
import ballerina/lang.'xml as xmllib;

xmlns "http://queue.amazonaws.com/doc/2012-11-05/" as ns;

function xmlToCreatedQueueUrl(xml response) returns string {
    string|error queueUrl = (response/<ns:CreateQueueResult>/<ns:QueueUrl>/*).toString();
    if (queueUrl is string) {
        return queueUrl != "" ? queueUrl.toString() : EMPTY_STRING;
    } else {
        return "";
    }
}

function xmlToOutboundMessage(xml response) returns OutboundMessage|ErrorDataMapping {
    xml msgSource = response[ns:SendMessageResult];
    if (msgSource.toString() != "") {
        OutboundMessage sentMessage = {
            md5OfMessageAttributes: (msgSource/<ns:MD5OfMessageAttributes>/*).toString(),
            md5OfMessageBody: (msgSource/<ns:MD5OfMessageBody>/*).toString(),
            messageId: (msgSource/<ns:MessageId>/*).toString(),
            sequenceNumber: (msgSource/<ns:SequenceNumber>/*).toString()
        };
        return sentMessage;
    } else {
        return error(ERROR_DATA_MAPPING, errorCode = CONVERT_XML_TO_OUTBOUND_MESSAGE_FAILED,
            message = OUTBOUND_MESSAGE_RESPONSE_EMPTY_MSG);
    }
}

function xmlToInboundMessages(xml response) returns InboundMessage[]|ErrorDataMapping {
    xml messages = response[ns:ReceiveMessageResult][ns:Message];
    InboundMessage[] receivedMessages = [];
    if (messages.elements().length() != 1) {
        int i = 0;
        foreach var b in messages.elements() {
            if (b is xml) {
                InboundMessage|ErrorDataMapping receivedMsg = xmlToInboundMessage(b.elements());
                if (receivedMsg is InboundMessage) {
                    receivedMessages[i] = receivedMsg;
                } else {
                    return error(ERROR_DATA_MAPPING,
                        message = CONVERT_XML_TO_INBOUND_MESSAGES_FAILED_MSG, 
                            errorCode = CONVERT_XML_TO_INBOUND_MESSAGES_FAILED, cause = receivedMsg);
                }
                i = i + 1;
            }
        }
        return receivedMessages;
    } else {
        InboundMessage|ErrorDataMapping receivedMsg = xmlToInboundMessage(messages);
        if (receivedMsg is InboundMessage) {
            return [receivedMsg]; 
        } else {
            return error(ERROR_DATA_MAPPING,
                message = CONVERT_XML_TO_INBOUND_MESSAGES_FAILED_MSG, 
                    errorCode = CONVERT_XML_TO_INBOUND_MESSAGES_FAILED, cause = receivedMsg);
        }
    }
}

function xmlToInboundMessage(xml message) returns InboundMessage|ErrorDataMapping {
    xml attribute = message[ns:Attribute];
    xml msgAttribute = message[ns:MessageAttribute];

    map<MessageAttributeValue>|ErrorDataMapping messageAttributes = xmlToInboundMessageMessageAttributes(msgAttribute);
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
        return error(ERROR_DATA_MAPPING,
            message = CONVERT_XML_TO_INBOUND_MESSAGE_FAILED_MSG, errorCode = CONVERT_XML_TO_INBOUND_MESSAGE_FAILED, 
                cause = messageAttributes);
    }
}

function xmlToInboundMessageAttributes(xml attribute) returns map<string> {
    map<string> attributes = {};
    if (attribute.elements().length() != 1) {
        int i = 0;
        foreach var b in attribute.elements() {
            if (b is xml) {
                string attName = (b/<ns:Name>/*).toString();
                string attValue = (b/<ns:Value>/*).toString();
                attributes[attName] = attValue;
                i = i + 1;
            }
        }
    } else {
        string attName = (attribute/<ns:Name>/*).toString();
        string attValue = (attribute/<ns:Value>/*).toString();
        attributes[attName] = attValue;
    }
    return attributes;
}

function xmlToInboundMessageMessageAttributes(xml msgAttributes) 
        returns map<MessageAttributeValue>|ErrorDataMapping {
    map<MessageAttributeValue> messageAttributes = {};
    string messageAttributeName = "";
    MessageAttributeValue messageAttributeValue;
    if (msgAttributes.elements().length() != 1) {
        int i = 0;
        foreach var b in msgAttributes.elements() {
            if (b is xml) {
                [string, MessageAttributeValue]|ErrorDataMapping resXml =
                    xmlToInboundMessageMessageAttribute(b.elements());
                if (resXml is [string, MessageAttributeValue]) {
                    [messageAttributeName, messageAttributeValue] = resXml;
                } else {
                    return error(ERROR_DATA_MAPPING,
                        message = CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED_MSG, 
                            errorCode = CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED, cause = resXml);
                }
                messageAttributes[messageAttributeName] = messageAttributeValue;
                i = i + 1;
            }
        }
    } else {
        [string, MessageAttributeValue]|ErrorDataMapping resXml = xmlToInboundMessageMessageAttribute(msgAttributes);
        if (resXml is [string, MessageAttributeValue]) {
            [messageAttributeName, messageAttributeValue] = resXml;
        } else {
            return error(ERROR_DATA_MAPPING,
                message = CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED_MSG, errorCode = 
                    CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED, cause = resXml);
        }
        messageAttributes[messageAttributeName] = messageAttributeValue;
    }
    return messageAttributes;
}

function xmlToInboundMessageMessageAttribute(xml msgAttribute) 
        returns ([string, MessageAttributeValue]|ErrorDataMapping) {
    string msgAttributeName = (msgAttribute/<ns:Name>/*).toString();
    xml msgAttributeValue = msgAttribute[ns:Value];
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
        return error(ERROR_DATA_MAPPING,
            message = CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTE_FAILED_MSG, 
                errorCode = CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTE_FAILED, cause = strListVals);
    }
}

function xmlMessageAttributeValueToListValues(xml msgAttributeVal) 
        returns ([string[], string[]]|ErrorDataMapping) {
    string[] binaryListValues = [];
    string[] stringListValues = [];

    // BinaryListValue.N and StringListValue.N arrays for MessageAttributeValue
    // are not yet implemented in the Amazon SQS specification in, 
    // https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_MessageAttributeValue.html
    // This method has to be implemented once the Amazon SQS specification implements them.

    return [binaryListValues, stringListValues];
}

function isXmlDeleteResponse(xml response) returns boolean {
    xmllib:Element topElement = <xmllib:Element> response;
    string topElementName = topElement.getName();
    if (topElementName.endsWith("DeleteMessageResponse")) {
        return true ;
    } else {
        return false;
    }
}

function read(string path) returns @tainted json|FileReadFailed {
    io:ReadableByteChannel|error readableByteChannel = io:openReadableFile(path);
    if (readableByteChannel is io:ReadableByteChannel) {
        io:ReadableCharacterChannel readableChannel = new(readableByteChannel, "UTF8");
        var result = readableChannel.readJson();
        if (result is error) {
            FileReadFailed? err = closeReadableChannel(readableChannel);
            return error(FILE_READ_FAILED, message = FILE_READ_FAILED_MSG, errorCode = FILE_READ_FAILED, cause = result);
        } else {
            FileReadFailed? err = closeReadableChannel(readableChannel);
            if (err is error) {
                return error(FILE_READ_FAILED, message = FILE_READ_FAILED_MSG, errorCode = FILE_READ_FAILED, cause = err);
            } else {
                return result;
            }
        }
    } else {
        return error(FILE_READ_FAILED, message = FILE_READ_FAILED_MSG, errorCode = FILE_READ_FAILED, cause = readableByteChannel);
    }
}

function closeReadableChannel(io:ReadableCharacterChannel readableChannel) returns FileReadFailed? {
    var result = readableChannel.close();
    if (result is error) {
        return error(FILE_READ_FAILED, message = CLOSE_CHARACTER_STREAM_FAILED_MSG, errorCode = FILE_READ_FAILED, cause = result);
    }
}
