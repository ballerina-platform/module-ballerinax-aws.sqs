import ballerina/test;

@test:Config {
    groups: ["createQueue"]
}

isolated function testCreateStandardQueue() returns error? {
    string queueName = "standard-test-queue";
    string|Error result = sqsClient->createQueue(queueName);
    if result is string {
        test:assertTrue(result.endsWith(queueName));
    } else {
        test:assertFail("Queue creation failed: " + result.toString());
    }
}

@test:Config {
    groups: ["createQueue"]
}
isolated function testCreateFifoQueue() returns error? {
    string queueName = "FIFO-test-queue.fifo";
    CreateQueueConfig config = {
        queueAttributes: {
            fifoQueue: true
        }
    };
    string|Error result = sqsClient->createQueue(queueName, config);
    if result is string {
        test:assertTrue(result.endsWith(queueName));
    } else {
        test:assertFail("Queue creation failed: " + result.toString());
    }
}


@test:Config {
    groups: ["createQueue"]
}
isolated function testCreateQueueWithInvalidName() returns error? {
    string queueName = "invalid/name";
    string|Error result = sqsClient->createQueue(queueName);
    test:assertTrue(result is Error);
    if result is error {
        ErrorDetails details = result.detail();
        test:assertEquals(details.errorCode, "InvalidParameterValue");
        test:assertEquals(details.httpStatusCode,400);
        test:assertEquals(details.errorMessage, "Can only include alphanumeric characters, hyphens, or underscores. 1 to 80 in length");
    }
}

@test:Config {
    groups: ["createQueue"]
}
isolated function testCreateQueueWithAttributes() returns error? {
    string queueName = "attr-test-queue-2";
    CreateQueueConfig config = {
        queueAttributes: {
            delaySeconds: 5,
            maximumMessageSize: 2048,
            messageRetentionPeriod: 86400,
            receiveMessageWaitTimeSeconds: 10,
            visibilityTimeout: 30,
            redrivePolicy: {
                deadLetterTargetArn: "arn:aws:sqs:eu-north-1:284495578152:standard-test-queue",
                maxReceiveCount: 4
                },
            sqsManagedSseEnabled: true,
            redriveAllowPolicy: {
                redrivePermission: "byQueue",
                sourceQueueArns: ["arn:aws:sqs:eu-north-1:284495578152:standard-test-queue"]
            }
        }
    };
    string|error result = sqsClient->createQueue(queueName, config);
    if result is string {
        test:assertTrue(result.endsWith(queueName));
    } else {
        test:assertFail("Queue creation with attributes failed: " + result.toString());
    }
}

@test:Config {
    groups: ["createQueue"]
}
isolated function testCreateQueueWithTags() returns error? {
    string queueName = "tagged-queue";
    CreateQueueConfig config = {
        tags: {
            "env": "dev",
            "project": "sqs"
        }
    };
    string|error result = sqsClient->createQueue(queueName, config);
    if result is string {
        test:assertTrue(result.endsWith(queueName));
    } else {
        test:assertFail("Queue creation with tags failed: " + result.toString());
    }
}

