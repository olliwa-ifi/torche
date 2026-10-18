
# Documentation du LogManager

Le `LogManager` est une classe utilitaire conçue pour centraliser toutes les informations d'exécution du plugin. Il permet de suivre le comportement du script en temps réel dans la console Ruby et de conserver une trace persistante dans un fichier texte.

## 🎯 Objectifs
- **Diagnostic** : Identifier rapidement l'origine d'un plantage via les backtraces.
- **Traçabilité** : Enregistrer les paramètres utilisés lors d'une session de génération.
- **Transparence** : Informer le développeur/utilisateur de l'état d'avancement du chargement et de la génération.

## 📂 Gestion du Fichier Log

### Emplacement Intelligent
Le `LogManager` détermine dynamiquement l'endroit où enregistrer le fichier log pour éviter les problèmes de droits d'écriture :
1. **Priorité au Modèle** : Si le fichier SketchUp (`.skp`) est déjà enregistré, le log est créé dans le **même dossier** que le modèle. Cela facilite l'envoi du log avec le fichier source pour le support.
2. **Repli (Fallback)** : Si le modèle n'est pas encore enregistré, le log est créé dans le **répertoire personnel de l'utilisateur** (`Dir.home`).

**Nommage du fichier** : `torche_dyn_v[VERSION].log` (ex: `torche_dyn_v1.0.0.log`).

### En-tête de Session
À chaque lancement (`write_header`), le gestionnaire inscrit un bloc d'informations initiales :
- Date et heure précises du démarrage.
- Version du plugin et version de SketchUp installée.
- Chemin absolu du fichier log pour confirmation.

## 🛠️ Fonctionnement Technique

### La Méthode Centrale `log`
Toutes les entrées passent par la méthode `log(level, msg, e = nil)`. Elle effectue deux actions simultanées :
1. **Sortie Console** : Affiche le message dans la console Ruby de SketchUp pour un feedback immédiat.
2. **Sortie Fichier** : Ajoute la ligne à la fin du fichier texte (`mode 'a'` pour *append*).

Chaque entrée est formatée ainsi : `[YYYY-MM-DD HH:MM:SS] NIVEAU: Message`

### Gestion des Exceptions
Si un objet d'erreur (`e`) est passé à la méthode `log`, le gestionnaire :
- Ajoute le message d'erreur détaillé.
- Extrait et écrit les **4 premières lignes de la backtrace**, permettant de localiser précisément la ligne de code fautive sans encombrer le fichier log.

## 🚦 Niveaux de Journalisation

Le `LogManager` propose quatre raccourcis pour qualifier l'importance de l'information :

| Niveau | Méthode | Usage |
| :--- | :--- | :--- |
| **INFO** | `.info()` | Événements normaux (ex: "Opération terminée", "Matériaux configurés"). |
| **DEBUG** | `.debug()` | Détails techniques pour le développement (ex: calculs de coordonnées). |
| **WARN** | `.warn()` | Alertes non bloquantes (ex: "Version inhabituelle détectée"). |
| **ERROR** | `.error()` | Erreurs critiques entraînant l'arrêt d'une fonction (ex: crash de génération). |

## 💻 Exemple de sortie log

```text
======================================================================
SESSION START  : 2026-10-18 14:30:05
Plugin Version : 1.0.0 | SketchUp: 20.0
LOG PATH (ABS) : C:/Users/Admin/Documents/Projets/Torche_v1.log
======================================================================
[2026-10-18 14:30:06] INFO: Matériau(x) configuré(s) : Bois Clair, Bois Foncé
[2026-10-18 14:30:10] ERROR: Erreur fatale lors de la génération
undefined method `pushpull' for nil:NilClass
C:/Plugins/torche_dyn/core.rb:142:in `build_simple_slat'
...
[2026-10-18 14:30:10] INFO: Opération terminée.
```