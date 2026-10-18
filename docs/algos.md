Voici une description détaillée des algorithmes de construction implémentés dans la classe `Core`. Le moteur de génération repose sur une approche modulaire : d'abord le calcul des constantes globales, puis la création de définitions de composants individuelles (lattes/douelles), et enfin leur positionnement spatial.

---

# 📐 Analyse Détaillée des Algorithmes de Construction (`Core`)

## 1. L'Algorithme de Pré-calcul (`setup_math_constants`)
Avant de créer la moindre géométrie, le script établit un référentiel mathématique pour garantir la cohérence du volume.

### A. Géométrie de la Section (Profil)
Le script définit un profil trapézoïdal (`@profile_pts`) qui représente la coupe transversale d'une latte :
- **Intérieur** : Largeur basée sur le rayon et la tangente de l'angle d'un quartier.
- **Extérieur** : Largeur augmentée de l'épaisseur (`@epais`) pour créer le volume.
- **Points A, B, C, D** : Définissent les quatre coins de la section (base et sommet).

### B. Logique de Courbure (Linéaire vs Parabolique)
Le script calcule deux coefficients de pente (`@coef1` et `@coef2`) selon le mode choisi :
- **Mode Linéaire** : La hauteur diminue proportionnellement à la distance $x$. 
  - Formule : $H = H_{max} - (Coef \times x)$
- **Mode Parabolique** : La hauteur suit une courbe quadratique, créant une silhouette plus organique.
  - Formule : $H = H_{max} - (Coef \times x^2)$

Le `@mid_threshold` définit le point de transition où la courbe intérieure s'arrête ou change, gérant ainsi le "décalage" (`decalage`).

---

## 2. Algorithmes de Construction des Lattes

Chaque latte est créée comme une `ComponentDefinition` séparée pour optimiser la mémoire de SketchUp.

### A. Mode "OpenCutList" (OCL) : L'approche par extrusion
L'algorithme OCL est conçu pour la fabrication simple (débit de bois).
1. **Calcul de la pente** : Il calcule la différence de hauteur entre le début et la fin de la latte ($\Delta z$).
2. **Création du profil** : Il génère une face plane basée sur les points du profil, décalée en $Z$.
3. **Extrusion** : Il utilise la méthode `pushpull` pour donner l'épaisseur à la latte.
4. **Résultat** : Un volume prismatique simple avec une face supérieure inclinée.

### B. Mode "Dressed" (Corroyé) : L'approche par maillage (8 points)
C'est l'algorithme le plus complexe. Au lieu d'une extrusion, il construit un volume fermé point par point pour obtenir une forme précise et "habillée".

1. **Définition des 8 Sommets** : Le script calcule 4 points pour le haut (`_t`) et 4 points pour le bas (`_b`), prenant en compte les hauteurs $z_{top}$, $z_{mid}$ et $z_{bot}$.
2. **Construction des Faces (Le Maillage)** :
   - **Les Côtés** : 4 faces quadrilatères sont créées pour fermer le pourtour.
   - **Le Haut et le Bas** : 2 faces triangulées ferment les extrémités.
3. **Algorithme de Triangulation d'Urgence** : 
   - Si deux points deviennent coincident (distance $\approx 0$), SketchUp refuse de créer une face. 
   - Le script détecte alors ce cas et bascule automatiquement d'une création de **quadrilatères** (4 points) à une création de **triangles** (3 points) pour forcer la génération de la face sans planter.
4. **Orientation des Normales** :
   - Un algorithme calcule le **centroïde global** du volume.
   - Pour chaque face, il vérifie si le vecteur normal pointe vers l'intérieur ou l'extérieur.
   - Si la normale pointe vers le centre, la face est inversée (`reverse!`). Cela garantit que les textures et le rendu sont corrects.

---

## 3. Algorithmes de Positionnement (`place_slat`)

Une fois la latte définie, elle doit être placée dans l'espace.

### A. Mode "Déroulé" (Flat Layout)
C'est une disposition linéaire :
- **Translation** : Chaque latte est simplement décalée sur l'axe X selon l'indice $\times$ largeur extérieure.
- **Hauteur** : La position Z est ajustée selon la courbe calculée.
- **Usage** : Utile pour créer un plan de découpe à plat.

### B. Mode "Circulaire" (Volume Torche)
C'est l'algorithme de mise en forme finale :
1. **Calcul Angulaire** : L'angle de rotation est déterminé par `(-360 / nb_quart) * index`.
2. **Positionnement Polaire** : La latte est placée sur un cercle de rayon `@params[:rayon]` en utilisant $\cos(\theta)$ et $\sin(\theta)$.
3. **Rotation Combinée** : 
   - La latte subit une translation vers sa position sur le cercle.
   - Elle subit une rotation autour de l'axe Z pour s'aligner radialement vers le centre.
