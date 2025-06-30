import ballerina/test;

@test:Config {
    groups: ["tagQueue"]
}

isolated function testTagQueue() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    map<string> tags = {
        "env": "dev",
        "version": "0.1.1"
    };

    Error? result = sqsClient->tagQueue(queueUrl, tags);

}
