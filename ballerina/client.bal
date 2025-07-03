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
# Provides access to Amazon Simple Queue Service (SQS) using the AWS SDK for Java V2.
# Supports static and profile-based credential configurations.
public isolated client class Client {

    # Initializes the Amazon SQS client with the provided connection configuration.
    #
    # + connectionConfig - The Amazon SQS client configuration
    # + return - The `sqs:Client` instance or `sqs:Error` if initialization fails
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
    # + queueUrl - URL of the Amazon SQS queue to which the message is sent
    # + messageBody - Message to send; minimum size is 1 byte and maximum is 262,144 bytes (256 KiB)
    # + sendMessageConfig - Optional parameters such as `delaySeconds`, `messageAttributes`, `messageSystemAttributes`, `messageDeduplicationId`, and `messageGroupId`
    # + return - A `sqs:SendMessageResponse` on success, or an `sqs:Error` on failure
    remote isolated function sendMessage(string queueUrl, string messageBody, *SendMessageConfig sendMessageConfig)
    returns SendMessageResponse|Error {
        return self.externSendMessage(queueUrl, messageBody, sendMessageConfig);
    }

    isolated function externSendMessage(string queueUrl, string messageBody, *SendMessageConfig sendMessageConfig)
    returns SendMessageResponse|Error = @java:Method {
        name: "sendMessage",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Retrieves one or more messages from the specified queue.
    #
    # + queueUrl - URL of the Amazon SQS queue from which messages are received
    # + receiveMessageConfig - Optional parameters for receiving messages
    # + return - An array of `sqs:Message` records, or an `sqs:Error` on failure
    remote isolated function receiveMessage(string queueUrl, *ReceiveMessageConfig receiveMessageConfig)
        returns Message[]|Error {
        return self.externReceiveMessage(queueUrl, receiveMessageConfig);
    }

    isolated function externReceiveMessage(string queueUrl, *ReceiveMessageConfig receiveMessageConfig)
        returns Message[]|Error = @java:Method {
        name: "receiveMessage",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Deletes a specified message from an Amazon SQS queue using the given receipt handle.
    #
    # + queueUrl - URL of the Amazon SQS queue from which messages are deleted
    # + receiptHandle - Receipt handle associated with the message to delete
    # + return - An `sqs:Error` if the operation fails
    remote isolated function deleteMessage(string queueUrl, string receiptHandle) returns Error? {
        return self.externDeleteMessage(queueUrl, receiptHandle);
    }

    isolated function externDeleteMessage(string queueUrl, string receiptHandle) returns Error? = @java:Method {
        name: "deleteMessage",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Sends up to 10 messages as a batch to the specified Amazon SQS queue.
    #
    # + queueUrl - URL of the Amazon SQS queue to which batched messages are sent
    # + entries - A list of `sqs:SendMessageBatchEntry` records
    # + return - A `sqs:SendMessageBatchResponse` indicating which messages succeeded or failed, or an `sqs:Error` on failure
    isolated remote function sendMessageBatch(string queueUrl, SendMessageBatchEntry[] entries)
        returns SendMessageBatchResponse|Error {
        return self.externSendMessageBatch(queueUrl, entries);
    }

    isolated function externSendMessageBatch(string queueUrl, SendMessageBatchEntry[] entries)
        returns SendMessageBatchResponse|Error = @java:Method {
        name: "sendMessageBatch",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Deletes up to ten messages from the specified queue. This is a batch version of `sqs:deleteMessage`. 
    # The result of the action on each message is reported individually in the response.
    #
    # + queueUrl - URL of the Amazon SQS queue from which messages are deleted
    # + entries - List of `sqs:DeleteMessageBatchEntry` records containing receipt handles of messages to delete
    # + return - A `sqs:DeleteMessageBatchResponse` indicating which deletions succeeded or failed, or an `sqs:Error` on failure
    isolated remote function deleteMessageBatch(string queueUrl, DeleteMessageBatchEntry[] entries)
        returns DeleteMessageBatchResponse|Error {
        return self.externDeleteMessageBatch(queueUrl, entries);
    }

    isolated function externDeleteMessageBatch(string queueUrl, DeleteMessageBatchEntry[] entries) returns DeleteMessageBatchResponse|Error = @java:Method {
        name: "deleteMessageBatch",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Creates a new Amazon SQS queue with the specified attributes and tags.
    #
    # + queueName - Name of the new queue; valid values include alphanumeric characters, hyphens (-), and underscores 
    # (_), and can be up to 80 characters long. FIFO queue names must end with the `.fifo` suffix
    # + createQueueConfig - Optional configuration such as `queueAttributes` and `tags`
    # + return - URL of the created queue, or an `sqs:Error` on failure
    isolated remote function createQueue(string queueName, *CreateQueueConfig createQueueConfig) returns string|Error {
        return self.externCreateQueue(queueName, createQueueConfig);
    }

    isolated function externCreateQueue(string queueName, *CreateQueueConfig createQueueConfig) returns string|Error = @java:Method {
        name: "createQueue",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Deletes the specified Amazon SQS queue.
    #
    # + queueUrl - The URL of the Amazon SQS queue to delete
    # + return - An `sqs:Error` on failure
    isolated remote function deleteQueue(string queueUrl) returns Error? {
        return self.externDeleteQueue(queueUrl);
    }

    isolated function externDeleteQueue(string queueUrl) returns Error? = @java:Method {
        name: "deleteQueue",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Retrieves the URL of the specified Amazon SQS queue.
    #
    # + queueName - Name of the queue; can include alphanumeric characters, hyphens (-), and underscores (_), and must be up to 80 characters long
    # + getQueueUrlConfig - Optional parameters such as `queueOwnerAWSAccountId`
    # + return - URL of the requested queue, or an `sqs:Error` on failure
    isolated remote function getQueueUrl(string queueName, *GetQueueUrlConfig getQueueUrlConfig)
        returns string|Error {
        return self.externGetQueueUrl(queueName, getQueueUrlConfig);
    }

    isolated function externGetQueueUrl(string queueName, *GetQueueUrlConfig getQueueUrlConfig) returns string|Error = @java:Method {
        name: "getQueueUrl",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Lists the Amazon SQS queues in the current region. Supports filtering by name prefix and paginated results.
    #
    # + listQueuesConfig - Optional parameters such as `queueNamePrefix`, `maxResults`, and `nextToken`
    # + return - A `sqs:ListQueuesResponse` containing queue URLs and an optional `nextToken`, or an `sqs:Error` on failure
    isolated remote function listQueues(*ListQueuesConfig listQueuesConfig) returns ListQueuesResponse|Error {
        return self.externListQueues(listQueuesConfig);
    }

    isolated function externListQueues(*ListQueuesConfig listQueuesConfig) returns ListQueuesResponse|Error = @java:Method {
        name: "listQueues",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Retrieves the attributes of the specified Amazon SQS queue.
    #
    # + queueUrl - URL of the Amazon SQS queue whose attributes are retrieved
    # + getQueueAttributesConfig - Optional parameters such as `attributeNames`
    # + return - A `sqs:GetQueueAttributesResponse` containing the queue attributes, or an `sqs:Error` on failure
    isolated remote function getQueueAttributes(string queueUrl, *GetQueueAttributesConfig getQueueAttributesConfig)
        returns GetQueueAttributesResponse|Error {
        return self.externgetQueueAttributes(queueUrl, getQueueAttributesConfig);
    }

    isolated function externgetQueueAttributes(string queueurl, *GetQueueAttributesConfig getQueueAttributesConfig) returns GetQueueAttributesResponse|Error = @java:Method {
        name: "getQueueAttributes",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Sets one or more attributes for the specified Amazon SQS queue.
    #
    # + queueUrl - URL of the Amazon SQS queue to configure
    # + queueAttributes - Attributes to set for the queue
    # + return - An `sqs:Error` on failure
    isolated remote function setQueueAttributes(string queueUrl, QueueAttributes queueAttributes) returns Error? {
        return self.externSetQueueAttributes(queueUrl, queueAttributes);
    }

    isolated function externSetQueueAttributes(string queueurl, QueueAttributes queueAttributes) returns Error? = @java:Method {
        name: "setQueueAttributes",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Changes the visibility timeout of a specific message in a queue.
    #
    # + queueUrl - URL of the Amazon SQS queue containing the message
    # + receiptHandle - Receipt handle of the message returned by the `sqs:receiveMessage` operation
    # + visibilityTimeout - New visibility timeout value in seconds (minimum 0, maximum 43,200)
    # + return - An `sqs:Error` on failure
    isolated remote function changeMessageVisibility(string queueUrl, string receiptHandle, int visibilityTimeout) returns Error? {
        return self.externChangeMessageVisibility(queueUrl, receiptHandle, visibilityTimeout);
    }

    isolated function externChangeMessageVisibility(string queueUrl, string receiptHandle, int visibilityTimeout)
    returns Error? = @java:Method {
        name: "changeMessageVisibility",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Purges the specified queue, deleting all messages in it. This action is irreversible.
    #
    # + queueUrl - TURL of the queue to purge
    # + return - An `sqs:Error` on failure
    isolated remote function purgeQueue(string queueUrl) returns Error? {
        return self.externPurgeQueue(queueUrl);
    }

    isolated function externPurgeQueue(string queueUrl) returns Error? = @java:Method {
        name: "purgeQueue",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Adds cost allocation tags to the specified Amazon SQS queue.
    #
    # - A maximum of 50 tags per queue is recommended  
    # - Tags are case-sensitive and treated as plain character strings  
    # - New tags with duplicate keys overwrite existing ones  
    #
    # + queueUrl - URL of the queue to which tags are added
    # + tags - Map of tags to add, where each tag is a key-value pair
    # + return - An `sqs:Error` on failure
    isolated remote function tagQueue(string queueUrl, map<string> tags
    ) returns Error? {
        return self.externTagQueue(queueUrl, tags);
    }

    isolated function externTagQueue(string queueUrl, map<string> tags) returns Error? = @java:Method {
        name: "tagQueue",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Removes cost allocation tags from the specified Amazon SQS queue.
    #
    # + queueUrl - URL of the queue from which tags are removed
    # + tags - List of tag keys to remove
    # + return - An `sqs:Error` on failure
    isolated remote function untagQueue(string queueUrl, string[] tags) returns Error? {
        return self.externUntagQueue(queueUrl, tags);
    }

    isolated function externUntagQueue(string queueurl, string[] tags) returns Error? = @java:Method {
        name: "untagQueue",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Lists all cost allocation tags added to the specified Amazon SQS queue.
    #
    # + queueUrl - URL of the queue whose tags are listed
    # + return - A `sqs:ListQueueTagsResponse` with associated tags, or an `sqs:Error` on failure
    isolated remote function listQueueTags(string queueUrl) returns ListQueueTagsResponse|Error {
        return self.externListQueueTags(queueUrl);
    }

    isolated function externListQueueTags(string queueUrl) returns ListQueueTagsResponse|Error = @java:Method {
        name: "listQueueTags",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Starts a message movement task to transfer messages from a dead-letter queue (DLQ) to another queue.
    #
    # - Only supported for DLQs whose sources are other Amazon SQS queues  
    # - Not supported for non-SQS sources (e.g., AWS Lambda, Amazon SNS)  
    # - Only one active task is allowed per queue at any time  
    #
    # + sourceARN - ARN of the DLQ from which messages are moved
    # + startMessageMoveTaskConfig - Optional parameters such as `destinationARN` and `maxNumberOfMessagesPerSecond`
    # + return - A `sqs:StartMessageMoveTaskResponse` if successful, or an `sqs:Error` on failure
    isolated remote function startMessageMoveTask(string sourceARN, *StartMessageMoveTaskConfig startMessageMoveTaskConfig)
        returns StartMessageMoveTaskResponse|Error {
        return self.externStartMessageMoveTask(sourceARN, startMessageMoveTaskConfig);
    }

    isolated function externStartMessageMoveTask(string sourceARN, *StartMessageMoveTaskConfig startMessageMoveTaskConfig) returns StartMessageMoveTaskResponse|Error = @java:Method {
        name: "startMessageMoveTask",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Cancels an active message movement task for the given task handle.
    #
    # - Only applicable when the task status is `RUNNING`  
    # - Already moved messages will not be reverted  
    # - Only one active task is allowed per queue at any time  
    #
    # + taskHandle - Identifier of the message movement task
    # + return - A `sqs:CancelMessageMoveTaskResponse` with the number of messages moved before cancellation, or an `sqs:Error`
    isolated remote function cancelMessageMoveTask(string taskHandle) returns CancelMessageMoveTaskResponse|Error {
        return self.externCancelMessageMoveTask(taskHandle);
    }

    isolated function externCancelMessageMoveTask(string taskHandle) returns CancelMessageMoveTaskResponse|Error = @java:Method {
        name: "cancelMessageMoveTask",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Gracefully closes the AWS SQS client and releases all associated resources.
    #
    # + return - An `sqs:Error` if closing fails, or else nil
    remote isolated function close() returns Error? = @java:Method {
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;
}
