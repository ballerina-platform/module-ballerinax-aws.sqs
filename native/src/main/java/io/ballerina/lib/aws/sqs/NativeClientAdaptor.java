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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.utils.StringUtils;
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
import software.amazon.awssdk.services.sqs.model.CancelMessageMoveTaskRequest;
import software.amazon.awssdk.services.sqs.model.CancelMessageMoveTaskResponse;
import software.amazon.awssdk.services.sqs.model.ChangeMessageVisibilityRequest;
import software.amazon.awssdk.services.sqs.model.CreateQueueRequest;
import software.amazon.awssdk.services.sqs.model.CreateQueueResponse;
import software.amazon.awssdk.services.sqs.model.DeleteMessageBatchRequest;
import software.amazon.awssdk.services.sqs.model.DeleteMessageBatchResponse;
import software.amazon.awssdk.services.sqs.model.DeleteMessageRequest;
import software.amazon.awssdk.services.sqs.model.DeleteQueueRequest;
import software.amazon.awssdk.services.sqs.model.GetQueueAttributesRequest;
import software.amazon.awssdk.services.sqs.model.GetQueueAttributesResponse;
import software.amazon.awssdk.services.sqs.model.GetQueueUrlRequest;
import software.amazon.awssdk.services.sqs.model.GetQueueUrlResponse;
import software.amazon.awssdk.services.sqs.model.ListQueueTagsRequest;
import software.amazon.awssdk.services.sqs.model.ListQueueTagsResponse;
import software.amazon.awssdk.services.sqs.model.ListQueuesRequest;
import software.amazon.awssdk.services.sqs.model.ListQueuesResponse;
import software.amazon.awssdk.services.sqs.model.PurgeQueueRequest;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageRequest;
import software.amazon.awssdk.services.sqs.model.ReceiveMessageResponse;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageBatchResponse;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageResponse;
import software.amazon.awssdk.services.sqs.model.SetQueueAttributesRequest;
import software.amazon.awssdk.services.sqs.model.StartMessageMoveTaskRequest;
import software.amazon.awssdk.services.sqs.model.StartMessageMoveTaskResponse;
import software.amazon.awssdk.services.sqs.model.TagQueueRequest;
import software.amazon.awssdk.services.sqs.model.UntagQueueRequest;

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
            AwsCredentialsProvider credentialsProvider = getCredentialsProvider(connectionConfig.authConfig());
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
            AwsCredentials credentials = Objects.nonNull(staticAuth.sessionToken()) ? AwsSessionCredentials.create(
                    staticAuth.accessKeyId(), staticAuth.secretAccessKey(), staticAuth.sessionToken())
                    : AwsBasicCredentials.create(staticAuth.accessKeyId(), staticAuth.secretAccessKey());
            return StaticCredentialsProvider.create(credentials);
        }
        InstanceProfileCredentials instanceProfileCredentials = (InstanceProfileCredentials) authConfig;
        InstanceProfileCredentialsProvider.Builder instanceCredentialBuilder = InstanceProfileCredentialsProvider
                .builder();
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

    public static Object sendMessage(Environment env, BObject bClient, BString queueUrl, BString messageBody,
            BMap<BString, Object> bConfig) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                SendMessageRequest request = SendMessageMapper.getNativeSendMessageRequest(queueUrl, messageBody,
                        bConfig);
                SendMessageResponse response = sqsClient.sendMessage(request);
                return SendMessageMapper.getNativeSendMessageResponse(response);
            } catch (Exception e) {
                String msg = "Failed to send message: " + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object receiveMessage(Environment env, BObject bClient, BString queueUrl,
            BMap<BString, Object> bConfig) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                ReceiveMessageRequest request = ReceiveMessageMapper.getNativeReceiveMessageRequest(queueUrl, bConfig);
                ReceiveMessageResponse response = sqsClient.receiveMessage(request);
                return ReceiveMessageMapper.getNativeReceiveMessageResponse(response);
            } catch (Exception e) {
                String msg = "Failed to receive message: "
                        + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
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
                SendMessageBatchRequest request = SendMessageBatchMapper.getNativeSendMessageBatchRequest(queueurl,
                        bEntries);
                SendMessageBatchResponse response = sqsClient.sendMessageBatch(request);
                return SendMessageBatchMapper.getNativeSendMessageBatchResponse(response);
            } catch (Exception e) {
                String msg = "Failed to send batch message"
                        + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object deleteMessageBatch(Environment env, BObject bClient, BString queueUrl, BArray bEntries) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                DeleteMessageBatchRequest request = DeleteMessageBatchMapper
                        .getNativeDeleteMessageBatchRequest(queueUrl, bEntries);
                DeleteMessageBatchResponse response = sqsClient.deleteMessageBatch(request);
                return DeleteMessageBatchMapper.getnativeDeleteMessageBatchResponse(response);
            } catch (Exception e) {
                String msg = "Failed to delete batch message"
                        + Objects.requireNonNullElse(e.getMessage(), "Unknown Error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object createQueue(Environment env, BObject bClient, BString queueName,
            BMap<BString, Object> bConfig) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                CreateQueueRequest request = CreateQueueMapper.getNativeCreateQueueRequest(queueName, bConfig);
                CreateQueueResponse response = sqsClient.createQueue(request);
                return StringUtils.fromString(response.queueUrl());
            } catch (Exception e) {
                String msg = "Failed to create queue: " + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
                return CommonUtils.createError(msg, e);
            }
        });

    }

    public static Object deleteQueue(Environment env, BObject bClient, BString queueUrl) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                DeleteQueueRequest request = DeleteQueueRequest.builder()
                        .queueUrl(queueUrl.getValue())
                        .build();
                sqsClient.deleteQueue(request);
                return null;
            } catch (Exception e) {
                return CommonUtils.createError("Failed to delete Queue: " + e.getMessage(), e);
            }
        });
    }

    public static Object getQueueUrl(Environment env, BObject bClient, BString queueName,
            BMap<BString, Object> bConfig) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                GetQueueUrlRequest request = GetQueueUrlMapper.getNativeGetQueueUrlRequest(queueName, bConfig);
                GetQueueUrlResponse response = sqsClient.getQueueUrl(request);
                return StringUtils.fromString(response.queueUrl());
            } catch (Exception e) {
                String msg = "Failed to get queue URL: " + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object listQueues(Environment env, BObject bClient, BMap<BString, Object> bConfig) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                ListQueuesRequest request = ListQueuesMapper.getNativeListQueuesRequest(bConfig);
                ListQueuesResponse response = sqsClient.listQueues(request);
                return ListQueuesMapper.getNativeListQueuesResponse(response);
            } catch (Exception e) {
                String msg = "Failed to list queues " + Objects.requireNonNullElse(e.getMessage(), "Unknown Error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object getQueueAttributes(Environment env, BObject bClient, BString queueUrl,
            BMap<BString, Object> bConfig) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                GetQueueAttributesRequest request = GetQueueAttributesMapper
                        .getNativeGetQueueAttributesRequest(queueUrl, bConfig);
                GetQueueAttributesResponse response = sqsClient.getQueueAttributes(request);
                return GetQueueAttributesMapper.getNativeGetQueueAttributesResponse(response);
            } catch (Exception e) {
                String msg = "Failed to get queue attributes: "
                        + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object setQueueAttributes(Environment env, BObject bClient, BString queueUrl,
            BMap<BString, Object> bQueueAttributes) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                SetQueueAttributesRequest request = SetQueueAttributesMapper
                        .getNativeSetQueueAttributesRequest(queueUrl, bQueueAttributes);
                sqsClient.setQueueAttributes(request);
                return null;
            } catch (Exception e) {
                String msg = "Failed to set queue attributes: "
                        + Objects.requireNonNullElse(e.getMessage(), "Unknown Error");
                return CommonUtils.createError(msg, e);
            }
        });

    }

    public static Object changeMessageVisibility(Environment env, BObject bClient, BString queueUrl,
            BString receiptHandle, long visibilityTimeout) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                ChangeMessageVisibilityRequest request = ChangeMessageVisibilityRequest.builder()
                        .queueUrl(queueUrl.getValue())
                        .receiptHandle(receiptHandle.getValue())
                        .visibilityTimeout((int) visibilityTimeout)
                        .build();
                sqsClient.changeMessageVisibility(request);
                return null;

            } catch (Exception e) {
                String msg = "Failed to change message visibility: "
                        + Objects.requireNonNullElse(e.getMessage(), "Unknown Error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object purgeQueue(Environment env, BObject bClient, BString queueurl) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                PurgeQueueRequest request = PurgeQueueRequest.builder()
                        .queueUrl(queueurl.getValue())
                        .build();
                sqsClient.purgeQueue(request);
                return null;
            } catch (Exception e) {
                String msg = "Failed to purge queue" + Objects.requireNonNullElse(e.getMessage(), "Unknown Error");
                return CommonUtils.createError(msg, e);
            }

        });
    }

    public static Object tagQueue(Environment env, BObject bClient, BString queueUrl, BMap<BString, Object> bTags) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                // Convert BMap<BString, Object> to Map<String, String>
                Map<String, String> tags = new HashMap<>();
                for (Object key : bTags.getKeys()) {
                    BString tagKey = (BString) key;
                    Object value = bTags.get(tagKey);
                    if (value != null) {
                        tags.put(tagKey.getValue(), value.toString());
                    }
                }
                TagQueueRequest request = TagQueueRequest.builder()
                        .queueUrl(queueUrl.getValue())
                        .tags(tags)
                        .build();
                sqsClient.tagQueue(request);
                return null;
            } catch (Exception e) {
                String msg = "Failed to tag queue: " + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object untagQueue(Environment env, BObject bClient, BString queueUrl, BArray bTagKeys) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                List<String> tagKeys = new ArrayList<>();
                for (int i = 0; i < bTagKeys.size(); i++) {
                    Object val = bTagKeys.get(i);
                    if (val instanceof BString) {
                        tagKeys.add(((BString) val).getValue());
                    }
                }
                UntagQueueRequest request = UntagQueueRequest.builder()
                        .queueUrl(queueUrl.getValue())
                        .tagKeys(tagKeys)
                        .build();
                sqsClient.untagQueue(request);
                return null;
            } catch (Exception e) {
                String msg = "Failed to untag queue: " + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object listQueueTags(Environment env, BObject bClient, BString queueUrl) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                ListQueueTagsRequest request = ListQueueTagsRequest.builder()
                        .queueUrl(queueUrl.getValue())
                        .build();
                ListQueueTagsResponse response = sqsClient.listQueueTags(request);
                return ListQueueTagsMapper.getNativeListQueueTagsResponse(response);
            } catch (Exception e) {
                String msg = "Failed to list queue tags: "
                        + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object startMessageMoveTask(Environment env, BObject bClient, BString sourceArn,
            BMap<BString, Object> bConfig) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                StartMessageMoveTaskRequest request = StartMessageMoveTaskMapper
                        .getNativeStartMessageMoveTaskRequest(sourceArn, bConfig);
                StartMessageMoveTaskResponse response = sqsClient.startMessageMoveTask(request);
                return StartMessageMoveTaskMapper.getNativeStartMessageMoveTaskResponse(response);
            } catch (Exception e) {
                String msg = "Failed to start message move task: "
                        + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
                return CommonUtils.createError(msg, e);
            }
        });
    }

    public static Object cancelMessageMoveTask(Environment env, BObject bClient, BString taskHandle) {
        SqsClient sqsClient = (SqsClient) bClient.getNativeData(NATIVE_SQS_CLIENT);

        return env.yieldAndRun(() -> {
            try {
                CancelMessageMoveTaskRequest request = CancelMessageMoveTaskRequest.builder()
                        .taskHandle(taskHandle.getValue())
                        .build();
                CancelMessageMoveTaskResponse response = sqsClient.cancelMessageMoveTask(request);
                return CancelMessageMoveTaskMapper.getNativeCancelMessageMoveTaskResponse(response);
            } catch (Exception e) {
                String msg = "Failed to cancel message move task: "
                        + Objects.requireNonNullElse(e.getMessage(), "Unknown error");
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
