#!/bin/bash
set -e               # arrêter dès la première erreur
IFS=$'\n\t'          # éviter les problèmes avec les espaces

# -------------------------------------------------
# 1️⃣  Version depuis config.rb
# -------------------------------------------------
VERSION=$(grep 'VERSION\s*=\s*"' src/torche_dyn/config.rb | cut -d'"' -f2)

if [ -z "$VERSION" ]; then
  echo "❌ Impossible de lire VERSION dans torche_dyn/config.rb"
  exit 1
fi

TAG="v$VERSION"
[[ $VERSION == v* ]] && TAG=$VERSION
echo "🔎 Version détectée : $TAG"

# -------------------------------------------------
# 2️⃣  Message de commit (argument du script)
# -------------------------------------------------
USER_MSG=$1
if [ -z "$USER_MSG" ]; then
  COMMIT_MSG="Release $TAG"
else
  COMMIT_MSG="Release $TAG : $USER_MSG"
fi
echo "📝 Message de commit : $COMMIT_MSG"

# -------------------------------------------------
# 3️⃣  Build du .rbz (build_release.sh)
# -------------------------------------------------
echo "⚙️  Construction du paquet .rbz ..."
chmod +x build_release.sh
./build_release.sh

# -------------------------------------------------
# 4️⃣  Le .rbz se trouve dans le dossier “release”
# -------------------------------------------------
RELEASE_DIR="release"
RBZ_FILE=$(find "$RELEASE_DIR" -maxdepth 1 -type f -name "*.rbz" -print -quit)

if [ -z "$RBZ_FILE" ]; then
  echo "❌ Aucun fichier .rbz trouvé dans le dossier $RELEASE_DIR"
  exit 1
fi

echo "✅ .rbz trouvé : $RBZ_FILE"

# -------------------------------------------------
# 5️⃣  Copier le .rbz dans un répertoire d’archives local
# -------------------------------------------------
ARTIFACTS_DIR="artifacts"
mkdir -p "$ARTIFACTS_DIR"
cp "$RBZ_FILE" "$ARTIFACTS_DIR/"

echo "📦 Copie du .rbz vers $ARTIFACTS_DIR/$(basename "$RBZ_FILE")"

# -------------------------------------------------
# 6️⃣  Commit / Tag / Push
# -------------------------------------------------
git add .
git commit -m "$COMMIT_MSG"
git tag "$TAG"

echo "🚀 Poussée du code et du tag vers GitHub ..."
git push origin main
git push origin "$TAG"

echo "🎉 Publication terminée – version $TAG disponible sur GitHub."
echo "    Le .rbz local est conservé dans le dossier ./$ARTIFACTS_DIR"
