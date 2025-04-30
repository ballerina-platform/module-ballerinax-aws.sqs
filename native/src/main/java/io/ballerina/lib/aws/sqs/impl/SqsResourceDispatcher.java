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

import io.ballerina.runtime.api.async.Callback;
import io.ballerina.runtime.api.async.StrandMetadata;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Resource dispatcher for SQS listener.
 */
public class SqsResourceDispatcher {

    private static final Logger logger = LoggerFactory.getLogger(SqsResourceDispatcher.class);

    /**
     * Dispatch resource function in the service.
     *
     * @param serviceObj      Service object
     * @param resource        Resource function name
     * @param moduleVersion   Module version
     * @param pollCycleListener Poll cycle future listener
     */
    public static void dispatchResource(BObject serviceObj, String resource, String moduleVersion,
                                        SqsPollCycleFutureListener pollCycleListener) {
        BArray sqsMessages = pollCycleListener.getSqsMessagesObj();

        // Create metadata
        StrandMetadata metadata = new StrandMetadata("ballerina", "aws.sqs", moduleVersion, resource);

        // Invoke resource function
        serviceObj.call(StringUtils.fromString(resource), null, new ResourceCallback(pollCycleListener),
                metadata, sqsMessages);
    }

    /**
     * Resource function callback.
     */
    private static class ResourceCallback implements Callback {

        private final SqsPollCycleFutureListener pollCycleListener;

        ResourceCallback(SqsPollCycleFutureListener pollCycleListener) {
            this.pollCycleListener = pollCycleListener;
        }

        /**
         * {@inheritDoc}
         */
        @Override
        public void notifySuccess(Object result) {
            pollCycleListener.complete(null);
        }

        /**
         * {@inheritDoc}
         */
        @Override
        public void notifyFailure(BError error) {
            logger.error("Error dispatching SQS messages: " + error.getMessage(), error);
            pollCycleListener.completeExceptionally(new RuntimeException(error.getMessage()));
        }
    }
}
