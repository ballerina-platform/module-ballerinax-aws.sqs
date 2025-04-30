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

import io.ballerina.lib.aws.sqs.api.SqsListener;
import io.ballerina.lib.aws.sqs.impl.PollingConfig;
import io.ballerina.lib.aws.sqs.impl.SqsConsumerConnector;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import software.amazon.awssdk.services.sqs.SqsClient;

import java.util.HashMap;
import java.util.Map;

/**
 * This class implements the start method for the SQS listener.
 */
public class Start {

    private static final Logger logger = LoggerFactory.getLogger(Start.class);
    private static final String SQS_CLIENT = "SQS_CLIENT";

    // Map to store active consumer connectors
    private static final Map<BObject, Map<BObject, SqsConsumerConnector>> ACTIVE_CONNECTORS = new HashMap<>();

    /**
     * Start the SQS listener.
     *
     * @param listenerObj Listener object
     * @return Error if starting fails
     */
    public static Object start(BObject listenerObj) {
        try {
            // Get SQS client
            SqsClient sqsClient = (SqsClient) listenerObj.getNativeData(SQS_CLIENT);
            if (sqsClient == null) {
                // Try to get from connection object
                BObject connectionObj = listenerObj.getObjectValue(StringUtils.fromString("connection"));
                sqsClient = (SqsClient) connectionObj.getNativeData(SQS_CLIENT);

                if (sqsClient == null) {
                    return createError("SQS client has not been initialized properly");
                }
            }

            // Get queue URL
            String queueUrl = listenerObj.getStringValue(StringUtils.fromString("queueUrl")).getValue();

            // Get polling configuration
            BMap<BString, Object> pollingConfigMap = listenerObj.getMapValue(StringUtils.fromString("pollingConfig"));
            PollingConfig pollingConfig = extractPollingConfig(pollingConfigMap);

            // Get registered service listeners
            Map<BObject, SqsListener> serviceListeners = Register.getServiceListeners(listenerObj);
            if (serviceListeners.isEmpty()) {
                return createError("No services have been registered with this listener");
            }

            // Create and start a consumer connector for each service
            Map<BObject, SqsConsumerConnector> connectorMap = new HashMap<>();
            for (Map.Entry<BObject, SqsListener> entry : serviceListeners.entrySet()) {
                BObject serviceObj = entry.getKey();
                SqsListener listener = entry.getValue();

                // Create consumer connector
                SqsConsumerConnector connector = new SqsConsumerConnector(sqsClient, queueUrl, pollingConfig, listener);

                // Start the connector
                connector.start();

                // Store the connector
                connectorMap.put(serviceObj, connector);
            }

            // Store active connectors
            ACTIVE_CONNECTORS.put(listenerObj, connectorMap);

            return null;
        } catch (Exception e) {
            logger.error("Error starting SQS listener", e);
            return createError("Error starting SQS listener: " + e.getMessage());
        }
    }

    /**
     * Get active consumer connectors for a listener.
     *
     * @param listenerObj Listener object
     * @return Map of service objects to consumer connectors
     */
    public static Map<BObject, SqsConsumerConnector> getActiveConnectors(BObject listenerObj) {
        return ACTIVE_CONNECTORS.getOrDefault(listenerObj, new HashMap<>());
    }

    /**
     * Extract polling configuration from Ballerina map.
     *
     * @param pollingConfigMap Ballerina polling configuration map
     * @return Polling configuration
     */
    private static PollingConfig extractPollingConfig(BMap<BString, Object> pollingConfigMap) {
        PollingConfig config = new PollingConfig();

        if (pollingConfigMap != null) {
            // Extract polling interval
            Object pollingIntervalObj = pollingConfigMap.get(StringUtils.fromString("pollingInterval"));
            if (pollingIntervalObj != null) {
                double pollingInterval = ((Number) pollingIntervalObj).doubleValue();
                config.setPollingInterval(pollingInterval);
            }

            // Extract max messages per poll
            Object maxMessagesPerPollObj = pollingConfigMap.get(StringUtils.fromString("maxMessagesPerPoll"));
            if (maxMessagesPerPollObj != null) {
                int maxMessagesPerPoll = ((Number) maxMessagesPerPollObj).intValue();
                config.setMaxMessagesPerPoll(maxMessagesPerPoll);
            }

            // Extract visibility timeout
            Object visibilityTimeoutObj = pollingConfigMap.get(StringUtils.fromString("visibilityTimeout"));
            if (visibilityTimeoutObj != null) {
                int visibilityTimeout = ((Number) visibilityTimeoutObj).intValue();
                config.setVisibilityTimeout(visibilityTimeout);
            }

            // Extract wait time seconds
            Object waitTimeSecondsObj = pollingConfigMap.get(StringUtils.fromString("waitTimeSeconds"));
            if (waitTimeSecondsObj != null) {
                int waitTimeSeconds = ((Number) waitTimeSecondsObj).intValue();
                config.setWaitTimeSeconds(waitTimeSeconds);
            }

            // Extract delete after processing
            Object deleteAfterProcessingObj = pollingConfigMap.get(StringUtils.fromString("deleteAfterProcessing"));
            if (deleteAfterProcessingObj != null) {
                boolean deleteAfterProcessing = (Boolean) deleteAfterProcessingObj;
                config.setDeleteAfterProcessing(deleteAfterProcessing);
            }

            // Extract concurrency level
            Object concurrencyLevelObj = pollingConfigMap.get(StringUtils.fromString("concurrencyLevel"));
            if (concurrencyLevelObj != null) {
                int concurrencyLevel = ((Number) concurrencyLevelObj).intValue();
                config.setConcurrencyLevel(concurrencyLevel);
            }
        }

        return config;
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
