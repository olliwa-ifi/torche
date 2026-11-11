#!/bin/bash

# ==============================================================================
# Script de build et d'installation locale pour Olliwa Torche Generator
# ==============================================================================

echo "------------------------------------------------------------"
echo "📦 Building & Installing Olliwa Torche Generator"
echo "------------------------------------------------------------"

# On définit la racine du projet
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$ROOT_DIR/src"

# --- NOMS DES FICHIERS ET DOSSIERS ---
# Le fichier loader (à la racine du dossier Plugins)
PLUGIN_LOADER="olw_torche_dyn_loader" 
# Le dossier contenant le code (qui sera créé dans Plugins/)
PLUGIN_DIR_NAME="olw_torche_dyn" 
# Fichier où est définie la version
CONFIG_FILE="$SOURCE_DIR/$PLUGIN_DIR_NAME/config.rb"

RELEASE_DIR="$ROOT_DIR/release"

echo "CONFIG_FILE path: $CONFIG_FILE"

# --- CONFIGURATION DU CHEMIN SKETCHUP (Windows via Git Bash) ---
SKETCHUP_PLUGINS_DIR="$APPDATA/SketchUp/SketchUp 2020/SketchUp/Plugins"
# --------------------------------------------------------------

# 1. Extraction de la version
echo "1. Extracting version from $CONFIG_FILE..."
if [ -f "$CONFIG_FILE" ]; then
    echo "✅ Found $CONFIG_FILE"
    # On cherche la ligne VERSION = "X.X.X"
    VERSION=$(grep "VERSION =" "$CONFIG_FILE" | awk -F'"' '{print $2}' | tr -d '\r\n ')
else
    echo "❌ Error: $CONFIG_FILE not found."
    exit 1
fi

if [ -z "$VERSION" ]; then
    echo "❌ Error: Could not extract VERSION from $CONFIG_FILE"
    exit 1
fi

echo "Version detected: $VERSION"
FINAL_FILENAME="${PLUGIN_DIR_NAME}_v${VERSION}.rbz"


# 2. Création du dossier release
echo "2. Creating release directory... in $(pwd)"
mkdir -p ${RELEASE_DIR}

# 3. Compression pour créer le .rbz (pour distribution)
echo "---------------------------------------------"
echo "🚀 Compressing with 7-Zip..."
echo "--------------------------------------------"
echo "3. Compressing into .rbz..."
echo "Final filename will be: $FINAL_FILENAME"

# On compresse le loader (.rb) ET le dossier du plugin
7z a -tzip "$RELEASE_DIR/$FINAL_FILENAME" "$SOURCE_DIR/$PLUGIN_LOADER.rb" "$SOURCE_DIR/$PLUGIN_DIR_NAME/"

if [ $? -eq 0 ]; then
    echo "✅ Success! Generated: release/$FINAL_FILENAME"
else
    echo "❌ Error: Compression failed."
    exit 1
fi


# 4. INSTALLATION LOCALE (Déploiement direct dans SketchUp 2020)
echo "------------------------------------------------------------"
echo "🚀 Installing to SketchUp 2020 Plugins folder..."
echo "------------------------------------------------------------"

if [ -d "$SKETCHUP_PLUGINS_DIR" ]; then
    echo "Target directory found: $SKETCHUP_PLUGINS_DIR"
    
    # On extrait le .rbz directement dans le dossier plugins de SketchUp
    # -y force l'écrasement des fichiers existants
    7z x "$RELEASE_DIR/$FINAL_FILENAME" "-o$SKETCHUP_PLUGINS_DIR" -y
    
    if [ $? -eq 0 ]; then
        echo "✅ Plugin successfully installed (forced) to: $SKETCHUP_PLUGINS_DIR"
    else
        echo "❌ Error: Extraction failed during installation."
    fi
    echo "✅ Installation complete! Please restart SketchUp 2020."
else
    echo "❌ Error: SketchUp 2020 Plugins directory not found at $SKETCHUP_PLUGINS_DIR"
    exit 1
fi

echo "------------------------------------------------------------"
echo "📦 Build and installation process completed successfully!"
echo "------------------------------------------------------------"
