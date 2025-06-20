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
 * {@code StaticAuthConfig} represents static authentication configurations
 * for the ballerina SQS API Client.
 *
 * @param accessKeyId     The AWS access key, used to identify the user
 *                        interacting with AWS.
 * @param secretAccessKey The AWS secret access key, used to authenticate the
 *                        user interacting with AWS.
 * @param sessionToken    The AWS session token, retrieved from an AWS token
 *                        service, used for authenticating that
 *                        * this user has received temporary permission to
 *                        access some resource.
 */
public record StaticAuthConfig(String accessKeyId, String secretAccessKey, String sessionToken) {
    static final BString AWS_ACCESS_KEY_ID = StringUtils.fromString("accessKeyId");
    private static final BString AWS_SECRET_ACCESS_KEY = StringUtils.fromString("secretAccessKey");
    private static final BString AWS_SESSION_TOKEN = StringUtils.fromString("sessionToken");

    public StaticAuthConfig(BMap<BString, Object> bAuthConfig) {
        this(
                bAuthConfig.getStringValue(AWS_ACCESS_KEY_ID).getValue(),
                bAuthConfig.getStringValue(AWS_SECRET_ACCESS_KEY).getValue(),
                bAuthConfig.containsKey(AWS_SESSION_TOKEN) ?
                        bAuthConfig.getStringValue(AWS_SESSION_TOKEN).getValue() : null
        );
    }
}