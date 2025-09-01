# Ballerina AWS SQS Library

[![Build](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/actions/workflows/build-timestamped-master.yml)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.sqs/branch/master/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-aws.sqs)
[![Trivy](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/actions/workflows/trivy-scan.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/actions/workflows/trivy-scan.yml)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/actions/workflows/build-with-bal-test-graalvm.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/actions/workflows/build-with-bal-test-native.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-aws.sqs.svg)](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/commits/master)

## Overview

[Amazon Simple Queue Service (SQS)](https://docs.aws.amazon.com/sqs/latest/dg/welcome.html) is a fully managed message queuing service provided by Amazon Web Services (AWS) that enables you to decouple and scale microservices, distributed systems, and serverless applications.

The `ballerinax/aws.sqs` package allows developers to interact with Amazon SQS seamlessly using Ballerina. This connector provides capabilities to send, receive, delete messages, and manage SQS queues programmatically.

## Setup guide

### Login to AWS Console

Log into the [AWS Management Console](https://console.aws.amazon.com/console). If you don’t have an AWS account yet, you can create one by visiting the AWS [sign-up](https://aws.amazon.com/free/) page. Sign up is free, and you can explore many services under the Free Tier.

### Create a user

1. In the AWS Management Console, search for IAM in the services search bar.
2. Click on IAM

   ![create-user-1.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sqs/refs/heads/master/docs/setup/resources/create-user-1.png)

3. Click Users

   ![create-user-2.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sqs/refs/heads/master/docs/setup/resources/create-user-2.png)

4. Click Create User

   ![create-user-3.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sqs/refs/heads/master/docs/setup/resources/create-user-3.png)

5. Provide a suitable name for the user and continue

   ![specify-user-details.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sqs/refs/heads/master/docs/setup/resources/specify-user-details.png)

6. Add necessary permissions by adding the user to a user group, copy permissions or directly attach the policies. And click next.

   ![set-user-permissions.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sqs/refs/heads/master/docs/setup/resources/set-user-permissions.png)
7. Review and create the user

   ![review-create-user.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sqs/refs/heads/master/docs/setup/resources/review-create-user.png)

### Get user access keys

1. Click the user that created

   ![users.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sqs/refs/heads/master/docs/setup/resources/users.png)

2. Click `Create access key`

   ![create-access-key-1.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sqs/refs/heads/master/docs/setup/resources/create-access-key-1.png)

3. Click your use case and click next.

   ![select-usecase.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sqs/refs/heads/master/docs/setup/resources/select-usecase.png)

4. Record the Access Key and Secret access key. These credentials will be used to authenticate your Ballerina application with Amazon SQS.

   ![retrieve-access-key.png](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-aws.sqs/refs/heads/master/docs/setup/resources/retrieve-access-key.png)

## Quickstart

To use the `aws.sqs` connector in your Ballerina project, modify the .bal file as follows.

### Step 1: Import the module

```ballerina
import ballerinax/aws.sqs;
```

### Step 2: Instantiate a new connector

Create a new `sqs:Client` by providing the region and authentication configurations.

```ballerina
configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;

sqs:Client sqsClient = check new ({
   region: sqs:US_EAST_1,
   auth: {
      accessKeyId,
      secretAccessKey
   }
});
```

#### Alternative authentication methods

##### Profile-based authentication

You can use AWS profile-based authentication as an alternative to static credentials.

```ballerina
sqs:Client sqsClient = check new ({
   region: sqs:US_EAST_1,
   auth: {
      profileName: "myAwsProfile",
      credentialsFilePath: "/path/to/custom/credentials"
   }
});
```

> **Note:** Ensure your AWS credentials file follows the standard format.
>
> ```ini
> [default]
> aws_access_key_id = YOUR_ACCESS_KEY_ID
> aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
>
> [myAwsProfile]
> aws_access_key_id = ANOTHER_ACCESS_KEY_ID
> aws_secret_access_key = ANOTHER_SECRET_ACCESS_KEY
> ```


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

## Examples


The `ballerinax/aws.sqs` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/examples):

1. [**Basic Queue Consumer**](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/examples/basic-queue-consumer) – Demonstrates creating a standard SQS queue, sending messages, and consuming them using a Ballerina listener.
2. [**Basic Queue Operations**](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/examples/basic-queue-operations) – Shows how to create a queue, send, receive, and delete messages, and delete the queue.
3. [**Advanced Messaging Features**](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/examples/advanced-messaging-features) – Demonstrates advanced messaging features such as message attributes, batch sending, and custom queue attributes.
4. [**FIFO Queue**](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/examples/fifo-queue) – Shows how to work with FIFO queues, including sending messages with different `messageGroupId`s and grouping received messages.


## Build from the source

### Prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

   - [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
   - [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To debug package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

5. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

6. Publish the generated artifacts to the local Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToLocalCentral=true
   ```

7. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

- For more information go to the [`aws.sqs` package](https://lib.ballerina.io/ballerinax/aws.sqs/latest).
- For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
- Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
- Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.


