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

import java.util.concurrent.Semaphore;

import io.ballerina.runtime.api.values.BError;

public class OnMsgCallback {
    private final Semaphore semaphore;

    public OnMsgCallback(Semaphore semaphore) {
        this.semaphore = semaphore;
    }

    public void notifySuccess(Object result) {
        semaphore.release();
        if (result instanceof BError bError) {
            bError.printStackTrace();
        }
    }

    public void notifyFailure(BError bError) {
        semaphore.release();
        bError.printStackTrace();
    }
}