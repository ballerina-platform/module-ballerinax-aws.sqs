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
import software.amazon.awssdk.regions.Region;

import static io.ballerina.lib.aws.sqs.StaticAuthConfig.AWS_ACCESS_KEY_ID;

/**
 * {@code ConnectionConfig} represents the connection configuration required for
 * ballerina SQS API Client.
 *
 * @param region         The AWS region where the SQS cluster is located.
 * @param authConfig     The authentication configuration required for the
 *                       SQS API Client.
 * @param dbAccessConfig The base access configurations for the SQS API.
 */
public record ConnectionConfig(Region region, Object authConfig) {
    private static final BString CONNECTION_CONFIG_REGION = StringUtils.fromString("region");
    private static final BString CONNECTION_CONFIG_AUTH_CONFIG = StringUtils.fromString("auth");

    public ConnectionConfig(BMap<BString, Object> bConnectionConfig) {
        this(
                getRegion(bConnectionConfig),
                getAuthConfig(bConnectionConfig));
    }

    private static Region getRegion(BMap<BString, Object> bConnectionConfig) {
        return Region.of(bConnectionConfig.getStringValue(CONNECTION_CONFIG_REGION).getValue());
    }

    @SuppressWarnings("unchecked")
    private static Object getAuthConfig(BMap<BString, Object> bConnectionConfig) {
        BMap<BString, Object> bAuthConfig = (BMap<BString, Object>) bConnectionConfig
                .getMapValue(CONNECTION_CONFIG_AUTH_CONFIG);
        if (bAuthConfig.containsKey(AWS_ACCESS_KEY_ID)) {
            return new StaticAuthConfig(bAuthConfig);
        }
        return new InstanceProfileCredentials(bAuthConfig);
    }

}