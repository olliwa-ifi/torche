# Generateur de Torche en bois for SketchUp 2020+

Un plugin Ruby pour SketchUp 2020+ permettant de générer des douelles avec une gestion avancée des courbes, du placement et des matériaux.

## 🚀 Fonctionnalités

- **Modes de génération** : Support du mode **Dressed (Corroyé)** et **OpenCutList (OCL)**.
- **Géométrie Flexible** : Choix entre des courbes **Paraboliques** (dynamiques selon un coefficient) ou **Linéaires**.
- **Mise en page "Déroulée"** : Option pour placer les douelles côte à côte linéairement plutôt qu'en cercle.
- **Personnalisation complète** :
  - Ajustement du Rayon, Nombre de quartiers, Offset et Épaisseur.
  - Contrôle de la hauteur maximale (`Hmax`) et du facteur de coefficient.
  - Positionnement précis de l'axe X/Y.
- **Gestion Intelligente des Matériaux** :
  - Support monochrome ou bicolore.
  - Cycle automatique : **2 lattes en Bois Clair / 1 latte en Bois Foncé**.
- **UI Persistante** : L'interface mémorise vos derniers réglages pour accélérer les itérations.

## 🛠 Installation

1. Téléchargez le dossier `torche_dyn`.
2. Copiez le dossier `torche_dyn` dans le répertoire des plugins de SketchUp :
   - **Windows** : `%AppData%\SketchUp\SketchUp 2020\SketchUp\Plugins`
   - **macOS** : `~/Library/Application Support/SketchUp 2020/SketchUp/Plugins`
3. Redémarrez SketchUp.
4. Accédez au générateur via le menu : `Extensions` $\rightarrow$ `Générateur Torche Volume`.

## 📖 Guide d'utilisation

### Paramètres de l'interface
| Paramètre | Description |
| :--- | :--- |
| **Mode** | Choisir entre `Dressed` (Corroyé) ou `OCL` (liste de coupe). |
| **Courbe** | `Para` pour un arc parabolique, `Lin` pour des arcs droits. |
| **Déroulé** | Si `True`, les douelles sont alignées sur un plan. Si `False`, elles sont réparties sur un cylindre. |
| **Coeff** | Modifie la courbure et la hauteur finale des lattes en mode Parabolique. |
| **Nb Matériaux** | `1` pour une couleur unique, `2` pour activer l'alternance Bois Clair/Foncé. |

## 🏗 Architecture Technique

Le code est modularisé pour faciliter la maintenance :

- `main.rb` : Point d'entrée et orchestration.
- `config.rb` : Constantes, couleurs RGB et valeurs par défaut.
- `ui_handler.rb` : Gestion de l'interface utilisateur et persistance des données (`@@last_params`).
- `core.rb` : Moteur géométrique, calculs de points et placement des instances.
- `logger.rb` : Système de logs centralisé pour le débogage.

## 📝 Notes de développement
- **Version** : 1.0.0
- **Compatibilité** : SketchUp 2020+
- **Langage** : Ruby

## 📦 Installation du Plugin

### Méthode Automatique (Recommandée)
1. Allez dans la section **Releases** de ce dépôt.
2. Téléchargez le fichier `.rbz` le plus récent.
3. Dans SketchUp, allez dans : `Fenêtre` $\rightarrow$ `Gestionnaire d'extensions` $\rightarrow$ `Installer l'extension`.
4. Sélectionnez le fichier `.rbz` téléchargé.

### Méthode Manuelle
1. Téléchargez le dossier `src/torche_dyn`.
2. Placez-le dans le dossier `Plugins` de SketchUp.
3. Assurez-vous que le fichier `torche_dyn_loader.rb` se trouve bien à la racine du dossier `Plugins`.

## 🛠 Développement & Build

### Lancer les tests
Pour exécuter la suite de tests dans la console Ruby de SketchUp :
```ruby
load 'C:/chemin/vers/projet/run\_tests.rb'



---
*Développé pour preparer la réalisation.*
