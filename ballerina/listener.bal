// Copyright (c) 2023 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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

# Represents an AWS SQS listener endpoint.
#
# + pollingConfig - Stores configurations related to SQS polling
# + connection - The SQS connection
# + queueUrl - The URL of the SQS queue to listen to
public isolated class Listener {

    final PollingConfiguration & readonly pollingConfig;
    final Client 'client;
    final string queueUrl;

    # Creates a new `aws.sqs:Listener`.
    #
    # + connection - The SQS connection to use
    # + queueUrl - The URL of the SQS queue to listen to
    # + config - Configurations related to the polling mechanism
    # + return - An `aws.sqs:Error` if an error is encountered or else '()'
    public isolated function init(string queueUrl, ConnectionConfig connectionConfig, *PollingConfiguration pollConfig) returns error? {
        self.'client = check new (connectionConfig);
        self.queueUrl = queueUrl;
        self.pollingConfig = pollConfig.cloneReadOnly();
        check self.initListener();
    }

    # Initialize the native SQS listener.
    #
    # + return - An `aws.sqs:Error` if an error is encountered or else '()'
    private isolated function initListener() returns error? =
    @java:Method {
        name: "initListener",
        'class: "io.ballerina.lib.aws.sqs.listener.BrokerConnection"
    } external;

    # Starts the registered services.
    # ```ballerina
    # error? result = listener.'start();
    # ```
    #
    # + return - An `aws.sqs:Error` if an error is encountered while starting the server or else `()`
    public isolated function 'start() returns error? =
    @java:Method {
        name: "start",
        'class: "io.ballerina.lib.aws.sqs.service.Start"
    } external;

    # Stops the SQS listener gracefully.
    # ```ballerina
    # error? result = listener.gracefulStop();
    # ```
    #
    # + return - An `aws.sqs:Error` if an error is encountered during the listener-stopping process or else `()`
    public isolated function gracefulStop() returns error? =
    @java:Method {
        name: "gracefulStop",
        'class: "io.ballerina.lib.aws.sqs.service.Stop"
    } external;

    # Stops the SQS listener immediately.
    # ```ballerina
    # error? result = listener.immediateStop();
    # ```
    #
    # + return - An `aws.sqs:Error` if an error is encountered during the listener-stopping process or else `()`
    public isolated function immediateStop() returns error? =
    @java:Method {
        name: "immediateStop",
        'class: "io.ballerina.lib.aws.sqs.service.Stop"
    } external;

    # Attaches a service to the listener.
    # ```ballerina
    # error? result = listener.attach(sqsService);
    # ```
    #
    # + 'service - The service to be attached
    # + name - Name of the service
    # + return - An `aws.sqs:Error` if an error is encountered while attaching the service or else `()`
    public isolated function attach(Service 'service, string[]|string? name = ()) returns error? =
    @java:Method {
        name: "register",
        'class: "io.ballerina.lib.aws.sqs.service.Register" 
    } external;

    # Detaches a consumer service from the listener.
    # ```ballerina
    # error? result = listener.detach(sqsService);
    # ```
    #
    # + 'service - The service to be detached  
    # + return - An `aws.sqs:Error` if an error is encountered while detaching a service or else `()`
    public isolated function detach(Service 'service) returns error? =
    @java:Method {
        name: "unregister",
        'class: "io.ballerina.lib.aws.sqs.service.Unregister"
    } external;
}
