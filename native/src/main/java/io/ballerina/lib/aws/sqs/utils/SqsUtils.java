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

package io.ballerina.lib.aws.sqs.utils;

import io.ballerina.lib.aws.sqs.constants.SqsConstants;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.types.MethodType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BObject;

/**
 * Utility functions for SQS operations.
 */
public class SqsUtils {

    /**
     * Creates a Ballerina error with the given message.
     *
     * @param message Error message
     * @return Ballerina error
     */
    public static BError createError(String message) {
        return ErrorCreator.createError(
                StringUtils.fromString(SqsConstants.SQS_ERROR),
                StringUtils.fromString(message));
    }

    /**
     * Validates if a service has the required 'onMessage' resource function.
     *
     * @param service Service to validate
     * @return True if the service is valid, false otherwise
     */
    public static boolean validateService(BObject service) {
        MethodType[] methods = service.getType().getMethods();
        for (MethodType method : methods) {
            if (SqsConstants.ON_MESSAGE_RESOURCE.equals(method.getName())) {
                return true;
            }
        }
        return false;
    }
}
