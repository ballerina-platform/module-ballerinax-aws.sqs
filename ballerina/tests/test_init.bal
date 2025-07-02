import ballerina/os;
import ballerina/test;

final string authType = os:getEnv("BALLERINA_AWS_TEST_AUTH_TYPE");
final string accessKeyId = os:getEnv("BALLERINA_AWS_TEST_ACCESS_KEY_ID");
final string secretAccessKey = os:getEnv("BALLERINA_AWS_TEST_SECRET_ACCESS_KEY");
final string profileName = os:getEnv("BALLERINA_AWS_TEST_PROFILE_NAME");
final string credentialsFilePath = os:getEnv("BALLERINA_AWS_TEST_CREDENTIALS_FILE");

final readonly & Region awsRegion = EU_NORTH_1;

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
    if (useStatic && accessKeyId != "" && secretAccessKey != "") {
        return new ({
            region: awsRegion,
            auth: staticAuth
        });
    } else if (useProfile) {
        return new ({
            region: awsRegion,
            auth: profileAuth
        });
    }
    return test:mock(Client);
}
