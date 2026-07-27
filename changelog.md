# Change Log
This file contains all the notable changes done to the Ballerina AWS SQS package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

This release revamps the connector's authentication and region configuration to use the shared
[`ballerinax/aws`](https://github.com/ballerina-platform/module-ballerinax-aws) package, so that all AWS
connectors share a single, consistent credential model.
([Revamp Connector Authentication Flow](https://github.com/wso2-enterprise/integration-engineering/issues/2091))

It contains breaking changes. See the "Migrating from 4.x" section below.

### Changed
- **[Breaking]** Authentication configuration is now sourced from `ballerinax/aws.auth` instead of being
  defined locally by this package. The `ConnectionConfig.auth` field type changed from
  `StaticAuthConfig|ProfileAuthConfig|DEFAULT_CREDENTIALS` to `auth:AuthConfig`. This is a widening — every
  4.x credential source remains supported, with four new ones added.
- **[Breaking]** The `ConnectionConfig.region` field type changed from `sqs:Region` to `aws:Region|string`.
  The `string` alternative allows regions that are not yet present in the `aws:Region` enum to be supplied
  directly.

### Removed
- **[Breaking]** `sqs:StaticAuthConfig`, `sqs:ProfileAuthConfig` and `sqs:DEFAULT_CREDENTIALS` have been
  removed in favour of the `ballerinax/aws.auth` equivalents. The replacement records are structurally
  identical to the ones they replace, so inline record literals continue to work unchanged — only explicit
  type references need updating.
- **[Breaking]** The `sqs:Region` enum has been removed in favour of `aws:Region`. The following members
  have no `aws:Region` equivalent and must now be supplied as plain region strings
  (for example, `region: "us-iso-east-1"`):

  | Removed member | Region string |
  | --- | --- |
  | `AWS_GLOBAL` | `aws-global` |
  | `AWS_CN_GLOBAL` | `aws-cn-global` |
  | `AWS_US_GOV_GLOBAL` | `aws-us-gov-global` |
  | `AWS_ISO_GLOBAL` | `aws-iso-global` |
  | `AWS_ISO_B_GLOBAL` | `aws-iso-b-global` |
  | `US_ISO_EAST_1` | `us-iso-east-1` |
  | `US_ISO_WEST_1` | `us-iso-west-1` |
  | `US_ISOB_EAST_1` | `us-isob-east-1` |
  | `EU_ISOE_WEST_1` | `eu-isoe-west-1` |

### Added
- Support for four additional AWS credential sources, available through `auth:AuthConfig`:
  - `auth:AssumeRoleConfig` — temporary credentials obtained by assuming an IAM role via AWS STS.
  - `auth:WebIdentityConfig` — web identity (OIDC) federation, including IAM Roles for Service Accounts (IRSA).
  - `auth:SsoAuthConfig` — AWS IAM Identity Center (SSO).
  - `auth:ProcessAuthConfig` — credentials sourced from an external credential process.
- A new optional `ConnectionConfig.endpoint` field of type `aws:EndpointConfig`, for selecting FIPS or
  dualstack endpoint variants and for overriding the endpoint entirely (for example, LocalStack or VPC
  interface endpoints).
- A new optional `requestId` field on `ErrorDetails`, carrying the AWS request ID of the failed call to
  simplify support escalations.
- New `aws:Region` members not present in the former `sqs:Region` enum: `AP_EAST_2`, `AP_SOUTHEAST_5`,
  `AP_SOUTHEAST_7` and `MX_CENTRAL_1`.

### Migrating from 4.x

Add an `import ballerinax/aws;` alongside the existing SQS import, and qualify region members with `aws:`
rather than `sqs:`. Authentication record literals do not need to change:

```ballerina
// 4.x
import ballerinax/aws.sqs;

sqs:ConnectionConfig config = {
    region: sqs:US_EAST_1,
    auth: {accessKeyId, secretAccessKey}
};
```

```ballerina
// 5.0.0
import ballerinax/aws;
import ballerinax/aws.sqs;

sqs:ConnectionConfig config = {
    region: aws:US_EAST_1,
    auth: {accessKeyId, secretAccessKey}
};
```

Code that referred to the removed types by name must be updated to the `ballerinax/aws.auth` equivalents:

```ballerina
// 4.x
sqs:StaticAuthConfig authConfig = {accessKeyId, secretAccessKey};
sqs:ProfileAuthConfig authConfig = {profileName: "dev"};
sqs:ConnectionConfig config = {region: sqs:US_EAST_1, auth: sqs:DEFAULT_CREDENTIALS};
```

```ballerina
// 5.0.0
import ballerinax/aws.auth;

auth:StaticAuthConfig authConfig = {accessKeyId, secretAccessKey};
auth:ProfileAuthConfig authConfig = {profileName: "dev"};
sqs:ConnectionConfig config = {region: aws:US_EAST_1, auth: auth:DEFAULT_CREDENTIALS};
```

Configurations that used one of the removed `Region` members should supply the region string directly:

```ballerina
// 4.x
sqs:ConnectionConfig config = {region: sqs:US_ISO_EAST_1, auth: authConfig};
```

```ballerina
// 5.0.0
sqs:ConnectionConfig config = {region: "us-iso-east-1", auth: authConfig};
```

## [4.1.0] - 2026-02-26

### Added
- [Support default credential login for the AWS SQS connector](https://github.com/wso2-enterprise/wso2-integration-internal/issues/4608)
