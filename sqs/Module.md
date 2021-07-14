## Overview
Ballerina connector for Amazon SQS is connecting the Amazon SQS API via Ballerina language easily. It provides capability to perform operations related to queues and messages.

This module supports [Amazon SQS API](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html) version 2012-11-05.

## Prerequisites
Before using this connector in your Ballerina application, complete the following:
* Create [AWS account](https://aws.amazon.com)
* Obtaining tokens
        
    Follow [this link](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/) and obtain the Access key ID, Secret access key, Region and Account number from navigation pane `Users` and selecting `Security credentials` tab.

## Quickstart

To use the Amazon SQS connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector
First, import the ballerinax/aws.sqs module into the Ballerina project.
```ballerina
import ballerinax/aws.sqs;
```
### Step 2: Create a new connector instance

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

### Step 3: Invoke connector operation

1. You can create a queue in SQS as follows with `createQueue` method for a preferred queue name and the required set of attributes. Successful creation returns the created queue URL as a string and the error cases returns an `error` object.

    ```ballerina
    map<string> attributes = {};
    attributes["VisibilityTimeout"] = "400";
    attributes["FifoQueue"] = "true";

    string|error response = sqsClient->createQueue("demo.fifo", attributes);
    if (response is string) {
        log:printInfo("Created queue URL: " + response);
    }
    ```
2. Use `bal run` command to compile and run the Ballerina program. 

## Quick reference
The following code snippets shows how the connector operations can be used in different scenarios after initializing the client.
* Create SQS Queue
    ``` ballerina
    map<string> attributes = {};
    attributes["VisibilityTimeout"] = "400";
    attributes["FifoQueue"] = "true";

    string response = check sqsClient->createQueue("demo.fifo", attributes);
    ```

* Send message to a SQS Queue
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

    sqs:OutboundMessage response = check sqsClient->sendMessage("Sample text message.", "/123456789012/demo.fifo",
        attributes);
    ```

* Delete SQS Queue
    ```ballerina
    error? response = sqsClient->deleteQueue("/123456789012/demo.fifo");
    ```

**[You can find more samples here](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/sqs/samples)**
