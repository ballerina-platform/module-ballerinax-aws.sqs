import ballerina/os;
import ballerina/test;


final string accessKeyId = os:getEnv("BALLERINA_AWS_TEST_ACCESS_KEY_ID");
final string secretAccessKey = os:getEnv("BALLERINA_AWS_TEST_SECRET_ACCESS_KEY");

final readonly & Region awsRegion = EU_NORTH_1;

final readonly & StaticAuthConfig auth = {
    accessKeyId,
    secretAccessKey
};

final Client sqsClient = check initClient();

isolated function initClient() returns Client|error {
    boolean enableTests = accessKeyId !is "" && secretAccessKey !is "";
    if enableTests {
        return new ({
            region: awsRegion,
            auth
        });
    }
    return test:mock(Client);
}