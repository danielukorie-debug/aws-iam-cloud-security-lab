#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")/.."

REGION="${AWS_REGION:-us-east-1}"

echo "========================================"
echo " AWS IAM POLICY VALIDATION LAB"
echo " Region: ${REGION}"
echo "========================================"

echo
echo "=== 1. S3 Read Reports: Identity Policy ==="
aws accessanalyzer validate-policy \
  --policy-document file://policies/identity-based/s3-read-reports.json \
  --policy-type IDENTITY_POLICY \
  --region "$REGION" \
  --query 'findings[].{Type:findingType,Code:issueCode,Details:findingDetails}' \
  --output json \
  --no-cli-pager

echo
echo "=== 2. Secrets Consumer: Identity Policy ==="
aws accessanalyzer validate-policy \
  --policy-document file://policies/identity-based/secrets-consumer.json \
  --policy-type IDENTITY_POLICY \
  --region "$REGION" \
  --query 'findings[].{Type:findingType,Code:issueCode,Details:findingDetails}' \
  --output json \
  --no-cli-pager

echo
echo "=== 3. Permissions Boundary ==="
aws accessanalyzer validate-policy \
  --policy-document file://policies/permissions-boundary/lab-boundary-example.json \
  --policy-type IDENTITY_POLICY \
  --region "$REGION" \
  --query 'findings[].{Type:findingType,Code:issueCode,Details:findingDetails}' \
  --output json \
  --no-cli-pager

echo
echo "=== 4. IAM Role Trust Policy ==="
aws accessanalyzer validate-policy \
  --policy-document file://policies/trust/human-role-trust-example.json \
  --policy-type RESOURCE_POLICY \
  --validate-policy-resource-type AWS::IAM::AssumeRolePolicyDocument \
  --region "$REGION" \
  --query 'findings[].{Type:findingType,Code:issueCode,Details:findingDetails}' \
  --output json \
  --no-cli-pager

echo
echo "=== 5. S3 Secure Transport Policy ==="
aws accessanalyzer validate-policy \
  --policy-document file://policies/resource-based/s3-deny-insecure-transport.json \
  --policy-type RESOURCE_POLICY \
  --validate-policy-resource-type AWS::S3::Bucket \
  --region "$REGION" \
  --query 'findings[].{Type:findingType,Code:issueCode,Details:findingDetails}' \
  --output json \
  --no-cli-pager

echo
echo "All five policy validation requests completed."
echo "Review each findings array above."
