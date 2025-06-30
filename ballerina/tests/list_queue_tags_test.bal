import ballerina/io;
import ballerina/test;

@test:Config {
    groups: ["listQueueTags"]
}

isolated function testListQueueTags() returns error? {
    string queueurl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";
    ListQueueTagsResponse|Error result = sqsClient->listQueueTags(queueurl);
    io:print(result);
}
