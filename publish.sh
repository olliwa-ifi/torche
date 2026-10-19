#!/bin/bash

# 1. Extraction de la version depuis config.rb
# Correction : suppression du guillemet erroné après config.rb
VERSION=$(grep 'VERSION\s*=\s*"' src/torche_dyn/config.rb | cut -d'"' -f2)

if [ -z "$VERSION" ]; then
    echo "❌ Erreur : Impossible de trouver la version dans torche_dyn/config.rb"
    exit 1
fi
echo "🔍 Version trouvée : $VERSION"

TAG="v$VERSION"
if [[ $VERSION == v* ]]; then
    TAG=$VERSION
fi

# 2. Gestion du message de commit
USER_MSG=$1
if [ -z "$USER_MSG" ]; then
    COMMIT_MSG="Release $TAG"
else
    COMMIT_MSG="Release $TAG : $USER_MSG"
fi

echo "🚀 Préparation de la release $TAG"
echo "📝 Message : $COMMIT_MSG"

# 3. Enregistrement des changements
git add .
git commit -m "$COMMIT_MSG"

# 4. Création du tag
git tag $TAG

# 5. Envoi vers GitHub
git push origin main
git push origin $TAG

echo "✅ Version $TAG poussée avec succès !"
