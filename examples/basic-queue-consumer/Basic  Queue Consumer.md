# Basic Queue Consumer Example with AWS SQS

This example demonstrates how to use the Ballerina AWS SQS Listener to work with AWS SQS queues. It covers;

- Creating a standard SQS queue
- Sending messages to the queue
- Receiving messages from the queue using a listener

## Prerequisites

- AWS Account with SQS access
- AWS Access Key ID and Secret Access Key
- Ballerina Swan Lake 2201.12.0 or later

## Configuration

Update the `Config.toml` with your AWS credentials and queue name.

```toml
# Standard queue name
queueName = "<QUEUE_NAME>"
queueUrl = "<QUEUE_URL>"

# AWS credentials
accessKeyId = "<YOUR_ACCESS_KEY_ID>"
secretAccessKey = "<YOUR_SECRET_ACCESS_KEY>"
```

## Run the Example

1. Ensure you have updated the `Config.toml` with your AWS credentials, queue name and the queueUrl.
2. Run the example.
```bash
bal run
```
## References

- [Ballerina AWS SQS Module](https://central.ballerina.io/ballerinax/aws.sqs)
