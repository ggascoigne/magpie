#!/bin/zsh

set -euo pipefail

repo_dir=${0:a:h:h}
configuration=${1:-debug}

if [[ "$configuration" != "debug" && "$configuration" != "release" ]]; then
    print -u2 "Usage: $0 [debug|release]"
    exit 2
fi

binary_directory=$(swift build --package-path "$repo_dir" --configuration "$configuration" --arch arm64 --show-bin-path)
swift build --package-path "$repo_dir" --configuration "$configuration" --arch arm64 >&2

binary_path="$binary_directory/Magpie"
app_path="$repo_dir/build/Magpie.app"
contents_path="$app_path/Contents"

mkdir -p "$contents_path/MacOS" "$contents_path/Resources"
install -m 755 "$binary_path" "$contents_path/MacOS/Magpie"
install -m 644 "$repo_dir/Resources/Info.plist" "$contents_path/Info.plist"
install -m 644 "$repo_dir/Resources/Magpie.icns" "$contents_path/Resources/Magpie.icns"

signing_identity=${MAGPIE_SIGNING_IDENTITY:--}
if [[ "$signing_identity" == "-" ]]; then
    codesign \
        --force \
        --sign - \
        --identifier dev.ggp.magpie \
        --requirements '=designated => identifier "dev.ggp.magpie"' \
        "$app_path" >&2
else
    codesign --force --sign "$signing_identity" "$app_path" >&2
fi

print "$app_path"
