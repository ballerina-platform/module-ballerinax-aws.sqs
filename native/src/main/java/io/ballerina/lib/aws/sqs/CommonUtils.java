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

package io.ballerina.lib.aws.sqs;

import io.ballerina.lib.aws.ErrorUtils;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

/**
 * {@code CommonUtils} Contains the common utility functions for the Ballerina
 * AWS SQS Client
 */

public final class CommonUtils {

    private static final String ERROR = "Error";

    private CommonUtils() {
    }

    /**
     * Creates an {@code sqs:Error} carrying the shared {@code ballerinax/aws:ErrorDetails}
     * built from the given exception.
     */
    public static BError createError(String message, Throwable exception) {
        BError cause = ErrorCreator.createError(exception);
        BMap<BString, Object> errorDetails = ErrorUtils.createErrorDetails(exception);
        return ErrorCreator.createError(
                ModuleUtils.getModule(), ERROR, StringUtils.fromString(message), cause, errorDetails);
    }

    /**
     * Creates an {@code sqs:Error} for a failure that did not originate from an AWS
     * service call, hence with all the {@code ballerinax/aws:ErrorDetails} fields unset.
     */
    public static BError createError(String message) {
        BMap<BString, Object> errorDetails = ErrorUtils.createErrorDetails(null);
        return ErrorCreator.createError(
                ModuleUtils.getModule(), ERROR, StringUtils.fromString(message), null, errorDetails);
    }
}
