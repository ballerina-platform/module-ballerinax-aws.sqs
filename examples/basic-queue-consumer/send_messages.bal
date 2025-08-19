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
import ballerina/log;
import ballerinax/aws.sqs;

// Utility to send test messages to the queue for demonstration purposes
public function main() returns error? {
    sqs:Client sqsClient = check new (connectionConfig);
    string createdQueueUrl = check sqsClient->createQueue(queueName);
    log:printInfo("Queue created successfully. URL: ", queueUrl = createdQueueUrl);

    foreach int i in 1 ... 20 {
        string msg = string `Test message #${i}`;
        _ = check sqsClient->sendMessage(createdQueueUrl, msg);
        log:printInfo("Sent message", count = i, body = msg);
        runtime:sleep(1);
    }
    log:printInfo("All test messages sent. The listener service will process them.", totalMessages = 20);
}
