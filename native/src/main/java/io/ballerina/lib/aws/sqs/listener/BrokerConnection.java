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

package io.ballerina.lib.aws.sqs.listener;

import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import software.amazon.awssdk.services.sqs.SqsClient;

/**
 * This class handles the initialization of SQS listener.
 */
public class BrokerConnection {

    private static final Logger logger = LoggerFactory.getLogger(BrokerConnection.class);
    private static final String SQS_CLIENT = "SQS_CLIENT";

    /**
     * Initialize SQS listener.
     *
     * @param listenerObj Listener object
     * @return Error if initialization fails
     */
    public static Object initListener(BObject listenerObj) {
        try {
            // Extract SQS connection
            BObject connectionObj = listenerObj.getObjectValue(StringUtils.fromString("connection"));
            SqsClient sqsClient = (SqsClient) connectionObj.getNativeData(SQS_CLIENT);

            if (sqsClient == null) {
                return createError("SQS client has not been initialized properly");
            }

            // Store SQS client for later use
            listenerObj.addNativeData(SQS_CLIENT, sqsClient);

            return null;
        } catch (Exception e) {
            logger.error("Error initializing SQS listener", e);
            return createError("Error initializing SQS listener: " + e.getMessage());
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
