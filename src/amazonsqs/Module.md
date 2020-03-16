Connects to Amazon SQS service.

# Module Overview
Amazon SQS Connector allows you to connect to the Amazon SQS service via REST API from Ballerina. This connector allows you to create a new SQS queue, send messages to a queue, receive messages from a queue, and delete the received messages from the queue.

## Compatibility

|                    |    Versions     |  
|:------------------:|:---------------:|
| Ballerina Language |   1.2.x         |
| Amazon SQS API     |   2012-11-05    |


## Sample

First, import the `ballerinax/aws.sqs` module and other related modules into the Ballerina project and create a `main` method.

```ballerina
import ballerinax/aws.sqs;
```

The Amazon SQS connector can be instantiated using the Access Key ID, Secret Access Key, Region of the Amazon SQS geographic location, and the Account Number in the Amazon SQS client configuration.

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

**Create Amazon SQS client**

You can now enter the credentials in the SQS client configuration and create SQS client by passing the configuration:

```ballerina
aws.sqs:Configuration configuration = {
    accessKey: "<ACCESS_KEY_ID>",
    secretKey: "<SECRET_ACCESS_KEY>",
    region: "<REGION>",
    accountNumber: "<ACCOUNT_NUMBER>"
};

aws.sqs:Client sqsClient = new(configuration);
```

If you want to add your own key store to define the `secureSocketConfig`, change the SQS configuration as
mentioned below.

```ballerina
aws.sqs:Configuration configuration = {
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
**Creating a SQS Queue**

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

**Sending a Message to a SQS Queue**

You can send a message to SQS as follows with `sendMessage` method. Use message to be sent, appropriate attribute parameters for the queue, and the path to the queue from Amazon host address as parameters to the operation. Successful send operation returns an `OutboundMessage` object and the error cases return an `error` object.

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
aws.sqs:OutboundMessage|error response = sqsClient->sendMessage("Sample text message.", "/123456789012/demo.fifo",
    attributes);
if (response is aws.sqs:OutboundMessage) {
    log:printInfo("Sent message to SQS. MessageID: " + response.messageId);
}
```

**Receiving a Message from the SQS Queue**

A sent message can be received with `receiveMessage` method. The path to the queue from the Amazon host address and appropriate attribute parameters should be used as the parameters for the operation. A successful receive operation returns an array of `InboundMessage` objects, each containing the message and the `receiptHandler`, while the error cases returns an `error` object.

```ballerina
map<string> attributes = {};
attributes["MaxNumberOfMessages"] = "1";
attributes["VisibilityTimeout"] = "600";
attributes["WaitTimeSeconds"] = "2";
attributes["AttributeName.1"] = "SenderId";
attributes["MessageAttributeName.1"] = "Name2";
aws.sqs:InboundMessage[]|error response = sqsClient->receiveMessage("/123456789012/demo.fifo", attributes);
if (response is aws.sqs:InboundMessage[]) {
    log:printInfo("Successfully received the message. Message body of the first message: " + response[0].body);
    log:printInfo("\nReceipt Handle: " + response[0].receiptHandle);
}
```

**Deleting a Message from the SQS Queue**

A received message should be deleted with the `deleteMessage` method within `VisibilityTimeout` number of seconds, providing the received `receiptHandler` string. A successful delete operation returns a boolean value `true` and the error cases return a `false` value or an `error` object.

```ballerina
boolean|error response = sqsClient->deleteMessage("/123456789012/demo.fifo", "AQEBnLBA/U5jSFADa0ZxCq2qCwpYE3biqcWOUrjzci0tB6LXG1Jyt4IZm8330mmghWuBeCovsXEiphTSXgkz2zNQFnnD/oSBnvAy8XTfA0hscepBMS2sdA81L/jNmR4mVl3dERQwwT1oJM4S2NwjXMGdjmERn/h8jok39ucnlSMJBfbPMUQ1VSHv7WCUheR/DHpVPhGlk2s5mUfAgmF5/srFsSr2NQmDG61wdNiU9LQgH3QR45c7KRtpepeyGAPKejqpKA0bPj6aw3oXSUOqNXAJmg==");
if (response is boolean) {
    if (response) {
        log:printInfo("Successfully deleted the message from the queue.");
    }
}
```
## Example 1

This example describes how an SQS Standard Queue is created, a message is sent to it, received from the queue, and deleted from the queue.

```ballerina
import ballerina/log;
import ballerinax/aws.sqs;

public function main(string... args) {

    // Add the SQS credentials as the Configuration
    aws.sqs:Configuration configuration = {
        accessKey: "AKIAIOSFODNN7EXAMPLE",
        secretKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        region: "us-east-2",
        accountNumber: "610973236798"
    };

    aws.sqs:Client sqsClient = new(configuration);

    // Declare common variables
    string queueResourcePath = "";
    string receivedReceiptHandler = "";

    // Create a new SQS standard queue named "myQueue"
    map<string> attributes = {};
    string|error response1 = sqsClient->createQueue("myQueue", attributes);
    if (response1 is string) {
        log:printInfo("Created queue URL: " + response1);
        // Keep the queue URL for future operations
        queueResourcePath = aws.sqs:splitString(response1, "amazonaws.com", 1);
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
    aws.sqs:OutboundMessage|error response2 = sqsClient->sendMessage("Sample text message.", queueResourcePath,
        attributes);
    if (response2 is aws.sqs:OutboundMessage) {
        log:printInfo("Sent message to SQS. MessageID: " + response2.messageId);
    }

    // Receive a message from the queue
    attributes = {};
    attributes["MaxNumberOfMessages"] = "1";
    attributes["VisibilityTimeout"] = "600";
    attributes["WaitTimeSeconds"] = "2";
    attributes["AttributeName.1"] = "SenderId";
    attributes["MessageAttributeName.1"] = "Name2";
    aws.sqs:InboundMessage[]|error response3 = sqsClient->receiveMessage(queueResourcePath, attributes);
    if (response3 is aws.sqs:InboundMessage[] && response3.length() > 0) {
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

}
```

## Example 2

This example describes how a SQS FIFO Queue is created, a message is sent to it, received from the queue, and deleted from the queue. 

```ballerina
import ballerina/log;
import ballerinax/aws.sqs;

public function main(string... args) {

    // Add the SQS credentials as the Configuration
    aws.sqs:Configuration configuration = {
        accessKey: "<ACCESS_KEY>",
        secretKey: "<SECRET_ACCESS>",
        region: "<REGION>",
        accountNumber: "<ACCOUNT_NUMBER>"
    };

    aws.sqs:Client sqsClient = new(configuration);

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
        queueResourcePath = aws.sqs:splitString(response1, "amazonaws.com", 1);
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
    aws.sqs:OutboundMessage|error response2 = sqsClient->sendMessage("Sample text message.", queueResourcePath,
        attributes);
    if (response2 is aws.sqs:OutboundMessage) {
        log:printInfo("Sent message to SQS. MessageID: " + response2.messageId);
    }

    // Receive a message from the queue
    attributes = {};
    attributes["MaxNumberOfMessages"] = "1";
    attributes["VisibilityTimeout"] = "600";
    attributes["WaitTimeSeconds"] = "2";
    attributes["AttributeName.1"] = "SenderId";
    attributes["MessageAttributeName.1"] = "Name2";
    aws.sqs:InboundMessage[]|error response3 = sqsClient->receiveMessage(queueResourcePath, attributes);
    if (response3 is aws.sqs:InboundMessage[] && response3.length() > 0) {
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

}
```
