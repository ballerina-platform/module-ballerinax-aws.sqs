Connects to Amazon SQS service.

# Module Overview

## Compatibility
| Ballerina Language Version 
| -------------------------- 
| 0.990.3                    

## Sample

```ballerina
import ballerina/config;
import ballerina/io;
import wso2/amazonrekn;
import wso2/amazoncommons;

amazonsqs:Configuration configuration = {
    accessKey: config:getAsString("ACCESS_KEY_ID"),
    secretKey: config:getAsString("SECRET_ACCESS_KEY"),
    region: config:getAsString("REGION"),
    accountNumber: config:getAsString("ACCOUNT_NUMBER")
};

amazonsqs:Client sqsClient = new(config);

public function main() {
    map<string> attributes = {};
    attributes["VisibilityTimeout"] = "400";
    attributes["FifoQueue"] = "true";

    string|error response = sqsClient->createQueue("demo.fifo", attributes);
    if(response is string && response.hasPrefix("http")) {
        log:printInfo("Created queue: \n" + response);
    }
}
```
