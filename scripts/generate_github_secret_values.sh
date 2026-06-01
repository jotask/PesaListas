#!/usr/bin/env bash
set -euo pipefail

# Generates local copy/paste files for GitHub Actions secrets.
# It does NOT upload anything to GitHub.
#
# Usage:
#   ./scripts/generate_github_secret_values.sh
#
# Output:
#   /tmp/<project>-github-secrets-YYYYMMDD-HHMMSS/*.txt

PROJECT_NAME="$(basename "$(pwd)")"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
OUT_DIR="${OUT_DIR:-/tmp/${PROJECT_NAME}-github-secrets-${TIMESTAMP}}"

umask 077
mkdir -p "$OUT_DIR"

write_secret() {
  local name="$1"
  local value="$2"

  if [[ -z "$value" ]]; then
    echo "ERROR: $name is empty" >&2
    exit 1
  fi

  printf '%s' "$value" > "$OUT_DIR/${name}.txt"
  echo "created $OUT_DIR/${name}.txt"
}

read_required() {
  local prompt="$1"
  local value=""
  read -r -p "$prompt: " value
  if [[ -z "$value" ]]; then
    echo "ERROR: value is required" >&2
    exit 1
  fi
  printf '%s' "$value"
}

read_secret_required() {
  local prompt="$1"
  local value=""
  read -r -s -p "$prompt: " value
  echo
  if [[ -z "$value" ]]; then
    echo "ERROR: value is required" >&2
    exit 1
  fi
  printf '%s' "$value"
}

base64_one_line() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "ERROR: file not found: $file" >&2
    exit 1
  fi

  # Portable one-line base64 using Python, avoids Linux/macOS base64 flag differences.
  python3 - "$file" <<'PY'
import base64
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
print(base64.b64encode(path.read_bytes()).decode("ascii"), end="")
PY
}

extract_key_property() {
  local file="$1"
  local key="$2"

  if [[ ! -f "$file" ]]; then
    return 1
  fi

  grep -E "^${key}=" "$file" | head -n1 | cut -d= -f2-
}

echo
echo "Generating GitHub secret copy/paste files for: $PROJECT_NAME"
echo "Output dir: $OUT_DIR"
echo

# ─────────────────────────────────────────────
# Supabase / Google web client
# ─────────────────────────────────────────────

DEFAULT_ENV_FILE="assets/.env"

SUPABASE_URL_DEFAULT=""
SUPABASE_ANON_KEY_DEFAULT=""
GOOGLE_WEB_CLIENT_ID_DEFAULT=""

if [[ -f "$DEFAULT_ENV_FILE" ]]; then
  SUPABASE_URL_DEFAULT="$(grep -E '^SUPABASE_URL=' "$DEFAULT_ENV_FILE" | head -n1 | cut -d= -f2- || true)"
  SUPABASE_ANON_KEY_DEFAULT="$(grep -E '^SUPABASE_ANON_KEY=' "$DEFAULT_ENV_FILE" | head -n1 | cut -d= -f2- || true)"
  GOOGLE_WEB_CLIENT_ID_DEFAULT="$(grep -E '^GOOGLE_WEB_CLIENT_ID=' "$DEFAULT_ENV_FILE" | head -n1 | cut -d= -f2- || true)"
fi

if [[ -n "$SUPABASE_URL_DEFAULT" ]]; then
  read -r -p "SUPABASE_URL [$SUPABASE_URL_DEFAULT]: " SUPABASE_URL
  SUPABASE_URL="${SUPABASE_URL:-$SUPABASE_URL_DEFAULT}"
else
  SUPABASE_URL="$(read_required "SUPABASE_URL")"
fi

if [[ -n "$SUPABASE_ANON_KEY_DEFAULT" ]]; then
  read -r -p "SUPABASE_ANON_KEY [loaded from assets/.env, press Enter to use it]: " SUPABASE_ANON_KEY
  SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-$SUPABASE_ANON_KEY_DEFAULT}"
else
  SUPABASE_ANON_KEY="$(read_secret_required "SUPABASE_ANON_KEY")"
fi

if [[ -n "$GOOGLE_WEB_CLIENT_ID_DEFAULT" ]]; then
  read -r -p "GOOGLE_WEB_CLIENT_ID [$GOOGLE_WEB_CLIENT_ID_DEFAULT]: " GOOGLE_WEB_CLIENT_ID
  GOOGLE_WEB_CLIENT_ID="${GOOGLE_WEB_CLIENT_ID:-$GOOGLE_WEB_CLIENT_ID_DEFAULT}"
else
  GOOGLE_WEB_CLIENT_ID="$(read_required "GOOGLE_WEB_CLIENT_ID")"
