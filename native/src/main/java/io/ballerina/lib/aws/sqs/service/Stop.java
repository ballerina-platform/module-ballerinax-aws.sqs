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

package io.ballerina.lib.aws.sqs.service;

import io.ballerina.lib.aws.sqs.impl.SqsConsumerConnector;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

/**
 * This class implements the stop methods for the SQS listener.
 */
public class Stop {

    private static final Logger logger = LoggerFactory.getLogger(Stop.class);

    /**
     * Stop the SQS listener gracefully.
     *
     * @param listenerObj Listener object
     * @return Error if stopping fails
     */
    public static Object gracefulStop(BObject listenerObj) {
        try {
            // Get active connectors
            Map<BObject, SqsConsumerConnector> connectors = Start.getActiveConnectors(listenerObj);

            if (connectors.isEmpty()) {
                logger.warn("No active SQS connectors found for this listener");
                return null;
            }

            // Stop each connector gracefully
            for (SqsConsumerConnector connector : connectors.values()) {
                connector.stop(true);
            }

            // Remove active connectors for this listener
            Start.getActiveConnectors(listenerObj).clear();

            return null;
        } catch (Exception e) {
            logger.error("Error stopping SQS listener gracefully", e);
            return createError("Error stopping SQS listener gracefully: " + e.getMessage());
        }
    }

    /**
     * Stop the SQS listener immediately.
     *
     * @param listenerObj Listener object
     * @return Error if stopping fails
     */
    public static Object immediateStop(BObject listenerObj) {
        try {
            // Get active connectors
            Map<BObject, SqsConsumerConnector> connectors = Start.getActiveConnectors(listenerObj);

            if (connectors.isEmpty()) {
                logger.warn("No active SQS connectors found for this listener");
                return null;
            }

            // Stop each connector immediately
            for (SqsConsumerConnector connector : connectors.values()) {
                connector.stop(false);
            }

            // Remove active connectors for this listener
            Start.getActiveConnectors(listenerObj).clear();

            return null;
        } catch (Exception e) {
            logger.error("Error stopping SQS listener immediately", e);
            return createError("Error stopping SQS listener immediately: " + e.getMessage());
        }
    }

    /**
     * Create Ballerina error.
     *
     * @param message Error message
     * @return Ballerina error
     */
    private static BError createError(String message) {
        return ErrorCreator.createError(StringUtils.fromString("SqsError"), StringUtils.fromString(message));
    }
}
