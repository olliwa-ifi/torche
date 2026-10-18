#!/bin/bash

# 1. Extract version
VERSION=$(grep "VERSION =" src/torche_dyn/config.rb | awk -F'"' '{print $2}')
if [ -z "$VERSION" ]; then
    echo "❌ Error: Could not find VERSION in config.rb"
    exit 1
fi

echo "📦 Building release version $VERSION..."

# 2. Setup directories
RELEASE_DIR="release"
BUILD_DIR="release/build_tmp"

rm -rf "$RELEASE_DIR"
mkdir -p "$BUILD_DIR"

# 3. Handle the Loader (Move it to root, remove from source folder)
LOADER_PATH=$(find . -name "torche_dyn_loader.rb" -print -quit)

if [ -z "$LOADER_PATH" ]; then
    echo "❌ Error: torche_dyn_loader.rb not found!"
    exit 1
fi

# Copy loader to the ROOT of the build folder
cp "$LOADER_PATH" "$BUILD_DIR/"

# 4. Copy the source folder
cp -r src/torche_dyn "$BUILD_DIR/"

# IMPORTANT: Remove the loader from INSIDE the torche_dyn folder 
# to prevent duplication in the .rbz
rm -f "$BUILD_DIR/torche_dyn/torche_dyn_loader.rb"

# 5. Create the .rbz
OUTPUT_FILE="$RELEASE_DIR/torche_dyn_v${VERSION}.rbz"
(cd "$BUILD_DIR" && 7z a -tzip "../torche_dyn_v${VERSION}.rbz" "*" )

# 6. Cleanup
rm -rf "$BUILD_DIR"

if [ -f "$OUTPUT_FILE" ]; then
    echo "✅ Release created: $OUTPUT_FILE"
    echo "Structure: [torche_dyn_loader.rb] and [torche_dyn/]"
else
    echo "❌ Error: Failed to create release."
    exit 1
fi
