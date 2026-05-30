#!/usr/bin/env bash
set -euo pipefail

BUMP="${1:-build}" # build | patch | minor | major
UPLOAD="${UPLOAD:-0}"
TRACK="${TRACK:-internal}"
RELEASE_STATUS="${RELEASE_STATUS:-draft}"

PUBSPEC="pubspec.yaml"
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"

if [[ ! -f "$PUBSPEC" ]]; then
  echo "[ERROR] pubspec.yaml not found. Run this from the Flutter project root."
  exit 1
fi

python3 - "$BUMP" "$PUBSPEC" <<'PY'
import re
import sys
from pathlib import Path

bump = sys.argv[1]
path = Path(sys.argv[2])
text = path.read_text()

pattern = re.compile(r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$", re.MULTILINE)
match = pattern.search(text)

if not match:
    print("[ERROR] Could not find version line like: version: 1.0.0+1")
    sys.exit(1)

major, minor, patch, build = map(int, match.groups())

if bump == "build":
    build += 1
elif bump == "patch":
    patch += 1
    build += 1
elif bump == "minor":
    minor += 1
    patch = 0
    build += 1
elif bump == "major":
    major += 1
    minor = 0
    patch = 0
    build += 1
else:
    print("[ERROR] Invalid bump type. Use: build, patch, minor, or major")
    sys.exit(1)

new_version = f"version: {major}.{minor}.{patch}+{build}"
new_text = pattern.sub(new_version, text, count=1)
path.write_text(new_text)

print(f"[SUCESS] Updated pubspec.yaml to {new_version}")
PY

echo "[PROGRESS] Cleaning Flutter project..."
flutter clean

echo "[PROGRESS] Getting packages..."
flutter pub get

echo "[PROGRESS] Building Android App Bundle..."
flutter build appbundle --release

if [[ ! -f "$AAB_PATH" ]]; then
  echo "[ERROR] AAB not found at $AAB_PATH"
  exit 1
fi

echo "[SUCESS] Built AAB:"
echo "$AAB_PATH"

if [[ "$UPLOAD" == "1" ]]; then
  echo "[SUCCESS] Uploading to Google Play track: $TRACK, status: $RELEASE_STATUS"
  cd android
  bundle exec fastlane android upload
else
  echo "[INFO] Upload skipped."
  echo "To upload later, run:"
  echo "UPLOAD=1 TRACK=internal RELEASE_STATUS=draft ./scripts/release_android.sh build"
fi