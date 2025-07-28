// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/lang.runtime;
import ballerina/test;

isolated boolean autoDeleteMessageReceived = false;
isolated boolean manualDeleteMessageReceived = false;
isolated boolean batchMessageReceived = false;

ConnectionConfig connectionConfig = {
    region: awsRegion,
    auth: staticAuth
};

@test:BeforeGroups {
    value: ["listener"]
}
function setupQueue() returns error? {
    Client sqsClient = check new (connectionConfig);
    string _ = check sqsClient->createQueue("Test-1");
    string _ = check sqsClient->createQueue("Test-2");
    string _ = check sqsClient->createQueue("Test-3");
    string _ = check sqsClient->createQueue("Test-4");
    string _ = check sqsClient->createQueue("Test-5");
    string _ = check sqsClient->createQueue("Test-6");
    string _ = check sqsClient->createQueue("Test-7");
    string _ = check sqsClient->createQueue("Test-8");
    string _ = check sqsClient->createQueue("Test-9");
}

PollingConfig pollingConfig = {
    pollInterval: 1,
    waitTime: 20
};

final Listener sqsListener = check new (connectionConfig, pollingConfig);

@test:BeforeGroups {
    value: ["listener"]
}
isolated function setupListener() returns error? {

    Service autoDeleteService = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-1",
        autoDelete: true
    } service object {
        isolated remote function onMessage(Message message) returns error? {
            if message.body == "Hello World" {
                lock {
                    autoDeleteMessageReceived = true;
                }
            }
        }
    };
    Service manualDeleteService = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-2",
        autoDelete: false
    } service object {
        isolated remote function onMessage(Caller caller, Message message) returns error? {
            if message.body == "Manual Delete test" {
                lock {
                    manualDeleteMessageReceived = true;
                }
                check caller->delete();
            }
        }
    };
    Service batchService = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-5",
        autoDelete: true
    } service object {
        isolated remote function onMessage(Message message) returns error? {
            if message.body is string {
                string msgBody = message.body ?: " ";
                if msgBody.startsWith("Batch Message Test") {
                    lock {
                        batchMessageReceived = true;
                    }
                }
            }
        }
    };
    check sqsListener.attach(autoDeleteService);
    check sqsListener.attach(manualDeleteService);
    check sqsListener.attach(batchService);
    check sqsListener.'start();
}

@test:Config {
    groups: ["listener"]
}
isolated function testListenerAutoDelete() returns error? {
    SendMessageResponse _ = check sqsClient->sendMessage("https://sqs.us-east-2.amazonaws.com/284495578152/Test-1", "Hello World");
    int attempts = 0;
    int maxAttempts = 40;
    boolean received = false;
    while attempts < maxAttempts {
        lock {
            received = autoDeleteMessageReceived;
        }
        if received {
            break;
        }
        runtime:sleep(3);
        attempts += 1;
    }
    test:assertTrue(received, "Message was not received by the listener");
}

@test:Config {
    groups: ["listener"]
}
isolated function testListenerManualDelete() returns error? {
    SendMessageResponse _ = check sqsClient->sendMessage("https://sqs.us-east-2.amazonaws.com/284495578152/Test-2", "Manual Delete test");
    int attempts = 0;
    int maxAttempts = 40;
    boolean received = false;
    while attempts < maxAttempts {
        lock {
            received = manualDeleteMessageReceived;
        }
        if received {
            break;
        }
        runtime:sleep(3);
        attempts += 1;
    }
    test:assertTrue(received, "Message was not received by the listener");
}

@test:Config {
    groups: ["listener"]
}
isolated function testListenerServiceDetach() returns error? {
    Service detachService = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-3",
        autoDelete: true
    } service object {
        isolated remote function onMessage(Message message) returns error? {
        }
    };
    check sqsListener.attach(detachService);
    check sqsListener.detach(detachService);
}

@test:Config {
    groups: ["listener"]
}
function testListenerGracefulStop() returns error? {
    Listener sqsListenerGracefulStop = check new (connectionConfig, pollingConfig);
    Service stopService = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-4",
        autoDelete: true
    } service object {
        isolated remote function onMessage(Message message) returns error? {
        }
    };
    check sqsListenerGracefulStop.attach(stopService);
    check sqsListenerGracefulStop.'start();
    runtime:sleep(2);
    check sqsListenerGracefulStop.gracefulStop();
}

@test:Config {
    groups: ["listener"]
}
function testListenerImmediateStop() returns error? {
    Listener sqsListenerImmediateStop = check new (connectionConfig, pollingConfig);
    Service stopService = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-6",
        autoDelete: true
    } service object {
        isolated remote function onMessage(Message message) returns error? {
        }
    };
    check sqsListenerImmediateStop.attach(stopService);
    check sqsListenerImmediateStop.'start();
    runtime:sleep(2);
    check sqsListenerImmediateStop.immediateStop();
}

@test:Config {
    groups: ["listener"]
}
isolated function testListenerBatchMessage() returns error? {
    SendMessageBatchEntry[] entries = [
        {id: "1", body: "Batch Message Test 1"},
        {id: "2", body: "Batch Message Test 2"},
        {id: "3", body: "Batch Message Test 3"}
    ];
    SendMessageBatchResponse _ = check sqsClient->sendMessageBatch("https://sqs.us-east-2.amazonaws.com/284495578152/Test-5", entries);
}