fi

write_secret "SUPABASE_URL" "$SUPABASE_URL"
write_secret "SUPABASE_ANON_KEY" "$SUPABASE_ANON_KEY"
write_secret "GOOGLE_WEB_CLIENT_ID" "$GOOGLE_WEB_CLIENT_ID"

# ─────────────────────────────────────────────
# Android keystore
# ─────────────────────────────────────────────

if [[ -f "android/app/pesalistas-upload-keystore.jks" ]]; then
  DEFAULT_KEYSTORE="android/app/pesalistas-upload-keystore.jks"
elif [[ -f "android/app/upload-keystore.jks" ]]; then
  DEFAULT_KEYSTORE="android/app/upload-keystore.jks"
else
  DEFAULT_KEYSTORE="$(find android/app -maxdepth 1 -type f \( -name "*.jks" -o -name "*.keystore" \) | head -n1)"
fi
read -r -p "Android upload keystore path [$DEFAULT_KEYSTORE]: " ANDROID_KEYSTORE_PATH
ANDROID_KEYSTORE_PATH="${ANDROID_KEYSTORE_PATH:-$DEFAULT_KEYSTORE}"

ANDROID_KEYSTORE_BASE64="$(base64_one_line "$ANDROID_KEYSTORE_PATH")"
write_secret "ANDROID_KEYSTORE_BASE64" "$ANDROID_KEYSTORE_BASE64"

KEY_PROPERTIES_FILE="android/key.properties"

DEFAULT_STORE_PASSWORD="$(extract_key_property "$KEY_PROPERTIES_FILE" "storePassword" || true)"
DEFAULT_KEY_PASSWORD="$(extract_key_property "$KEY_PROPERTIES_FILE" "keyPassword" || true)"
DEFAULT_KEY_ALIAS="$(extract_key_property "$KEY_PROPERTIES_FILE" "keyAlias" || true)"

if [[ -n "$DEFAULT_STORE_PASSWORD" ]]; then
  read -r -s -p "ANDROID_KEYSTORE_PASSWORD [loaded from android/key.properties, press Enter to use it]: " ANDROID_KEYSTORE_PASSWORD
  echo
  ANDROID_KEYSTORE_PASSWORD="${ANDROID_KEYSTORE_PASSWORD:-$DEFAULT_STORE_PASSWORD}"
else
  ANDROID_KEYSTORE_PASSWORD="$(read_secret_required "ANDROID_KEYSTORE_PASSWORD")"
fi

if [[ -n "$DEFAULT_KEY_PASSWORD" ]]; then
  read -r -s -p "ANDROID_KEY_PASSWORD [loaded from android/key.properties, press Enter to use it]: " ANDROID_KEY_PASSWORD
  echo
  ANDROID_KEY_PASSWORD="${ANDROID_KEY_PASSWORD:-$DEFAULT_KEY_PASSWORD}"
else
  ANDROID_KEY_PASSWORD="$(read_secret_required "ANDROID_KEY_PASSWORD")"
fi

if [[ -n "$DEFAULT_KEY_ALIAS" ]]; then
  read -r -p "ANDROID_KEY_ALIAS [$DEFAULT_KEY_ALIAS]: " ANDROID_KEY_ALIAS
  ANDROID_KEY_ALIAS="${ANDROID_KEY_ALIAS:-$DEFAULT_KEY_ALIAS}"
else
  ANDROID_KEY_ALIAS="$(read_required "ANDROID_KEY_ALIAS")"
fi

write_secret "ANDROID_KEYSTORE_PASSWORD" "$ANDROID_KEYSTORE_PASSWORD"
write_secret "ANDROID_KEY_PASSWORD" "$ANDROID_KEY_PASSWORD"
write_secret "ANDROID_KEY_ALIAS" "$ANDROID_KEY_ALIAS"

# ─────────────────────────────────────────────
# Google Play service account JSON
# ─────────────────────────────────────────────


# Try to auto-detect the Google Play service account JSON.
# If exactly one match is found, use it as default.
# If more than one match is found, fail so we do not accidentally use the wrong private key.

GOOGLE_PLAY_JSON_PATTERNS=(
  "google-play-service-account.json"
  "android/app/pesalistas-*.json"
)

mapfile -t GOOGLE_PLAY_JSON_MATCHES < <(
  python3 - "${GOOGLE_PLAY_JSON_PATTERNS[@]}" <<'PY'
import glob
import os
import sys

matches = []
seen = set()

for pattern in sys.argv[1:]:
    pattern = os.path.expanduser(pattern)
    for path in glob.glob(pattern):
        if not os.path.isfile(path):
            continue

        path = os.path.normpath(path)

        if path in seen:
            continue

        seen.add(path)
        matches.append(path)

for match in matches:
    print(match)
PY
)

