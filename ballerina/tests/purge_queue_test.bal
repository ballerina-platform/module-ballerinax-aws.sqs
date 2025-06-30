
import ballerina/test;

@test:Config {
    groups: ["purgeQueue"]
}

isolated function testPurgeQueue() returns error? {
    string queueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";

    Error? result = sqsClient->purgeQueue(queueUrl);
    test:assertFalse(result is error, msg = "purgeQueue should not return an error");

}
