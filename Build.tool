set -e
cd "$(dirname "$0")"

NAME="iBooksVolumeKeys"
IN_PATH="Inject.m"
TARGET="com.apple.iBooks"
VERSION="1"

packagePath="Package"
installPath="$packagePath/Library/MobileSubstrate/DynamicLibraries"
dylibPath="$installPath/$NAME.dylib"
plistPath="$installPath/$NAME.plist"
metaPath="$packagePath/DEBIAN"
outPath="$NAME.deb"

rm -rf "$packagePath"
mkdir -p "$installPath"
mkdir -p "$metaPath"

xcrun -sdk iphoneos clang -dynamiclib -fmodules -arch armv7 -arch arm64 -F "$PWD" "$IN_PATH" -o "$dylibPath"
codesign -f -s - "$dylibPath"

/usr/libexec/PlistBuddy -c "add Filter:Bundles array" "$plistPath"
/usr/libexec/PlistBuddy -c "add Filter:Bundles:0 string $TARGET" "$plistPath"

echo "Package:$NAME\nVersion:$VERSION\nArchitecture:iphoneos-arm\nDepends:mobilesubstrate" > "$metaPath/control"

dpkg-deb -Z none -b "$packagePath" "$outPath"