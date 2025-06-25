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

# Represents the connection configuration for the Amazon SQS client
#
# + region - AWS region (e.g., `us-east-1`)
# + auth - Authentication configuration using static credentials or AWS profile
public type ConnectionConfig record {|
   Region region;
   StaticAuthConfig|ProfileAuthConfig auth;
|};

# Represents static authentication configurations for the SQS API
#
# + accessKeyId - The AWS access key ID, used to identify the user interacting with AWS
# + secretAccessKey - The AWS secret access key, used to authenticate the user interacting with AWS
# + sessionToken - The AWS session token, used for authenticating a user with temporary permission to a resource
public type StaticAuthConfig record {|
   string accessKeyId;
   string secretAccessKey;
   string sessionToken?;
|};

# Represents AWS profile-based authentication configuration for SQS API
#
# + profileName - Name of the AWS profile in `~/.aws/credentials`
# + credentialsFilePath - Optional custom path to the credentials file. Defaults to `"~/.aws/credentials"`. 
# The credentials file should follow the standard AWS format:
#
# ```
# [default]
# aws_access_key_id = YOUR_ACCESS_KEY_ID
# aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
#
# [profile-name]
# aws_access_key_id = ANOTHER_ACCESS_KEY_ID
# aws_secret_access_key = ANOTHER_SECRET_ACCESS_KEY
# ```
public type ProfileAuthConfig record {|
   string profileName = "default";
   string credentialsFilePath = "~/.aws/credentials";
|};

# An Amazon Web Services region that hosts a set of Amazon services.
public enum Region {
   AF_SOUTH_1 = "af-south-1",
   AP_EAST_1 = "ap-east-1",
   AP_NORTHEAST_1 = "ap-northeast-1",
   AP_NORTHEAST_2 = "ap-northeast-2",
   AP_NORTHEAST_3 = "ap-northeast-3",
   AP_SOUTH_1 = "ap-south-1",
   AP_SOUTH_2 = "ap-south-2",
   AP_SOUTHEAST_1 = "ap-southeast-1",
   AP_SOUTHEAST_2 = "ap-southeast-2",
   AP_SOUTHEAST_3 = "ap-southeast-3",
   AP_SOUTHEAST_4 = "ap-southeast-4",
   AWS_CN_GLOBAL = "aws-cn-global",
   AWS_GLOBAL = "aws-global",
   AWS_ISO_GLOBAL = "aws-iso-global",
   AWS_ISO_B_GLOBAL = "aws-iso-b-global",
   AWS_US_GOV_GLOBAL = "aws-us-gov-global",
   CA_WEST_1 = "ca-west-1",
   CA_CENTRAL_1 = "ca-central-1",
   CN_NORTH_1 = "cn-north-1",
   CN_NORTHWEST_1 = "cn-northwest-1",
   EU_CENTRAL_1 = "eu-central-1",
   EU_CENTRAL_2 = "eu-central-2",
   EU_ISOE_WEST_1 = "eu-isoe-west-1",
   EU_NORTH_1 = "eu-north-1",
   EU_SOUTH_1 = "eu-south-1",
   EU_SOUTH_2 = "eu-south-2",
   EU_WEST_1 = "eu-west-1",
   EU_WEST_2 = "eu-west-2",
   EU_WEST_3 = "eu-west-3",
   IL_CENTRAL_1 = "il-central-1",
   ME_CENTRAL_1 = "me-central-1",
   ME_SOUTH_1 = "me-south-1",
   SA_EAST_1 = "sa-east-1",
   US_EAST_1 = "us-east-1",
   US_EAST_2 = "us-east-2",
   US_GOV_EAST_1 = "us-gov-east-1",
   US_GOV_WEST_1 = "us-gov-west-1",
   US_ISOB_EAST_1 = "us-isob-east-1",
   US_ISO_EAST_1 = "us-iso-east-1",
   US_ISO_WEST_1 = "us-iso-west-1",
   US_WEST_1 = "us-west-1",
   US_WEST_2 = "us-west-2"
}

