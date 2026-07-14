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

import ballerinax/aws;
import ballerinax/aws.auth;

# Represents the connection configuration for the Amazon SQS client.
#
# + region - AWS region (e.g., `us-east-1`)
# + auth - Authentication configuration: any AWS credential source supported by
# `ballerinax/aws.auth` — static credentials, an AWS profile, STS assume-role,
# web identity (OIDC), IAM Identity Center (SSO), an external credential
# process, or the default credential provider chain
# + endpoint - Optional endpoint options: FIPS/dualstack variants, or a custom
# endpoint override (e.g. LocalStack, VPC interface endpoints)
public type ConnectionConfig record {|
    auth:AuthConfig auth;
    aws:Region region;
    aws:EndpointConfig endpoint?;
|};

# Contains response details returned by the `sendMessage` API.
#
# + messageId - Unique ID assigned to the message
# + md5OfMessageBody - MD5 digest of the non-URL-encoded message body
# + md5OfMessageAttributes - MD5 digest of the non-URL-encoded message attribute string
# + md5OfMessageSystemAttributes - MD5 digest of the non-URL-encoded system attribute string
# + sequenceNumber - Message sequence number for FIFO queues
public type SendMessageResponse record {|
    string messageId;
    string md5OfMessageBody;
    string md5OfMessageAttributes?;
    string md5OfMessageSystemAttributes?;
    string sequenceNumber?;
|};

# Represents optional parameters for sending messages to Amazon SQS.
#
# + delaySeconds - Duration to delay the message, in seconds (0 to 900)
# + messageAttributes - Custom attributes to attach to the message
# + awsTraceHeader - X-Ray tracing header for distributed tracing support
# + messageDeduplicationId - Token for deduplicating messages (FIFO only)
# + messageGroupId - Tag specifying the message group (FIFO only)
public type SendMessageConfig record {|
    int delaySeconds?;
    map<MessageAttributeValue> messageAttributes?;
    string awsTraceHeader?;
    string messageDeduplicationId?;
    string messageGroupId?;
|};

# Represents a user-defined message attribute sent with a message.
#
# + dataType - Type of the attribute: `String`, `Number`, or `Binary`
# + stringValue - Optional string value
# + binaryValue - Optional binary data (e.g., encrypted or compressed)
public type MessageAttributeValue record {|
    string dataType;
    string stringValue?;
    byte[] binaryValue?;
|};

# Represents optional parameters for receiving messages from an SQS queue.
#
# + waitTimeSeconds - Duration to wait for a message to arrive (long polling)
# + visibilityTimeout - Visibility timeout for received messages
# + maxNumberOfMessages - Maximum number of messages to receive (1 to 10)
# + receiveRequestAttemptId - Deduplication token for `receiveMessage` requests (FIFO only)
# + messageAttributeNames - List of message attribute names to return; use `All` to get all
# + messageSystemAttributeNames - List of system attribute names to return; use `All` to get all
public type ReceiveMessageConfig record {|
    int waitTimeSeconds?;
    int visibilityTimeout?;
    int maxNumberOfMessages?;
    string receiveRequestAttemptId?;
    string[] messageAttributeNames?;
    MessageSystemAttributeName[] messageSystemAttributeNames?;
|};

# Represents supported system attribute names for SQS messages.
public enum MessageSystemAttributeName {
    ALL = "All",
    SENDER_ID = "SenderId",
    SENT_TIMESTAMP = "SentTimestamp",
    APPROXIMATE_RECEIVE_COUNT = "ApproximateReceiveCount",
    APPROXIMATE_FIRST_RECEIVE_TIMESTAMP = "ApproximateFirstReceiveTimestamp",
    SEQUENCE_NUMBER = "SequenceNumber",
    MESSAGE_DEDUPLICATION_ID = "MessageDeduplicationId",
    MESSAGE_GROUP_ID = "MessageGroupId",
    AWS_TRACE_HEADER = "AWSTraceHeader",
    DEAD_LETTER_QUEUE_SOURCE_ARN = "DeadLetterQueueSourceArn",
    SQS_MANAGED_SSE_ENABLED = "SqsManagedSseEnabled"
}