@test:Config {
    groups: ["listenerValidation"]
}
function testListenerWithNonExistentQueue() returns error? {
    Listener nonExistentQueueListener = check new (connectionConfig, pollingConfig);
    Service svc = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/NonExistentQueue",
        autoDelete: true
    } service object {
        isolated remote function onMessage(Message message) returns error? {
        }
    };
    check nonExistentQueueListener.attach(svc);
    Error? result = nonExistentQueueListener.'start();
    test:assertTrue(result is Error, "Expected an error when starting the listener with a non-existent queue");
    if result is Error {
        string message = result.message();
        test:assertEquals(message, "Queue does not exist before polling: https://sqs.us-east-2.amazonaws.com/284495578152/NonExistentQueue");
    }
}

@test:Config {
    groups: ["listenerValidation"]
}
isolated function testListenerAttachWithInvalidOnMessageSignature() returns error? {
    Service svc = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-7",
        autoDelete: true
    } service object {
        isolated remote function onMessage(int value) returns error? {
        }
    };
    Error? result = sqsListener.attach(svc);
    //io:println("Result of attaching service with invalid signature: ", result);
    test:assertTrue(result is Error, "Expected error when attaching service with invalid onMessage signature");
}

@test:Config {
    groups: ["listenerValidation"]
}
isolated function testListenerAttachWithoutServiceConfig() returns error? {
    Service svc = service object {
        isolated remote function onMessage(Message message) returns error? {
        }
    };
    Error? result = sqsListener.attach(svc);
    test:assertTrue(result is Error, "Expected error when attaching service without ServiceConfig annotation");
    if result is Error {
        test:assertEquals(result.message(), "Failed to attach service : Service configuration annotation is required.", "Invalid error message received ");
    }
}

@test:Config {
    groups: ["listenerValidation"]
}
isolated function testListenerWithResourceMethods() returns error? {
    Service svc = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-8",
        autoDelete: true
    } service object {
        resource function get .() returns error? {
        }
        isolated remote function onMessage(Message message) returns error? {
        }
    };

    Error? result = sqsListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(result.message(), "Failed to attach service : SQS service cannot have resource methods.", "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidation"]
}
isolated function testListenerWithNoOnMessagemethod() returns error? {
    Service svc = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-9",
        autoDelete: true
    } service object {
        isolated remote function onError(Error err) returns error? {
        }
    };

    Error? result = sqsListener.attach(svc);
    test:assertTrue(result is Error, "Expected error when attaching service without remote methods");
    if result is Error {
        test:assertEquals(result.message(), "Failed to attach service : SQS service must have an 'onMessage' remote method.", "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidation"]
}
isolated function testListenerWithInvalidRemoteMethod() returns error? {
    Service svc = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-9",
        autoDelete: true
    } service object {
        remote function onRequest(Message message, Caller caller) returns error? {
        }
    };
    Error? result = sqsListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service : Invalid remote method name: onRequest",
                "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidation"]
}
isolated function testListenerMethodWithAdditionalParameters() returns error? {
    Service svc = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-10",
        autoDelete: true
    } service object {
        remote function onMessage(Message message, Caller caller, string requestType) returns error? {
        }
    };
    Error? result = sqsListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service : onMessage method can have only have either one or two parameters.",
                "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidation"]
}
isolated function testListenerMethodWithInvalidParams() returns error? {
    Service svc = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-11",
        autoDelete: true
    } service object {
        remote function onMessage(Message message, string requestType) returns error? {
        }
    };
    Error? result = sqsListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service : onMessage method parameters must be of type 'sqs:Message' or 'sqs:Caller'.",
                "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidation"]
}
isolated function testListenerMethodMandatoryParamMissing() returns error? {
    Service svc = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-12",
        autoDelete: true
    } service object {
        remote function onMessage(Caller caller) returns error? {
        }
    };
    Error? result = sqsListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service : Required parameter 'sqs:Message' cannot be found.",
                "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidation"]
}
isolated function testListenerOnErrorWithoutParameters() returns error? {
    Service svc = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-13",
        autoDelete: true
    } service object {
        remote function onMessage(Message message, Caller caller) returns error? {
        }
        remote function onError() returns error? {
        }
    };
    Error? result = sqsListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service : onError method must have exactly one parameter of type 'sqs:Error'.",
                "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidations"]
}
isolated function testListenerOnErrorWithInvalidParameter() returns error? {
    Service svc = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-14",
        autoDelete: true
    } service object {
        remote function onMessage(Message message, Caller caller) returns error? {
        }
        remote function onError(Message message) returns error? {
        }
    };
    Error? result = sqsListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service : onError method parameter must be of type 'sqs:Error'.",
                "Invalid error message received");
    }
}

@test:Config {
    groups: ["listenerValidation"]
}
isolated function testListenerOnErrorWithAdditionalParameters() returns error? {
    Service svc = @ServiceConfig {
        queueUrl: "https://sqs.us-east-2.amazonaws.com/284495578152/Test-12",
        autoDelete: true
    } service object {
        remote function onMessage(Message message, Caller caller) returns error? {
        }
        remote function onError(Error err, Message message) returns error? {
        }
    };
    Error? result = sqsListener.attach(svc);
    test:assertTrue(result is Error);
    if result is Error {
        test:assertEquals(
                result.message(),
                "Failed to attach service : onError method must have exactly one parameter of type 'sqs:Error'.",
                "Invalid error message received");
    }
}
