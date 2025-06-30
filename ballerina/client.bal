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
    } external;

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
        name: "deleteMessage",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

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
    # action on each message is reported individually in the response.
    #
    # + queueUrl - The URL of the Amazon SQS queue from which messages are deleted. Queue URLs and names are case-sensitive.
    # + entries - List of the receipt handles of the messages to be deleted.
    # + return - A `DeleteMessageBatchResponse` indicating which deletions succeeded or failed and `Error` on failure.
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
    # + queueName - The name of the new queue.
    # The following limits apply to this name:
    # - A queue name can have up to 80 characters.
    # - Valid values: alphanumeric characters, hyphens (-), and underscores (_).
    # A FIFO queue name must end with the .fifo suffix. Queue URLs and names are case-sensitive. 
    # + createQueueConfig - Optional parameters such as `queueAttributes` and `tags`.
    # + return - The URL of the created queue, or an Error.
    isolated remote function createQueue(string queueName, *CreateQueueConfig createQueueConfig) returns string|Error {
        return self.externCreateQueue(queueName, createQueueConfig);
    }

    isolated function externCreateQueue(string queueName, *CreateQueueConfig createQueueConfig) returns string|Error = @java:Method {
        name: "createQueue",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Deletes the specified Amazon SQS queue
    #
    # + queueUrl - The URL of the Amazon SQS queue to delete.Queue URLs and names are case-sensitive
    # + return - `Error` on failure
    isolated remote function deleteQueue(string queueUrl) returns Error? {
        return self.externDeleteQueue(queueUrl);
    }

    isolated function externDeleteQueue(string queueUrl) returns Error? = @java:Method {
        name: "deleteQueue",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Retrieves the URL of the specified Amazon SQS queue.
    #
    # + queueName - The name of the queue for which you want to fetch the URL. The name can be up to 80 characters long and can include alphanumeric characters, hyphens (-), and underscores (_). Queue URLs and names are case-sensitive. 
    # + getQueueUrlConfig - The optional parameters for retrieving the queue URL, such as `queueOwnerAWSAccountId`.
    # + return - The URL of the requested queue, or an Error
    isolated remote function getQueueUrl(string queueName, *GetQueueUrlConfig getQueueUrlConfig)
        returns string|Error {
        return self.externGetQueueUrl(queueName, getQueueUrlConfig);
    }

    isolated function externGetQueueUrl(string queueName, *GetQueueUrlConfig getQueueUrlConfig) returns string|Error = @java:Method {
        name: "getQueueUrl",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Returns a list of your queues in the current region. The response includes a maximum of 1,000 results.
    # If you specify a value for the optional QueueNamePrefix parameter, only queues with a name that begins with the specified value are returned.
    #
    # + listQueuesConfig - The optional parameters for listing queues, such as `maxResults`, `nextToken`, and `queueNamePrefix`.
    # + return - A `ListQueuesResponse` with queue URLs and optional  `nextToken`, or an Error.
    isolated remote function listQueues(*ListQueuesConfig listQueuesConfig) returns ListQueuesResponse|Error {
        return self.externListQueues(listQueuesConfig);
    }

    isolated function externListQueues(*ListQueuesConfig listQueuesConfig) returns ListQueuesResponse|Error = @java:Method {
        name: "listQueues",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Retrieves the attributes of the specified Amazon SQS queue.
    #
    # + queueUrl - The URL of the Amazon SQS queue whose attribute information is retrieved. Queue URLs and names are case-sensitive.
    # + getQueueAttributesConfig - The optional parameters for retrieving queue attributes, such as `attributeNames`.
    # + return - A `GetQueueAttributesResponse` containing the queue attributes or an Error.
    isolated remote function getQueueAttributes(string queueUrl, *GetQueueAttributesConfig getQueueAttributesConfig)
        returns GetQueueAttributesResponse|Error {
        return self.externgetQueueAttributes(queueUrl, getQueueAttributesConfig);
    }

    isolated function externgetQueueAttributes(string queueurl, *GetQueueAttributesConfig getQueueAttributesConfig) returns GetQueueAttributesResponse|Error = @java:Method {
        name: "getQueueAttributes",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Sets one or more attributes of the specified SQS queue.
    #
    # + queueUrl - The URL of the Amazon SQS queue whose attributes are set. Queue URLs and names are case-sensitive.
    # + queueAttributes - The optional parameters for setting queue attributes, such as `queueAttributes`.
    # + return - `Error` on failure.
    isolated remote function setQueueAttributes(string queueUrl, QueueAttributes queueAttributes) returns Error? {
        return self.externSetQueueAttributes(queueUrl, queueAttributes);
    }

    isolated function externSetQueueAttributes(string queueurl, QueueAttributes queueAttributes) returns Error? = @java:Method {
        name: "setQueueAttributes",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;

    # Changes the visibility timeout of a specified message in a queue to a new value. The default visibility timeout for a message is 30 seconds. The  minimum is 0 seconds. The maximum is 12 hours.
    #
    # + queueUrl - The URL of the Amazon SQS queue whose message's visibility is changed. Queue URLs and names are case-sensitive. 
    # + receiptHandle - The receipt handle associated with the message, whose visibility timeout is changed. This parameter is returned by the `ReceiveMessage` action. 
    # + visibilityTimeout - The new value for the message's visibility timeout (in seconds).
    # + return - `Error` on failure.
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
    # + queueUrl - The URL of the queue from which the PurgeQueue action deletes messages. Queue URLs and names are case-sensitive.
    # + return - `Error` on failure.
    isolated remote function purgeQueue(string queueUrl) returns Error? {
        return self.externPurgeQueue(queueUrl);
    }

    isolated function externPurgeQueue(string queueUrl) returns Error? = @java:Method {
        name: "purgeQueue",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Add cost allocation tags to the specified Amazon SQS queue. For an overview, see Tagging Your Amazon SQS Queues in the Amazon SQS Developer Guide. When you use queue tags, keep the following guidelines in mind:
    # - Adding more than 50 tags to a queue isn't recommended.
    # - Tags don't have any semantic meaning. Amazon SQS interprets tags as character strings.
    # - Tags are case-sensitive.
    # - A new tag with a key identical to that of an existing tag overwrites the existing tag.
    #
    # + queueUrl - The URL of the Amazon SQS queue to which tags are added. Queue URLs and names are case-sensitive.
    # + tags - The list of tags to be added to the specified queue. Each tag is a key-value pair.
    # + return - `Error` on failure.
    isolated remote function tagQueue(string queueUrl, map<string> tags
    ) returns Error? {
        return self.externTagQueue(queueUrl, tags);
    }

    isolated function externTagQueue(string queueUrl, map<string> tags) returns Error? = @java:Method {
        name: "tagQueue",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Remove cost allocation tags from the specified Amazon SQS queue.
    #
    # + queueUrl - The URL of the Amazon SQS queue from which tags are removed. Queue URLs and names are case-sensitive.
    # + tags - The list of tags to be untagged from the specified queue.
    # + return - `Error` on failure.
    isolated remote function untagQueue(string queueUrl, string[] tags) returns Error? {
        return self.externUntagQueue(queueUrl, tags);
    }

    isolated function externUntagQueue(string queueurl, string[] tags) returns Error? = @java:Method {
        name: "untagQueue",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # List all cost allocation tags added to the specified Amazon SQS queue.
    #
    # + queueUrl - The URL of the queue.
    # + return - The `ListQueueTagsResponse` with tags relevant to the specified queue or an Error.
    isolated remote function listQueueTags(string queueUrl) returns ListQueueTagsResponse|Error {
        return self.externListQueueTags(queueUrl);
    }

    isolated function externListQueueTags(string queueUrl) returns ListQueueTagsResponse|Error = @java:Method {
        name: "listQueueTags",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Starts an asynchronous task to move messages from a specified source queue to a specified destination queue. This action is currently limited to supporting message redrive from queues that are configured as dead-letter queues (DLQs) of other Amazon SQS queues only. Non-SQS queue sources of dead-letter queues, such as AWS Lambda or Amazon SNS topics, are currently not supported. In dead-letter queues redrive context, the  `StartMessageMoveTask` the source queue is the DLQ, while the destination  queue can be the original source queue (from which the messages were driven to the dead-letter-queue), or a custom destination queue. Only one active message movement task is supported per queue at any given time.
    #
    # + sourceARN - The ARN of the queue that contains the messages to be moved to another queue. Currently, only ARNs of dead-letter queues (DLQs) whose sources are other Amazon SQS queues are accepted. DLQs whose sources are non-SQS queues, such as AWS Lambda or Amazon SNS topics, are not currently supported.
    # + startMessageMoveTaskConfig - The optional parameters for starting a message move task, such as `destinationARN` and `maxNumberOfMessagesPerSecond`.
    # + return - The `StartMessageMoveTaskResponse` if the operation is successful or an Error.
    isolated remote function startMessageMoveTask(string sourceARN, *StartMessageMoveTaskConfig startMessageMoveTaskConfig)
        returns StartMessageMoveTaskResponse|Error {
        return self.externStartMessageMoveTask(sourceARN, startMessageMoveTaskConfig);
    }

    isolated function externStartMessageMoveTask(string sourceARN, *StartMessageMoveTaskConfig startMessageMoveTaskConfig) returns StartMessageMoveTaskResponse|Error = @java:Method {
        name: "startMessageMoveTask",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Cancels a specified message movement task. A message movement can only be cancelled when the current status is RUNNING. Cancelling a message movement task does not revert the messages that have already been moved. It can only stop the messages that have not been moved yet.
    # - This action is currently limited to supporting message redrive from dead-letter queues (DLQs) only. In this context, the source queue is the dead-letter queue (DLQ), while the destination queue can be the original source queue (from which the messages were driven to the dead-letter-queue), or a custom destination queue.
    # - Only one active message movement task is supported per queue at any given time.
    #
    # + taskHandle - An identifier associated with a message movement task.
    # + return - The `CancelMessageMoveTaskResponse` containing the approximate number of messages already moved to the destination queue, or an Error.
    isolated remote function cancelMessageMoveTask(string taskHandle) returns CancelMessageMoveTaskResponse|Error {
        return self.externCancelMessageMoveTask(taskHandle);
    }

    isolated function externCancelMessageMoveTask(string taskHandle) returns CancelMessageMoveTaskResponse|Error = @java:Method {
        name: "cancelMessageMoveTask",
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"

    } external;

    # Gracefully closes AWS SQS API client resources
    #
    # + return - An `Error` if there is an error while closing the client resources or else nil
    remote isolated function close() returns Error? = @java:Method {
        'class: "io.ballerina.lib.aws.sqs.NativeClientAdaptor"
    } external;
}

