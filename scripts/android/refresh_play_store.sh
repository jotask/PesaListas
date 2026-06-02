#!/usr/bin/env bash
set -euo pipefail

echo "This will force-stop and clear Google Play Store data on the connected Android device."
echo "It may reset Play Store cache/session state."
echo

read -r -p "Continue? [y/N]: " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Cancelled."
  exit 0
fi

adb shell am force-stop com.android.vending
adb shell pm clear com.android.vending

echo "Google Play Store cache cleared."
echo "Now reopen Play Store or the internal testing link."