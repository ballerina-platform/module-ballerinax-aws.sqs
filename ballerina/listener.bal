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

import ballerina/jballerina.java;

# Represents an AWS SQS Listener endpoint that can be used to receive messages from an SQS queue.
public isolated class Listener {
    # Initializes the AWS SQS listener.
    #
    # + pollingConfig - Default polling behavior for all services (can be overridden per service)
    # + connectionConfig - The configurations to be used when initializing the AWS SQS listener
    # + return - An `Error` if the initialization failed, nil otherwise
    public isolated function init(ConnectionConfig connectionConfig, PollingConfig pollingConfig = {}) returns Error? {
        return self.initListener(pollingConfig, connectionConfig);
    }

    isolated function initListener(PollingConfig pollingConfig, ConnectionConfig connectionConfig) returns Error? = @java:Method {
        name: "init",
        'class: "io.ballerina.lib.aws.sqs.listener.Listener"
    } external;

    # Attaches an SQS service to the SQS listener.
    # + s - The SQS Service to attach
    # + path - Not applicable for SQS. Must be a null value
    # + return - An `Error` if the attaching failed, nil otherwise
    public isolated function attach(Service s, null path = ()) returns Error? = @java:Method {
        'class: "io.ballerina.lib.aws.sqs.listener.Listener"
    } external;

    # Detaches an SQS service from the SQS listener.
    # + s - The SQS Service to detach
    # + return - An `Error` if the detaching failed, nil otherwise
    public isolated function detach(Service s) returns Error? = @java:Method {
        'class: "io.ballerina.lib.aws.sqs.listener.Listener"
    } external;

    # Starts the SQS listener.
    # + return - An error if the starting failed, nil otherwise
    public isolated function 'start() returns Error? = @java:Method {
        'class: "io.ballerina.lib.aws.sqs.listener.Listener"
    } external;

    # Gracefully stops the SQS listener.
    # + return - An `Error` if the stopping failed, nil otherwise
    public isolated function gracefulStop() returns Error? = @java:Method {
        'class: "io.ballerina.lib.aws.sqs.listener.Listener"
    } external;

    # Immediately stops the SQS listener.
    # + return - An `Error` if the stopping failed, nil otherwise
    public isolated function immediateStop() returns Error? = @java:Method {
        'class: "io.ballerina.lib.aws.sqs.listener.Listener"
    } external;
}
