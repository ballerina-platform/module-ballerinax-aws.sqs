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
        region: region
    };

    sqs:Client sqsClient = check new (configuration);

    // Declare common variables
    string queueResourcePath = "";
    string receivedReceiptHandler = "";

    // Create a new SQS FIFO queue named "demo.fifo"
    QueueAttributes queueAttributes = {  
        visibilityTimeout : 400,
        fifoQueue : true
    };
    CreateQueueResponse|error response1 = sqsClient->createQueue("demo.fifo", queueAttributes);
    if (response1 is CreateQueueResponse) {
        string createdQueUrl = response1.createQueueResult.queueUrl;
        log:printInfo("Created queue URL: " + createdQueUrl);
        // Keep the queue URL for future operations
        queueResourcePath = sqs:splitString(createdQueUrl, "amazonaws.com", 1);
    }

    // Send a message to the created queue
    MessageAttribute[] messageAttributes = 
        [{keyName : "N1", value : { stringValue : "V1", dataType : "String"}},
        {keyName : "N2", value : { stringValue : "V2", dataType : "String"}}];
    string queueUrl = "";
    sqs:SendMessageResponse|error response2 = sqsClient->sendMessage("Sample text message.", queueResourcePath,
        messageAttributes);
    if (response2 is sqs:SendMessageResponse) {
        log:printInfo("Sent message to SQS. MessageID: " + response2.sendMessageResult.messageId);
    }

    // Receive a message from the queue
    string[] attributeNames = ["SenderId"];
    string[] messageAttributeNames = ["Name1"];
    sqs:ReceiveMessageResponse|error response3 = sqsClient->receiveMessage(fifoQueueResourcePath, 1, 600, 2, attributeNames, messageAttributeNames);
    if ((response3.receiveMessageResult.message) is sqs:InboundMessage[] && (response3.receiveMessageResult.message).length() > 0) {
        log:printInfo("Successfully received the message. Message body: " + (response3.receiveMessageResult.message)[0].body);
        log:printInfo("\nReceipt Handle: " + (response3.receiveMessageResult.message)[0].receiptHandle);
        // Keep receipt handle for deleting the message from the queue
        receivedReceiptHandler = (response3.receiveMessageResult.message)[0].receiptHandle;
    }

    // Delete the received the message from the queue
    DeleteMessageResponse|error response4 = sqsClient->deleteMessage(queueResourcePath, receivedReceiptHandler);
    if (response4 is DeleteMessageResponse) {
        log:printInfo("Successfully deleted the message from the queue.");
    }

    // Delete the queue
    DeleteQueueResponse|error response5 = sqsClient->deleteQueue(queueResourcePath);
    if (response is DeleteQueueResponse) {
        log:printInfo("Successfully deleted the queue.");
    }
}