4. **Résultat** : Les lattes s'assemblent pour former un cylindre creux dont la hauteur varie selon la courbe choisie.

---

## 🛠️ Résumé Technique
| Fonctionnalité | Algorithme OCL | Algorithme Dressed |
| :--- | :--- | :--- |
| **Méthode** | Profil $\rightarrow$ `pushpull` | Nuage de 8 points $\rightarrow$ Faces |
| **Complexité** | Basse (Prismatique) | Haute (Polyèdre irrégulier) |
| **Précision** | Approximation linéaire | Géométrie exacte |
| **Robustesse** | Standard | Triangulation dynamique + Inversion de normales |

Voici un complément technique détaillé sur le calcul des normales et la méthodologie de construction des points à partir du plan de référence $Z=0$.

---

# 🔍 Détails Techniques : Normales et Construction Géométrique

## 1. Algorithme de Calcul et Orientation des Normales

Dans SketchUp, une face a une "face avant" (blanche) et une "face arrière" (bleue). Pour un volume architectural, il est crucial que toutes les faces pointent vers l'extérieur. Le `Core` utilise un algorithme de **validation par centroïde**.

### Le processus étape par étape :
1. **Calcul du Centroïde Global** : 
   Le script calcule le centre de gravité de l'ensemble de la latte. Il ne se contente pas de faire la moyenne des points, il effectue une **moyenne pondérée par l'aire** :
   $$\text{Centroïde} = \frac{\sum (\text{Centre de la face} \times \text{Aire de la face})}{\sum \text{Aires totales}}$$
   Cela garantit que le point de référence est réellement à l'intérieur du volume, même si la forme est asymétrique.

2. **Vecteur de Sortie** :
   Pour chaque face du maillage, le script crée un vecteur partant du centroïde global vers le centre de la face :
   $$\vec{V}_{out} = \text{Centre Face} - \text{Centroïde Global}$$

3. **Produit Scalaire (Dot Product)** :
   Le script compare ce vecteur $\vec{V}_{out}$ avec le vecteur normal actuel de la face ($\vec{N}$) :
   - Si $\vec{V}_{out} \cdot \vec{N} > 0$ : L'angle est inférieur à 90°, la normale pointe déjà vers l'extérieur.
   - Si $\vec{V}_{out} \cdot \vec{N} < 0$ : La normale pointe vers l'intérieur.

4. **Correction** : 
   Dès qu'un produit scalaire négatif est détecté, la méthode `face.reverse!` est appelée pour inverser la face.

---

## 2. Construction des Points depuis le Plan $Z=0$

Le script ne construit pas la latte "dans le vide", mais projette une section 2D (le plan de référence) vers le haut en appliquant des offsets de hauteur.

### A. Le Plan de Référence ($Z=0$)
Tout commence par le `@profile_pts`. Imaginez un rectangle trapézoïdal posé à plat sur le sol (plan XY) :
- **Pt A & B** : Segment intérieur (largeur `@interieur`).
- **Pt C & D** : Segment extérieur (largeur `@exterieur`), décalé de la valeur `@epais` sur l'axe Y.
- **Z** : Tous ces points ont initialement une coordonnée $Z = 0$.

### B. Projection et Décalage Vertical
L'algorithme transforme ce profil 2D en volume 3D en calculant des "hauteurs de sommet". Le plan $Z=0$ sert de base de calcul, mais les points sont déplacés verticalement selon les coefficients de courbe.

#### Pour le mode "Dressed" (le plus complexe) :
Le script crée deux versions du profil (Haut et Bas) en appliquant des décalages $Z$ différents :

1. **Le Sommet (Top)** :
   - Le point **A_t** (Intérieur Gauche) et **D_t** (Extérieur Gauche) sont remontés à la hauteur `ztop`.
   - Le point **B_t** (Intérieur Droit) et **C_t** (Extérieur Droit) restent à `z0` (ou une valeur relative).
   - *L'inclinaison de la latte est ainsi créée par la différence de hauteur entre la gauche et la droite du profil.*

2. **La Base (Bottom)** :
   - Le script calcule une seconde hauteur pour le bas de la latte (`zmid` et `zbot`).
   - Ces points sont projetés depuis le plan $Z=0$ vers le haut, mais à une altitude inférieure au sommet.

### C. Synthèse du volume
Le volume final est donc le résultat de la "tension" entre :
- **Le profil 2D** (qui définit la largeur et l'épaisseur).
- **Le vecteur Z** (qui définit la hauteur et la pente).

**En résumé :** 
L'algorithme prend un trapèze plat $\rightarrow$ lui donne une épaisseur $\rightarrow$ tire les coins vers le haut selon une courbe mathématique $\rightarrow$ ferme le volume $\rightarrow$ et s'assure que la "peau" du volume est orientée vers l'extérieur.