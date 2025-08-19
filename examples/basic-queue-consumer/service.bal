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

import ballerina/log;
import ballerinax/aws.sqs;

configurable string queueName = ?;
configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string queueUrl = ?;

sqs:PollingConfig pollingConfig = {
    pollInterval: 1.0,
    waitTime: 20
};

sqs:ConnectionConfig connectionConfig = {
    region: sqs:US_EAST_2,
    auth: {
        accessKeyId,
        secretAccessKey
    }
};

listener sqs:Listener sqsListener = new (connectionConfig, pollingConfig);

@sqs:ServiceConfig {
    queueUrl: queueUrl,
    autoDelete: true
}
service on sqsListener {
    remote function onMessage(sqs:Message message) returns error? {
        log:printInfo("Received message: ", body = message.body.toString());
        return;
    }

    remote function onError(sqs:Error err) returns error? {
        log:printError("Listener error", err);
    }
}


