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

function xmlToCreatedQueueUrl(xml response) returns string {
    xmlns "http://queue.amazonaws.com/doc/2012-11-05/" as ns1;
    string|error queueUrl = response[ns1:CreateQueueResult][ns1:QueueUrl].getTextValue();
    if (queueUrl is string) {
        return queueUrl != "" ? queueUrl.toString() : EMPTY_STRING;
    } else {
        return "";
    }
}

function xmlToOutboundMessage(xml response) returns OutboundMessage|DataMappingError {
    xmlns "http://queue.amazonaws.com/doc/2012-11-05/" as ns1;
    xml msgSource = response[ns1:SendMessageResult];
    if (!msgSource.isEmpty()) {
        string MD5OfMessageAttributes = msgSource[ns1:MD5OfMessageAttributes].getTextValue();
        string MD5OfMessageBody = msgSource[ns1:MD5OfMessageBody].getTextValue();
        string messageId = msgSource[ns1:MessageId].getTextValue();
        string sequenceNumber = msgSource[ns1:SequenceNumber].getTextValue();
        OutboundMessage sentMessage = {
            MD5OfMessageAttributes: MD5OfMessageAttributes,
            MD5OfMessageBody: MD5OfMessageBody,
            messageId: messageId,
            sequenceNumber: sequenceNumber
        };
        return sentMessage;
    } else {
        return error(DATA_MAPPING_ERROR, errorCode = CONVERT_XML_TO_OUTBOUND_MESSAGE_FAILED, 
            message = OUTBOUND_MESSAGE_RESPONSE_EMPTY_MSG);
    }
}

function xmlToInboundMessages(xml response) returns InboundMessage[]|DataMappingError {
    xmlns "http://queue.amazonaws.com/doc/2012-11-05/" as ns1;
    xml messages = response[ns1:ReceiveMessageResult][ns1:Message];
    InboundMessage[] receivedMessages = [];
    if (!messages.isSingleton()) {
        int i = 0;
        foreach var b in messages.elements() {
            if (b is xml) {
                InboundMessage|DataMappingError receivedMsg = xmlToInboundMessage(b.elements());
                if (receivedMsg is InboundMessage) {
                    receivedMessages[i] = receivedMsg;
                } else {
                    return error(DATA_MAPPING_ERROR, 
                        message = CONVERT_XML_TO_INBOUND_MESSAGES_FAILED_MSG, 
                            errorCode = CONVERT_XML_TO_INBOUND_MESSAGES_FAILED, cause = receivedMsg);
                }
                i = i + 1;
            }
        }
        return receivedMessages;
    } else {
        InboundMessage|DataMappingError receivedMsg = xmlToInboundMessage(messages);
        if (receivedMsg is InboundMessage) {
            return [receivedMsg]; 
        } else {
            return error(DATA_MAPPING_ERROR, 
                message = CONVERT_XML_TO_INBOUND_MESSAGES_FAILED_MSG, 
                    errorCode = CONVERT_XML_TO_INBOUND_MESSAGES_FAILED, cause = receivedMsg);
        }
    }
}

function xmlToInboundMessage(xml message) returns InboundMessage|DataMappingError {
    xmlns "http://queue.amazonaws.com/doc/2012-11-05/" as ns1;
    xml attribute = message[ns1:Attribute];

    map<string> attributes = xmlToInboundMessageAttributes(attribute);
    string body = message[ns1:Body].getTextValue();
    string MD5OfBody = message[ns1:MD5OfBody].getTextValue();
    string MD5OfMessageAttributes = message[ns1:MD5OfMessageAttributes].getTextValue();
    xml msgAttribute = message[ns1:MessageAttribute];

    map<MessageAttributeValue>|DataMappingError messageAttributes = xmlToInboundMessageMessageAttributes(msgAttribute);
    if (messageAttributes is map<MessageAttributeValue>) {
        string messageId = message[ns1:MessageId].getTextValue();
        string receiptHandle = message[ns1:ReceiptHandle].getTextValue();
        InboundMessage receivedMessage = {
            attributes: attributes,
            body: body,
            MD5OfBody: MD5OfBody,
            MD5OfMessageAttributes: MD5OfMessageAttributes,
            messageAttributes: messageAttributes,
            messageId: messageId,
            receiptHandle: receiptHandle
        };
        return receivedMessage;
    } else {
        return error(DATA_MAPPING_ERROR, 
            message = CONVERT_XML_TO_INBOUND_MESSAGE_FAILED_MSG, errorCode = CONVERT_XML_TO_INBOUND_MESSAGE_FAILED, 
                cause = messageAttributes);
    }
}

function xmlToInboundMessageAttributes(xml attribute) returns map<string> {
    xmlns "http://queue.amazonaws.com/doc/2012-11-05/" as ns1;
    map<string> attributes = {};
    if (!attribute.isSingleton()) {
        int i = 0;
        foreach var b in attribute.elements() {
            if (b is xml) {
                string attName = b[ns1:Name].getTextValue();
                string attValue = b[ns1:Value].getTextValue();
                attributes[attName] = attValue;
                i = i + 1;
            }
        }
    } else {
        string attName = attribute[ns1:Name].getTextValue();
        string attValue = attribute[ns1:Value].getTextValue();
        attributes[attName] = attValue;
    }
    return attributes;
}

