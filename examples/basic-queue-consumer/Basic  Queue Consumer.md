# Using Basic Queue Consumer with AWS SQS

This example demonstrates how to implement a listener-service based AWS SQS queue consumer using ballerina.

## Files

- `service.bal` - The main SQS listener service that consumes messages
- `send_messages.bal` - Utility to send test messages to the queue

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
