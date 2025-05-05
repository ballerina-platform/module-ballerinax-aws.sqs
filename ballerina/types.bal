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

import ballerinax/'client.config;

# Represents the AWS SQS Connector configurations.
#
@display {label: "Connection Config"}
public type ConnectionConfig record {|
    *config:ConnectionConfig;
    # Authentication mechanism (not used in this configuration)
    never auth?;
    # AccessKey of Amazon Account
    string accessKey;
    # SecretKey of Amazon Account
    @display{
        label: "",
        kind: "password"
    } 
    string secretKey;
    # Region of SQS Queue
    string region;
|};

# Queue attribute
#
# + delaySeconds - Delay seconds
# + maximumMessageSize - Maximum message size
# + messageRetentionPeriod - Time Amazon SQS retains a message
# + policy - Valid AWS queue policy
# + receiveMessageWaitTimeSeconds - Time receiveMessage action waits for a message to arrive
# + visibilityTimeout - Visibility timeout for the queue
# + contentBasedDeduplication - Enables content-based deduplication
# + fifoQueue - Designates a queue as FIFO
# + kmsMasterKeyId - ID of an AWS managed customer master key
# + kmsDataKeyReusePeriodSeconds - Time that Amazon SQS can reuse a data key to encrypt or decrypt messages
# + deduplicationScope - Specifies whether message deduplication occurs at the message group or queue level
# + fifoThroughputLimit - Specifies whether the FIFO queue throughput quota applies to the entire queue or per message group
# + redrivePolicy - Parameters for the dead-letter queue functionality of the source queue 
# + redriveAllowPolicy - Permissions for the dead-letter queue redrive permission
public type QueueAttributes record {
    int delaySeconds?;
    int maximumMessageSize?;
    int messageRetentionPeriod?;
    string policy?;
    int receiveMessageWaitTimeSeconds?;    
    int visibilityTimeout?;
    boolean contentBasedDeduplication?;
    boolean fifoQueue?;
    string kmsMasterKeyId?;
    int kmsDataKeyReusePeriodSeconds?;
    string deduplicationScope?;
    string fifoThroughputLimit?;
    json redrivePolicy?;
    json redriveAllowPolicy?;
};

# Create queue response
#
# + createQueueResult - Result of queue creation
# + responseMetadata - Response metadata
public type CreateQueueResponse record {
    CreateQueueResult createQueueResult;
    ResponseMetadata responseMetadata;
};

# Create queue result
#
# + queueUrl - Url of the queue
public type CreateQueueResult record {
    string queueUrl;
};

# Send message response
#
# + sendMessageResult - Result of send message
# + responseMetadata - Response metadata
public type SendMessageResponse record {
    SendMessageResult sendMessageResult;
    ResponseMetadata responseMetadata;
};

# Send message result
#
# + md5OfMessageAttributes - MD5 of message attributes sent to sendMessage method
# + md5OfMessageBody - MD5 of message body sent to sendMessage method
# + messageId - Message ID for the message sent to sendMessage method
# + sequenceNumber - Sequence number of the sent message
public type SendMessageResult record {
    string md5OfMessageAttributes?;
    string md5OfMessageBody;
    string messageId;
    string sequenceNumber?;
};

# Delete message response
#
# + responseMetadata - Response metadata
public type DeleteMessageResponse record {
    ResponseMetadata responseMetadata;
};

# Delete queue response
#
# + responseMetadata - Response metadata
public type DeleteQueueResponse record {
    ResponseMetadata responseMetadata;
};

# Response metadata
#
# + requestId - Request id of response
public type ResponseMetadata record {
    string requestId;
};

# Response message for sendMessage method
#
# + md5OfMessageAttributes - MD5 of message attributes sent to sendMessage method
# + md5OfMessageBody - MD5 of message body sent to sendMessage method
# + messageId - Message ID for the message sent to sendMessage method
# + sequenceNumber - Sequence number of the sent message
public type OutboundMessage record {
    string md5OfMessageAttributes?;
    string md5OfMessageBody;
    string messageId;
    string sequenceNumber?;
};

# Response message for receiveMessage method
#
# + attributes - Attribute parameters got from receiveMessage method 
# + body - Message body got from receiveMessage method 
# + md5OfBody - MD5 of message body got from receiveMessage method
# + md5OfMessageAttributes - MD5 of message attributes got from receiveMessage method
# + messageAttributes - Message Attribute parameters got from receiveMessage method 
# + messageId - Message ID for the message got from receiveMessage method
# + receiptHandle - Receipt Handle of the message got from receiveMessage method
public type InboundMessage record {
    map<string> attributes;
    string body;
    string md5OfBody;
    string md5OfMessageAttributes;
    map<MessageAttributeValue> messageAttributes;
    string messageId;
    string receiptHandle;
};

# Receive message response
#
# + receiveMessageResult - Result of receive message
# + responseMetadata - Response metadata
public type ReceiveMessageResponse record {
    ReceiveMessageResult receiveMessageResult;
    ResponseMetadata responseMetadata;
};

# Receive message result
#
# + message - Collection of received messages
public type ReceiveMessageResult record {
    InboundMessage[] message;
};

# Data defined in a message attribute
#
# + keyName - Key name
# + value - Message attribute values
public type MessageAttribute record {
    string keyName;
    MessageAttributeValues value;
};

# Data defined in a message attribute value
#
# + stringValue - String value
# + dataType - Data type
public type MessageAttributeValues record {
    string stringValue;
    string dataType;
};

# Data parameters defined in a MessageAttributeValue parameter
#
# + binaryListValues - Array of Base64-encoded binary data objects. Reserved for future use.
# + binaryValue - Base64-encoded binary data object. Binary type attributes can store any binary data, such as compressed data, encrypted data, or images. 
# + dataType - Supports the following logical data types: String, Number, and Binary. For the Number data type, you must use StringValue.
# + stringListValues - Array of strings. Reserved for future use.
# + stringValue - String values of Unicode with UTF-8 binary encoding.
public type MessageAttributeValue record {
    string[] binaryListValues;
    string binaryValue;
    string dataType;
    string[] stringListValues;
    string stringValue;
};
