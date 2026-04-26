#!/bin/bash
set -e

# --- Step 0: Setup ---
email="$1"
REPO_DIR="$2"

if [ -z "$email" ]; then
  echo "[X] Email is required"
  echo "Usage: $0 <email> <repo_path>"
  exit 1
fi

if [ -z "$REPO_DIR" ]; then
  echo "[X] Repo path is required"
  echo "Usage: $0 <email> <repo_path>"
  exit 1
fi

if ! git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[X] Invalid git repo: $REPO_DIR"
  exit 1
fi

# --- Config ---
DATA_DIR="${GIT_STATS_DATA_DIR:-./data}"
repo_name=$(basename "$REPO_DIR")

BASE_DIR="$DATA_DIR/$repo_name"
AUTHORED_DIR="$BASE_DIR/authored"

# sanitize email for filename
safe_email=$(echo "$email" | sed 's/[^a-zA-Z0-9]/_/g')

# ensure directory exists
mkdir -p "$AUTHORED_DIR"

file="$AUTHORED_DIR/${safe_email}.jsonl"

# --- Debug ---
echo "---------------------------------"
echo "Email      : $email"
echo "Repo       : $REPO_DIR"
echo "Data dir   : $DATA_DIR"
echo "Output file: $file"
echo "---------------------------------"

# --- Step 1: get last commit (if file exists) ---
echo Step 1

#last_commit=""
#
#if [ -f "$file" ] && [ -s "$file" ]; then
#  last_commit=$(head -n 1 "$file" | jq -r '.hash')
#
#  # handle malformed JSON or null
#  if [ -z "$last_commit" ] || [ "$last_commit" = "null" ]; then
#    echo "[*] Could not read last commit. Rebuilding full history."
#    last_commit=""
#  fi
#fi

echo "Last commit: [$last_commit]"

last_commit=""

if [ -f "$file" ] && [ -s "$file" ]; then
  first_line=$(head -n 1 "$file")

  if echo "$first_line" | jq -e '.hash' >/dev/null 2>&1; then
    last_commit=$(echo "$first_line" | jq -r '.hash')
  else
    echo "[*] Invalid JSON in first line. Rebuilding full history."
  fi
fi



# --- Step 2: build git range ---
echo Step 2
if [ -n "$last_commit" ]; then
  if git -C "$REPO_DIR" cat-file -e "$last_commit" 2>/dev/null; then
    range="$last_commit..HEAD"
  else
    echo "[*] Commit $last_commit not found. Rebuilding full history."
    range=""
  fi
else
  range=""
fi

# --- Step 3: temp file ---
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
echo Step 3

# --- Step 4: fetch + convert to JSONL ---
echo Step 4
echo "Range: [$range]"

git -C "$REPO_DIR" log ${range:+$range} \
  --author="$email" \
  --no-merges \
  --pretty=format:'%H%x1f%cd%x1f%s' \
  --date=short |
jq -R -c --arg e "$email" '
  split("\u001f") |
  select(length == 3) |
  {hash: .[0], date: .[1], subject: .[2], email: $e}
' > "$tmp"

# --- Step 5: prepend old data ---
echo Step 5
if [ -f "$file" ]; then
  [ -s "$tmp" ] && echo >> "$tmp"
  cat "$file" >> "$tmp"
fi

# --- Step 6: replace file ---
echo Step 6
mv "$tmp" "$file"

echo "[Done] Updated $file"