# Represents a message received using the `receiveMessage` API.
#
# + messageSystemAttributes - System-defined attributes associated with the message
# + body - Content of the message
# + md5OfBody - MD5 digest of the non-URL-encoded message body
# + md5OfMessageAttributes - MD5 digest of the non-URL-encoded attribute string
# + messageAttributes - User-defined attributes attached to the message
# + messageId - Unique ID assigned to the message
# + receiptHandle - Token required to delete or change visibility of the message
public type Message record {|
    MessageAttributes messageSystemAttributes?;
    string body?;
    string md5OfBody?;
    string md5OfMessageAttributes?;
    map<MessageAttributeValue> messageAttributes?;
    string messageId?;
    string receiptHandle?;
|};

# Represents the system attributes of an Amazon SQS message.
#
# + approximateReceiveCount - Number of times the message has been received across all queues
# + approximateFirstReceiveTimestamp - Time (in epoch milliseconds) when the message was first received
# + awsTraceHeader - X-Ray trace header used for distributed tracing
# + messageDeduplicationId - Token used to deduplicate messages within a 5-minute deduplication interval (FIFO only)
# + messageGroupId - Tag specifying the message group for ordered processing (FIFO only)
# + senderId - AWS account ID of the message sender
# + sentTimeStamp - Time (in epoch milliseconds) when the message was sent to the queue
# + sequenceNumber - Unique, non-consecutive number assigned to the message (FIFO only)
# + deadLetterQueueSourceArn - ARN of the dead-letter queue where the message was moved
public type MessageAttributes record {|
    int approximateReceiveCount?;
    int approximateFirstReceiveTimestamp?;
    string awsTraceHeader?;
    string messageDeduplicationId?;
    string messageGroupId?;
    string senderId?;
    int sentTimeStamp?;
    string sequenceNumber?;
    string deadLetterQueueSourceArn?;
|};

# Represents a single message entry in a `sendMessageBatch` request.
#
# + id - Unique ID for the batch message entry (up to 80 characters)
# + body - The body of the message
public type SendMessageBatchEntry record {|
    string id;
    string body;
    *SendMessageConfig;
|};

# Represents the response returned by the `sendMessageBatch` operation.
#
# + successful - List of successfully enqueued messages
# + failed - List of failed messages with error details

public type SendMessageBatchResponse record {|
    SendMessageBatchResultEntry[] successful;
    BatchResultErrorEntry[] failed;
|};

# Represents a successful result entry from a `sendMessageBatch` response.
#
# + id - Batch message ID
# + md5OfMessageBody - MD5 digest of the message body
# + messageId - ID assigned to the message
# + md5OfMessageAttributes - MD5 digest of the message attributes
# + md5OfMessageSystemAttributes - MD5 digest of the system attributes
# + sequenceNumber - Unique message sequence number (FIFO only)
public type SendMessageBatchResultEntry record {|
    string id;
    string md5OfMessageBody;
    string messageId;
    string md5OfMessageAttributes?;
    string md5OfMessageSystemAttributes?;
    string sequenceNumber?;
|};

# Represents an error entry in a `sendMessageBatch` or `deleteMessageBatch` response.
#
# + id - Batch entry ID that failed
# + code - Error code describing the failure
# + senderFault - Whether the error was caused by the sender
# + message - Additional error details
public type BatchResultErrorEntry record {|
    string id;
    string code;
    boolean senderFault;
    string message?;
|};

# Represents a single message entry in a `deleteMessageBatch` request.
#
# + id - Batch entry ID for the receipt handle
# + receiptHandle - The receipt handle of the message to delete
public type DeleteMessageBatchEntry record {|
    string id;
    string receiptHandle;
|};

# Represents the response returned by the `deleteMessageBatch` operation.
#
# + successful - List of successfully deleted message entries
# + failed - List of failed message entries with error details
public type DeleteMessageBatchResponse record {|
    DeleteMessageBatchResultEntry[] successful;
    BatchResultErrorEntry[] failed;
|};

# Represents a successful result entry from a `deleteMessageBatch` response.
#
# + id - Batch entry ID of the successfully deleted message
public type DeleteMessageBatchResultEntry record {|
    string id;
|};

# Represents the configuration used when creating an SQS queue.
#
# + queueAttributes - Optional queue attributes to apply
# + tags - Optional cost allocation tags to associate with the queue
public type CreateQueueConfig record {|
    QueueAttributes queueAttributes?;
    map<string> tags?;
|};