if (( ${#GOOGLE_PLAY_JSON_MATCHES[@]} > 1 )); then
  echo "ERROR: More than one Google Play service account JSON candidate found:" >&2
  printf '  - %s\n' "${GOOGLE_PLAY_JSON_MATCHES[@]}" >&2
  echo "Move/delete the wrong files, or enter the exact path manually after adjusting the script." >&2
  exit 1
elif (( ${#GOOGLE_PLAY_JSON_MATCHES[@]} == 1 )); then
  DEFAULT_GOOGLE_PLAY_JSON="${GOOGLE_PLAY_JSON_MATCHES[0]}"
else
  DEFAULT_GOOGLE_PLAY_JSON="google-play-service-account.json"
fi

read -r -p "Google Play service account JSON path [$DEFAULT_GOOGLE_PLAY_JSON]: " GOOGLE_PLAY_JSON_PATH
GOOGLE_PLAY_JSON_PATH="${GOOGLE_PLAY_JSON_PATH:-$DEFAULT_GOOGLE_PLAY_JSON}"

if [[ ! -f "$GOOGLE_PLAY_JSON_PATH" ]]; then
  echo "ERROR: file not found: $GOOGLE_PLAY_JSON_PATH" >&2
  exit 1
fi

python3 - "$GOOGLE_PLAY_JSON_PATH" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())

required = ["type", "client_email", "private_key"]
missing = [key for key in required if not data.get(key)]

if missing:
    raise SystemExit(f"ERROR: Google Play JSON missing keys: {', '.join(missing)}")

if data.get("type") != "service_account":
    raise SystemExit("ERROR: Google Play JSON must be type=service_account")
PY

GOOGLE_PLAY_SERVICE_ACCOUNT_JSON="$(cat "$GOOGLE_PLAY_JSON_PATH")"
write_secret "GOOGLE_PLAY_SERVICE_ACCOUNT_JSON" "$GOOGLE_PLAY_SERVICE_ACCOUNT_JSON"

# ─────────────────────────────────────────────
# Optional Firebase secrets, if files exist
# ─────────────────────────────────────────────

if [[ -f "android/app/google-services.json" ]]; then
  write_secret "GOOGLE_SERVICES_JSON_BASE64" "$(base64_one_line "android/app/google-services.json")"
fi

if [[ -f "lib/firebase_options.dart" ]]; then
  write_secret "FIREBASE_OPTIONS_DART_BASE64" "$(base64_one_line "lib/firebase_options.dart")"
fi

# ─────────────────────────────────────────────
# Helper files
# ─────────────────────────────────────────────

cat > "$OUT_DIR/README.txt" <<EOF
GitHub secret values generated for: $PROJECT_NAME

Open each .txt file and paste its full content into:
GitHub repo → Settings → Secrets and variables → Actions → New repository secret

Required secrets generated:
- SUPABASE_URL
- SUPABASE_ANON_KEY
- GOOGLE_WEB_CLIENT_ID
- ANDROID_KEYSTORE_BASE64
- ANDROID_KEYSTORE_PASSWORD
- ANDROID_KEY_PASSWORD
- ANDROID_KEY_ALIAS
- GOOGLE_PLAY_SERVICE_ACCOUNT_JSON

Optional Firebase secrets are generated only if these files exist:
- android/app/google-services.json → GOOGLE_SERVICES_JSON_BASE64
- lib/firebase_options.dart → FIREBASE_OPTIONS_DART_BASE64

Do not commit this output directory.
Delete it after pasting secrets:
rm -rf "$OUT_DIR"
EOF

cat > "$OUT_DIR/gh-secret-set-commands.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail

# Optional helper if you later want to upload using GitHub CLI.
# Usage:
#   REPO=jotask/YourRepo ./gh-secret-set-commands.sh

: "\${REPO:?Set REPO, example: REPO=jotask/PesaListas}"

for file in ./*.txt; do
  name="\$(basename "\$file" .txt)"
  [[ "\$name" == "README" ]] && continue
  gh secret set "\$name" --repo "\$REPO" < "\$file"
done
EOF

chmod +x "$OUT_DIR/gh-secret-set-commands.sh"

echo
echo "Done."
echo
echo "Secret files:"
ls -1 "$OUT_DIR"/*.txt
echo
echo "To open the folder:"
echo "  xdg-open \"$OUT_DIR\""
echo
echo "To delete after pasting:"
echo "  rm -rf \"$OUT_DIR\""
echo