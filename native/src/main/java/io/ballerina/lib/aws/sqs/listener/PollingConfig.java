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

import java.math.BigDecimal;

import io.ballerina.lib.aws.sqs.CommonUtils;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BError;
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

    static final BString POLL_INTERVAL = StringUtils.fromString("pollInterval");
    static final BString WAIT_TIME = StringUtils.fromString("waitTime");
    static final BString VISIBILITY_TIMEOUT = StringUtils.fromString("visibilityTimeout");

    public PollingConfig {
        if (pollInterval < 0) {
            throw createInvalidPollIntervalError(pollInterval);
        }
    }

    /**
     * Creates polling configuration from Ballerina config map.
     *
     * @param config The Ballerina configuration map containing polling settings
     */
    public PollingConfig(BMap<BString, Object> config) {
        this(
                getPollInterval(config),
                config.getIntValue(WAIT_TIME).intValue(),
                config.getIntValue(VISIBILITY_TIMEOUT).intValue());
    }

    private static double getPollInterval(BMap<BString, Object> config) {
        // Validate the decimal value itself, as tiny negative values underflow to -0.0 when converted to double.
        BigDecimal pollInterval = ((BDecimal) config.get(POLL_INTERVAL)).value();
        if (pollInterval.signum() < 0) {
            throw createInvalidPollIntervalError(pollInterval);
        }
        return pollInterval.doubleValue();
    }

    private static BError createInvalidPollIntervalError(Object pollInterval) {
        return CommonUtils.createError("Invalid polling configuration: 'pollInterval' must be greater than or " +
                "equal to 0, but found " + pollInterval);
    }

    public long pollIntervalInMillis() {
        return (long) (pollInterval * 1000);
    }
}
