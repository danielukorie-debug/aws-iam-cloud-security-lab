# AWS IAM Least-Privilege Policy Test Matrix

## Purpose

This document defines expected authorization behavior for the
example policies in this repository.

These are test expectations, not claims that AWS has already
executed the tests or that the policies have been deployed.

## Test Cases

| Policy | Test case | Expected result from this policy |
|---|---|---|
| s3-read-reports.json | List the bucket with s3:prefix set to reports/ | Allow, if other applicable controls permit |
| s3-read-reports.json | Read an object under reports/ | Allow, if other applicable controls permit |
| s3-read-reports.json | Read an object outside reports/ | This policy does not grant access |
| s3-read-reports.json | Upload or delete an object | This policy does not grant access |
| secrets-consumer.json | Retrieve the matching example secret | Allow, if the ARN matches and other controls permit |
| secrets-consumer.json | Retrieve a different secret | This policy does not grant access |
| secrets-consumer.json | Create, update, or delete a secret | This policy does not grant access |
| human-role-trust-example.json | Matching principal requests sts:AssumeRole with the required MFA context | The trust statement matches, subject to the actual credential flow |
| human-role-trust-example.json | Different principal requests sts:AssumeRole | This statement does not authorize that principal |
| human-role-trust-example.json | Required MFA context is absent or false | This statement's condition is not satisfied |
| lab-boundary-example.json | Identity policy allows listing the reports bucket | The boundary permits that action only if the boundary applies and other controls permit |
| lab-boundary-example.json | Identity policy allows reading objects under reports/ | The boundary permits that action only if the boundary applies and other controls permit |
| lab-boundary-example.json | Identity policy allows unrelated S3 actions | This boundary does not allow those actions |
| s3-deny-insecure-transport.json | S3 request has aws:SecureTransport=false | Explicit deny applies to matching bucket resources |
| s3-deny-insecure-transport.json | S3 request has aws:SecureTransport=true | This statement does not deny the request or grant access |

## Important Interpretation Rules

- No Allow in one policy does not prove that every possible request
  is denied by AWS. Other applicable policies might grant access.
- An applicable explicit Deny overrides an Allow.
- The permissions boundary limits permissions but does not grant them.
- A trust policy determines who may assume a role; it does not define
  the role's permissions after assumption.
- Test the MFA condition with the intended credential and federation
  flow. Do not assume MFA context is automatically preserved in
  every role-chaining scenario.
- A resource policy that denies insecure transport does not, by itself,
  grant access to securely transported requests.
- Secret access using a customer-managed KMS key may also require
  appropriate kms:Decrypt permissions and a compatible key policy.

## Validation Status

Local JSON syntax validation has been performed.

AWS policy validation, authorization simulation, deployment testing,
and CloudTrail investigation must be recorded separately when performed.

## Evidence To Capture

- JSON syntax validation output
- IAM Access Analyzer policy-validation findings
- Authorization simulation results for selected Allow and Deny cases
- Screenshots of genuine test results, with account details and
  sensitive information excluded where possible


## Observed Authorization Simulation Results

The following decisions were observed when AWS IAM simulate-custom-policy evaluated the example S3 read policy. These were simulations, not live S3 requests.

| Action | Resource path | Context supplied | Observed decision |
|---|---|---|---|
| `s3:GetObject` | `reports/demo.txt` | None | `allowed` |
| `s3:GetObject` | `private/demo.txt` | None | `implicitDeny` |
| `s3:PutObject` | `reports/demo.txt` | None | `implicitDeny` |
| `s3:ListBucket` | Bucket | `s3:prefix=reports/` | `allowed` |
| `s3:ListBucket` | Bucket | `s3:prefix=private/` | `implicitDeny` |

The simulator reported missing `s3:prefix` context on some object-action tests. That condition belongs to the ListBucket statement. These outcomes demonstrate the evaluated policy behavior but do not prove how every applicable policy in a live AWS account would affect access.