# Contains the response details returned by the SendMessage API.
# Includes identifiers and checksums used to validate the success and integrity of the message sent.
# For FIFO queues, includes a sequence number to maintain message order.
#
# + messageId - Contains the MessageId of the message sent to the queue. 
# + md5OfMessageBody - An MD5 digest of the non-URL-encoded message body string. This attribute can be used to verify that Amazon SQS received the message correctly. 
# + md5OfMessageAttributes - An MD5 digest of the non-URL-encoded message attribute string. This attribute can be used to verify that Amazon SQS received the message correctly. 
# + md5OfMessageSystemAttributes - An MD5 digest of the non-URL-encoded message system attribute string. This attribute can be used to verify that Amazon SQS received the message correctly.  
# + sequenceNumber - The large, non-consecutive number that Amazon SQS assigns to each message. The length of SequenceNumber is 128 bits. SequenceNumber continues to increase for a particular MessageGroupId. Applies only to FIFO queues. 
public type SendMessageResponse record {|
   string messageId;
   string md5OfMessageBody;
   string md5OfMessageAttributes?;
   string md5OfMessageSystemAttributes?;
   string sequenceNumber?;
|};

# Represents common optional parameters used when sending a message to an Amazon SQS queue.These fields can be applied to both `SendMessage` and `SendMessageBatch`.
# 
# + delaySeconds - The length of time, in seconds, for which to delay a specific message. Valid values: 0 to 900. Maximum: 15 minutes. Messages with a positive DelaySeconds value become available for processing after the delay period is finished. If you don't specify a value, the default value for the queue applies. 
# + messageAttributes - Custom user-defined attributes to send with the message. Each attribute has a name, type, and value. `messageAttributes` can be used to attach custom metadata to Amazon SQS messages for your applications. 
# + awsTraceHeader - The AWS X-Ray tracing header to associate with the message. This value is assigned to the system attribute `awsTraceHeader` and enables distributed tracing support in AWS services. This is the only supported system attribute in Amazon SQS currently.
# + messageDeduplicationId - A token used for deduplicating sent messages. Applies only to FIFO queues.
# + messageGroupId - A tag that specifies the message group it belongs to. Applies only to FIFO queues.
public type SendMessageConfig record {|
   int delaySeconds?;
   map<MessageAttributeValue> messageAttributes?;
   string awsTraceHeader?; 
   string messageDeduplicationId?;
   string messageGroupId?;
|};

# The user-specified message attribute value that is sent as part of the message. Each attribute includes a data type and one of the following: a string, a binary value, or a list of strings. The name, data type, and value must not be empty or null. All parts of the message attribute contribute to the 256 KB message size limit (262,144 bytes), including name, type, and value.
#
# + dataType - The type of the attribute. Must be String, Number, or Binary.
# + stringValue - Strings are Unicode with UTF-8 binary encoding. 
# + binaryValue - Binary type attributes can store any binary data, such as compressed data, encrypted data, or images. 
public type MessageAttributeValue record {|
   string dataType;
   string stringValue?;
   byte[] binaryValue?;
|};

# Configuration options for receiving messages from an AWS SQS queue.
# 
# + waitTimeSeconds - The duration (in seconds) for which the call waits for a message to arrive before returning. Enables long polling when set to greater than 0.
# + visibilityTimeout - The duration (in seconds) that the received messages are hidden from subsequent retrieve requests. 
# + maxNumberOfMessages - The maximum number of messages to return. Valid values: 1 to 10. Default is 1.
# + receiveRequestAttemptId - A token used for deduplication of `ReceiveMessage` calls. Applies only to FIFO queues. If a networking issue occurs after a ReceiveMessage action, and instead of a response you receive a generic error, it is possible to retry the same action with an identical `receiveRequestAttemptId` to retrieve the same set of messages, even if their visibility timeout has not yet expired. 
# + messageAttributeNames - A list of message attribute names to return. Use `All` to receive all message attributes.
# + messageSystemAttributeNames - A list of system attribute names to return. Use `All` to receive all system attributes.
public type ReceiveMessageConfig record {|
   int waitTimeSeconds?;
   int visibilityTimeout?;
   int maxNumberOfMessages?;
   string receiveRequestAttemptId?;
   string[] messageAttributeNames?;
   MessageSystemAttributeName[] messageSystemAttributeNames?;
|};

