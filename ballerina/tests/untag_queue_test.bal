import ballerina/test;

@test:Config {
    groups: ["tagQueue"]
}

isolated function testUntagQueue() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    string[] tags = ["env", "version"];

    Error? result = sqsClient->untagQueue(queueUrl, tags);

}
