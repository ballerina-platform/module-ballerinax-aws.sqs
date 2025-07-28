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

package io.ballerina.lib.aws.sqs.listener;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

/**
 * Represents the configuration for an SQS service.
 * Maps the Ballerina ServiceConfig annotation values to Java.
 * Handles queue URL, polling configuration, and acknowledgment behavior.
 */
public final class ServiceConfig {
    // Configuration keys from Ballerina ServiceConfig
    private static final BString QUEUE_URL = StringUtils.fromString("queueUrl");
    private static final BString CONFIG = StringUtils.fromString("config");
    private static final BString AUTO_DELETE = StringUtils.fromString("autoDelete");

    // Configuration values
    public final String queueUrl;
    public final PollingConfig pollingConfig;
    public final boolean autoDelete;

    /**
     * Creates a service configuration from Ballerina config map.
     *
     * @param config The Ballerina configuration map from ServiceConfig annotation
     */
    @SuppressWarnings("unchecked")
    public ServiceConfig(BMap<BString, Object> config) {
        this.queueUrl = config.getStringValue(QUEUE_URL).getValue();
        this.pollingConfig = config.containsKey(CONFIG) && config.get(CONFIG) != null
                ? new PollingConfig((BMap<BString, Object>) config.get(CONFIG))
                : null;
        this.autoDelete = config.containsKey(AUTO_DELETE) && config.getBooleanValue(AUTO_DELETE);
    }
}
