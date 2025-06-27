import ballerina/io;
import ballerina/test;

@test:Config {
    groups: ["getQueueAttributes"]
}

isolated function testGetQueueAttributesAll() returns error? {

    GetQueueAttributesConfig config = {
        attributeNames: ["All"]
    };
    GetQueueAttributesResponse|Error result = sqsClient->getQueueAttributes("https://sqs.eu-north-1.amazonaws.com/284495578152/attr-test-queue-1", config);
    io:println(result);
}

@test:Config {
    groups: ["getQueueAttributes"]
}

isolated function testGetQueueAttributesWithoutConfig() returns error? {

    GetQueueAttributesResponse|Error result = sqsClient->getQueueAttributes("https://sqs.eu-north-1.amazonaws.com/284495578152/attr-test-queue-1");
    io:println(result);
}

@test:Config {
    groups: ["getQueueAttributes"]
}

isolated function testGetQueueAttributesWithSomeAttributes() returns error? {

    GetQueueAttributesConfig config = {
        attributeNames: [MAXIMUM_MESSAGE_SIZE, REDRIVE_ALLOW_POLICY, REDRIVE_POLICY]
    };
    GetQueueAttributesResponse|Error result = sqsClient->getQueueAttributes("https://sqs.eu-north-1.amazonaws.com/284495578152/attr-test-queue-1", config);
    io:println(result);

    test:assertTrue(result is GetQueueAttributesResponse);

    test:assertFalse(result is Error);
    if result is error {
        ErrorDetails detail = result.detail();
        test:assertEquals(detail.errorCode, "InvalidAttributeName");
        test:assertEquals(detail.errorMessage, "Unknown Attribute FifoQueue.");
        test:assertEquals(detail.httpStatusCode, 400);
    }
}
