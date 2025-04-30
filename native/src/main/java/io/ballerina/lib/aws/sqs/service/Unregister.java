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
 * This class implements the unregister method for the SQS listener.
 */
public class Unregister {

    private static final Logger logger = LoggerFactory.getLogger(Unregister.class);

    /**
     * Unregister a service from the SQS listener.
     *
     * @param listenerObj Listener object
     * @param service Service object
     * @return Error if unregistration fails
     */
    public static Object unregister(BObject listenerObj, BObject service) {
        try {
            // Get active connectors
            Map<BObject, SqsConsumerConnector> activeConnectors = Start.getActiveConnectors(listenerObj);

            // If service has an active connector, stop it
            SqsConsumerConnector connector = activeConnectors.remove(service);
            if (connector != null) {
                connector.stop(true);
            }

            // Remove service from registered listeners
            Map<BObject, io.ballerina.lib.aws.sqs.api.SqsListener> serviceListeners = Register.getServiceListeners(listenerObj);
            serviceListeners.remove(service);

            return null;
        } catch (Exception e) {
            logger.error("Error unregistering service from SQS listener", e);
            return createError("Error unregistering service from SQS listener: " + e.getMessage());
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