function xmlToInboundMessageMessageAttributes(xml msgAttributes) 
    returns map<MessageAttributeValue>|DataMappingError {
    map<MessageAttributeValue> messageAttributes = {};
    string messageAttributeName = "";
    MessageAttributeValue messageAttributeValue;
    if (!msgAttributes.isSingleton()) {
        int i = 0;
        foreach var b in msgAttributes.elements() {
            if (b is xml) {
                [string, MessageAttributeValue]|DataMappingError resXml = 
                    xmlToInboundMessageMessageAttribute(b.elements());
                if (resXml is [string, MessageAttributeValue]) {
                    [messageAttributeName, messageAttributeValue] = resXml;
                } else {
                    return error(DATA_MAPPING_ERROR, 
                        message = CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED_MSG, 
                            errorCode = CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED, cause = resXml);
                }
                messageAttributes[messageAttributeName] = messageAttributeValue;
                i = i + 1;
            }
        }
    } else {
        [string, MessageAttributeValue]|DataMappingError resXml = xmlToInboundMessageMessageAttribute(msgAttributes);
        if (resXml is [string, MessageAttributeValue]) {
            [messageAttributeName, messageAttributeValue] = resXml;
        } else {
            return error(DATA_MAPPING_ERROR, 
                message = CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED_MSG, errorCode = 
                    CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTES_FAILED, cause = resXml);
        }
        messageAttributes[messageAttributeName] = messageAttributeValue;
    }
    return messageAttributes;
}

function xmlToInboundMessageMessageAttribute(xml msgAttribute) 
    returns ([string, MessageAttributeValue]|DataMappingError) {
    xmlns "http://queue.amazonaws.com/doc/2012-11-05/" as ns1;
    string msgAttributeName = msgAttribute[ns1:Name].getTextValue();
    xml msgAttributeValue = msgAttribute[ns1:Value];
    string[] binaryListValues; 
    string[] stringListValues;
    [string[], string[]]|error strListVals = xmlMessageAttributeValueToListValues(msgAttributeValue);
    if (strListVals is [string[], string[]]) {
        [binaryListValues, stringListValues] = strListVals;
        string binaryValue = msgAttributeValue[ns1:BinaryValue].getTextValue();
        string dataType = msgAttributeValue[ns1:DataType].getTextValue();
        string stringValue = msgAttributeValue[ns1:StringValue].getTextValue();
        MessageAttributeValue messageAttributeValue = {
            binaryListValues: binaryListValues,
            binaryValue: binaryValue,
            dataType: dataType,
            stringListValues: stringListValues,
            stringValue: stringValue 
        };
        return [msgAttributeName, messageAttributeValue];
    } else {
        return error(DATA_MAPPING_ERROR, 
            message = CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTE_FAILED_MSG, 
                errorCode = CONVERT_XML_TO_INBOUND_MESSAGE_MESSAGE_ATTRIBUTE_FAILED, cause = strListVals);
    }
}

function xmlMessageAttributeValueToListValues(xml msgAttributeVal) 
    returns ([string[], string[]]|DataMappingError) {
    string[] binaryListValues = [];
    string[] stringListValues = [];

    // BinaryListValue.N and StringListValue.N arrays for MessageAttributeValue
    // are not yet implemented in the Amazon SQS specification in, 
    // https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/API_MessageAttributeValue.html
    // This method has to be implemented once the Amazon SQS specification implements them.

    return [binaryListValues, stringListValues];
}

function isXmlDeleteResponse(xml response) returns boolean {
    string topElementName = response.getElementName();
    if (topElementName.endsWith("DeleteMessageResponse")) {
        return true ;
    } else {
        return false;
    }
}

function read(string path) returns @tainted json|FileReadFailed {
    io:ReadableByteChannel|error rbc = io:openReadableFile(path);
    if (rbc is io:ReadableByteChannel) {
        io:ReadableCharacterChannel rch = new(rbc, "UTF8");
        var result = rch.readJson();
        if (result is error) {
            FileReadFailed? err = closeRc(rch);
            return error(FILE_READ_FAILED, message = FILE_READ_FAILED_MSG, errorCode = FILE_READ_FAILED, cause = result);
        } else {
            FileReadFailed? err = closeRc(rch);
            if (err is error) {
                return error(FILE_READ_FAILED, message = FILE_READ_FAILED_MSG, errorCode = FILE_READ_FAILED, cause = err);
            } else {
                return result;
            }
        }
    } else {
        return error(FILE_READ_FAILED, message = FILE_READ_FAILED_MSG, errorCode = FILE_READ_FAILED, cause = rbc);
    }
}

function closeRc(io:ReadableCharacterChannel rc) returns FileReadFailed? {
    var result = rc.close();
    if (result is error) {
        return error(FILE_READ_FAILED, message = CLOSE_CHARACTER_STREAM_FAILED_MSG, errorCode = FILE_READ_FAILED, cause = result);
    }
}
