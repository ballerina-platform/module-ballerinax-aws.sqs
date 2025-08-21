# Basic Queue Operations with AWS SQS

This example demonstrates basic operations with Amazon SQS using the Ballerina AWS SQS connector. It showcases;

- Creating a standard queue
- Sending a message to the queue
- Receiving messages from the queue
- Deleting a message from the queue
- Deleting the queue

## Prerequisites

- AWS Account with SQS access
- AWS Access Key ID and Secret Access Key
- Ballerina Swan Lake 2201.12.0 or later

## Configuration

Update the `Config.toml` with your AWS credentials and queue configuration.

```toml
# Queue name
queueName = "<QUEUE_NAME>"

# AWS credentials
accessKeyId = "<YOUR_ACCESS_KEY_ID>"
secretAccessKey = "<YOUR_SECRET_ACCESS_KEY>"
```

## Run the Example

1. Ensure you have updated the `Config.toml` with your AWS credentials
2. Run the example.
```bash
bal run
```
## References

- [Ballerina AWS SQS Module](https://central.ballerina.io/ballerinax/aws.sqs)
