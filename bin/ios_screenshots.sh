#!/usr/bin/env bash
set -euo pipefail

# Capture App Store screenshots (and optionally app preview videos) from the
# iOS Simulator using the app's litloop:// deep links.
#
# Requirements: macOS with Xcode command line tools (xcodebuild, simctl, sips).
# Run from anywhere; paths are resolved from the repository root.
#
# Usage:
#   bin/ios_screenshots.sh
#   ROUTES="home:|club:book_clubs/1|book:books/2453" bin/ios_screenshots.sh
#   VIDEO=1 bin/ios_screenshots.sh
#
# Environment:
#   IPHONE_DEVICE  Simulator name for the iPhone set (default: iPhone 16 Pro Max)
#   IPAD_DEVICE    Simulator name for the iPad set   (default: iPad Pro 13-inch (M4))
#   ROUTES         "name:path|name:path"; an empty path launches the home tab.
#                  A path may be a full https:// URL; prefer bare paths (litloop://
#                  is more reliable than universal links in the simulator).
#   OUTPUT_DIR     Destination directory (default: build/app-store-screenshots)
#   WAIT_SECONDS   Delay after opening each route (default: 6)
#   VIDEO          1 to record an app preview per device (needs ffmpeg to trim)
#   SKIP_IPAD      1 to capture only iPhone

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BUNDLE_ID="${BUNDLE_ID:-et.netale.litloop}"
OUTPUT_DIR="${OUTPUT_DIR:-build/app-store-screenshots}"
DERIVED_DATA="${DERIVED_DATA:-build/ios-screenshots-derived}"
APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/LitLoop.app"
IPHONE_DEVICE="${IPHONE_DEVICE:-iPhone 16 Pro Max}"
IPAD_DEVICE="${IPAD_DEVICE:-iPad Pro 13-inch (M4)}"
ROUTES="${ROUTES:-club:book_clubs/1|home:|book_read:book_clubs/1/book_reads/6|clubs:book_clubs|book:books/2453}"
WAIT_SECONDS="${WAIT_SECONDS:-6}"
VIDEO="${VIDEO:-0}"
SKIP_IPAD="${SKIP_IPAD:-0}"

for tool in xcodebuild xcrun python3 sips; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "error: $tool not found (run this on macOS with Xcode installed)" >&2
    exit 1
  }
done

route_url() {
  case "$1" in
    http://* | https://*) printf '%s' "$1" ;;
    *) printf 'litloop://%s' "$1" ;;
  esac
}

find_device() {
  python3 - "$1" <<'PY'
import json
import subprocess
import sys

name = sys.argv[1]
data = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"]))
candidates = []
for runtime, devices in data["devices"].items():
    version = runtime.rsplit(".", 1)[-1]
    key = tuple(int(part) for part in version.split(".") if part.isdigit())
    for device in devices:
        if device["name"] == name:
            candidates.append((key, device["udid"]))
if not candidates:
    available = sorted({device["name"] for devices in data["devices"].values() for device in devices})
    sys.stderr.write(
        "error: simulator not found: %s\nAvailable simulators:\n%s\n"
        % (name, "\n".join("  " + entry for entry in available))
    )
    sys.exit(1)
candidates.sort()
print(candidates[-1][1])
PY
}

echo "Building LitLoop for the simulator..."
xcodebuild \
  -project ios/LitLoop.xcodeproj \
  -scheme LitLoop \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  -quiet \
  build

[[ -d "$APP_PATH" ]] || {
  echo "error: built app not found at $APP_PATH" >&2
  exit 1
}

capture_device() {
  local device_name="$1"
  local slug="$2"
  local udid dir entry name path out dims index
  local -a route_list

  udid="$(find_device "$device_name")"
  dir="$OUTPUT_DIR/$slug"
  rm -rf "$dir"
  mkdir -p "$dir"

  echo "== $device_name ($udid)"
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null
  xcrun simctl install "$udid" "$APP_PATH"

  xcrun simctl status_bar "$udid" override \
    --time "9:41" \
    --dataNetwork wifi \
    --wifiMode active \
    --wifiBars 3 \
    --cellularMode active \
    --cellularBars 4 \
    --batteryState charged \
    --batteryLevel 100

  IFS='|' read -ra route_list <<< "$ROUTES"
  index=0
  for entry in "${route_list[@]}"; do
    [[ -n "$entry" ]] || continue
    index=$((index + 1))
    name="${entry%%:*}"
    path="${entry#*:}"
    out="$(printf '%s/%02d-%s.png' "$dir" "$index" "$name")"

    xcrun simctl terminate "$udid" "$BUNDLE_ID" 2>/dev/null || true
    if [[ -n "$path" ]]; then
      echo "   $name -> $(route_url "$path")"
      xcrun simctl openurl "$udid" "$(route_url "$path")"
    else
      echo "   $name -> launch"
      xcrun simctl launch "$udid" "$BUNDLE_ID" >/dev/null
    fi
    sleep "$WAIT_SECONDS"

    xcrun simctl io "$udid" screenshot --type=png "$out"
    dims="$(sips -g pixelWidth -g pixelHeight "$out" | awk '/pixel/ {printf "%s ", $2}')"
    echo "   wrote $out (${dims% }px)"
  done

  if [[ "$VIDEO" == "1" ]]; then
    record_preview "$udid" "$dir"
  fi

  xcrun simctl status_bar "$udid" clear
}

record_preview() {
  local udid="$1"
  local dir="$2"
  local raw="$dir/app-preview-raw.mov"
  local final="$dir/app-preview.mov"
  local rec_pid entry path
  local -a route_list

  echo "   recording app preview..."
  xcrun simctl io "$udid" recordVideo --codec=h264 --force "$raw" &
  rec_pid=$!

  IFS='|' read -ra route_list <<< "$ROUTES"
  local shots=0
  for entry in "${route_list[@]}"; do
    [[ -n "$entry" ]] || continue
    path="${entry#*:}"
    shots=$((shots + 1))
    xcrun simctl terminate "$udid" "$BUNDLE_ID" 2>/dev/null || true
    if [[ -n "$path" ]]; then
      xcrun simctl openurl "$udid" "$(route_url "$path")"
    else
      xcrun simctl launch "$udid" "$BUNDLE_ID" >/dev/null
    fi
    sleep 5
  done
  if (( shots * 5 < 15 )); then
    echo "   warning: preview will be shorter than the 15s minimum; add routes or lengthen the loop" >&2
  fi
  sleep 1
  kill -INT "$rec_pid" 2>/dev/null || true
  wait "$rec_pid" 2>/dev/null || true

  if command -v ffmpeg >/dev/null 2>&1; then
    ffmpeg -y -loglevel error -i "$raw" -t 20 -c copy "$final"
    rm -f "$raw"
    echo "   wrote $final"
  else
    echo "   warning: ffmpeg not found; raw video left at $raw (trim to 15-30s manually)" >&2
  fi
}

mkdir -p "$OUTPUT_DIR"
capture_device "$IPHONE_DEVICE" "iphone-6.9"
if [[ "$SKIP_IPAD" != "1" ]]; then
  capture_device "$IPAD_DEVICE" "ipad-13"
fi

echo
echo "Screenshots ready in $OUTPUT_DIR"
