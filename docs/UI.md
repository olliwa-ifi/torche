
# Documentation de l'Interface Utilisateur (UIHandler)

Le module `UIHandler` sert de pont entre l'utilisateur et le moteur de génération (`Core`). Il est responsable de la capture des paramètres, de leur persistance durant la session et de la préparation des ressources visuelles (matériaux).

## 🛠️ Rôle et Responsabilités
La classe `UIHandler` orchestre le flux de travail suivant :
1. **Vérification de l'environnement** : Contrôle de la version de SketchUp.
2. **Saisie des données** : Interface de dialogue pour les paramètres géométriques.
3. **Persistance** : Mémorisation des dernières valeurs saisies.
4. **Gestion des ressources** : Création et assignation des matériaux.
5. **Sécurisation** : Encapsulation de la génération dans une opération `Undo` (Annuler).

## ⚙️ Gestion des Paramètres

### Saisie via `UI.inputbox`
Le script utilise une boîte de dialogue standard SketchUp. Comme `UI.inputbox` ne supporte pas nativement les booléens (Vrai/Faux), les options sont gérées par des entiers :
- `1` : Activé / Oui / Sélectionné.
- `0` : Désactivé / Non / Non sélectionné.

### Persistance des données
Pour éviter à l'utilisateur de ressaisir systématiquement les mêmes valeurs lors de tests successifs, une variable de classe `@@last_params` est utilisée :
- **Initialisation** : Prend les valeurs de `Config::DEFAULT_PARAMS` au lancement.
- **Mise à jour** : Une fois que l'utilisateur valide la boîte de dialogue, `@@last_params` est actualisé avec les nouvelles valeurs.
- **Rappel** : Lors de l'appel suivant, ces valeurs servent de valeurs par défaut (`defaults`) dans l'inputbox.

## 🎨 Gestion des Matériaux

Le système supporte deux modes de colorisation basés sur les couleurs définies dans le module `Config` :

| Matériau | Couleur (RGB) | Rôle |
| :--- | :--- | :--- |
| **Bois Clair** | `[222, 184, 135]` | Matériau principal / Slat standard |
| **Bois Foncé** | `[101, 67, 33]` | Matériau d'accentuation (cycle 2+1) |

### Logique d'assignation
- **Si `nb_materials == 1`** : Seul le matériau "Bois Clair" est retourné.
- **Si `nb_materials == 2`** : Un tableau `[mat1, mat2]` est retourné, permettant au `Core` d'appliquer le cycle alterné (deux latte claires, une latte foncée).

## 🛡️ Flux d'Exécution et Sécurité

### Opérations et Undo
Pour éviter de polluer l'historique de SketchUp avec des centaines de petites actions (création de chaque face/ligne), toute la génération est enveloppée dans :
`model.start_operation('Générer Torche v...', true)`

Cela permet à l'utilisateur d'annuler la création complète du volume en un seul `Ctrl+Z`.

### Gestion des Erreurs
Le processus de génération est entouré d'un bloc `begin...rescue...ensure` :
- **Rescue** : Capture toute erreur critique, l'enregistre dans le `LogManager` et affiche un message d'alerte à l'utilisateur via `UI.messagebox`.
- **Ensure** : Garantit que l'opération SketchUp est clôturée (`commit_operation`), même en cas de crash, pour éviter de bloquer le modèle.

## 📝 Tableau des Paramètres UI

| Paramètre | Type | Description |
| :--- | :--- | :--- |
| `rayon` | Float | Rayon du volume |
| `nb_quart` | Integer | Nombre de sections/quartiers |
| `decalage` | Float | Offset de positionnement |
| `epais` | Float | Épaisseur des lattes |
| `hmax` | Float | Hauteur maximale |
| `coef_factor` | Float | Coefficient de courbure |
| `mode_corroye` | Bool (0/1) | 1 = Dressed (Corroyé) / 0 = OCL |
| `show_normals` | Bool (0/1) | Affiche les vecteurs de normale |
| `parabole_lin` | Bool (0/1) | 1 = Parabole / 0 = Linéaire |
| `mode_deroule` | Bool (0/1) | 1 = Flat layout / 0 = Circular |
| `pos_x / pos_y` | Float | Coordonnées de placement |
| `nb_materials` | Integer | Nombre de matériaux (1 ou 2) |