# Possible values for the `messageAttributeNames` parameter in the `receiveMessage` API.
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

# Represents a single SQS message returned by the `receiveMessage` API.
#
# + messageSystemAttributes - A map of the message system attributes requested in ReceiveMessage to their respective values. Supported attributes are:
#   - ApproximateReceiveCount
#   - ApproximateFirstReceiveTimestamp
#   - AWSTraceHeader
#   - MessageDeduplicationId
#   - MessageGroupId
#   - SenderId
#   - SentTimestamp
#   - SequenceNumber
# ApproximateFirstReceiveTimestamp and SentTimestamp are each returned as an integer representing the epoch time in milliseconds.
# + body - The content of the message(not URL-encoded). 
# + md5OfBody - An MD5 digest of the non-URL-encoded message body string. 
# + md5OfMessageAttributes - An MD5 digest of the non-URL-encoded message attribute string.  
# + messageAttributes - Each message attribute consists of a Name, Type, and Value. 
# + messageId - A unique identifier for the message. A MessageId is considered unique across all AWS accounts for an extended period of time.
# + receiptHandle - An identifier associated with the act of receiving the message. A new receipt handle is returned every time you receive a message. When deleting a message, you provide the last received receipt handle to delete the message.
public type Message record {|
   MessageAttributes messageSystemAttributes?;
   string body?;
   string md5OfBody?; 
   string md5OfMessageAttributes?;
   map<MessageAttributeValue> messageAttributes?;
   string messageId?;
   string receiptHandle?;
|};

# Represents the attributes of an SQS message.
#
# + approximateReceiveCount - The number of times a message has been received across all queues. This value is incremented each time a message is received from the queue, including when it is received by the same consumer.
# + approximateFirstReceiveTimestamp -  The approximate time, in milliseconds since the epoch, when the message was first received from the queue. This value is returned as an integer representing the epoch time in milliseconds. 
# + awsTraceHeader - The AWS X-Ray trace header string.
# + messageDeduplicationId - The token used for deduplication of messages within a 5-minute minimum deduplication interval. If a message with a particular MessageDeduplicationId is sent successfully, subsequent messages with the same MessageDeduplicationId are accepted successfully but aren't delivered.
#  This parameter applies only to FIFO (first-in-first-out) queues. 
# + messageGroupId -  The tag that specifies that a message belongs to a specific message group. Messages that belong to the same message group are processed in a FIFO manner (however, messages in different message groups might be processed out of order). To interleave multiple ordered streams within a single queue, use MessageGroupId values (for example, session data for multiple users).
# This parameter applies only to FIFO (first-in-first-out) queues. 
# + senderId - The AWS account number of the sender. This is the same as the AWS account number that you use to sign in to the AWS Management Console.
# + sentTimeStamp - The approximate time, in milliseconds since the epoch, when the message was sent to the queue. This value is returned as an integer representing the epoch time in milliseconds.
# + sequenceNumber - The large, non-consecutive number that Amazon SQS assigns to each message. The length of SequenceNumber is 128 bits. SequenceNumber continues to increase for a particular MessageGroupId. 
# + deadLetterQueueSourceArn -  The Amazon Resource Name (ARN) of the dead-letter queue that the message was moved to after the value of `maxReceiveCount` was exceeded. This attribute is returned only for messages that are moved to a dead-letter queue.
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

# A single message entry in a SendMessageBatch request.
#
# + id - An identifier for a message in this batch used to communicate the result. The Ids of a batch request need to be unique within a request. This identifier can have up to 80 characters.
# The following characters are accepted: alphanumeric characters, hyphens(-), and underscores (_). 
# + body - The body of the message.
public type SendMessageBatchEntry record {|
  string id;
  string body;
  *SendMessageConfig;
|};

