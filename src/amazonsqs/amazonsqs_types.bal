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

# Response message for sendMessage method
#
# + MD5OfMessageAttributes - MD5 of message attributes sent to sendMessage method
# + MD5OfMessageBody - MD5 of message body sent to sendMessage method
# + messageId - Message ID for the message sent to sendMessage method
# + sequenceNumber - Sequence number of the sent message
public type OutboundMessage record {|
    string MD5OfMessageAttributes;
    string MD5OfMessageBody;
    string messageId;
    string sequenceNumber;
|};

# Response message for receiveMessage method
#
# + attributes - Parameters got from receiveMessage method 
# + body - Message body got from receiveMessage method 
# + MD5OfBody - MD5 of message body got from receiveMessage method
# + MD5OfMessageAttributes - MD5 of message attributes got from receiveMessage method
# + messageAttributes - Message Attribute parameters got from receiveMessage method 
# + messageId - Message ID for the message got from receiveMessage method
# + receiptHandle - Receipt Handle of the message got from receiveMessage method
public type InboundMessage record {|
    map<string> attributes = {};
    string body;
    string MD5OfBody;
    string MD5OfMessageAttributes;
    map<MessageAttributeValue> messageAttributes;
    string messageId;
    string receiptHandle;
|};

# Data parameters defined in a MessageAttributeValue parameter
#
# + binaryListValues - Array of Base64-encoded binary data objects. Reserved for future use.
# + binaryValue - Base64-encoded binary data object. Binary type attributes can store any binary data, such as compressed data, encrypted data, or images. 
# + dataType - Supports the following logical data types: String, Number, and Binary. For the Number data type, you must use StringValue.
# + stringListValues - Array of strings. Reserved for future use.
# + stringValue - Strings are Unicode with UTF-8 binary encoding.
public type MessageAttributeValue record {|
    string[] binaryListValues;
    string binaryValue;
    string dataType;
    string[] stringListValues;
    string stringValue;
|};
