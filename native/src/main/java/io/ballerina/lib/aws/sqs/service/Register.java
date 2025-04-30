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
import io.ballerina.lib.aws.sqs.impl.SqsListenerImpl;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.types.MethodType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

/**
 * This class implements the register method for the SQS listener.
 */
public class Register {

    private static final Logger logger = LoggerFactory.getLogger(Register.class);
    private static final String ON_MESSAGE_RESOURCE = "onMessage";
    private static final String AWS_SQS_VERSION = "1.0.0"; // Update with current version

    // Map to store service listeners
    private static final Map<BObject, Map<BObject, SqsListener>> SERVICE_LISTENERS = new HashMap<>();

    /**
     * Register a service with the SQS listener.
     *
     * @param listenerObj Listener object
     * @param service Service object
     * @param name Service name
     * @return Error if registration fails
     */
    public static Object register(BObject listenerObj, BObject service, Object name) {
        try {
            // Validate service has required resources
            if (!validateService(service)) {
                return createError("Service does not contain the required '" + ON_MESSAGE_RESOURCE + "' resource function");
            }

            // Create SQS listener implementation
            SqsListener sqsListener = new SqsListenerImpl(service, ON_MESSAGE_RESOURCE, AWS_SQS_VERSION);

            // Store the listener with the service
            Map<BObject, SqsListener> serviceMap = SERVICE_LISTENERS.computeIfAbsent(listenerObj, k -> new HashMap<>());
            serviceMap.put(service, sqsListener);

            return null;
        } catch (Exception e) {
            logger.error("Error registering service with SQS listener", e);
            return createError("Error registering service with SQS listener: " + e.getMessage());
        }
    }

    /**
     * Get service listeners for a listener object.
     *
     * @param listenerObj Listener object
     * @return Map of service objects to listeners
     */
    public static Map<BObject, SqsListener> getServiceListeners(BObject listenerObj) {
        return SERVICE_LISTENERS.getOrDefault(listenerObj, new HashMap<>());
    }

    /**
     * Validate that service has required resource functions.
     *
     * @param service Service object
     * @return True if valid, false otherwise
     */
    private static boolean validateService(BObject service) {
        MethodType[] methods = service.getType().getMethods();
        for (MethodType method : methods) {
            if (ON_MESSAGE_RESOURCE.equals(method.getName())) {
                return true;
            }
        }
        return false;
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
