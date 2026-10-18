# 🧪 Guide de Tests - Torche Volume Generator

Ce document détaille la stratégie de test et la procédure de validation du plugin Torche Volume.

## 🎯 Objectifs des Tests
L'objectif est de garantir que :
1. La géométrie est correcte selon le mode (Parabolique vs Linéaire).
2. Le placement respecte le choix "Déroulé" ou "Circulaire".
3. L'alternance des matériaux (2 clairs / 1 foncé) est strictement respectée.
4. L'interface utilisateur mémorise correctement les paramètres.
5. Le plugin ne crash pas lors de la génération de volumes avec des valeurs extrêmes.

## 🛠 Environnement de Test
- **Logiciel** : SketchUp 2020 (ou version supérieure).
- **Framework** : `Minitest` (intégré à Ruby).
- **Exécution** : Les tests doivent être lancés **à l'intérieur** de la console Ruby de SketchUp.

## 📂 Organisation des Tests
Les tests sont situés dans le dossier `/tests` :

| Fichier | Type de Test | Focus |
| :--- | :--- | :--- |
| `test_helper.rb` | Configuration | Chargement des modules et initialisation de Minitest. |
| `test_core.rb` | Unitaire | Calculs de points, logique de courbure et matériaux. |
| `test_ui_handler.rb` | Unitaire | Vérification de `@@last_params` et création des matériaux. |
| `test_integration.rb` | Intégration | Cycle complet : Saisie $\rightarrow$ Génération $\rightarrow$ Modèle. |

## 🏃 Procédure de Lancement

### Méthode Rapide (Console Ruby)
Pour lancer l'intégralité de la suite de tests :
1. Ouvrez SketchUp.
2. Ouvrez la **Console Ruby** (`Fenêtre` $\rightarrow$ `Console Ruby`).
3. Tapez la commande suivante (adaptez le chemin) :
   ```ruby
   load 'C:/chemin/vers/projet/run\_tests.rb'
