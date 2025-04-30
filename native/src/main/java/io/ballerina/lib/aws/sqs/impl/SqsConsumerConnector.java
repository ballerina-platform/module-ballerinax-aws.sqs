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

import io.ballerina.lib.aws.sqs.api.SqsListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.DeleteMessageRequest;
import software.amazon.awssdk.services.sqs.model.Message;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageResponse;
import software.amazon.awssdk.services.sqs.model.SqsException;

import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * SQS consumer connector that polls for messages.
 */
public class SqsConsumerConnector {

    private static final Logger logger = LoggerFactory.getLogger(SqsConsumerConnector.class);

    private final SqsClient sqsClient;
    private final String queueUrl;
    private final PollingConfig pollingConfig;
    private final SqsListener sqsListener;
    private final ScheduledExecutorService scheduledExecutorService;
    private final AtomicBoolean active;
    private ScheduledFuture<?> pollingTask;

    /**
     * Create a new SQS consumer connector.
     *
     * @param sqsClient     SQS client
     * @param queueUrl      Queue URL
     * @param pollingConfig Polling configuration
     * @param sqsListener   SQS listener
     */
    public SqsConsumerConnector(SqsClient sqsClient, String queueUrl, PollingConfig pollingConfig,
                                SqsListener sqsListener) {
        this.sqsClient = sqsClient;
        this.queueUrl = queueUrl;
        this.pollingConfig = pollingConfig;
        this.sqsListener = sqsListener;
        this.scheduledExecutorService = Executors.newScheduledThreadPool(pollingConfig.getConcurrencyLevel());
        this.active = new AtomicBoolean(false);
    }

    /**
     * Start polling for messages.
     */
    public void start() {
        if (active.compareAndSet(false, true)) {
            long pollingIntervalMillis = (long) (pollingConfig.getPollingInterval() * 1000);
            pollingTask = scheduledExecutorService.scheduleAtFixedRate(
                    this::pollMessages,
                    0,
                    pollingIntervalMillis,
                    TimeUnit.MILLISECONDS
            );
        }
    }

    /**
     * Stop polling for messages.
     *
     * @param graceful Whether to stop gracefully
     */
    public void stop(boolean graceful) {
        if (active.compareAndSet(true, false)) {
            if (pollingTask != null) {
                pollingTask.cancel(true);
            }
            scheduledExecutorService.shutdown();
            try {
                if (graceful) {
                    if (!scheduledExecutorService.awaitTermination(30, TimeUnit.SECONDS)) {
                        scheduledExecutorService.shutdownNow();
                    }
                } else {
                    scheduledExecutorService.shutdownNow();
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                logger.error("Error while stopping SQS consumer", e);
            }
        }
    }

    /**
     * Poll for messages.
     */
    private void pollMessages() {
        if (!active.get()) {
            return;
        }

        try {
            ReceiveMessageRequest receiveRequest = ReceiveMessageRequest.builder()
                    .queueUrl(queueUrl)
                    .maxNumberOfMessages(pollingConfig.getMaxMessagesPerPoll())
                    .visibilityTimeout(pollingConfig.getVisibilityTimeout())
                    .waitTimeSeconds(pollingConfig.getWaitTimeSeconds())
                    .attributeNames("All")
                    .messageAttributeNames("All")
                    .build();

            ReceiveMessageResponse response = sqsClient.receiveMessage(receiveRequest);
            List<Message> messages = response.messages();

            if (!messages.isEmpty()) {
                SqsPollCycleFutureListener pollCycleListener = new SqsPollCycleFutureListener(messages);
                sqsListener.onMessagesReceived(queueUrl, pollCycleListener);

                // Auto-delete messages if configured
                if (pollingConfig.isDeleteAfterProcessing()) {
                    pollCycleListener.whenComplete((aVoid, throwable) -> {
                        if (throwable == null) {
                            deleteMessages(messages);
                        }
                    });
                }
            }
        } catch (SqsException e) {
            logger.error("Error polling SQS queue: " + e.getMessage(), e);
            sqsListener.onError(e);
        }
    }

    /**
     * Delete messages after processing.
     *
     * @param messages Messages to delete
     */
    private void deleteMessages(List<Message> messages) {
        for (Message message : messages) {
            try {
                DeleteMessageRequest deleteRequest = DeleteMessageRequest.builder()
                        .queueUrl(queueUrl)
                        .receiptHandle(message.receiptHandle())
                        .build();
                sqsClient.deleteMessage(deleteRequest);
            } catch (SqsException e) {
                logger.error("Error deleting SQS message: " + e.getMessage(), e);
            }
        }
    }
}
