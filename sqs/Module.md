## Overview
Ballerina connector for Amazon SQS connects the Amazon SQS API via Ballerina language with ease. It provides capability to perform operations related to queues and messages.

This module supports [Amazon SQS API](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html) version 2012-11-05.

## Prerequisites
Before using this connector in your Ballerina application, complete the following:
* Create an [AWS account](https://aws.amazon.com)
* Obtain tokens - Follow [this link](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/) to obtain Access key ID, Secret access key, Region and Account number from navigation pane `Users` and selecting `Security credentials` tab.

## Quickstart

To use the Amazon SQS connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector
Import the ballerinax/aws.sqs module into the Ballerina project as follows.
```ballerina
import ballerinax/aws.sqs;
```
### Step 2: Create a new connector instance

You can now enter the credentials in the SQS client configuration and create the SQS client by passing the configuration as follows.

```ballerina
sqs:ConnectionConfig configuration = {
    accessKey: "<ACCESS_KEY_ID>",
    secretKey: "<SECRET_ACCESS_KEY>",
    region: "<REGION>",
    accountNumber: "<ACCOUNT_NUMBER>"
};

sqs:Client sqsClient = check new (configuration);
```

### Step 3: Invoke connector operation

1. You can create a queue in SQS as follows with `createQueue` method for a preferred queue name and the required set of attributes.

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

**[You can find more samples here](https://github.com/ballerina-platform/module-ballerinax-aws.sqs/tree/master/sqs/samples)**
