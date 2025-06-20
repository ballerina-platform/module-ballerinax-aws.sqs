// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

# Represents the connection configuration for the Amazon SQS client
#
# + region - AWS region (e.g., `us-east-1`)
# + auth - Authentication configuration using static credentials or AWS profile
public type ConnectionConfig record {|
   Region region;
   StaticAuthConfig|ProfileAuthConfig auth;
|};

# Represents static authentication configurations for the SQS API
#
# + accessKeyId - The AWS access key ID, used to identify the user interacting with AWS
# + secretAccessKey - The AWS secret access key, used to authenticate the user interacting with AWS
# + sessionToken - The AWS session token, used for authenticating a user with temporary permission to a resource
public type StaticAuthConfig record {|
   string accessKeyId;
   string secretAccessKey;
   string sessionToken?;
|};

# Represents AWS profile-based authentication configuration for SQS API
#
# + profileName - Name of the AWS profile in `~/.aws/credentials`
# + credentialsFilePath - Optional custom path to the credentials file. Defaults to `"~/.aws/credentials"`. 
# The credentials file should follow the standard AWS format:
#
#   ```
#   [default]
#   aws_access_key_id = YOUR_ACCESS_KEY_ID
#   aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
#
#   [profile-name]
#   aws_access_key_id = ANOTHER_ACCESS_KEY_ID
#   aws_secret_access_key = ANOTHER_SECRET_ACCESS_KEY
#   ```
public type ProfileAuthConfig record {|
   string profileName = "default";
   string credentialsFilePath = "~/.aws/credentials";
|};
