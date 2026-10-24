#!/bin/sh

# Fail this script if any subcommand fails
set -e

echo "==========================================================="
echo "=== [Xcode Cloud] Starting Flutter & CocoaPods Setup     ==="
echo "==========================================================="

# Navigate to the repository root directory
cd "$CI_PRIMARY_REPOSITORY_PATH"

# 1. Clone Flutter SDK (stable branch)
echo "=== [Xcode Cloud] Cloning Flutter SDK (stable)... ==="
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

# 2. Check Flutter version
flutter --version

# 3. Precache iOS engine artifacts
echo "=== [Xcode Cloud] Precaching iOS artifacts... ==="
flutter precache --ios

# 4. Fetch Dart and Flutter package dependencies
echo "=== [Xcode Cloud] Running flutter pub get... ==="
flutter pub get

# 5. Build iOS configuration files and assemble Flutter frameworks
echo "=== [Xcode Cloud] Running flutter build ios --config-only... ==="
flutter build ios --config-only --no-codesign

# 6. Ensure CocoaPods is installed and run pod install
echo "=== [Xcode Cloud] Installing CocoaPods & running pod install... ==="
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods || true
cd ios
pod install --repo-update

echo "==========================================================="
echo "=== [Xcode Cloud] Setup completed successfully!         ==="
echo "=== Handing over to Xcode build and archive process.    ==="
echo "==========================================================="
exit 0
