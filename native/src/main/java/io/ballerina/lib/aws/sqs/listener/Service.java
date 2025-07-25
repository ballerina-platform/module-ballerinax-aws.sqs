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

import io.ballerina.runtime.api.types.Parameter;
import io.ballerina.runtime.api.types.RemoteMethodType;
import io.ballerina.runtime.api.types.ServiceType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.utils.TypeUtils;
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
public class Service {
    /// Full annotation name including organization and version
    private static final BString SERVICE_CONFIG_ANNOTATION = StringUtils.fromString(
            getModule().getOrg() + ORG_NAME_SEPARATOR +
                    getModule().getName() + VERSION_SEPARATOR +
                    getModule().getMajorVersion() + VERSION_SEPARATOR +
                    "ServiceConfig");

    // Core service components
    private final BObject consumerService; // The Ballerina service object
    private final ServiceType serviceType; // Type information for the service
    private final ServiceConfig serviceConfig; // Parsed service configuration
    private final RemoteMethodType onMessage; // The required onMessage method
    private final RemoteMethodType onError; // Optional onError method

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
            if ("onMessage".equals(method.getName())) {
                foundOnMessage = method;
            } else if ("onError".equals(method.getName())) {
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
     * - Has correctly typed onMessage method
     *
     * @param consumerService The service to validate
     * @throws RuntimeException if validation fails
     */
    public static void validateService(BObject consumerService) {
        ServiceType serviceType = (ServiceType) TypeUtils.getType(consumerService);
        Object svcConfig = serviceType.getAnnotation(SERVICE_CONFIG_ANNOTATION);
        if (Objects.isNull(svcConfig)) {
            throw new RuntimeException("Service configuration annotation is required.");
        }
        if (serviceType.getResourceMethods().length > 0) {
            throw new RuntimeException("SQS service cannot have resource methods.");
        }
        RemoteMethodType[] remoteMethods = serviceType.getRemoteMethods();
        boolean hasOnMessage = false;
        for (RemoteMethodType method : remoteMethods) {
            if ("onMessage".equals(method.getName())) {
                hasOnMessage = true;
                validateOnMessageMethod(method);
            }
        }
        if (!hasOnMessage) {
            throw new RuntimeException("SQS service must have an 'onMessage' remote method.");
        }
    }

    /**
     * Validates the onMessage method signature:
     * - Must have 1 or 2 parameters
     * - First parameter must be Message
     * - Second parameter (if present) must be Caller
     *
     * @param onMessageMethod The method to validate
     * @throws RuntimeException if validation fails
     */
    private static void validateOnMessageMethod(RemoteMethodType onMessageMethod) {
        Parameter[] parameters = onMessageMethod.getParameters();
        if (parameters.length < 1 || parameters.length > 2) {
            throw new RuntimeException("onMessage method must have one or two parameters");
        }

        // Validate first parameter is Messagge
        Type firstParam = TypeUtils.getReferredType(parameters[0].type);
        if (firstParam.getTag() != TypeTags.RECORD_TYPE_TAG) {
            throw new RuntimeException("First parameter of onMessage must be Message record");
        }

        // If there's a second parameter, validate it's a Caller
        if (parameters.length == 2) {
            Type secondParam = TypeUtils.getReferredType(parameters[1].type);
            if (secondParam.getTag() != TypeTags.OBJECT_TYPE_TAG) {
                throw new RuntimeException("Second parameter of onMessage must be a Caller");
            }
        }
    }

    public RemoteMethodType getOnMessageMethod() {
        if (onMessage == null) {
            throw new RuntimeException("onMessage method not found");
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
