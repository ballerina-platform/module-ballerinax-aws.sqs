# Ballerina Amazon SQS Connector Test

The Amazon SQS connector allows you to access the Amazon S3 REST API through ballerina.

## Compatibility
| Ballerina Version | Amazon SQS API Version |
|-------------------|----------------------- |
| 0.991.0           | 2012-11-05             |

###### Running tests

1. Create `ballerina.conf` file in `module-amazonsqs`, with following keys and provide values for the variables.
    
    ```.conf
    ACCESS_KEY_ID=""
    SECRET_ACCESS_KEY=""
    REGION=""
    ACCOUNT_NUMBER=""
    ```
2. Navigate to the folder module-amazonsqs

3. Run tests :

    ```ballerina
    ballerina init
    ballerina test amazonsqs --config ballerina.conf
    ```
```