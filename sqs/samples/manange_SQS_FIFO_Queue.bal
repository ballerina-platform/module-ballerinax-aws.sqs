import ballerina/log;
import ballerinax/aws.sqs;

configurable string accessKeyId = ?;
configurable string secretAccessKey = ?;
configurable string region = ?;
configurable string accountNumber = ?;

public function main(string... args) {

    // Add the SQS credentials as the Configuration
    sqs:ConnectionConfig configuration = {
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
        region: region,
        accountNumber: accountNumber
    };

    sqs:Client sqsClient = check new (configuration);

    // Declare common variables
    string queueResourcePath = "";
    string receivedReceiptHandler = "";

    // Create a new SQS FIFO queue named "demo.fifo"
    map<string> attributes = {};
    attributes["VisibilityTimeout"] = "400";
    attributes["FifoQueue"] = "true";
    string|error response1 = sqsClient->createQueue("demo.fifo", attributes);
    if (response1 is string) {
        log:printInfo("Created queue URL: " + response1);
        // Keep the queue URL for future operations
        queueResourcePath = sqs:splitString(response1, "amazonaws.com", 1);
    }

    // Send a message to the created queue
    attributes = {};
    attributes["MessageAttribute.1.Name"] = "Name1";
    attributes["MessageAttribute.1.Value.StringValue"] = "Value1";
    attributes["MessageAttribute.1.Value.DataType"] = "String";
    attributes["MessageAttribute.2.Name"] = "Name2";
    attributes["MessageAttribute.2.Value.StringValue"] = "Value2";
    attributes["MessageAttribute.2.Value.DataType"] = "String";
    string queueUrl = "";
    sqs:OutboundMessage|error response2 = sqsClient->sendMessage("Sample text message.", queueResourcePath,
        attributes, "grpID1", "dupID1");
    if (response2 is sqs:OutboundMessage) {
        log:printInfo("Sent message to SQS. MessageID: " + response2.messageId);
    }

    // Receive a message from the queue
    string[] attributeNames = ["SenderId"];
    string[] messageAttributeNames = ["Name1"];
    sqs:InboundMessage[]|error response3 = sqsClient->receiveMessage(fifoQueueResourcePath, 1, 600, 2, attributeNames, messageAttributeNames);
    if (response3 is sqs:InboundMessage[] && response3.length() > 0) {
        log:printInfo("Successfully received the message. Message body: " + response3[0].body);
        log:printInfo("\nReceipt Handle: " + response3[0].receiptHandle);
        // Keep receipt handle for deleting the message from the queue
        receivedReceiptHandler = response3[0].receiptHandle;
    }

    // Delete the received the message from the queue
    boolean|error response4 = sqsClient->deleteMessage(queueResourcePath, receivedReceiptHandler);
    if (response4 is boolean && response4) {
        log:printInfo("Successfully deleted the message from the queue.");
    }

    // Delete the queue
    boolean|error response5 = sqsClient->deleteQueue(queueResourcePath);
    if (response is boolean && response5) {
        log:printInfo("Successfully deleted the queue.");
    }
}
