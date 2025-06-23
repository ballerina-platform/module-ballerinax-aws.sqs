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
import ballerina/constraint;

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
   DelaySeconds delaySeconds?;
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


@constraint:String {
       pattern: {
           value: re `^https:\\/\\/sqs\.[a-z0-9-]+\\.amazonaws\\.com\\/[0-9]{12}\\/[a-zA-Z0-9_-]{1,80}(\\.fifo)?$`,
           message: "Invalid SQS queue URL format"
       }
   }
public type QueueUrl string;

@constraint:Int {
       minValue: {
           value: 0,
           message: "Delay must be at least 0 seconds"
       },
       maxValue: {
           value: 900,
           message: "Delay cannot exceed 900 seconds.(15 minutes)"
       }
   }
public type DelaySeconds int;
