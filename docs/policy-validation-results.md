# AWS IAM Policy Validation Results

## Summary

AWS IAM Access Analyzer policy validation was performed for five
example policy documents in the `us-east-1` Region.

The observed result for each policy was an empty findings array (`[]`).

## Policies Checked

| Policy file | Validation type | Observed result |
|---|---|---|
| `identity-based/s3-read-reports.json` | Identity policy | No findings returned |
| `identity-based/secrets-consumer.json` | Identity policy | No findings returned |
| `permissions-boundary/lab-boundary-example.json` | Identity policy | No findings returned |
| `trust/human-role-trust-example.json` | IAM role trust policy | No findings returned |
| `resource-based/s3-deny-insecure-transport.json` | S3 bucket resource policy | No findings returned |

## What This Demonstrates

- The five example documents were accepted by the policy-validation
  operation without reported findings during the observed runs.
- The lab distinguishes identity permissions, resource permissions,
  role trust relationships, permissions boundaries, and explicit-deny
  controls.
- A repeatable Bash script can run validation checks for the policy set.

## Limitations

An empty findings array does not prove that a policy is secure in every
context or that an authorization request will succeed or be denied as
intended.

These are example policies. Their ARNs and account identifiers include
placeholders, and the policies have not been attached to live identities
or resources as part of this validation exercise.

The validation results do not establish that:
- users or roles were created;
- a secret was stored or retrieved;
- encryption was configured on a live resource;
- an authorization simulation passed;
- a CloudTrail investigation was completed.

## Next Validation Activities

1. Review policy findings and policy scopes.
2. Replace placeholders only in an approved test environment.
3. Simulate representative allowed and denied requests.
4. Verify role-assumption and authentication flows.
5. Record actual test output and timestamps.
6. Review CloudTrail evidence when the accountability module is performed.

## Security Reminder

Never commit AWS credentials, access tokens, private keys, live secret
values, Terraform state, or unredacted security evidence.


## GitHub Actions OIDC Trust Policy Validation

Policy: `policies/trust/github-actions-oidc-example.json`

Validation used `RESOURCE_POLICY` and `AWS::IAM::AssumeRolePolicyDocument` in `us-east-1`.

Observed finding: `SUGGESTION` — `CONFIRM_AUDIENCE_CLAIM_TYPE`.

AWS noted that the audience claim is single-valued and should not use a condition-set qualifier. The example uses `StringEquals` directly for the audience claim, without a qualifier. The suggestion is recorded for review; it did not require adding a qualifier.

The subject condition includes owner-ID and repository-ID placeholders. Before live use, verify the exact subject claim emitted by the repository and replace the placeholders with the corresponding verified IDs. This example has not been deployed, and a live OIDC role-assumption flow has not been tested.


## Secrets Manager and KMS Policy Validation

Two additional identity-based policy documents were validated using AWS IAM Access Analyzer in us-east-1.

| Policy | Observed result |
|---|---|
| `policies/identity-based/secrets-metadata-reviewer.json` | No findings returned (`[]`) |
| `policies/identity-based/secrets-consumer-cmk-example.json` | No findings returned (`[]`) |

These results reflect policy validation, not live secret retrieval or KMS decryption tests. The example resource ARNs and customer-managed KMS key ID are placeholders. The key policy and applicable permissions must be reviewed before any live use.
