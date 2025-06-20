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

# Represents a AWS SQS  distinct error.
public type Error distinct error<ErrorDetails>;

# The error details type for the AWS SQS  module.
public type ErrorDetails record {|
    # The HTTP status code for the error
    int httpStatusCode?;
    # The HTTP status text returned from the service
    string httpStatusText?;
    # The error code associated with the response
    string errorCode?;
    # The human-readable error message provided by the service
    string errorMessage?;
|};