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

import io.ballerina.runtime.api.values.BArray;
import software.amazon.awssdk.services.sqs.model.Message;

import java.util.List;
import java.util.concurrent.CompletableFuture;

/**
 * This is a future listener to control the flow of polling cycle.
 */
public class SqsPollCycleFutureListener implements CompletableFuture<Void> {

    private final CompletableFuture<Void> completableFuture;
    private final List<Message> messages;
    private BArray sqsMessagesObj;

    public SqsPollCycleFutureListener(List<Message> messages) {
        this.completableFuture = new CompletableFuture<>();
        this.messages = messages;
    }

    /**
     * Set the converted BArray of SQS messages.
     *
     * @param sqsMessagesObj Ballerina array of SQS messages
     */
    public void setSqsMessagesObj(BArray sqsMessagesObj) {
        this.sqsMessagesObj = sqsMessagesObj;
    }

    /**
     * Get the list of SQS messages.
     *
     * @return List of SQS messages
     */
    public List<Message> getMessages() {
        return messages;
    }

    /**
     * Get the converted Ballerina array of SQS messages.
     *
     * @return Ballerina array of SQS messages
     */
    public BArray getSqsMessagesObj() {
        return sqsMessagesObj;
    }

    // CompletableFuture implementation methods
    @Override
    public boolean isDone() {
        return completableFuture.isDone();
    }

    @Override
    public Void get() {
        return completableFuture.join();
    }

    @Override
    public Void join() {
        return completableFuture.join();
    }

    @Override
    public boolean complete(Void value) {
        return completableFuture.complete(value);
    }

    @Override
    public boolean completeExceptionally(Throwable ex) {
        return completableFuture.completeExceptionally(ex);
    }

    @Override
    public boolean cancel(boolean mayInterruptIfRunning) {
        return completableFuture.cancel(mayInterruptIfRunning);
    }

    @Override
    public boolean isCancelled() {
        return completableFuture.isCancelled();
    }

    @Override
    public boolean isCompletedExceptionally() {
        return completableFuture.isCompletedExceptionally();
    }

    @Override
    public void obtrudeValue(Void value) {
        completableFuture.obtrudeValue(value);
    }

    @Override
    public void obtrudeException(Throwable ex) {
        completableFuture.obtrudeException(ex);
    }

    @Override
    public int getNumberOfDependents() {
        return completableFuture.getNumberOfDependents();
    }
}
