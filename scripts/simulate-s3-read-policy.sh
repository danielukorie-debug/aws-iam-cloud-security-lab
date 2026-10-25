#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")/.."

REGION="${AWS_REGION:-us-east-1}"
BUCKET="iam-lab-example-bucket-123456"
SOURCE_POLICY="policies/identity-based/s3-read-reports.json"
TEMP_POLICY="$(mktemp)"
trap 'rm -f "$TEMP_POLICY"' EXIT

if ! command -v aws >/dev/null 2>&1; then
    echo "ERROR: AWS CLI is not installed." >&2
    exit 1
fi

if [[ ! -f "$SOURCE_POLICY" ]]; then
    echo "ERROR: Policy file not found: $SOURCE_POLICY" >&2
    exit 1
fi

sed "s/REPLACE_WITH_BUCKET_NAME/$BUCKET/g" \
    "$SOURCE_POLICY" > "$TEMP_POLICY"

python3 -m json.tool "$TEMP_POLICY" >/dev/null

FAILURES=0

run_test() {
    local label="$1"
    local action="$2"
    local resource="$3"
    local expected="$4"
    local context="${5:-}"
    local decision

    local args=(
        iam simulate-custom-policy
        --policy-input-list "$(cat "$TEMP_POLICY")"
        --action-names "$action"
        --resource-arns "$resource"
        --region "$REGION"
        --query 'EvaluationResults[0].EvalDecision'
        --output text
        --no-cli-pager
    )

    if [[ -n "$context" ]]; then
        args+=(--context-entries "$context")
    fi

    decision="$(aws "${args[@]}")"

    if [[ "$decision" == "$expected" ]]; then
        printf '[PASS] %-34s expected=%-13s actual=%s\n' \
            "$label" "$expected" "$decision"
    else
        printf '[FAIL] %-34s expected=%-13s actual=%s\n' \
            "$label" "$expected" "$decision"
        FAILURES=$((FAILURES + 1))
    fi
}

echo "AWS IAM S3 Read-Only Authorization Simulations"
echo "Region: $REGION"
echo "Example bucket: $BUCKET"
echo "Simulation only: no S3 objects are read or changed."
echo

run_test \
    "Read reports object" \
    "s3:GetObject" \
    "arn:aws:s3:::$BUCKET/reports/demo.txt" \
    "allowed"

run_test \
    "Read outside reports prefix" \
    "s3:GetObject" \
    "arn:aws:s3:::$BUCKET/private/demo.txt" \
    "implicitDeny"

run_test \
    "Upload reports object" \
    "s3:PutObject" \
    "arn:aws:s3:::$BUCKET/reports/demo.txt" \
    "implicitDeny"

run_test \
    "List reports prefix" \
    "s3:ListBucket" \
    "arn:aws:s3:::$BUCKET" \
    "allowed" \
    "ContextKeyName=s3:prefix,ContextKeyValues=reports/,ContextKeyType=string"

run_test \
    "List private prefix" \
    "s3:ListBucket" \
    "arn:aws:s3:::$BUCKET" \
    "implicitDeny" \
    "ContextKeyName=s3:prefix,ContextKeyValues=private/,ContextKeyType=string"

echo

if (( FAILURES > 0 )); then
    echo "$FAILURES test(s) did not match their expected result."
    exit 1
fi

echo "All five authorization simulations matched their expected results."
