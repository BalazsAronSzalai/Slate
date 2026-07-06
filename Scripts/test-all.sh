#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Swift package tests (SlateCore + SlateWriteCore)"
swift test --package-path Slate/Packages/SlateCore
swift test --package-path Slate/Packages/SlateWriteCore

echo "==> Xcode unit tests"
xcodebuild test \
  -project Slate.xcodeproj \
  -scheme Slate \
  -destination 'platform=macOS' \
  -quiet \
  CODE_SIGNING_ALLOWED=NO

echo "All tests passed."
