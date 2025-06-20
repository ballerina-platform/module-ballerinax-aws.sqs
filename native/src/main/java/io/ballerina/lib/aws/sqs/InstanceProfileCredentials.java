/*
 * Copyright (c) 2025, WSO2 LLC. (http://www.wso2.org).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
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

package io.ballerina.lib.aws.sqs;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

/**
 * {@code InstanceProfileCredentials} represents EC2 IAM role based authentication configurations
 * for the ballerina SQS API Client.
 *
 * @param profileName Configure the profile name used for loading IMDS-related configuration,
 *                    like the endpoint mode (IPv4 vs IPv6).
 * @param credentialsFilePath The path to the profile file containing the credentials.
 */
public record InstanceProfileCredentials(String profileName, String credentialsFilePath) {
    private static final BString EC2_INSTANCE_PROFILE_NAME = StringUtils.fromString("profileName");
    private static final BString EC2_INSTANCE_PROFILE_FILE = StringUtils.fromString("credentialsFilePath");

    public InstanceProfileCredentials(BMap<BString, Object> bAuthConfig) {
        this(
                bAuthConfig.containsKey(EC2_INSTANCE_PROFILE_NAME) ?
                        bAuthConfig.getStringValue(EC2_INSTANCE_PROFILE_NAME).getValue() : null,
                bAuthConfig.containsKey(EC2_INSTANCE_PROFILE_FILE) ?
                        bAuthConfig.getStringValue(EC2_INSTANCE_PROFILE_FILE).getValue() : null
        );
    }
}