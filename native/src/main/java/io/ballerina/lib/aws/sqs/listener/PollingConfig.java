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
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

/**
 * Configuration record for SQS message polling behavior.
 * Defines how the listener retrieves messages from the queue.
 */
public record PollingConfig(
        double pollInterval,
        int waitTime,
        int visibilityTimeout) {
    // Configuration keys from Ballerina PollingConfig
    private static final BString POLL_INTERVAL = StringUtils.fromString("pollInterval");
    private static final BString WAIT_TIME = StringUtils.fromString("waitTime");
    private static final BString VISIBILITY_TIMEOUT = StringUtils.fromString("visibilityTimeout");

    /**
     * Creates polling configuration from Ballerina config map.
     *
     * @param config The Ballerina configuration map containing polling settings
     */
    public PollingConfig(BMap<BString, Object> config) {
        this(
                ((BDecimal) config.get(POLL_INTERVAL)).value().doubleValue(),
                config.getIntValue(WAIT_TIME).intValue(),
                config.getIntValue(VISIBILITY_TIMEOUT).intValue());
    }

    public long pollIntervalInMillis() {
        return (long) (pollInterval * 1000);
    }

    public int maxMessages() {
        return 1;
    }
}
