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
        isolated remote function onMessage(Message message, Caller caller) returns error? {
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

