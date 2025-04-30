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

package io.ballerina.lib.aws.sqs.constants;

import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BString;

/**
 * Constants for SQS operations.
 */
public class SqsConstants {

    // Module information
    public static final String BALLERINA_BUILTIN_PKG_PREFIX = "ballerina";
    public static final String AWS_SQS_PKG_NAME = "aws.sqs";
    public static final String AWS_SQS_VERSION = "1.0.0";  // Update with current version

    // Native data binding keys
    public static final String SQS_CLIENT = "SQS_CLIENT";

    // Resource names
    public static final String ON_MESSAGE_RESOURCE = "onMessage";

    // Error types
    public static final String SQS_ERROR = "Error";

    // Record names
    public static final String SQS_MESSAGE_RECORD = "SqsMessage";

    // Function names
    public static final String SQS_LISTENER_PROCESS_FUNCTION = "process";

    // Module package
    public static final Module AWS_SQS_PACKAGE_ID = new Module(
            BALLERINA_BUILTIN_PKG_PREFIX, AWS_SQS_PKG_NAME, AWS_SQS_VERSION);

    // Constants for listener functionality
    public static final BString LISTENER_CONFIG = StringUtils.fromString("config");
    public static final BString QUEUE_URL = StringUtils.fromString("queueUrl");
    public static final BString CONNECTION = StringUtils.fromString("connection");
}
