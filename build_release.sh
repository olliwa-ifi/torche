#!/bin/bash

# 1. Extract version
# On nettoie agressivement la variable pour supprimer tout caractère invisible
VERSION=$(grep "VERSION =" src/torche_dyn/config.rb | awk -F'"' '{print $2}' | tr -d '\r\n ')

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

# 3. Handle the Loader
LOADER_PATH=$(find . -name "torche_dyn_loader.rb" -print -quit)

if [ -z "$LOADER_PATH" ]; then
    echo "❌ Error: torche_dyn_loader.rb not found!"
    exit 1
fi

# Copy loader to the ROOT of the build folder
cp "$LOADER_PATH" "$BUILD_DIR/"

# 4. Copy the source folder
cp -r src/torche_dyn "$BUILD_DIR/"

# Remove the loader from INSIDE the folder to prevent duplication
rm -f "$BUILD_DIR/torche_dyn/torche_dyn_loader.rb"

# 5. Create the .rbz
# Utilisation de chemins absolus pour éviter les erreurs de syntaxe Windows avec ../
ABS_BUILD_DIR="$(pwd)/$BUILD_DIR"
ABS_RELEASE_DIR="$(pwd)/$RELEASE_DIR"
FILENAME="torche_dyn_v${VERSION}.rbz"

# On execute la compression
(cd "$ABS_BUILD_DIR" && 7z a -tzip "$ABS_RELEASE_DIR/$FILENAME" "*")

# 6. Cleanup
rm -rf "$BUILD_DIR"

if [ -f "$ABS_RELEASE_DIR/$FILENAME" ]; then
    echo "✅ Release created: $ABS_RELEASE_DIR/$FILENAME"
    echo "Structure: [torche_dyn_loader.rb] and [torche_dyn/]"
else
    echo "❌ Error: Failed to create release."
    exit 1
fi
