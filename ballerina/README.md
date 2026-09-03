## Overview

Amazon Simple Queue Service (SQS) is a fully managed message queuing service that enables you to decouple and scale microservices, distributed systems, and serverless applications. It provides a reliable and highly scalable way to exchange messages between different components. The AWS SQS connector allows you to interact with SQS queues, enabling efficient message processing in the cloud.

### Key Features

- Fully managed and highly scalable message queuing
- Support for both standard and FIFO queues
- Reliable message delivery with dead-letter queue support
- Secure communication with AWS IAM authentication
- Simplified message production and consumption
- GraalVM compatible for native image builds

## Setup guide

### Obtain IAM user credentials

To create an IAM user and generate an access key, follow the [obtaining IAM user credentials](https://central.ballerina.io/ballerinax/aws/latest#obtaining-iam-user-credentials) guide.

Attach the SQS permissions your application needs to the user — the AWS managed `AmazonSQSFullAccess` policy grants full access, or scope a custom policy to only the SQS actions you call.

## Quickstart

To use the `aws.sqs` connector in your Ballerina project, modify the .bal file as follows.

### Step 1: Import the module

```ballerina
import ballerinax/aws;
import ballerinax/aws.sqs;
```

### Step 2: Instantiate a new connector

Create a new `sqs:Client` by providing the region and authentication configurations.

```ballerina
configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;

sqs:Client sqsClient = check new ({
   region: aws:US_EAST_1,
   auth: {
      accessKeyId,
      secretAccessKey
   }
});
```

### Step 3: Invoke the connector operations

Now, utilize the available connector operations.

#### Create a queue
```ballerina
string queueUrl = check sqsClient->createQueue("my-test-queue");
```

#### Send a message
```ballerina
sqs:SendMessageResponse response = check sqsClient->sendMessage(queueUrl, "Hello from Ballerina!");
```

#### Receive messages
```ballerina
sqs:Message[] messages = check sqsClient->receiveMessage(queueUrl);
```

#### Delete a message
```ballerina
check sqsClient->deleteMessage(queueUrl, receiptHandle);
```

#### Batch operations
```ballerina
// Send multiple messages at once
sqs:SendMessageBatchEntry[] entries = [
    {id: "msg1", body: "First message"},
    {id: "msg2", body: "Second message", delaySeconds: 5}
];
sqs:SendMessageBatchResponse batchResponse = check sqsClient->sendMessageBatch(queueUrl, entries);

// Delete multiple messages at once
sqs:DeleteMessageBatchEntry[] deleteEntries = [
    {id: "del1", receiptHandle: "receipt-handle-1"},
    {id: "del2", receiptHandle: "receipt-handle-2"}
];
sqs:DeleteMessageBatchResponse deleteResponse = check sqsClient->deleteMessageBatch(queueUrl, deleteEntries);
```

#### Queue management
```ballerina
// List all queues
sqs:ListQueuesResponse queues = check sqsClient->listQueues();

// Get queue attributes
sqs:GetQueueAttributesResponse attributes = check sqsClient->getQueueAttributes(queueUrl);

// Set queue attributes
sqs:QueueAttributes newAttributes = {
    visibilityTimeout: 300,
    messageRetentionPeriod: 1209600 // 14 days
};
check sqsClient->setQueueAttributes(queueUrl, newAttributes);

// Delete a queue
check sqsClient->deleteQueue(queueUrl);
```

#### Working with FIFO queues

For First-In-First-Out (FIFO) queues, you need to provide additional parameters:

```ballerina
// Create a FIFO queue
sqs:QueueAttributes fifoAttributes = {
    fifoQueue: true,
    contentBasedDeduplication: true
};
string fifoQueueUrl = check sqsClient->createQueue("my-fifo-queue.fifo", queueAttributes = fifoAttributes);

// Send message to FIFO queue
sqs:SendMessageResponse fifoResponse = check sqsClient->sendMessage(
    fifoQueueUrl,
    "FIFO message",
    messageGroupId = "group1",
    messageDeduplicationId = "unique-id-1"
);
```

### Step 4: Run the Ballerina application

Use the following command to compile and run the Ballerina program.

```bash
bal run
```

### Alternative authentication methods

#### Profile-based authentication

You can use AWS profile-based authentication as an alternative to static credentials.

```ballerina
simpledb:Client sqsClient = check new ({
    region: aws:US_EAST_1,
    auth: {
        profileName: "myAwsProfile",
        credentialsFilePath: "/path/to/custom/credentials"
    }
});
```

#### Default credential provider chain

Resolves credentials automatically from the AWS SDK's default chain. This is the recommended option when the application runs on AWS infrastructure (EC2 instance roles, ECS task roles, EKS Pod Identity/IRSA), since no long-lived credentials need to be stored with the application. The assume-role, web identity, SSO, and credential-process options below also work without long-term access keys, when you need to select a specific source explicitly.

```ballerina
import ballerinax/aws.auth;

simpledb:Client sqsClient = check new ({
    region: aws:US_EAST_1,
    auth: auth:DEFAULT_CREDENTIALS
});
```

> **Note:** Beyond the three options above, the `auth` field also accepts `auth:AssumeRoleConfig` (STS assume-role), `auth:WebIdentityConfig` (web identity / OIDC), `auth:SsoAuthConfig` (IAM Identity Center), and `auth:ProcessAuthConfig` (external credential process). See the [`Ballerina AWS`](https://central.ballerina.io/ballerinax/aws/latest) documentation for details.

## Examples

The `ballerinax/aws.sqs` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/examples):

1. [**Basic Queue Consumer**](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/examples/basic-queue-consumer) – Demonstrates creating a standard SQS queue, sending messages, and consuming them using a Ballerina listener.
2. [**Basic Queue Operations**](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/examples/basic-queue-operations) – Shows how to create a queue, send, receive, and delete messages, and delete the queue.
3. [**Advanced Messaging Features**](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/examples/advanced-messaging-features) – Demonstrates advanced messaging features such as message attributes, batch sending, and custom queue attributes.
4. [**FIFO Queue**](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/examples/fifo-queue) – Shows how to work with FIFO queues, including sending messages with different `messageGroupId`s and grouping received messages.