# Represents configurable attributes for an Amazon SQS queue.
#
# + delaySeconds - Time (in seconds) to delay delivery of all messages
# + maximumMessageSize - Maximum allowed size (in bytes) for a message
# + messageRetentionPeriod - Time (in seconds) that messages are retained
# + policy - JSON-formatted access policy for the queue
# + receiveMessageWaitTimeSeconds - Time (in seconds) to wait for a message in long polling
# + visibilityTimeout - Visibility timeout (in seconds) for messages
# + redrivePolicy - Dead-letter queue configuration for this queue
# + redriveAllowPolicy - Permissions for queues that can specify this one as a dead-letter queue
# + kmsMasterKeyId - AWS KMS key ID used for server-side encryption
# + kmsDataKeyReusePeriodSeconds - Reuse duration (in seconds) for data keys in SSE
# + sqsManagedSseEnabled - Enables SQS-managed server-side encryption
# + fifoQueue - Whether the queue is FIFO; must be set at creation time
# + contentBasedDeduplication - Enables content-based deduplication (FIFO only)
# + deduplicationScope - Scope for message deduplication (FIFO high throughput only)
# + fifoThroughputLimit - Throughput quota mode (FIFO high throughput only)
public type QueueAttributes record {|
    int delaySeconds?;
    int maximumMessageSize?;
    int messageRetentionPeriod?;
    string policy?;
    int receiveMessageWaitTimeSeconds?;
    int visibilityTimeout?;
    RedrivePolicy redrivePolicy?;
    RedriveAllowPolicy redriveAllowPolicy?;
    string kmsMasterKeyId?;
    string kmsDataKeyReusePeriodSeconds?;
    boolean sqsManagedSseEnabled?;
    boolean fifoQueue?;
    boolean contentBasedDeduplication?;
    DeduplicationScope deduplicationScope?;
    FifoThroughputLimit fifoThroughputLimit?;
|};

# Represents a dead-letter queue redrive policy.
#
# + deadLetterTargetArn - ARN of the dead-letter queue
# + maxReceiveCount - Maximum number of receives before moving message to the DLQ
public type RedrivePolicy record {|
    string deadLetterTargetArn?;
    int maxReceiveCount?;
|};

# Represents permissions for queues to specify another as a dead-letter queue.
#
# + redrivePermission - Allowed permission type
# + sourceQueueArns - List of ARNs allowed to use this queue as a DLQ (if `byQueue`)
public type RedriveAllowPolicy record {|
    RedrivePermission redrivePermission = ALLOW_ALL;
    string[] sourceQueueArns?;
|};

# Represents allowed redrive permission values.
#
# - `allowAll` – All queues in the account can use this queue as a DLQ (default)
# - `denyAll` – No queues can use this queue as a DLQ
# - `byQueue` – Only specified source queues can use this queue as a DLQ
public enum RedrivePermission {
    ALLOW_ALL = "allowAll",
    DENY_ALL = "denyAll",
    BY_QUEUE = "byQueue"
};

# Represents deduplication scope for high throughput FIFO queues.
#
# - `messageGroup` – Deduplication is scoped per message group
# - `queue` – Deduplication is scoped across the entire queue
public enum DeduplicationScope {
    MESSAGE_GROUP = "messageGroup",
    QUEUE = "queue"
};

# Represents throughput limit mode for high throughput FIFO queues.
#
# - `perMessageGroupId` – Throughput quota is per message group
# - `perQueue` – Throughput quota is shared across the entire queue
public enum FifoThroughputLimit {
    PER_MESSAGE_GROUP_ID = "perMessageGroupId",
    PER_QUEUE = "perQueue"
};

# Represents the optional configuration for the `getQueueUrl` operation.
#
# + queueOwnerAWSAccountId - AWS account ID of the queue owner. Required when accessing a queue owned by another AWS account
public type GetQueueUrlConfig record {|
    string queueOwnerAWSAccountId?;
|};

# Represents the optional parameters for the `listQueues` operation.
#
# + maxResults - Maximum number of results to return. Required to receive a `nextToken` in the response.
# + nextToken - Token to retrieve the next set of results in paginated responses
# + queueNamePrefix - Prefix to filter queue names. Only queues that start with this value are returned
public type ListQueuesConfig record {|
    int maxResults?;
    string nextToken?;
    string queueNamePrefix?;
|};

# Represents the response from the `listQueues` operation.
#
# + queueUrls - List of matching queue URLs
# + nextToken - Pagination token for the next request. `null` if there are no more results.
public type ListQueuesResponse record {|
    string[] queueUrls;
    string nextToken?;
|};

