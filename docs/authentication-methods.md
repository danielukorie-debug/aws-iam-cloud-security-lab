# AWS Authentication Methods and MFA

## Purpose

This module documents ways people and workloads authenticate to AWS.
These examples are learning materials; they do not configure or create
live identities or authentication providers.

## Authentication Methods

| Method | Typical use | Main security consideration |
|---|---|---|
| IAM Identity Center | Workforce single sign-on | Apply appropriate MFA and permission assignments |
| IAM user password | Console sign-in where IAM users are necessary | Avoid unnecessary IAM users; protect sign-in with MFA |
| MFA | Additional verification for supported sign-in and API flows | Protect enrollment and recovery processes |
| SAML 2.0 federation | Enterprise identity provider integration | Validate the trusted IdP and role mapping |
| OpenID Connect (OIDC) | Federated application or CI/CD identity | Restrict issuer, audience, subject, repository, and branch |
| AWS STS | Temporary role-session credentials | Limit trust, permissions, and session duration |
| AWS access keys | Programmatic access in exceptional cases | Long-lived credentials create additional risk |
| AWS Signature Version 4 | Signs supported AWS API requests | Signing authenticates requests using AWS credentials; it is not an identity provider |

## Human Authentication

For workforce access, consider federation through IAM Identity Center.
Use the organization's approved identity provider and authentication
requirements, including MFA.

Do not change your existing administrator or root sign-in settings
during this learning exercise.

## Workload Authentication

For automation such as a GitHub Actions workflow, OIDC can allow AWS
to exchange a trusted identity token for temporary role credentials.
This avoids storing long-lived AWS access keys in GitHub repository
secrets.

The OIDC trust policy must restrict the provider and the intended
subject. This project uses a sample condition limited to this lab's
GitHub repository and main branch.

## MFA and STS

MFA provides an additional authentication factor. AWS STS can issue
temporary role-session credentials when the caller, trust relationship,
and applicable policies permit the request.

The IAM condition key aws:MultiFactorAuthPresent is not present for
some federated identities or requests signed using long-term access
keys. Do not assume this condition alone enforces MFA for every
federation method. Configure and test the appropriate identity-provider
or IAM Identity Center controls for the actual sign-in flow.

## Validation Plan

1. Validate the local OIDC trust-policy JSON.
2. Run IAM Access Analyzer policy validation.
3. Review the exact repository and branch restrictions.
4. Only configure a live OIDC provider and role after reviewing
   account access, permissions, and deployment impact.

## Security Guardrails

- Never publish AWS access keys, secret keys, session tokens, or MFA codes.
- Do not store long-lived AWS credentials in GitHub workflow files.
- Do not use wildcard-only OIDC subject conditions.
- Keep example account IDs as placeholders.
- Policy validation does not prove that a live authentication flow works.
