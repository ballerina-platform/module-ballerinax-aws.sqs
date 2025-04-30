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

package io.ballerina.lib.aws.sqs.impl;

/**
 * Configuration for SQS polling.
 */
public class PollingConfig {

    private double pollingInterval = 30;
    private int maxMessagesPerPoll = 10;
    private int visibilityTimeout = 30;
    private int waitTimeSeconds = 20;
    private boolean deleteAfterProcessing = true;
    private int concurrencyLevel = 1;

    /**
     * Create a new polling configuration with default values.
     */
    public PollingConfig() {
        // Default constructor with default values
    }

    /**
     * Get polling interval in seconds.
     *
     * @return Polling interval
     */
    public double getPollingInterval() {
        return pollingInterval;
    }

    /**
     * Set polling interval in seconds.
     *
     * @param pollingInterval Polling interval
     * @return This polling config instance
     */
    public PollingConfig setPollingInterval(double pollingInterval) {
        this.pollingInterval = pollingInterval;
        return this;
    }

    /**
     * Get maximum messages per poll.
     *
     * @return Maximum messages per poll
     */
    public int getMaxMessagesPerPoll() {
        return maxMessagesPerPoll;
    }

    /**
     * Set maximum messages per poll.
     *
     * @param maxMessagesPerPoll Maximum messages per poll
     * @return This polling config instance
     */
    public PollingConfig setMaxMessagesPerPoll(int maxMessagesPerPoll) {
        // AWS SQS has a maximum limit of 10 messages per receive request
        this.maxMessagesPerPoll = Math.min(maxMessagesPerPoll, 10);
        return this;
    }

    /**
     * Get visibility timeout in seconds.
     *
     * @return Visibility timeout
     */
    public int getVisibilityTimeout() {
        return visibilityTimeout;
    }

    /**
     * Set visibility timeout in seconds.
     *
     * @param visibilityTimeout Visibility timeout
     * @return This polling config instance
     */
    public PollingConfig setVisibilityTimeout(int visibilityTimeout) {
        this.visibilityTimeout = visibilityTimeout;
        return this;
    }

    /**
     * Get wait time for long polling in seconds.
     *
     * @return Wait time
     */
    public int getWaitTimeSeconds() {
        return waitTimeSeconds;
    }

    /**
     * Set wait time for long polling in seconds.
     *
     * @param waitTimeSeconds Wait time
     * @return This polling config instance
     */
    public PollingConfig setWaitTimeSeconds(int waitTimeSeconds) {
        // AWS SQS has a maximum limit of 20 seconds for long polling
        this.waitTimeSeconds = Math.min(waitTimeSeconds, 20);
        return this;
    }

    /**
     * Get whether to delete messages after processing.
     *
     * @return Whether to delete messages after processing
     */
    public boolean isDeleteAfterProcessing() {
        return deleteAfterProcessing;
    }

    /**
     * Set whether to delete messages after processing.
     *
     * @param deleteAfterProcessing Whether to delete messages after processing
     * @return This polling config instance
     */
    public PollingConfig setDeleteAfterProcessing(boolean deleteAfterProcessing) {
        this.deleteAfterProcessing = deleteAfterProcessing;
        return this;
    }

    /**
     * Get concurrency level.
     *
     * @return Concurrency level
     */
    public int getConcurrencyLevel() {
        return concurrencyLevel;
    }

    /**
     * Set concurrency level.
     *
     * @param concurrencyLevel Concurrency level
     * @return This polling config instance
     */
    public PollingConfig setConcurrencyLevel(int concurrencyLevel) {
        this.concurrencyLevel = Math.max(concurrencyLevel, 1); // Ensure at least 1 thread
        return this;
    }
}
