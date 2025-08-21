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

import ballerina/os;
import ballerina/test;

final string authType = os:getEnv("BALLERINA_AWS_TEST_AUTH_TYPE");
final string accessKeyId = os:getEnv("BALLERINA_AWS_TEST_ACCESS_KEY_ID");
final string secretAccessKey = os:getEnv("BALLERINA_AWS_TEST_SECRET_ACCESS_KEY");
final string profileName = os:getEnv("BALLERINA_AWS_TEST_PROFILE_NAME");
final string credentialsFilePath = os:getEnv("BALLERINA_AWS_TEST_CREDENTIALS_FILE");

final readonly & Region awsRegion = US_EAST_2;

final readonly & StaticAuthConfig staticAuth = {
    accessKeyId,
    secretAccessKey
};

final readonly & ProfileAuthConfig profileAuth = {
    profileName,
    credentialsFilePath
};

final Client sqsClient = check initClient();

isolated function initClient() returns Client|error {
    boolean useStatic = authType == "static";
    boolean useProfile = authType == "profile";
    if useStatic && accessKeyId != "" && secretAccessKey != "" {
        return new ({
            region: awsRegion,
            auth: staticAuth
        });
    } else if useProfile {
        return new ({
            region: awsRegion,
            auth: profileAuth
        });
    }
    return test:mock(Client);
}
