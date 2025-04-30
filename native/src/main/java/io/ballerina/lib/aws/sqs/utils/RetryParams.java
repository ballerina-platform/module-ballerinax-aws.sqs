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

/**
 * Parameters for SQS retry configuration.
 */
public class RetryParams {
    private int maxRetries = 3;
    private double backOffFactor = 2.0;
    private double maxBackOffTime = 20;
    private double initialBackOffTime = 1;

    public int getMaxRetries() {
        return maxRetries;
    }

    public void setMaxRetries(int maxRetries) {
        this.maxRetries = maxRetries;
    }

    public double getBackOffFactor() {
        return backOffFactor;
    }

    public void setBackOffFactor(double backOffFactor) {
        this.backOffFactor = backOffFactor;
    }

    public double getMaxBackOffTime() {
        return maxBackOffTime;
    }

    public void setMaxBackOffTime(double maxBackOffTime) {
        this.maxBackOffTime = maxBackOffTime;
    }

    public double getInitialBackOffTime() {
        return initialBackOffTime;
    }

    public void setInitialBackOffTime(double initialBackOffTime) {
        this.initialBackOffTime = initialBackOffTime;
    }
}
