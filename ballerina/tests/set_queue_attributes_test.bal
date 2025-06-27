import ballerina/io;
import ballerina/test;

@test:Config {
    groups: ["setQueueAttributes"]
}

isolated function testSetQueueAttribues() returns error? {
    string url = "https://sqs.eu-north-1.amazonaws.com/284495578152/setqueueAttributestest";
    QueueAttributes attributes = {
        delaySeconds: 78
    };
    Error? result = sqsClient->setQueueAttributes(url, attributes);
    io:print(result);
    test:assertTrue(result is ());
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "MissingParameter");
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorMessage, "The request must contain the parameter Attribute.Name.");
    }
}

@test:Config {
    groups: ["setQueueAttributes"]
}
isolated function testSetQueueAttribuesWithInvalidDelay() returns error? {
    string url = "https://sqs.eu-north-1.amazonaws.com/284495578152/setqueueAttributestest";
    QueueAttributes attributes = {
        delaySeconds: 901
    };
    Error? result = sqsClient->setQueueAttributes(url, attributes);
    io:print(result);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "InvalidAttributeValue");
        test:assertEquals(details.httpStatusCode, 400);
        test:assertEquals(details.errorMessage, "Invalid value for the parameter DelaySeconds.");
    }
}
