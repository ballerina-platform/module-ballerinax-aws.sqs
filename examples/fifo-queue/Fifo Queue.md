# FIFO Queue Example with AWS SQS

This example demonstrates how to use the Ballerina AWS SQS connector to work with FIFO queues. It covers;

- Creating a FIFO queue
- Sending messages with different `messageGroupId`s
- Receiving messages from the queue
- Grouping received messages by their group ID

## Prerequisites

- AWS Account with SQS access
- AWS Access Key ID and Secret Access Key
- Ballerina Swan Lake 2201.12.0 or later

## Configuration

Update the `Config.toml` with your AWS credentials and FIFO queue name.

```toml
# FIFO queue name (must end with .fifo)
fifoQueueName = "<FIFO_QUEUE_NAME.fifo>"

# AWS credentials
accessKeyId = "<YOUR_ACCESS_KEY_ID>"
secretAccessKey = "<YOUR_SECRET_ACCESS_KEY>"
```

## Running the Example

1. Ensure you have updated the `Config.toml` with your AWS credentials and queue name.
2. Run the example:
```bash
bal run
```

## References

- [Ballerina AWS SQS Module](https://central.ballerina.io/ballerinax/aws.sqs)
