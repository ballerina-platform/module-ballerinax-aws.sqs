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

# Configurations related to SQS polling mechanism.
#
# + pollingInterval - Interval between each poll in seconds (default: 30s)
# + maxMessagesPerPoll - Maximum number of messages to receive per polling attempt (default: 10, max: 10)
# + visibilityTimeout - Duration (in seconds) that the received messages are hidden from subsequent retrieve requests (default: 30s)
# + waitTimeSeconds - Duration (in seconds) for which the call waits for a message to arrive in the queue before returning (default: 20s, max: 20s)
# + deleteAfterProcessing - Whether to delete messages automatically after processing (default: true)
# + concurrencyLevel - Number of concurrent message processing threads (default: 1)
public type PollingConfiguration record {|
    decimal pollingInterval = 30;
    int maxMessagesPerPoll = 10;
    int visibilityTimeout = 30;
    int waitTimeSeconds = 20;
    boolean deleteAfterProcessing = true;
    int concurrencyLevel = 1;
|};
