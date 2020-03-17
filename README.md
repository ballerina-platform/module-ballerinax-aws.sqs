[![Build Status](https://travis-ci.org/ballerina-platform/module-amazonsqs.svg?branch=master)](https://travis-ci.org/ballerina-platform/module-amazonsqs)

# Ballerina Amazon SQS Connector

Amazon SQS Connector allows you to connect to the Amazon Simple Queue Service (SQS) via REST API from Ballerina.

## Compatibility
| Ballerina Language Versions | Amazon SQS API version  |
| --------------------------- | ----------------------  |
|            1.2.x            | 2012-11-05              |

The following sections provide you with information on how to use the Ballerina Amazon SQS connector.

- [Contribute To Develop](#contribute-to-develop)
- [Working with Amazon SQS Connector Actions](#Working-with-Amazon-SQS-Connector)
- [Sample](#sample)

### Contribute to development

Clone the repository by running the following command 
```shell
git clone https://github.com/wso2-ballerina/module-amazonsqs.git
```

### Working with Amazon SQS Connector

First, import the `ballerinax/aws.sqs` module into the Ballerina project.

```ballerina
import ballerinax/aws.sqs;
```

In order for you to use the Amazon SQS Connector, first you need to create an Amazon SQS Client.

Ballerina provides a [config module](https://ballerina.io/v1-1/learn/by-example/config-api.html) to obtain parameters from the configuration file. Specify the configuration object and create the client as follows.

```ballerina
sqs:Configuration configuration = {
    accessKey: config:getAsString("ACCESS_KEY_ID"),
    secretKey: config:getAsString("SECRET_ACCESS_KEY"),
    region: config:getAsString("REGION"),
    accountNumber: config:getAsString("ACCOUNT_NUMBER")
};

sqs:Client sqsClient = new(configuration);
```

##### Sample

```ballerina
import ballerina/log;
import ballerinax/aws.sqs;

// Add the SQS credentials as the Configuration
sqs:Configuration configuration = {
    accessKey: "<ACCESS_KEY>",
    secretKey: "<SECRET_ACCESS>",
    region: "<REGION>",
    accountNumber: "<ACCOUNT_NUMBER>"
};

sqs:Client sqsClient = new(configuration);

public function main(string... args) {

    // Create a new SQS Standard queue named "newQueue"
    map<string> attributes = {};
    string|error response = sqsClient->createQueue("newQueue", attributes);
    if (response is string) {
        log:printInfo("Created queue URL: " + response);
    } else {
        log:printInfo("Error while creating a queue");
    }

}
```
