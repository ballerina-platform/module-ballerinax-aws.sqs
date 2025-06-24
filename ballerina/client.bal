// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerina/jballerina.java;

# The Amazon SQS API Client.
#
# This client provides access to Amazon Simple Queue Service (SQS) API using AWS SDK for Java V2.
# The connector supports static credentials and profile-based credentials.
#
public isolated client class Client {


    # Initializes the Amazon SQS client with the provided connection configuration
    #
    # + connectionConfig - The Amazon SQS client configuration
    # + return - The `sqs:Client` or `sqs:Error` if initialization fails
    public isolated function init(*ConnectionConfig connectionConfig) returns Error? {
        return self.externInit(connectionConfig);
    }

    isolated function externInit(ConnectionConfig connectionConfig)
    returns Error? = @java:Method {
        name: "init",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;
        
    # Delivers a message to the specified SQS queue.
    # 
    # + queueUrl - The URL of the Amazon SQS queue to which the message is sent. Queue URLs and names are case-sensitive.
    # + messageBody - The message to send.The minimum message size is 1 byte (1 character). The maximum is 262,144 bytes (256 KiB).
    # + sendMessageConfig - Optional parameters such as `delaySeconds`, `messageAttributes`, `messageSystemAttributes`, `messageDeduplicationId`and `messageGroupId`.
    # + return - A `SendMessageResponse` record on success, or an `Error` on failure.
    remote isolated function sendMessage(string queueUrl, string messageBody, *SendMessageConfig sendMessageConfig)
    returns SendMessageResponse|Error {
        
        return self.externSendMessage(queueUrl, messageBody, sendMessageConfig);
    }

    isolated function externSendMessage(string queueUrl, string messageBody, *SendMessageConfig sendMessageConfig)
    returns SendMessageResponse|Error = @java:Method {
        name: "sendMessage",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    }external;

    # Retrieves one or more messages from the specified queue
    # 
    # + queueUrl - The URL of the Amazon SQS queue from which messages are received
    # + receiveMessageConfig - Optional parameters for receiving messages
    # + return - An array of `Message` records or an `Error`
    remote isolated function receiveMessage(string queueUrl, *ReceiveMessageConfig receiveMessageConfig)
        returns Message[]|Error {
        return self.externReceiveMessage(queueUrl, receiveMessageConfig);
    }

    isolated function externReceiveMessage(string queueUrl, *ReceiveMessageConfig receiveMessageConfig)
        returns Message[]|Error = @java:Method {
        name: "receiveMessage",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Deletes a specified message from an Amazon SQS queue using the given receipt handle
    # 
    # + queueUrl - The URL of the Amazon SQS queue from which messages are deleted
    # + receiptHandle - The receipt handle associated with the message to delete
    # + return - `Error` on failure
    remote isolated function deleteMessage(string queueUrl, string receiptHandle) returns Error? {
        return self.externDeleteMessage(queueUrl, receiptHandle);
    }

    isolated function externDeleteMessage(string queueUrl, string receiptHandle) returns Error? = @java:Method {
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor",
        name: "deleteMessage"
    } external;

    # Sends up to 10 messages as a batch to the specified Amazon SQS queue
    #
    # + queueUrl - The URL of the Amazon SQS queue to which batched messages are sent. Queue URLs and names are case-sensitive
    # + entries - A list of `SendMessageBatchEntry` items
    # + return - A `SendMessageBatchResponse` indicating which messages succeeded or failed and `Error` on failure
    isolated remote function sendMessageBatch(string queueUrl, SendMessageBatchEntry[] entries)
        returns SendMessageBatchResponse|Error {
        return self.externSendMessageBatch(queueUrl, entries);
    }

    isolated function externSendMessageBatch(string queueUrl, SendMessageBatchEntry[] entries) 
        returns SendMessageBatchResponse|Error = @java:Method {
        name: "sendMessageBatch",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Deletes up to ten messages from the specified queue. This is a batch version of `DeleteMessage`. The result of the
    #  action on each message is reported individually in the response.
    #
    # + queueUrl - The URL of the Amazon SQS queue from which messages are deleted. Queue URLs and names are case-sensitive.
    # + entries - List of the receipt handles of the messages to be deleted.
    # + return - A `DeleteMessageBatchResponse` indicating which deletions succeeded or failed and `Error` on failure.
    isolated remote function deleteMessageBatch(string queueUrl, DeleteMessageBatchEntry[] entries)
        returns DeleteMessageBatchResponse|Error {
        return self.externDeleteMessageBatch(queueUrl,entries);
    }

    isolated function externDeleteMessageBatch(string queueUrl, DeleteMessageBatchEntry[] entries) returns DeleteMessageBatchResponse|Error = @java:Method {
        name: "deleteMessagebatch",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;






    # Gracefully closes AWS SQS API client resources
    #
    # + return - An `Error` if there is an error while closing the client resources or else nil
    remote isolated function close() returns Error? = @java:Method {
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;
}

