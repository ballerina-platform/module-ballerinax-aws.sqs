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
 * {@code ProfileAuthCredentials} provides a utility to create an AWS
 * credentials provider
 * using a named profile from a specified AWS credentials file.
 *
 * <p>
 * This is used for profile-based authentication in the Ballerina AWS SQS API
 * Client.
 * The credentials file should be in the standard AWS format, and the profile
 * name must exist in that file.
 * </p>
 *
 * @param profileName         The name of the AWS profile to use from the
 *                            credentials file
 * @param credentialsFilePath The path to the AWS credentials file (e.g.,
 *                            "~/.aws/credentials")
 */

public class ProfileAuthConfig {
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