# Represents the optional parameters for the `getQueueAttributes` operation.
#
# + attributeNames - List of queue attributes to retrieve
public type GetQueueAttributesConfig record {|
    QueueAttributeName[] attributeNames?;
|};

# Represents the attributes that can be retrieved from a queue.
public enum QueueAttributeName {
    ALL = "All",
    POLICY = "Policy",
    VISIBILITY_TIMEOUT = "VisibilityTimeout",
    MAXIMUM_MESSAGE_SIZE = "MaximumMessageSize",
    MESSAGE_RETENTION_PERIOD = "MessageRetentionPeriod",
    APPROXIMATE_NUMBER_OF_MESSAGES = "ApproximateNumberOfMessages",
    APPROXIMATE_NUMBER_OF_MESSAGES_NOT_VISIBLE = "ApproximateNumberOfMessagesNotVisible",
    CREATED_TIMESTAMP = "CreatedTimestamp",
    LAST_MODIFIED_TIMESTAMP = "LastModifiedTimestamp",
    QUEUE_ARN = "QueueArn",
    APPROXIMATE_NUMBER_OF_MESSAGES_DELAYED = "ApproximateNumberOfMessagesDelayed",
    DELAY_SECONDS = "DelaySeconds",
    RECEIVE_MESSAGE_WAIT_TIME_SECONDS = "ReceiveMessageWaitTimeSeconds",
    REDRIVE_POLICY = "RedrivePolicy",
    FIFO_QUEUE = "FifoQueue",
    CONTENT_BASED_DEDUPLICATION = "ContentBasedDeduplication",
    KMS_MASTER_KEY_ID = "KmsMasterKeyId",
    KMS_DATA_KEY_REUSE_PERIOD_SECONDS = "KmsDataKeyReusePeriodSeconds",
    DEDUPLICATION_SCOPE = "DeduplicationScope",
    FIFO_THROUGHPUT_LIMIT = "FifoThroughputLimit",
    REDRIVE_ALLOW_POLICY = "RedriveAllowPolicy",
    SQS_MANAGED_SSE_ENABLED = "SqsManagedSseEnabled"
}

# Represents the response from the `getQueueAttributes` operation.
#
# + queueAttributes - Map of queue attribute names to their values
public type GetQueueAttributesResponse record {|
    map<string> queueAttributes;
|};

# Represents the response from the `listQueueTags` operation.
#
# + tags - Map of tags added to the specified queue
public type ListQueueTagsResponse record {|
    map<string> tags;
|};

# Represents the configuration for starting a message movement task.
#
# + destinationARN - ARN of the destination queue. If not set, messages are redriven to their original source queues
# + maxNumberOfMessagesPerSecond - Fixed message movement rate. Max value is 500. If not set, the system optimizes the rate.
public type StartMessageMoveTaskConfig record {|
    string destinationARN?;
    int maxNumberOfMessagesPerSecond?;
|};

# Represents the response from the `startMessageMoveTask` operation.
#
# + taskHandle - Unique identifier for the initiated message movement task. Use to cancel the task if needed
public type StartMessageMoveTaskResponse record {|
    string taskHandle;
|};

# Represents the response from the `cancelMessageMoveTask` operation.
#
# + approximateNumberOfMessagesMoved - Number of messages moved before the task was cancelled
public type CancelMessageMoveTaskResponse record {|
    int approximateNumberOfMessagesMoved;
|};

# Polling configuration for message retrieval.
#
# + pollInterval - Interval between polling attempts in seconds. If set to 0, the listener will poll back-to-back without delay. Use with caution as it may cause high CPU usage.
# + waitTime - The duration, in seconds, for which the polling waits for messages
# + visibilityTimeout - The duration, in seconds, for which the received message remains invisible to other consumers
public type PollingConfig record {|
    decimal pollInterval = 1;
    int waitTime = 20;
    int visibilityTimeout = 30;
|};

# Represents an AWS SQS service object that can be attached to an `sqs:Listener`.
public type Service distinct service object {};

# The service configuration type for the `sqs:Service`.
# + queueUrl - The URL of the SQS queue to consume messages from
# + config - Optional per-service polling behavior
# + autoDelete - Whether to automatically delete messages after receiving
public type ServiceConfigType record {|
    string queueUrl;
    PollingConfig config?;
    boolean autoDelete = true;
|};

# Annotation to configure the `sqs:Service`.
public annotation ServiceConfigType ServiceConfig on service;
