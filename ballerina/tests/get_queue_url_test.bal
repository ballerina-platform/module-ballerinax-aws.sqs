import ballerina/test;
import ballerina/io;

@test:Config {
    groups: ["getQueueUrl"]
}
isolated function testGetQueueUrl() returns error? {
    string queueName = "TestQueue";
    string expectedQueueUrl = "https://sqs.eu-north-1.amazonaws.com/284495578152/TestQueue";

    string|Error? result = sqsClient->getQueueUrl(queueName);
    io:println(result);

    if result is string {
        test:assertEquals(result, expectedQueueUrl, msg = "Returned queue URL does not match the expected value.");
    } 
    
}

@test:Config {
    groups: ["getQueueUrl"]
}
isolated function testGetNonExistentQueueUrl() returns error? {
    string queueName = "TestQueue2";
    
    string|Error? result = sqsClient->getQueueUrl(queueName);
    io:println(result);

    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode,"AWS.SimpleQueueService.NonExistentQueue");
        test:assertEquals(details.errorMessage, "The specified queue does not exist.");
        test:assertEquals(details.httpStatusCode,400);
        
    } 
    
}
