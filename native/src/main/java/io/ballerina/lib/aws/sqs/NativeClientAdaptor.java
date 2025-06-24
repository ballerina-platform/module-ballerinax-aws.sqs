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

package io.ballerina.lib.aws.sqs;

import java.nio.file.Path;
import java.util.Objects;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentials;
import software.amazon.awssdk.auth.credentials.AwsCredentialsProvider;
import software.amazon.awssdk.auth.credentials.AwsSessionCredentials;
import software.amazon.awssdk.auth.credentials.InstanceProfileCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.profiles.ProfileFile;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.DeleteMessageRequest;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageResponse;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchResponse;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageResponse;

/**
 * Representation of {@link software.amazon.awssdk.services.sqs.SqsClient} with
 * utility methods to invoke as inter-op functions.
 */

public class NativeClientAdaptor {
     static final String NATIVE_SQS_CLIENT = "nativeCLient";

     private NativeClientAdaptor() {
     }

     public static Object init(BObject bClient, BMap<BString, Object> bConnectionConfig) {
        try {
            ConnectionConfig connectionConfig = new ConnectionConfig(bConnectionConfig);
            AwsCredentialsProvider credentialsProvider =getCredentialsProvider(connectionConfig.authConfig());
            SqsClient nativeClient = SqsClient.builder()
                .region(connectionConfig.region())
                .credentialsProvider(credentialsProvider)
                .build();
            bClient.addNativeData(NATIVE_SQS_CLIENT, nativeClient);
        } catch (Exception e) {
            String errorMsg = String.format("Error occurred while initializing the SQS client: %s",
                    e.getMessage());
            return CommonUtils.createError(errorMsg, e);
        }
        return null;
     }

     private static AwsCredentialsProvider getCredentialsProvider(Object authConfig) {
        if (authConfig instanceof StaticAuthConfig staticAuth) {
            AwsCredentials credentials = Objects.nonNull(staticAuth.sessionToken()) ?
                    AwsSessionCredentials.create(
                            staticAuth.accessKeyId(), staticAuth.secretAccessKey(), staticAuth.sessionToken()) :
                    AwsBasicCredentials.create(staticAuth.accessKeyId(), staticAuth.secretAccessKey());
            return StaticCredentialsProvider.create(credentials);
        }
        InstanceProfileCredentials instanceProfileCredentials = (InstanceProfileCredentials) authConfig;
        InstanceProfileCredentialsProvider.Builder instanceCredentialBuilder =
                InstanceProfileCredentialsProvider.builder();
        if (Objects.nonNull(instanceProfileCredentials.profileName())) {
            instanceCredentialBuilder.profileName(instanceProfileCredentials.profileName());
        }
        if (Objects.nonNull(instanceProfileCredentials.credentialsFilePath())) {
            instanceCredentialBuilder.profileFile(ProfileFile.builder()
                    .content(Path.of(instanceProfileCredentials.credentialsFilePath()))
                    .type(ProfileFile.Type.CONFIGURATION)
                    .build());
        }
        return instanceCredentialBuilder.build();
    }
    
    public static Object sendMessage(Environment env, BObject bClient, BString queueUrl, BString messageBody, BMap<BString, Object> bConfig) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                SendMessageRequest request = CommonUtils.getNativeSendMessageRequest(queueUrl, messageBody, bConfig);
                SendMessageResponse response = sqsClient.sendMessage(request);
                return CommonUtils.getNativeSendMessageResponse(response);
            } catch (Exception e) {
                String msg = "Failed to send message: " + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object receiveMessage(Environment env, BObject bClient, BString queueUrl, BMap<BString, Object> bConfig) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                ReceiveMessageRequest request = CommonUtils.getNativeReceiveMessageRequest(queueUrl, bConfig);
                ReceiveMessageResponse response = sqsClient.receiveMessage(request);
                return CommonUtils.getNativeReceiveMessageResponse(response);
            } catch (Exception e) {
                String msg = "Failed to receive message: " + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object deleteMessage(Environment env, BObject bClient, BString queueUrl, BString receiptHandle) {
    SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

    return env.yieldAndRun(() -> {
        try {
            DeleteMessageRequest request = DeleteMessageRequest.builder()
                .queueUrl(queueUrl.getValue())
                .receiptHandle(receiptHandle.getValue())
                .build();
            sqsClient.deleteMessage(request);
            return null;
            } catch (Exception e) {
                return CommonUtils.createError("Failed to delete message: " + e.getMessage(), e);
            }
         });
    }

    public static Object sendMessageBatch(Environment env, BObject bClient, BString queueurl, BArray bEntries) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                SendMessageBatchRequest request = CommonUtils.getNativeSendMessageBatchRequest(queueurl, bEntries);
                SendMessageBatchResponse response = sqsClient.sendMessageBatch(request);
                return CommonUtils.getNativeSendMessageBatchResponse(response);
            } catch (Exception e) {
                String msg = "Failed to send batch message"+Objects.requireNonNullElse(e.getMessage(), "Unknown error");
                return CommonUtils.createError(msg, e);
            }
        });
    }


     public static Object close(BObject bClient) {
        SqsClient nativeClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);
        try {
            nativeClient.close();
        } catch (Exception e) {
            String errorMsg = String.format("Error occurred while closing the SQS client: %s",
                    Objects.requireNonNullElse(e.getMessage(), "Unknown error"));
            return CommonUtils.createError(errorMsg, e);
        }
        return null;
    }

     


}