# The full response of the `SendMessageBatch` operation.
#
# + successful - A list of `SendMessageBatchResultEntry` items.
# + failed - A list of `BatchResultErrorEntry` items with Error details about each message that can't be enqueued.
public type SendMessageBatchResponse record {|
   SendMessageBatchResultEntry[] successful;
   BatchResultErrorEntry[] failed;
|};

# A successful result entry from a SendMessageBatch response.
#
# + id - An identifier for the message in this batch.
# + md5OfMessageBody - An MD5 digest of the non-URL-encoded message body string. You can use this attribute to verify that Amazon SQS received the message correctly. Amazon SQS URL-decodes the message before creating the MD5 digest.
# + messageId - An identifier for the message. 
# + md5OfMessageAttributes - An MD5 digest of the non-URL-encoded message attribute string. You can use this attribute to verify that Amazon SQS received the message correctly. Amazon SQS URL-decodes the message before creating the MD5 digest.
# + md5OfMessageSystemAttributes - An MD5 digest of the non-URL-encoded message system attribute string. You can use this attribute to verify that Amazon SQS received the message correctly. Amazon SQS URL-decodes the message before creating the MD5 digest. 
# + sequenceNumber - The large, non-consecutive number that Amazon SQS assigns to each message. The length of SequenceNumber is 128 bits. As SequenceNumber continues to increase for a particular MessageGroupId. Applies only to FIFO queues. 
public type SendMessageBatchResultEntry record {|
   string id;
   string md5OfMessageBody;
   string messageId;
   string md5OfMessageAttributes?;
   string md5OfMessageSystemAttributes?;
   string sequenceNumber?;
|};

# An Error entry in a failed SendMessageBatch response.
#
# + id - The Id of an entry in a batch request.
# + code - An Error code representing why the action failed on this entry.
# + senderFault - Specifies whether the Error happened due to the caller of the batch API action. 
# + message - A message explaining why the action failed on this ent
public type BatchResultErrorEntry record {|
   string id;
   string code;
   boolean senderFault;
   string message?;
|};

# A single message entry in a DeleteMessageBatch request.
#
# + id - The identifier for a particular receipt handle. This is used to communicate the result. The Ids of a batch request need to be unique within a request. This identifier can have up to 80 characters. 
# + receiptHandle - A receipt handle.
public type DeleteMessageBatchEntry record {|
   string id;
   string receiptHandle;
|};

# The full response of the `DeleteMessageBatch` operation
#
# + successful - A list of `DeleteMessageBatchResultEntry` items
# + failed - A list of `BatchResultErrorEntry` items with Error details about each message that can't be dequeued
public type DeleteMessageBatchResponse record {|
   DeleteMessageBatchResultEntry[] successful;
   BatchResultErrorEntry[] failed;
|};

# A successful result entry from a DeleteMessageBatch response
#
# + id - the Id of a successfully deleted message
public type DeleteMessageBatchResultEntry record {|
   string id;
|};

# Configuration options for creating an AWS SQS queue.
#
# + queueAttributes - A map of attributes with their corresponding values. 
# + tags - Add cost allocation tags to the specified Amazon SQS queue. When you use queue tags, keep the following guidelines in mind:
#     - Adding more than 50 tags to a queue isn't recommended.
#     - Tags don't have any semantic meaning.
#     - Amazon SQS interprets tags as character strings.
#     - Tags are case-sensitive.
#     - A new tag with a key identical to that of an existing tag overwrites the existing tag.
public type CreateQueueConfig record {|
   QueueAttributes queueAttributes?;
   map<string> tags?;
|};

