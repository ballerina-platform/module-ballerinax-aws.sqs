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

package io.ballerina.lib.aws.sqs.listener;

import java.util.List;
import java.util.Objects;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

import io.ballerina.lib.aws.sqs.CommonUtils;
import io.ballerina.runtime.api.values.BObject;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.Message;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageResponse;

public class MessageReceiver {
    private static final long STOP_TIMEOUT = 30000;

    private final ScheduledExecutorService executorService = Executors.newScheduledThreadPool(1);
    private final AtomicBoolean closed = new AtomicBoolean(false);

    private final SqsClient sqsClient;
    private final ReceiveMessageRequest receiveRequest;
    private final MessageDispatcher messageDispatcher;
    private final long pollingInterval;
    private final BObject bListener;
    private final String queueUrl;
    private final boolean autoDelete;

    private ScheduledFuture<?> pollingTaskFuture;

    public MessageReceiver(SqsClient sqsClient, String queueUrl, PollingConfig pollingConfig,
            MessageDispatcher messageDispatcher, BObject bListener, boolean autoDelete) {
        this.sqsClient = sqsClient;
        this.queueUrl = queueUrl;
        this.pollingInterval = pollingConfig.pollIntervalInMillis();
        this.bListener = bListener;
        this.messageDispatcher = messageDispatcher;
        this.autoDelete = autoDelete;

        this.receiveRequest = ReceiveMessageRequest.builder()
                .queueUrl(queueUrl)
                .maxNumberOfMessages(1)
                .waitTimeSeconds(pollingConfig.waitTime())
                .visibilityTimeout(pollingConfig.visibilityTimeout())
                .build();
    }

    private void poll() {
        try {
            if (closed.get())
                return;

            ReceiveMessageResponse response = sqsClient.receiveMessage(receiveRequest);
            if (!response.hasMessages())
                return;

            for (Message message : response.messages()) {
                Semaphore semaphore = new Semaphore(0);
                OnMsgCallback callback = new OnMsgCallback(semaphore);
                messageDispatcher.dispatch(List.of(message), bListener, queueUrl, autoDelete, callback);
                try {
                    semaphore.acquire();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    CommonUtils.createError("Message processing interrupted", e);
                    this.pollingTaskFuture.cancel(false);
                    return;
                }
            }
        } catch (Exception e) {
            if (!closed.get()) {
                CommonUtils.createError("Polling Error: " + e.getMessage(), e);
                this.pollingTaskFuture.cancel(false);
            }
        }
    }

    public void consume() {
        this.pollingTaskFuture = this.executorService.scheduleAtFixedRate(
                this::poll, 0, this.pollingInterval, TimeUnit.MILLISECONDS);
    }

    public void stop() throws Exception {
        closed.set(true);
        if (Objects.nonNull(this.pollingTaskFuture) && !this.pollingTaskFuture.isCancelled()) {
            this.pollingTaskFuture.cancel(true);
        }
        this.executorService.shutdown();
        try {
            boolean terminated = this.executorService.awaitTermination(STOP_TIMEOUT, TimeUnit.MILLISECONDS);
            if (!terminated) {
                this.executorService.shutdownNow();
            }
        } catch (InterruptedException e) {
            this.executorService.shutdownNow();
            Thread.currentThread().interrupt();
        }
    }

    public boolean isClosed() {
        return closed.get();
    }

    public String getQueueUrl() {
        return queueUrl;
    }

    public long getPollingInterval() {
        return pollingInterval;
    }
}
