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

import java.nio.file.Paths;

import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.profiles.ProfileFile;

/**
 * {@code InstanceProfileCredentials} represents IAM role based
 * authentication configurations
 * for the ballerina SQS API Client.
 *
 * @param profileName         Configure the profile name used for loading
 *                            IMDS-related configuration,
 *                            like the endpoint mode (IPv4 vs IPv6).
 * @param credentialsFilePath The path to the profile file containing the
 *                            credentials.
 */

public class ProfileAuthCredentials {
    public static AwsCredentialsProvider fromConfig(String profileName, String credentialsFilePath) {
        return ProfileCredentialsProvider.builder()
                .profileName(profileName)
                .profileFile(ProfileFile.builder()
                        .content(Paths.get(credentialsFilePath))
                        .type(ProfileFile.Type.CREDENTIALS)
                        .build())
                .build();
    }
}