# Advanced Messaging with AWS SQS

This example demonstrates how to use the Ballerina AWS SQS connector to perform advanced messaging operations with AWS SQS. It covers queue creation with custom attributes, sending messages in batch with attributes, receiving messages, and cleaning up the queue.


## Prerequisites

- AWS Account with SQS access
- AWS Access Key ID and Secret Access Key
- Ballerina Swan Lake 2201.12.0 or later

## Configuration

Update the `Config.toml` with your AWS credentials and queue name.

```toml
# Queue name
queueName = "<QUEUE_NAME>"

# AWS credentials
accessKeyId = "<YOUR_ACCESS_KEY_ID>"
secretAccessKey = "<YOUR_SECRET_ACCESS_KEY>"
```


## Run the Example
Execute the following command to run the example:
```bash
bal run
```

## References

- [Ballerina AWS SQS Module](https://central.ballerina.io/ballerinax/aws.sqs)