# Represents the attributes of an SQS queue. These attributes can be set when creating a queue or
# updated later using the `setQueueAttributes` API.
#
# + delaySeconds -  The length of time, in seconds, for which the delivery of all messages in the queue is delayed.
# + maximumMessageSize - The limit of how many bytes a message can contain before Amazon SQS rejects it.
# + messageRetentionPeriod - The length of time, in seconds, for which Amazon SQS retains a message. 
# When you change a queue's attributes, the change can take up to 60 seconds for most of the attributes to propagate throughout the Amazon SQS system. Changes made to the `MessageRetentionPeriod` attribute can take up to 15 minutes and will impact existing messages in the queue potentially causing them to be expired and deleted if the `MessageRetentionPeriod` is reduced below the age of existing messages.
# + policy - The queue's policy,this must be a valid AWS policy.
# + receiveMessageWaitTimeSeconds - The length of time, in seconds, for which a `ReceiveMessage` action waits for a message to arrive.  
# + visibilityTimeout - The visibility timeout for the queue, in seconds.
# + redrivePolicy -Includes the parameters for the dead-letter queue functionality of the source queue.  Apply only to dead-letter queues. 
# + redriveAllowPolicy - Includes the parameters for the permissions for the dead-letter queue redrive permission. Apply only to dead-letter queues. 
# + kmsMasterKeyId - The ID of an AWS managed customer master key (CMK) for Amazon SQS or a custom CMK. Apply only to server side encryption.
# + kmsDataKeyReusePeriodSeconds - The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again.  Apply only to server side encryption.
# + sqsManagedSseEnabled -  Enables server-side queue encryption using SQS owned encryption keys. Only one server-side encryption option is supported per queue. For example, Server Side Encryption Key Management Service (SSE-KMS) or SSE-SQS. Apply only to server side encryption.
# + fifoQueue - Designates a queue as FIFO. If you don't specify the `fifoQueue` attribute, Amazon SQS creates a standard queue. You can provide this attribute only during queue creation. Apply only to FIFO queues.
# You can't change it for an existing queue. When you set this attribute, you must also provide the `MessageGroupId` for your messages explicitly.
# + contentBasedDeduplication - Enables content-based deduplication. Apply only to FIFO queues.
# + deduplicationScope - Specifies whether message deduplication occurs at the message group or queue level. Apply only to high throughput for FIFO queues. 
# + fifoThroughputLimit - Specifies whether the FIFO queue throughput quota applies to the entire queue or per message group. Apply only to high throughput for FIFO queues. 
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

# Dead-letter queue redrive policy.
#
# + deadLetterTargetArn - The Amazon Resource Name (ARN) of the dead-letter queue to which Amazon SQS moves messages after the value of `maxReceiveCount` is exceeded.
# + maxReceiveCount - The number of times a message is delivered to the source queue before being moved to the dead-letter queue. Default: 10. When the `ReceiveCount` for a message exceeds the `maxReceiveCount` for a queue,
# Amazon SQS moves the message to the dead-letter-queue.
public type RedrivePolicy record {|
   string deadLetterTargetArn?;
   int maxReceiveCount?;
|};

# Redrive permission policy for a dead-letter queue.
#
# + redrivePermission - The permission type that defines which source queues can specify the current queue as the dead-letter queue.
# Valid values are:
#   - `allowAll` – (Default) Any source queues in this AWS account in the same Region can specify this queue as the dead-letter queue.
#   - `denyAll` – No source queues can specify this queue as the dead-letter queue.
#   - `byQueue` – Only queues specified by the `sourceQueueArns` parameter can specify this queue as the dead-letter queue
# + sourceQueueArns - An array of Amazon Resource Names (ARNs) of source queues that can specify the current queue as the dead-letter queue.
public type RedriveAllowPolicy record {|
   RedrivePermission redrivePermission = ALLOW_ALL;
   string[] sourceQueueArns?;
|};

# Allowed redrive permission values.
public enum RedrivePermission {
   ALLOW_ALL = "allowAll",
   DENY_ALL = "denyAll",
   BY_QUEUE = "byQueue"
};

# Represents the scope of deduplication for FIFO queues.
public enum DeduplicationScope{
   MESSAGE_GROUP = "messageGroup",
   QUEUE = "queue"
};

# Represents the throughput limit for FIFO queues.
public enum FifoThroughputLimit {
   PER_MESSAGE_GROUP_ID = "perMessageGroupId",
   PER_QUEUE = "perQueue"
};
