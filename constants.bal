// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

const SQS_SERVICE_NAME = "sqs";
const SQS_CONTENT_TYPE = "application/x-www-form-urlencoded";

const HOST = "Host";
const X_AMZ_CONTENT_SHA256 = "X-Amz-Content-Sha256";
const UNSIGNED_PAYLOAD = "UNSIGNED-PAYLOAD";
const ERROR_CODE = "(ballerinax/aws.sqs)Error";
const AMAZON_HOST = "amazonaws.com";

const ISO8601_BASIC_DATE_FORMAT = "yyyyMMdd'T'HHmmss'Z'";
const SHORT_DATE_FORMAT = "yyyyMMdd";
const X_AMZ_DATE = "X-Amz-Date";
const X_AMZ_SECURITY_TOKEN = "X-Amz-Security-Token";
const UTF_8 = "UTF-8";
const CONTENT_TYPE = "Content-Type";
const AWS4_HMAC_SHA256 = "AWS4-HMAC-SHA256";
const SERVICE_NAME = "sqs";
const TERMINATION_STRING = "aws4_request";
const AWS4 = "AWS4";
const CREDENTIAL = "Credential";
const SIGNED_HEADER = " SignedHeaders";
const SIGNATURE = " Signature";
const AUTHORIZATION = "Authorization";
const PUT = "PUT";
const POST = "POST";
const GET = "GET";

const string STATUS_CODE = "status code";
const string COLON_SYMBOL = ":";
const string FULL_STOP = ".";
const string SEMICOLON_SYMBOL = ";";
const string WHITE_SPACE = " ";
const string AMBERSAND = "&";
const string EQUAL = "=";
const string FORWARD_SLASH = "/";
const string MESSAGE = "message";
const string NEW_LINE = "\n";
const string ERROR = "error";
const string EMPTY_STRING = "";
const string SQS_VERSION = "2012-11-05";
const string AMAZON_SQS_API_VERSION = "AmazonSQSv20121105";
const string ACTION_CREATE_QUEUE = "CreateQueue";
const string ACTION_SEND_MESSAGE = "SendMessage";
const string ACTION_RECEIVE_MESSAGE = "ReceiveMessage";
const string ACTION_DELETE_MESSAGE = "DeleteMessage";
const string ACTION_DELETE_QUEUE = "DeleteQueue";

const string PAYLOAD_PARAM_ACTION = "Action";
const string PAYLOAD_PARAM_VERSION = "Version";
const string PAYLOAD_PARAM_QUEUE_NAME = "QueueName";
const string PAYLOAD_PARAM_MESSAGE_BODY = "MessageBody";
const string PAYLOAD_PARAM_RECEIPT_HANDLE = "ReceiptHandle";
