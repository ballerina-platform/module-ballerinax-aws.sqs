/*
 * Copyright (c) 2023, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.lib.aws.sqs.utils;

/**
 * Parameters for SQS polling configuration.
 */
public class PollingParams {
    private double pollingInterval = 30;
    private int maxMessagesPerPoll = 10;
    private int visibilityTimeout = 30;
    private int waitTimeSeconds = 20;
    private boolean deleteAfterProcessing = true;
    private int concurrencyLevel = 1;
    private RetryParams retryParams = null;

    public double getPollingInterval() {
        return pollingInterval;
    }

    public void setPollingInterval(double pollingInterval) {
        this.pollingInterval = pollingInterval;
    }

    public int getMaxMessagesPerPoll() {
        return maxMessagesPerPoll;
    }

    public void setMaxMessagesPerPoll(int maxMessagesPerPoll) {
        // AWS SQS has a maximum limit of 10 messages per receive request
        this.maxMessagesPerPoll = Math.min(maxMessagesPerPoll, 10);
    }

    public int getVisibilityTimeout() {
        return visibilityTimeout;
    }

    public void setVisibilityTimeout(int visibilityTimeout) {
        this.visibilityTimeout = visibilityTimeout;
    }

    public int getWaitTimeSeconds() {
        return waitTimeSeconds;
    }

    public void setWaitTimeSeconds(int waitTimeSeconds) {
        // AWS SQS has a maximum limit of 20 seconds for long polling
        this.waitTimeSeconds = Math.min(waitTimeSeconds, 20);
    }

    public boolean isDeleteAfterProcessing() {
        return deleteAfterProcessing;
    }

    public void setDeleteAfterProcessing(boolean deleteAfterProcessing) {
        this.deleteAfterProcessing = deleteAfterProcessing;
    }

    public int getConcurrencyLevel() {
        return concurrencyLevel;
    }

    public void setConcurrencyLevel(int concurrencyLevel) {
        this.concurrencyLevel = Math.max(concurrencyLevel, 1); // Ensure at least 1 thread
    }

    public RetryParams getRetryParams() {
        return retryParams;
    }

    public void setRetryParams(RetryParams retryParams) {
        this.retryParams = retryParams;
    }
}
