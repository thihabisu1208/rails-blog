#!/bin/bash
set -e

# Parse RSpec JSON output and create a formatted PR comment
RSPEC_JSON="$1"
PR_NUMBER="$2"

if [ ! -f "$RSPEC_JSON" ]; then
  echo "Error: RSpec JSON file not found: $RSPEC_JSON"
  exit 1
fi

# Parse JSON using jq
TOTAL=$(jq -r '.summary.example_count' "$RSPEC_JSON")
PASSED=$(jq -r '.summary.example_count - .summary.failure_count - .summary.pending_count' "$RSPEC_JSON")
FAILED=$(jq -r '.summary.failure_count' "$RSPEC_JSON")
PENDING=$(jq -r '.summary.pending_count' "$RSPEC_JSON")
DURATION=$(jq -r '.summary.duration' "$RSPEC_JSON")

# Round duration to 1 decimal place
DURATION=$(awk "BEGIN {printf \"%.1f\", $DURATION}")

# Calculate percentage (exclude pending tests from percentage)
RUNNABLE=$((TOTAL - PENDING))
if [ "$RUNNABLE" -gt 0 ]; then
  PERCENTAGE=$(awk "BEGIN {printf \"%.1f\", ($PASSED/$RUNNABLE)*100}")
else
  PERCENTAGE="0.0"
fi

# Determine status emoji and title
if [ "$FAILED" -eq 0 ]; then
  STATUS_EMOJI="✅"
  TITLE="RSpec Tests - All Passed!"
else
  STATUS_EMOJI="❌"
  TITLE="RSpec Tests - Some Failures"
fi

# Start building the comment
COMMENT="## $STATUS_EMOJI $TITLE

### 📊 Test Summary
\`\`\`
━━━━━━━━━━━━━━━━━━━━━━━━
Total:     $TOTAL tests
✅ Passed: $PASSED ($PERCENTAGE%)
❌ Failed: $FAILED"

if [ "$PENDING" -gt 0 ]; then
  COMMENT="$COMMENT
⏸️  Pending: $PENDING"
fi

COMMENT="$COMMENT
⏱️  Duration: ${DURATION}s
\`\`\`

### 📋 Test Suites
\`\`\`
━━━━━━━━━━━━━━━━━━━━━━━━"

# Get unique example groups (test files) - use process substitution to avoid subshell
while IFS= read -r file; do
  # Get test counts for this file
  file_total=$(jq -r --arg file "$file" '[.examples[] | select(.file_path == $file)] | length' "$RSPEC_JSON")
  file_failed=$(jq -r --arg file "$file" '[.examples[] | select(.file_path == $file and .status == "failed")] | length' "$RSPEC_JSON")
  file_pending=$(jq -r --arg file "$file" '[.examples[] | select(.file_path == $file and .status == "pending")] | length' "$RSPEC_JSON")
  file_passed=$((file_total - file_failed - file_pending))

  # Get friendly name from file path (convert snake_case to Title Case and add "spec")
  filename=$(basename "$file" | sed 's/_spec\.rb$//' | sed 's/_/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')

  # Determine status emoji and suffix
  if [ "$file_failed" -gt 0 ]; then
    emoji="❌"
    suffix="$file_total $([ "$file_total" -eq 1 ] && echo "test" || echo "tests")"
  elif [ "$file_pending" -eq "$file_total" ]; then
    emoji="⏸️"
    suffix="$file_pending $([ "$file_pending" -eq 1 ] && echo "pending" || echo "pending")"
  elif [ "$file_pending" -gt 0 ]; then
    emoji="✅"
    suffix="$file_passed $([ "$file_passed" -eq 1 ] && echo "test" || echo "tests"), $file_pending pending"
  else
    emoji="✅"
    suffix="$file_total $([ "$file_total" -eq 1 ] && echo "test" || echo "tests")"
  fi

  COMMENT="$COMMENT
$emoji ${filename} spec - ${suffix}"
done < <(jq -r '.examples[] | .file_path' "$RSPEC_JSON" | sort -u | sort)

COMMENT="$COMMENT
\`\`\`
"

# Add failed test details section
COMMENT="$COMMENT
### ❌ Failed Tests
"

if [ "$FAILED" -gt 0 ]; then
  # Get failed examples
  COMMENT="$COMMENT
\`\`\`
━━━━━━━━━━━━━━━━━━━━━━━━
"

  while IFS= read -r example; do
    full_desc=$(echo "$example" | jq -r '.full_description')
    file_path=$(echo "$example" | jq -r '.file_path')
    line_num=$(echo "$example" | jq -r '.line_number')
    error_msg=$(echo "$example" | jq -r '.exception.message')

    COMMENT="$COMMENT
❌ $full_desc
   📁 $file_path:$line_num

   Error:
   $(echo "$error_msg" | sed 's/^/   /')
━━━━━━━━━━━━━━━━━━━━━━━━
"
  done < <(jq -c '.examples[] | select(.status == "failed")' "$RSPEC_JSON")

  COMMENT="$COMMENT\`\`\`"
else
  COMMENT="$COMMENT
\`\`\`
━━━━━━━━━━━━━━━━━━━━━━━━
✅ No failed tests
━━━━━━━━━━━━━━━━━━━━━━━━
\`\`\`"
fi

# Post comment to PR using gh CLI
if [ -n "$PR_NUMBER" ]; then
  echo "$COMMENT" | gh pr comment "$PR_NUMBER" --body-file -
  echo "✅ Posted RSpec results comment to PR #$PR_NUMBER"
else
  echo "No PR number provided, skipping comment post"
  echo "Comment content:"
  echo "$COMMENT"
fi
