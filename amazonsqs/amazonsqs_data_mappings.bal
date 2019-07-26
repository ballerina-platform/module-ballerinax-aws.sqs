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

import ballerina/log;
import ballerina/io;

function jsonToCreatedQueueUrl(json source) returns string {
    json queueUrl = source.CreateQueueResponse.CreateQueueResult.QueueUrl;
    return queueUrl != null ? queueUrl.toString() : EMPTY_STRING;
}

function jsonToOutboundMessage(json source) returns OutboundMessage {
    json msgSource = source.SendMessageResponse.SendMessageResult != null ? 
        source.SendMessageResponse.SendMessageResult : {};

    string MD5OfMessageAttributes = msgSource.MD5OfMessageAttributes != null ? msgSource.MD5OfMessageAttributes.toString() : EMPTY_STRING;
    string MD5OfMessageBody = msgSource.MD5OfMessageBody != null ? msgSource.MD5OfMessageBody.toString() : EMPTY_STRING;
    string messageId = msgSource.MessageId != null ? msgSource.MessageId.toString() : EMPTY_STRING;
    string sequenceNumber = msgSource.SequenceNumber != null ? msgSource.SequenceNumber.toString() : EMPTY_STRING;
    OutboundMessage sentMessage = {
        MD5OfMessageAttributes: MD5OfMessageAttributes,
        MD5OfMessageBody: MD5OfMessageBody,
        messageId: messageId,
        sequenceNumber: sequenceNumber
    };
    return sentMessage;
}

function jsonToInboundMessages(json source) returns InboundMessage[]|error {
    json messages = source.ReceiveMessageResponse.ReceiveMessageResult.Message;

    InboundMessage[] receivedMessages = [];
    if (messages is json[]) {
        int l = messages.length();
        int i = 0;
        while (i < l) {
            receivedMessages[i] = check jsonToInboundMessage(messages[i]);
            i = i + 1;
        }
        return receivedMessages;
    } else {
        return [check jsonToInboundMessage(messages)];
    }
}

function jsonToInboundMessage(json message) returns InboundMessage|error {
    json attribute = message.Attribute != null ? message.Attribute : {};

    map<string> attributes = jsonToInboundMessageAttributes(attribute);
    string body = message.Body != null ? message.Body.toString() : EMPTY_STRING;
    string MD5OfBody = message.MD5OfBody != null ? message.MD5OfBody.toString() : EMPTY_STRING;
    string MD5OfMessageAttributes = message.MD5OfMessageAttributes != null ? message.MD5OfMessageAttributes.toString() : EMPTY_STRING;
    json msgAttribute = message.MessageAttribute != null ? message.MessageAttribute : {};

    map<MessageAttributeValue> messageAttributes = check jsonToInboundMessageMessageAttributes(msgAttribute);
    string messageId = message.MessageId != null ? message.MessageId.toString() : EMPTY_STRING;
    string receiptHandle = message.ReceiptHandle != null ? message.ReceiptHandle.toString() : EMPTY_STRING;
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
}

function jsonToInboundMessageAttributes(json attribute) returns map<string> {
    map<string> attributes = {};
    if (attribute is json[]) {
        int l = attribute.length();
        int i = 0;
        while (i < l) {
            string attName = attribute[i].Name.toString();
            string attValue = attribute[i].Value.toString();
            attributes[attName] = attValue;
            i = i + 1;
        }
    } else {
        string attName = attribute.Name != null ? attribute.Name.toString() : EMPTY_STRING;
        string attValue = attribute.Value != null ? attribute.Value.toString() : EMPTY_STRING;
        attributes[attName] = attValue;
    }
    return attributes;
}

function jsonToInboundMessageMessageAttributes(json msgAttributes) returns map<MessageAttributeValue>|error {
    map<MessageAttributeValue> messageAttributes = {};
    string messageAttributeName = "";
    MessageAttributeValue messageAttributeValue;
    if (msgAttributes is json[]) {
        int l = msgAttributes.length();
        int i = 0;
        while (i < l) {
            (messageAttributeName, messageAttributeValue) = check jsonToInboundMessageMessageAttribute(msgAttributes[i]);
            messageAttributes[messageAttributeName] = messageAttributeValue;
            i = i + 1;
        }
    } else {
        (messageAttributeName, messageAttributeValue) = check jsonToInboundMessageMessageAttribute(msgAttributes);
        messageAttributes[messageAttributeName] = messageAttributeValue;
    }
    return messageAttributes;
}

function jsonToInboundMessageMessageAttribute(json msgAttribute) returns (string, MessageAttributeValue)|error {

    string msgAttributeName = msgAttribute.Name != null ? msgAttribute.Name.toString() : EMPTY_STRING;
    json msgAttributeValue = msgAttribute.Value != null ? msgAttribute.Value : {};
    string[] binaryListValues; 
    string[] stringListValues;
    (binaryListValues, stringListValues) = check jsonMessageAttributeValueToListValues(msgAttributeValue);

    string binaryValue = msgAttributeValue.BinaryValue != null ? msgAttributeValue.BinaryValue.toString() : EMPTY_STRING;
    string dataType = msgAttributeValue.DataType != null ? msgAttributeValue.DataType.toString() : EMPTY_STRING;
    string stringValue = msgAttributeValue.StringValue != null ? msgAttributeValue.StringValue.toString() : "String";

    MessageAttributeValue messageAttributeValue = {
        binaryListValues: binaryListValues,
        binaryValue: msgAttributeValue.BinaryValue != null ? msgAttributeValue.BinaryValue.toString() : EMPTY_STRING,
        dataType: msgAttributeValue.DataType != null ? msgAttributeValue.DataType.toString() : EMPTY_STRING,
        stringListValues: stringListValues,
        stringValue: msgAttributeValue.StringValue != null ? msgAttributeValue.StringValue.toString() : EMPTY_STRING 
    };
    return (msgAttributeName, messageAttributeValue);

}

function jsonMessageAttributeValueToListValues(json msgAttributeVal) returns (string[], string[])|error {
    string[] binaryListValues = [];
    string[] stringListValues = [];

    map<json> msgAttributeValMap = <map<json>> map<json>.convert(msgAttributeVal);
    foreach var (k, v) in msgAttributeValMap {
        string[] attribVal = k.split(".");
        if (attribVal.length() > 0 && attribVal[0] == "BinaryListValue" && check attribVal[1].matches("\\d+")) {
            binaryListValues[check int.convert(attribVal[1])] = v.toString();
        } else if (attribVal.length() > 0 && attribVal[0] == "StringListValue" && check attribVal[1].matches("\\d+")) {
            stringListValues[check int.convert(attribVal[1])] = v.toString();
        }
    }
    return (binaryListValues, stringListValues);
}

function read(string path) returns json|error {
    io:ReadableByteChannel rbc = io:openReadableFile(path);
    io:ReadableCharacterChannel rch = new(rbc, "UTF8");
    var result = rch.readJson();
    if (result is error) {
        closeRc(rch);
        return result;
    } else {
        closeRc(rch);
        return result;
    }
}

function closeRc(io:ReadableCharacterChannel rc) {
    var result = rc.close();
    if (result is error) {
        log:printError("Error occurred while closing character stream", err = result);
    }
}
