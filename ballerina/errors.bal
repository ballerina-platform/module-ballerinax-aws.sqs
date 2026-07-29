// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
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

import ballerinax/aws;

# Represents a AWS SQS distinct error. The fields of `aws:ErrorDetails` are populated
# when the failure originates from an AWS SQS service call, and are left unset when the
# failure occurs before a response is received (e.g. an invalid configuration).
public type Error distinct error<aws:ErrorDetails>;
