import ballerina/test;
import ballerina/io;

@test:Config {
    groups: ["listQueues"]
}
isolated function testListQueues() returns error? {
    ListQueuesResponse|Error result = sqsClient->listQueues();
    test:assertTrue(result is ListQueuesResponse);
    io:print(result);
}

@test:Config {
    groups: ["listQueues"]
}
isolated function testListQueuesWithPrefix() returns error? {
    
    ListQueuesConfig config = {
        queueNamePrefix: "attr"
        };

    ListQueuesResponse|Error result = sqsClient->listQueues(config);
    io:print(result);     
}

@test:Config {
    groups: ["listQueues"]
}
isolated function testListQueuesWithMaxResult() returns error? {
    
    ListQueuesConfig config = {
        maxResults: 3
        };

    ListQueuesResponse|Error result = sqsClient->listQueues(config);
    io:print(result); 

}

@test:Config {
    groups: ["listQueues"]
}
isolated function testListQueuesPagination() returns error? {
    
    ListQueuesConfig config1 = {
        maxResults: 2
    };

    ListQueuesResponse|Error firstPage = sqsClient->listQueues(config1);
    io:println("First page: ", firstPage);

    if firstPage is ListQueuesResponse {
        test:assertEquals(firstPage.queueUrls.length(), 2, msg = "Expected 2 queues in first page");
        test:assertNotEquals(firstPage.nextToken, (), msg = "Expected nextToken in first page");

        if firstPage.nextToken is string {
            string? nextPageToken = firstPage.nextToken;

            ListQueuesConfig config2 = {
                maxResults: 10,
                nextToken: nextPageToken
            };

            ListQueuesResponse|Error secondPage = sqsClient->listQueues(config2);
            io:println("Second page: ", secondPage);

            if secondPage is ListQueuesResponse {
                test:assertTrue(secondPage.queueUrls.length() > 0, msg = "Expected at least 1 queue in second page");
            }
        } else {
            test:assertFail("Expected nextToken to be present in first page");
        }
    }
}