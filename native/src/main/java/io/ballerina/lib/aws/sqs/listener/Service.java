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

import io.ballerina.lib.aws.sqs.CommonUtils;
import io.ballerina.runtime.api.types.Parameter;
import io.ballerina.runtime.api.types.RemoteMethodType;
import io.ballerina.runtime.api.types.ServiceType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import static io.ballerina.lib.aws.sqs.ModuleUtils.getModule;
import static io.ballerina.runtime.api.constants.RuntimeConstants.ORG_NAME_SEPARATOR;
import static io.ballerina.runtime.api.constants.RuntimeConstants.VERSION_SEPARATOR;

import java.util.Objects;

/**
 * Native representation of the Ballerina SQS service object.
 * Handles configuration and service validation for SQS services.
 */
public final class Service {
    /// Full annotation name including organization and version
    private static final BString SERVICE_CONFIG_ANNOTATION = StringUtils.fromString(
            getModule().getOrg() + ORG_NAME_SEPARATOR +
                    getModule().getName() + VERSION_SEPARATOR +
                    getModule().getMajorVersion() + VERSION_SEPARATOR +
                    "ServiceConfig");

    static final String ON_MESSAGE_METHOD = "onMessage";
    static final String ON_ERROR_METHOD = "onError";

    // Core service components
    private final BObject consumerService;
    private final ServiceType serviceType;
    private final ServiceConfig serviceConfig;
    private final RemoteMethodType onMessage;
    private final RemoteMethodType onError;

    /**
     * Creates a new Service instance from a Ballerina service object.
     * Validates the service structure and extracts configuration.
     *
     * @param consumerService The Ballerina service object to wrap
     * @throws RuntimeException if service validation fails
     */
    public Service(BObject consumerService) {
        this.consumerService = consumerService;
        this.serviceType = (ServiceType) TypeUtils.getType(consumerService);

        @SuppressWarnings("unchecked")
        BMap<BString, Object> svcConfig = (BMap<BString, Object>) serviceType.getAnnotation(SERVICE_CONFIG_ANNOTATION);
        this.serviceConfig = new ServiceConfig(svcConfig);

        RemoteMethodType foundOnMessage = null;
        RemoteMethodType foundOnError = null;

        for (RemoteMethodType method : serviceType.getRemoteMethods()) {
            if (ON_MESSAGE_METHOD.equals(method.getName())) {
                foundOnMessage = method;
            } else if (ON_ERROR_METHOD.equals(method.getName())) {
                foundOnError = method;
            }
        }
        this.onMessage = foundOnMessage;
        this.onError = foundOnError;
    }

    /**
     * Validates that a service meets all SQS requirements:
     * - Has ServiceConfig annotation
     * - Has no resource methods
     * - Has exactly one or two remote methods (onMessage, optional onError)
     * - Has correctly typed onMessage method
     * - Has correctly typed onError method (if present)
     *
     * @param consumerService The service to validate
     * @throws BError if validation fails
     */
    public static void validateService(BObject consumerService) {
        ServiceType serviceType = (ServiceType) TypeUtils.getType(consumerService);
        Object svcConfig = serviceType.getAnnotation(SERVICE_CONFIG_ANNOTATION);
        if (Objects.isNull(svcConfig)) {
            throw CommonUtils.createError("Failed to attach service : Service configuration annotation is required.");
        }
        if (serviceType.getResourceMethods().length > 0) {
            throw CommonUtils.createError("Failed to attach service : SQS service cannot have resource methods.");
        }
        RemoteMethodType[] remoteMethods = serviceType.getRemoteMethods();
        if (remoteMethods.length < 1 || remoteMethods.length > 2) {
            throw CommonUtils
                    .createError("Failed to attach service : SQS service must have exactly one or two remote methods.");
        }
        boolean hasOnMessage = false;
        for (RemoteMethodType method : remoteMethods) {
            String methodName = method.getName();
            if (ON_MESSAGE_METHOD.equals(methodName)) {
                hasOnMessage = true;
                validateOnMessageMethod(method);
            } else if (ON_ERROR_METHOD.equals(methodName)) {
                validateOnErrorMethod(method);
            } else {
                throw CommonUtils.createError("Failed to attach service : Invalid remote method name: " + methodName);
            }
        }
        if (!hasOnMessage) {
            throw CommonUtils
                    .createError("Failed to attach service : SQS service must have an 'onMessage' remote method.");
        }
    }

    /**
     * Validates the onMessage method signature:
     * - Must have 1 or 2 parameters
     * - First parameter must be Message
     * - Second parameter (if present) must be Caller
     *
     * @param onMessageMethod The method to validate
     * @throws BError if validation fails
     */
    private static void validateOnMessageMethod(RemoteMethodType onMessageMethod) {
        Parameter[] parameters = onMessageMethod.getParameters();
        if (parameters.length < 1 || parameters.length > 2) {
            throw CommonUtils.createError(
                    "Failed to attach service : onMessage method can have only have either one or two parameters.");
        }
        Parameter messageParam = null;
        boolean hasCaller = false;

        for (Parameter param : parameters) {
            Type paramType = TypeUtils.getReferredType(param.type);
            if (paramType.getTag() == TypeTags.RECORD_TYPE_TAG) {
                messageParam = param;
            } else if (paramType.getTag() == TypeTags.OBJECT_TYPE_TAG) {
                hasCaller = true;
            } else {
                throw CommonUtils.createError(
                        "Failed to attach service : onMessage method parameters must be of type 'sqs:Message' or 'sqs:Caller'.");
            }
        }
        if (messageParam == null) {
            throw CommonUtils
                    .createError("Failed to attach service : Required parameter 'sqs:Message' cannot be found.");
        }
        // If two parameters, one must be Caller
        if (parameters.length == 2 && !hasCaller) {
            throw CommonUtils.createError(
                    "Failed to attach service : If two parameters are present, one must be of the type 'sqs:Caller'.");
        }
    }

    /**
     * Validates the onError method signature:
     * - Must have exactly one parameter
     * - Parameter must be of type Error
     *
     * @param onErrorMethod The method to validate
     * @throws BError if validation fails
     */
    private static void validateOnErrorMethod(RemoteMethodType onErrorMethod) throws BError {
        if (onErrorMethod.getParameters().length != 1) {
            throw CommonUtils.createError(
                    "Failed to attach service : onError method must have exactly one parameter of type 'sqs:Error'.");
        }
        Parameter param = onErrorMethod.getParameters()[0];
        Type paramType = TypeUtils.getReferredType(param.type);
        if (paramType.getTag() != TypeTags.ERROR_TAG) {
            throw CommonUtils
                    .createError("Failed to attach service : onError method parameter must be of type 'sqs:Error'.");
        }
    }

    public RemoteMethodType getOnMessageMethod() {
        if (onMessage == null) {
            throw new RuntimeException("Failed to attach service : onMessage method not found");
        }
        return onMessage;
    }

    public boolean isOnMessageMethodIsolated() {
        RemoteMethodType method = getOnMessageMethod();
        return method != null && method.isIsolated();
    }

    public ServiceConfig getServiceConfig() {
        return serviceConfig;
    }

    public RemoteMethodType getOnErrorMethod() {
        return onError;
    }

    public BObject getConsumerService() {
        return consumerService;
    }

    public ServiceType getServiceType() {
        return serviceType;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (!(o instanceof Service))
            return false;
        Service service = (Service) o;
        return consumerService.equals(service.consumerService);
    }

    @Override
    public int hashCode() {
        return Objects.hash(consumerService);
    }
}
