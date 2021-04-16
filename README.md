[![Build Status](https://travis-ci.org/ballerina-platform/module-amazonsqs.svg?branch=master)](https://travis-ci.org/ballerina-platform/module-amazonsqs)

# Ballerina Amazon SQS Connector

Amazon SQS Connector allows you to connect to the Amazon Simple Queue Service (SQS) via REST API from Ballerina.

## Key Features of Amazon SQS
* Manage queues
* Manage messages 

## Connector Overview

The Amazon SQS Connector allows you to access the Amazon SQS REST API through Ballerina. The following sections provide the details on client operations.

**Client Operations**
Connector contains operations that create and delete queue, send messages, receive messages and delete messages in a queue.


![image](docs/images/aws_sqs_connector.png)

## Compatibility
| Ballerina Language Versions | Amazon SQS API version  |
| --------------------------- | ----------------------  |
|     Swan Lake Alpha 4       |        2012-11-05       |

The following sections provide you with information on how to use the Ballerina Amazon SQS connector.

### Contribute to development

Clone the repository by running the following command 
```shell
git clone git@github.com:ballerina-platform/module-ballerinax-aws.sqs.git
```

### Signing Up for AWS

1. Navigate to [Amazon](https://aws.amazon.com), and then click `Create an AWS Account`.  

    **Note**: If you previously signed in to the AWS Management Console using the root user credentials of the AWS account, click `Sign in` to use a different account. If you previously signed in to the console using the IAM credentials, sign in using the credentials of the root account.

2. Click `Create a new AWS account` and follow the given instructions.  

Follow the method explained below to obtain AWS credentials.

### Obtaining Access Key ID and Secret Access Key to Run the Sample

1. Sign in to the AWS Management Console and open the IAM console at https://console.aws.amazon.com/iam/.
2. In the navigation pane, choose `Users`.
3. Choose the name of the user whose access keys you want to create, and then choose the `Security credentials` tab.
4. In the `Access keys` section, choose `Create access key`.
5. To view the new access key pair, choose `Show`. You will not have access to the secret access key again after this dialog box closes. Your credentials will look something like this:
    - Access key ID: AKIAIOSFODNN7EXAMPLE
    - Secret access key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY  

For more information please visit https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-setting-up.html .  

# Running Tests
1. Create Config.toml file in module-ballerinax-aws.s3 with the following configurations and provide appropriate value.
```ballerina
accessKeyId = "testAccessKeyValue"
secretAccessKey = "testSecretAccessKeyValue"
region = "testRegion"
accountNumber = "testAccountNumber"
```
2. Navigate to the `module-ballerinax-aws.sqs` directory.
3. Run tests :
```ballerina
bal test
```

# Quickstart

## Import the AWS SQS module
First, import the ballerinax/aws.sqs module into the Ballerina project.

```ballerina
import ballerinax/aws.sqs;
```

## Initialize the AWS SQS Client giving necessary credentials

You can now enter the credentials in the SQS client configuration and create SQS client by passing the configuration:

```ballerina
sqs:Configuration configuration = {
    accessKey: "<ACCESS_KEY_ID>",
    secretKey: "<SECRET_ACCESS_KEY>",
    region: "<REGION>",
    accountNumber: "<ACCOUNT_NUMBER>"
};

sqs:Client sqsClient = check new (configuration);
```

If you want to add your own key store to define the `secureSocketConfig`, change the SQS configuration as
mentioned below.

```ballerina
sqs:Configuration configuration = {
    accessKey: "<ACCESS_KEY_ID>",
    secretKey: "<SECRET_ACCESS_KEY>",
    region: "<REGION>",
    accountNumber: "<ACCOUNT_NUMBER>",
    secureSocketConfig: {
        trustStore: {
            path: "<TRUSTSTORE_PATH>",
            password: "<TRUSTSTORE_PASSWORD>"
        }
    }
};
```
## Creating a SQS Queue

You can create a queue in SQS as follows with `createQueue` method for a preferred queue name and the required set of attributes. Successful creation returns the created queue URL as a string and the error cases returns an `error` object.

```ballerina
map<string> attributes = {};
attributes["VisibilityTimeout"] = "400";
attributes["FifoQueue"] = "true";

string|error response = sqsClient->createQueue("demo.fifo", attributes);
if (response is string) {
    log:printInfo("Created queue URL: " + response);
}
```

## Sending a Message to a SQS Queue

You can send a message to SQS as follows with `sendMessage` method. Use message to be sent, appropriate attribute parameters for the queue, and the path to the queue from AWS host address as parameters to the operation. Successful send operation returns an `OutboundMessage` object and the error cases return an `error` object.

```ballerina
map<string> attributes = {};
attributes["MessageDeduplicationId"] = "duplicationID1";
attributes["MessageGroupId"] = "groupID1";
attributes["MessageAttribute.1.Name"] = "Name1";
attributes["MessageAttribute.1.Value.StringValue"] = "Value1";
attributes["MessageAttribute.1.Value.DataType"] = "String";
attributes["MessageAttribute.2.Name"] = "Name2";
attributes["MessageAttribute.2.Value.StringValue"] = "Value2";
attributes["MessageAttribute.2.Value.DataType"] = "String";
string queueUrl = "";
sqs:OutboundMessage|error response = sqsClient->sendMessage("Sample text message.", "/123456789012/demo.fifo",
    attributes);
if (response is sqs:OutboundMessage) {
    log:printInfo("Sent message to SQS. MessageID: " + response.messageId);
}
```

## Receiving a Message from the SQS Queue

A sent message can be received with `receiveMessage` method. The path to the queue from the AWS host address and appropriate attribute parameters should be used as the parameters for the operation. A successful receive operation returns an array of `InboundMessage` objects, each containing the message and the `receiptHandler`, while the error cases returns an `error` object.

```ballerina
map<string> attributes = {};
attributes["MaxNumberOfMessages"] = "1";
attributes["VisibilityTimeout"] = "600";
attributes["WaitTimeSeconds"] = "2";
attributes["AttributeName.1"] = "SenderId";
attributes["MessageAttributeName.1"] = "Name2";
sqs:InboundMessage[]|error response = sqsClient->receiveMessage("/123456789012/demo.fifo", attributes);
if (response is sqs:InboundMessage[]) {
    log:printInfo("Successfully received the message. Message body of the first message: " + response[0].body);
    log:printInfo("\nReceipt Handle: " + response[0].receiptHandle);
}
```

## Deleting a Message from the SQS Queue

A received message should be deleted with the `deleteMessage` method within `VisibilityTimeout` number of seconds, providing the received `receiptHandler` string. A successful delete operation returns a boolean value `true` and the error cases return a `false` value or an `error` object.

```ballerina
boolean|error response = sqsClient->deleteMessage("/123456789012/demo.fifo", "AQEBnLBA/U5jSFADa0ZxCq2qCwpYE3biqcWOUrjzci0tB6LXG1Jyt4IZm8330mmghWuBeCovsXEiphTSXgkz2zNQFnnD/oSBnvAy8XTfA0hscepBMS2sdA81L/jNmR4mVl3dERQwwT1oJM4S2NwjXMGdjmERn/h8jok39ucnlSMJBfbPMUQ1VSHv7WCUheR/DHpVPhGlk2s5mUfAgmF5/srFsSr2NQmDG61wdNiU9LQgH3QR45c7KRtpepeyGAPKejqpKA0bPj6aw3oXSUOqNXAJmg==");
if (response is boolean) {
    if (response) {
        log:printInfo("Successfully deleted the message from the queue.");
    }
}
```

## Deleting SQS Queue

A queue should be deleted with the `deleteQueue` method. A successful delete operation returns a boolean value `true` and the error cases return a `false` value or an `error` object.

```ballerina
boolean|error response = sqsClient->deleteQueue("/123456789012/demo.fifo");
if (response is boolean) {
    if (response) {
        log:printInfo("Successfully deleted the queue.");
    }
}
```

# Sample
Samples are available at : https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/samples. To run a sample, create a new TOML file with name Config.toml in the same directory as the .bal file with above-mentioned configurable values.

## Managing SQS Standard Queue

This example describes how an SQS Standard Queue is created, a message is sent to it, received from the queue, and deleted from the queue.

```ballerina
import ballerina/log;
import ballerinax/aws.sqs;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;
configurable string accountNumber = ?;

public function main(string... args) {

    // Add the SQS credentials as the Configuration
    sqs:Configuration configuration = {
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
        region: region,
        accountNumber: accountNumber
    };

    sqs:Client sqsClient = new(configuration);

    // Declare common variables
    string queueResourcePath = "";
    string receivedReceiptHandler = "";

    // Create a new SQS standard queue named "myQueue"
    map<string> attributes = {};
    string|error response1 = sqsClient->createQueue("myQueue", attributes);
    if (response1 is string) {
        log:printInfo("Created queue URL: " + response1);
        // Keep the queue URL for future operations
        queueResourcePath = sqs:splitString(response1, "amazonaws.com", 1);
    } else {
        log:printInfo("Error occurred while creating a queue");
    }

    // Send a message to the created queue
    attributes = {};
    attributes["MessageAttribute.1.Name"] = "Name1";
    attributes["MessageAttribute.1.Value.StringValue"] = "Value1";
    attributes["MessageAttribute.1.Value.DataType"] = "String";
    attributes["MessageAttribute.2.Name"] = "Name2";
    attributes["MessageAttribute.2.Value.StringValue"] = "Value2";
    attributes["MessageAttribute.2.Value.DataType"] = "String";
    string queueUrl = "";
    sqs:OutboundMessage|error response2 = sqsClient->sendMessage("Sample text message.", queueResourcePath,
        attributes);
    if (response2 is sqs:OutboundMessage) {
        log:printInfo("Sent message to SQS. MessageID: " + response2.messageId);
    }

    // Receive a message from the queue
    attributes = {};
    attributes["MaxNumberOfMessages"] = "1";
    attributes["VisibilityTimeout"] = "600";
    attributes["WaitTimeSeconds"] = "2";
    attributes["AttributeName.1"] = "SenderId";
    attributes["MessageAttributeName.1"] = "Name2";
    sqs:InboundMessage[]|error response3 = sqsClient->receiveMessage(queueResourcePath, attributes);
    if (response3 is sqs:InboundMessage[] && response3.length() > 0) {
        log:printInfo("Successfully received the message. Message body: " + response3[0].body);
        log:printInfo("\nReceipt Handle: " + response3[0].receiptHandle);
        // Keep receipt handle for deleting the message from the queue
        receivedReceiptHandler = response3[0].receiptHandle;
    }

    // Delete the received the message from the queue
    boolean|error response4 = sqsClient->deleteMessage(queueResourcePath, receivedReceiptHandler);
    if (response4 is boolean && response4) {
        if (response4) {
            log:printInfo("Successfully deleted the message from the queue.");
        }
    }

    // Delete the queue
    boolean|error response5 = sqsClient->deleteQueue(queueResourcePath);
    if (response is boolean && response5) {
        log:printInfo("Successfully deleted the queue.");
    }
}
```

## Managing SQS FIFO Queue

This example describes how a SQS FIFO Queue is created, a message is sent to it, received from the queue, and deleted from the queue. 

```ballerina
import ballerina/log;
import ballerinax/aws.sqs;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;
configurable string accountNumber = ?;

public function main(string... args) {

    // Add the SQS credentials as the Configuration
    sqs:Configuration configuration = {
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
        region: region,
        accountNumber: accountNumber
    };

    sqs:Client sqsClient = check new (configuration);

    // Declare common variables
    string queueResourcePath = "";
    string receivedReceiptHandler = "";

    // Create a new SQS FIFO queue named "demo.fifo"
    map<string> attributes = {};
    attributes["VisibilityTimeout"] = "400";
    attributes["FifoQueue"] = "true";

    string|error response1 = sqsClient->createQueue("demo.fifo", attributes);
    if (response1 is string) {
        log:printInfo("Created queue URL: " + response1);
        // Keep the queue URL for future operations
        queueResourcePath = sqs:splitString(response1, "amazonaws.com", 1);
    }

    // Send a message to the created queue
    attributes = {};
    attributes["MessageDeduplicationId"] = "duplicationID1";
    attributes["MessageGroupId"] = "groupID1";
    attributes["MessageAttribute.1.Name"] = "Name1";
    attributes["MessageAttribute.1.Value.StringValue"] = "Value1";
    attributes["MessageAttribute.1.Value.DataType"] = "String";
    attributes["MessageAttribute.2.Name"] = "Name2";
    attributes["MessageAttribute.2.Value.StringValue"] = "Value2";
    attributes["MessageAttribute.2.Value.DataType"] = "String";
    string queueUrl = "";
    sqs:OutboundMessage|error response2 = sqsClient->sendMessage("Sample text message.", queueResourcePath,
        attributes);
    if (response2 is sqs:OutboundMessage) {
        log:printInfo("Sent message to SQS. MessageID: " + response2.messageId);
    }

    // Receive a message from the queue
    attributes = {};
    attributes["MaxNumberOfMessages"] = "1";
    attributes["VisibilityTimeout"] = "600";
    attributes["WaitTimeSeconds"] = "2";
    attributes["AttributeName.1"] = "SenderId";
    attributes["MessageAttributeName.1"] = "Name2";
    sqs:InboundMessage[]|error response3 = sqsClient->receiveMessage(queueResourcePath, attributes);
    if (response3 is sqs:InboundMessage[] && response3.length() > 0) {
        log:printInfo("Successfully received the message. Message body: " + response3[0].body);
        log:printInfo("\nReceipt Handle: " + response3[0].receiptHandle);
        // Keep receipt handle for deleting the message from the queue
        receivedReceiptHandler = response3[0].receiptHandle;
    }

    // Delete the received the message from the queue
    boolean|error response4 = sqsClient->deleteMessage(queueResourcePath, receivedReceiptHandler);
    if (response4 is boolean && response4) {
        log:printInfo("Successfully deleted the message from the queue.");
    }

    // Delete the queue
    boolean|error response5 = sqsClient->deleteQueue(queueResourcePath);
    if (response is boolean && response5) {
        log:printInfo("Successfully deleted the queue.");
    }
}
```
### Pull the Module
You can pull the Amazon SQS client from Ballerina Central:
```shell
$ bal pull ballerinax/aws.sqs
```

### Building the Source
Execute the commands below to build from the source after installing Ballerina SLAlpha2 version.

1. Clone this repository using the following command:
    ```shell
    $ git clone https://github.com/ballerina-platform/module-ballerinax-aws.sqs.git
    ```

2. Run this command from the `module-ballerinax-aws.sqs` root directory:
    ```shell
    $ bal build
    ```

3. To build the module without the tests:
    ```shell 
    $ bal build --skip-tests
    ```

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community. 

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of Conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful Links

* Discuss the code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Slack channel](https://ballerina.io/community/slack/).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.


## How you can contribute

As an open source project, we welcome contributions from the community. Check the [issue tracker](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/issues) for open issues that interest you. We look forward to receiving your contributions.