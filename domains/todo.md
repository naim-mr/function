# Plan de route — nouveaux domaines de contraintes, tests, produits

## 0. État des lieux (juillet 2026)

Pile actuelle (du bas vers le haut) :

```
CONSTRAINT            un prédicat de nœud (sig/Constraints.ml)
   └─ PARTITION       conjonction de contraintes = abstraction d'un chemin (sig/Ranking.ml)
        └─ FUNCTION   feuille = fonction de rang sur une partition (AP_Affines.ml, AP_Ordinals.ml)
             └─ Decision_Tree (F : FUNCTION) : RANKING_FUNCTION
```

Variante APRON : `AP_CONSTRAINT` / `AP_PARTITION` / `AP_NUMERIC` + `AP_Affine (N) (B)`.
Exemples complets existants : `Congruence.ml`, `Bool_Constraint.ml` (chacun fait
Constraint + Partition + Function + instanciation `TS_*`).

État au 13/08/2026 : build vert, suite de régression verte et garde-fou CI
actif (J0 et J0.5 faits, §10). `Partitions_Union.ml` reste supprimé — sa
reconstruction propre est J4.

## 1. Refactorisations à faire AVANT d'écrire de nouveaux domaines

Par ordre de rentabilité :

1. **Dé-dupliquer PARTITION — mais APRÈS avoir deux vrais clients.**
   L'objectif reste un foncteur générique :
   ```ocaml
   module Conj_Partition (C : CONSTRAINT) : PARTITION with module C = C
   ```
   pour qu'un nouveau domaine n'ait plus qu'à fournir son `CONSTRAINT`
   (~100 lignes au lieu de ~350).

   ⚠️ **Mais `Congruence.ml` a été supprimé** : il ne reste qu'une seule
   implémentation écrite à la main, `Bool_Partition`, et elle est dégénérée
   (`type t = bool`, pas une liste de contraintes du tout). Abstraire sur ce
   seul exemple figerait une interface sur un cas qui n'en est pas un. D'où
   l'ordre des jalons §10 : écrire d'abord un vrai domaine à la main (J1),
   factoriser ensuite sur ce que les deux implémentations partagent
   réellement (J2).

2. **Arrêter de sceller opaquement les modules.** `module Bool_Constraint :
   CONSTRAINT = ...` cache `type cons` — impossible ensuite d'écrire un produit
   ou une réduction qui inspecte les contraintes. Toujours sceller *transparent* :
   ```ocaml
   module Cong_Constraint : CONSTRAINT with type cons = congruence and type env = ...
   ```
   (idem pour les `PARTITION`). C'est la condition sine qua non des produits.

3. **Garder `AP_NUMERIC` comme interface des feuilles** (déjà dans
   `sig/Ranking.ml`) : les feuilles affines n'ont besoin que de
   `ap_env / ap_constraints / ap_inner`. Tout produit de partitions qui contient
   au moins une composante linéaire peut exposer cette projection — c'était le
   rôle de `Partitions_Union.ml` ; le reconstruire proprement (§3).

4. **(Optionnel, plus tard) Alléger `Decision_Tree.ml`** (2100 lignes) : extraire
   les utilitaires d'ordre/canonisation des nœuds dans un module à part. Ne pas
   le faire tant que les produits ne sont pas stabilisés — c'est du confort.

### 1.1 Restructuration profonde (option, si on repart vraiment de zéro)

Trois changements structurels au-delà du plan conservateur ci-dessus, dans
l'ordre où les faire (chacun est utile seul) :

- **Fiabiliser `env`, pas le supprimer.** *(Position révisée le 13/08/2026 —
  la version précédente disait « sortir `env` des contraintes » au motif qu'il
  relèverait de l'état d'analyse et non du prédicat. C'est faux : une
  `Lincons1.t` est positionnelle, ses dimensions n'ont aucun sens sans leur
  environnement, et `vars` porte une information propre au domaine — la
  correspondance dimension APRON ↔ variable programme, et demain d'éventuelles
  variables symboliques.)*

  Le vrai problème est dans `lincons_env = { vars : var list; ap_env :
  Environment.t }` associé à `cons = Lincons1.t` :

  1. **`ap_env` est dupliqué** — la `Lincons1.t` porte déjà son propre
     `Environment.t`. Toute duplication invite la divergence.
  2. **La correspondance `vars` ↔ nom APRON est re-dérivée à la main à chaque
     site**, par comparaison de chaînes. C'est la cause exacte du bug corrigé
     le 13/08 : `AP_Affines.print` comparait `Var.to_string x` à
     `Z.to_string y.var_id` — jamais égaux — donc le `List.find` échouait
     toujours, le `with Not_found -> ()` avalait *tous* les termes variables,
     et une fonction de rang affine s'affichait comme sa seule constante.

  Correctif : **exposer la bijection une fois pour toutes** dans le module
  d'environnement (`apron_of_var` / `var_of_apron`) et interdire les
  comparaisons de chaînes ad hoc. Ça élimine la classe de bug, pas l'instance.
  Et **renommer** : `env` évoque en compilation un liage variable→valeur, alors
  qu'il s'agit d'un *univers de variables* — `scope`, `universe` ou `dims`.
- **APRON comme capacité optionnelle, pas hiérarchie parallèle.** Remplacer
  les trois signatures quasi identiques `AP_CONSTRAINT`/`AP_PARTITION`/
  `AP_NUMERIC` par un petit module-vue passé séparément :
  ```ocaml
  module type NUM_VIEW = sig
    type t
    val to_lincons : t -> Lincons1.t list
    val of_lincons : Environment.t -> Lincons1.t list -> t
  end
  ```
  La feuille affine devient `AP_Affine (N) (V : NUM_VIEW with type t = path)`.
  Un produit de partitions n'a alors *rien* à prouver structurellement : il
  fournit la vue ssi une composante l'a. C'est le problème que
  `ap_constraints`/`ap_inner` résolvait, sans contaminer la signature de
  partition.
- **Découpler l'arbre en deux paramètres.** `Decision_Tree (F : FUNCTION)`
  prend un monolithe où la feuille embarque sa partition (`module B`).
  Préférer `Decision_Tree (C : CONSTRAINT) (L : LEAF with type path = ...)` :
  la feuille reçoit le chemin en *argument* de ses opérations au lieu de le
  posséder → combinaisons orthogonales (nœuds mixtes × feuilles affines,
  nœuds linéaires × feuilles ordinales) sans réécrire un `FUNCTION` par paire.
  Ne le lancer qu'au moment d'écrire le *deuxième* produit — c'est là que le
  monolithe fait mal.

**Idée rejetée — une signature `LATTICE` universelle** (tout module l'inclut,
un seul foncteur produit générique). Ça ne marche pas ici, pour deux raisons
vérifiées dans les signatures :
1. les opérations de `FUNCTION` sont *indexées par un contexte de partition*
   (`is_leq kind B.t t t`, `join ?random kind B.t`, `widen ?jokers B.t`) —
   ce n'est pas un treillis mais un treillis relatif, avec des paramètres
   hétérogènes (`kind`, `jokers`) qu'aucune signature commune ne capture ;
2. les fonctions de transfert diffèrent par niveau et par sens :
   `PARTITION` a `bwd_assign ?controllable`/`ubwd_assign`/`fwd_assign`/
   `fwd_filter`/`ubwd_filter`, `FUNCTION` seulement `bwd_assign`/`filter`.
La factorisation partagée existe déjà et suffit : c'est `DOMAIN`
(sig/Domain.ml), que `PARTITION` inclut. Conséquence pratique : **un foncteur
produit par niveau de signature** (cf. §3), pas de produit universel.

## 2. Écrire un nouveau domaine de contraintes (recette)

Pour un domaine `Foo` (ex. parité, signes, intervalles symboliques…) :

1. `domains/Foo.ml` : un seul module `Foo_Constraint : CONSTRAINT with type cons = ...`.
   Fonctions clés à soigner : `meet`-simplification paire à paire (via la
   partition générique), `negate` (pour les deux branches d'un test),
   `is_bot`, `isLeq`.
2. Instancier : `module Foo_Partition = Conj_Partition (Foo_Constraint)`.
3. Feuilles : soit réutiliser une feuille existante (booléenne / affine si
   projection APRON possible), soit `Foo_Function : FUNCTION` si le domaine
   porte sa propre notion de rang.
4. `module TS_Foo = Decision_Tree.Decision_Tree (Foo_Function)` + câblage dans
   `main/Main.ml` derrière une option `-domain foo`.
5. Tests (§4) au fur et à mesure, pas à la fin.

Modèle à copier : `Congruence.ml` (une fois la partition dé-dupliquée).

## 3. Produits — trois niveaux, dans cet ordre

**a. Produit de CONSTRAINT (somme de contraintes de nœud).**
Un type somme `C1.cons + C2.cons` : les nœuds de l'arbre peuvent porter l'un OU
l'autre type de contrainte. C'est ce que fait un arbre « linéaire + congruence ».
Fournir : ordre total inter-variantes (pour la canonisation de l'arbre),
`negate` par variante, simplification croisée optionnelle (réduction).
```ocaml
module Sum_Constraint (C1 : CONSTRAINT) (C2 : CONSTRAINT)
  : CONSTRAINT with type cons = C1.cons either C2.cons
```

**b. Produit de PARTITION (produit réduit de chemins).**
Une paire `(P1.t, P2.t)` avec une fonction de réduction (ex. la congruence
x≡0[2] resserre les bornes d'intervalle). C'est LE bon niveau pour combiner
numérique APRON × non-numérique : la composante APRON donne `ap_constraints`
/ `ap_inner`, donc le produit satisfait `AP_NUMERIC` et les feuilles affines
marchent sans modification. Reconstruire `Partitions_Union.ml` sous cette forme :
```ocaml
module Prod_Partition (P1 : AP_PARTITION) (P2 : PARTITION)
  : AP_NUMERIC with module C = Sum_Constraint(P1.C)(P2.C)
```
et réinstancier `TS_BoxCong = Decision_Tree (AP_Affine (AP_Box) (Prod...))`.

**c. Produit d'ARBRES (produit de RANKING_FUNCTION).**
Deux arbres analysés côte à côte + réduction aux points de jointure. Plus cher
et redondant avec (b) pour la précision des chemins ; ne le faire que si tu veux
combiner deux notions de rang incomparables (ex. affine × ordinal × booléen).
Signature : foncteur `Prod_Ranking (R1 : RANKING_FUNCTION) (R2 : RANKING_FUNCTION)`,
chaque opération appliquée composante par composante, `isLeq` conjonctif.

**Recommandation : faire (a) puis (b) ; garder (c) en réserve.** (b) est celui
qui sert directement le papier ATL (précision des invariants de chemin sans
toucher aux feuilles ni au widening).

**Pourquoi un produit PAR NIVEAU et pas un produit générique** (cf. §1.1,
idée LATTICE rejetée) : au niveau `PARTITION` les signatures sont *uniformes*
entre instances (mêmes `bwd_assign ?controllable`, `fwd_filter`, …) donc le
produit est pointwise + réduction optionnelle — c'est le cas facile. Un
produit de *feuilles* (`Prod_Function`) n'a de sens que **sur une partition
commune** : les opérations de `FUNCTION` étant indexées par `B.t`, deux
composantes sur des partitions différentes ne parlent pas du même contexte.
L'ordre est donc imposé : produit de partitions d'abord, puis éventuellement
produit de feuilles au-dessus de la partition produit.

## 4. Tests

Trois étages, du plus rapide au plus lent. Le signal rapide manque totalement
aujourd'hui : `dune test` ne teste rien, tout passe par `script/*.py` (minutes
à heures). C'est le premier trou à boucher.

### 4.0 Baseline de régression — À FAIRE AVANT TOUT REFACTOR

**Outillage en place (13/08/2026).** Un seul lanceur, `script/harness.py`,
partagé par la régression et le rendu ; la comparaison reste
`script/function-diff.py` (vendoré MOPSA).

```bash
# régression : rejoue tout, vérifie la couverture, puis compare
script/harness.py run -o regression_out --layout flat --cover logs
script/function-diff.py logs regression_out --regression

script/harness.py cover logs regression_out    # couverture seule
script/runtest.py --csv -f termination         # rendu (HTML/LaTeX/CSV)
```

⚠️ **Les deux façades n'invoquent PAS l'analyseur pareil, et c'est voulu.**
`runtest.py` ajoute `-domain polyhedra -refine -ordinals 3 -joinbwd 7`
(`harness.REPORT_FLAGS`, analyse plus fine pour les tables du papier) ; la
régression invoque `-config <cfg>` nu, comme ce qui a produit `logs/`.
L'analyseur **encode ses options dans le nom du rapport** : avec les options
de rendu on obtient `foo.c-domainpolyhedra-ordinals3-refine.json` là où la
baseline est `foo.c-domainpolyhedra.json`, donc *plus aucune* baseline ne
correspond. D'où le paramètre `extra` de `build_cmd`/`run_one` plutôt qu'une
constante partagée.

Deux règles de conception, chacune tirée d'un bug constaté :

1. **La config est la source de vérité, pas le nom du répertoire.** Le mode
   d'analyse vient du champ `analysis` du `.json` ; la table `GROUP_MODES`
   n'est qu'un repli. Et la découverte énumère *tous* les sous-dossiers de
   `tests/` au lieu d'une liste en dur.
2. **La couverture se calcule depuis les baselines, pas depuis la
   découverte.** Toute baseline de `logs/` non reproduite ⇒ rouge.
   L'inverse ne peut pas détecter un groupe entier sauté.

Ce que ça corrigeait : `runregression.py` (supprimé, absorbé par `harness.py`)
dérivait ses groupes d'une table où `atl` manquait et où `resilience`
pointait sur un dossier renommé `resilience_excluded` → **2 des 4 groupes
baselinés, dont les 139 configs de `tests/atl/`, n'étaient jamais rejoués**,
sans aucune erreur. `runtest.py` avait déjà la bonne logique mais dans une
copie séparée, d'où la dérive.

Aussi supprimés : `runtest.sh` / `runtest-fast.sh` (545 et 544 lignes, 11 de
différence) et `runtest-res.sh`, redondants avec `runtest.py` ; `logs_new/`
(run partiel : 2 groupes contre 4). Récupérables via git si besoin.

### 4.0.1 `expected` : ce que chaque test épingle

Chaque config peut déclarer ce qu'on attend d'elle. Deux formes, la chaîne
restant valide (aucune migration des 48 configs existantes) :

```json
"expected": "TRUE"
"expected": { "result": "TRUE", "suff": 3, "leaves": 7, "time": 1.23 }
```

Tous les champs sont optionnels — on ne vérifie que ce qui est épinglé.
`suff` = feuilles **définies** de l'arbre = nombre de préconditions
suffisantes trouvées ; `leaves` = total (proxy de la taille de l'arbre, donc
la mesure directe de `-max-partitions`, §7.5).

Tolérances **globales** (défauts dans `harness.py`, surcharge CLI
`--tol-suff` / `--tol-leaves` / `--tol-time` / `--strict-time`), pas par test :
`suff`/`leaves` sont déterministes pour un binaire donné, il n'y a donc pas de
bruit à absorber, et quand un bouton comme `-max-partitions` les déplace il
les déplace sur toute la suite d'un coup.

| Champ | Comparaison | Fatal ? |
|---|---|---|
| `result` | égalité stricte | oui |
| `suff`, `leaves` | écart absolu (0 par défaut) | oui |
| `time` | facteur (×3 par défaut) | **non**, sauf `--strict-time` |
| `status` | égalité (`FAIL` = échec *connu*, avec `reason`) | oui |

Épingler `"status": "FAIL"` sert à sortir du bruit un bug connu (les 21 tests
CTL qui plantent sur `undeclared identifier 'true'`) **sans le cacher** : le
jour où le test se remet à réussir, l'outil le signale.

⚠️ `time` est mesuré en **horloge murale**, pas via le temps rapporté par
l'analyseur : ce dernier n'a qu'une résolution d'une seconde (`"time": "1"`),
au point qu'une suite de 66 tests totalisait exactement 65,0 s des deux côtés
d'une ablation. L'horloge murale est plus bruitée (démarrage du process,
gonflée par `-j`) mais c'est la seule qui porte du signal.

Autres champs de config utilisables : `timeout` (budget propre à un test, pour
que le `-t` global n'ait pas à être réglé sur le plus lent).

```bash
script/harness.py bless <run>.run.json -n   # ce qui changerait
script/harness.py bless <run>.run.json      # promeut le run en référence
```

`bless` refuse de promouvoir un test en échec ou en timeout (sinon on fige un
crash comme attendu) et saute les configs partagées de `tests/atl/resilience/`
(6 configs pour 37 116 sources : un `expected` plat y est impossible ; sidecar
indexé par `.c` à prévoir si le besoin se présente).

### 4.0.2 `compare` : les ablations

Une ablation est une propriété du **run**, pas d'un test — donc pas de JSON à
embarquer, seulement des options forcées :

```bash
script/harness.py run --force "-max-partitions 4" -o run_k4
script/harness.py run --force "-max-partitions 8" -o run_k8
script/harness.py compare run_k4.run.json run_k8.run.json --csv sweep.csv
```

La précédence passe par l'**ordre des options** : `--report-flags` est placé
*avant* `-config` (la config du test peut l'écraser — c'est un défaut),
`--force` *après* (il gagne — c'est une ablation imposée à tous).

`compare` sort le mouvement des verdicts (perdus / gagnés, avec la liste), le
delta de `suff` et `leaves`, le facteur de temps, et la couverture (présents
d'un seul côté) — sur les seuls tests **décidés des deux côtés**, sinon un run
qui plante plus tôt paraît plus rapide. `--csv` ajoute la ligne agrégée : une
ligne par point d'ablation, c'est directement le tableau de §7.5. Le `meta` de
`run.json` (git, options forcées, layout) permet d'étiqueter les deux côtés et
d'avertir quand ils diffèrent par autre chose que le bouton étudié.

Le critère de succès de J1/J4/J7/J9 est « mêmes verdicts qu'avant » ; sans ce
filet ce sont des refactors à l'aveugle sur un `Decision_Tree.ml` de 2100
lignes. Donc, avant tout refactor :

1. build vert (J0) ;
2. `runregression.py` **vert** sur la baseline actuelle — si des tests
   divergent déjà aujourd'hui, les traiter ou les documenter AVANT de
   commencer, sinon on ne saura plus attribuer les régressions ;
3. `--update` uniquement en fin de jalon, en justifiant chaque verdict changé.

Reste à faire (petit) : `logs_new/` (160 rapports) coexiste avec `logs/`
(120) sans que la différence soit documentée — trancher lequel est la
référence et supprimer l'autre, sinon la baseline est ambiguë.

### 4.1 Unitaires par domaine — un foncteur de test générique

Plutôt qu'écrire une suite par domaine, **une suite paramétrée par le
domaine** (même logique que `Conj_Partition` en §1.1 : le nouveau domaine
fournit son `CONSTRAINT`, il obtient ses tests gratuitement) :

```
test/
  dune                      (test (name test_domains) (libraries domains alcotest))
  Domain_laws.ml            foncteur générique : lois d'un CONSTRAINT
  Partition_laws.ml         foncteur générique : lois d'une PARTITION
  Test_domains.ml           instanciations + runner
```

```ocaml
(* Domain_laws.ml *)
module Make (C : CONSTRAINT) (S : sig
  val name : string
  val samples : C.t list      (* échantillons représentatifs du domaine *)
  val env : C.env
end) : sig
  val tests : unit Alcotest.test_case list
end
```

Lois à vérifier sur `S.samples` (produit cartésien, quelques dizaines de
paires — pas de QuickCheck au début, des échantillons choisis à la main
sont plus informatifs quand ça casse) :

| Loi | Énoncé |
|---|---|
| réflexivité | `is_leq c c` |
| transitivité | `is_leq a b && is_leq b c ⇒ is_leq a c` |
| antisymétrie | `is_leq a b && is_leq b a ⇒ is_eq a b` |
| involution | `negate (negate c)` ≡ `c` (modulo normalisation) |
| exclusion | `meet c (negate c)` est `is_bot` |
| bot absorbant | `is_bot (make_unsat env)`, `is_leq bot c` |
| env stable | `env (op c) = env c` pour toute op sans changement de dim |
| print/parse | `print` ne lève pas, sur bot/top/cas dégénérés |

Pour une `PARTITION` (foncteur `Partition_laws`), en plus :
`meet` = borne inf (`is_leq (meet a b) a` et `b`), `join` = borne sup,
`inner env [] = top`, `widen` extensif (`is_leq a (widen a b)` et `b` aussi),
et **cohérence transferts/ordre** : `is_leq a b ⇒ is_leq (fwd_assign a e) (fwd_assign b e)`
(monotonie), `bwd_assign` sur-approxime `ubwd_assign`.

Pour un **produit** (§3), en plus :
- la réduction ne perd rien : `is_leq (reduce p) p` et `reduce` idempotent ;
- projection : chaque composante du produit est ⊒ à ce que la composante
  seule aurait calculé (le produit ne peut qu'améliorer) ;
- si la composante APRON existe : `ap_inner env (ap_constraints p)` ⊑ `p`
  (aller-retour de la vue numérique ne perd pas de sol).

**Coût** : ~1 j pour les deux foncteurs + l'instanciation de `Congruence` et
`Bool_Constraint` (qui servent de validation du harnais lui-même) ; ensuite
~1 h par nouveau domaine (écrire ses `samples`, instancier).

### 4.2 End-to-end (par domaine et par produit)

Un `.c` minimal dans `tests/` prouvable **uniquement** grâce au domaine visé —
modèle : `tests/j.c` pour la congruence (x pair, `x := x-2`, non-terminaison).
Pour chaque produit, un test que **ni l'une ni l'autre** composante seule ne
prouve : c'est la seule preuve que la réduction sert à quelque chose.
Chacun accompagné de son `test.json` (domaines + propriété + verdict attendu).

### 4.3 Régression

Brancher 4.2 dans `script/runregression.py` / `runtest.py` et mettre à jour
`tests/baseline.json` (4.0) à chaque jalon terminé, en justifiant tout verdict
qui change.

## 5. Widening modulaire (pipeline de passes)

Le widening de `Decision_Tree.ml` (l. 852–1135) est déjà de fait un pipeline :
`widen_right` → `left_unification` → `tree_unification` → `widen_up` →
extrapolation des feuilles (`extend`/`adjacent`). Le rendre explicite :

```ocaml
type ctx = { f_env : B.env; domain : B.t option; jokers : int; kind : kind }

type pass =
  | Structural  of string * (ctx -> tree * tree -> tree * tree)  (* unifications *)
  | Extrapolate of string * (ctx -> tree * tree -> tree)         (* n'élargit que t2 *)

val run : pass list -> ctx -> tree * tree -> tree
```

- Une heuristique = une valeur `pass` dans un module `Widening_passes`
  (record de fonctions, PAS un foncteur par heuristique — les types sont
  locaux au foncteur `Decision_Tree`).
- Le runner absorbe le tracing : plus de `if !tracebwd then …` dupliqué 5×,
  chaque passe est tracée par son nom.
- Le pipeline actif est une **donnée** : `let default = [widen_right;
  left_unif; tree_unif; widen_up; extrapolate]`. Exposé en CLI
  (`-widening right,lunify,up,ext`) → études d'ablation gratuites pour les
  benchs du papier.
- `Structural` vs `Extrapolate` n'est pas cosmétique : seules les passes
  structurelles touchent t1, et c'est l'extrapolation qui porte la charge de
  terminaison du widening.
- ⚠️ Les passes ne commutent pas : les unifications sont des *préconditions*
  de `widen_up`/extrapolation (actuellement `Invalid_argument` sinon) —
  encoder ça par les types (cf. §6.1).
- Le **widening angélique** (TODO du papier) rentre pile dedans : même
  pipeline, `kind` différent dans `ctx` ou passe d'extrapolation alternative.

### 5.1 Passe d'extrapolation par LLM (guess-and-check)

Une passe `Extrapolate ("llm", …)` qui demande des candidats à un LLM,
**vérifiés par le domaine avant usage** — la correction vient du check, jamais
de la proposition (schéma Houdini / guess-and-check) :

1. Sérialiser le contexte en prompt : fragment de programme, contraintes du
   chemin (`B.print`), feuille courante et historique des itérés
   (f1, f2, delta).
2. Le LLM propose des candidats : fonction de rang affine pour la feuille,
   et/ou contraintes de partition à conserver au lieu de les élargir.
3. Parser + **vérifier** : candidat feuille accepté ssi il majore les deux
   itérés (`F.is_leq COMPUTATIONAL b f1 cand && F.is_leq … f2 cand`) et
   décroît ; sinon fallback sur l'extrapolation classique.
4. Terminaison : une passe LLM ne stabilise rien par elle-même — la borner
   (n'invoquer qu'aux k premiers points de widening, ou couplée aux
   `jokers`), le widening classique restant le fallback terminant.

Ingénierie : un module `Llm_oracle : sig val propose : prompt -> string list end`
derrière une signature, avec **cache disque clé = hash du prompt** →
runs déterministes, rejouables hors-ligne, CI sans réseau. Un stub trivial
(liste vide) garde l'analyseur indépendant du LLM.

## 6. Features OCaml (≤ 5.x) à exploiter

Par rapport bénéfice/coût décroissant :

1. **Types abstraits / `private` pour les invariants du pipeline** —
   `tree_unification` retourne un type `unified` (abstrait), et
   `widen_up`/extrapolation ne prennent que lui : les
   `raise (Invalid_argument "widen:aux:")` deviennent impossibles par
   construction. Même idée pour la canonisation (`remove_redundant`/
   `rebalance_tree` → type `canonical`).
2. **Modules de première classe** — registre `(string * (module SEMANTIC))`
   dans Main.ml au lieu de l'échelle de `match` ; composition
   domaines/produits à l'exécution.
3. **Handlers d'effets (OCaml 5)** — pour le tracing : les passes font
   `perform (Trace msg)`, le handler décide (stdout/fichier/rien) ; sort
   `!tracebwd`/`!Config.fmt` de la logique du domaine. Usage plus
   spéculatif : backtracking pour la recherche guidée par conflits
   (`assume`). À doser (lisibilité pour un relecteur d'artefact).
4. **Parallélisme `Domain.spawn`** — portfolio de pipelines de widening,
   benchs parallèles. ⚠️ managers APRON non thread-safe (un manager par
   thread) → à réserver au niveau `runtest.py`, pas dans l'analyseur.
5. **ppx_deriving (`compare`, `show`)** sur les types `cons` des nouveaux
   domaines — élimine le boilerplate d'ordre total et de printing de chaque
   `CONSTRAINT`.

6. **Opérateurs de liaison (`let*`) — ciblés, pas partout.** Deux usages qui
   paient, un qui ne paie pas :
   - **Propagation de bottom** : le code est truffé de
     `if is_bot … then bot else …` et de `match … with Bot, _ | _, Bot -> …`.
     Un `let*` sur `Bot | Val of 'a` court-circuite et rend l'oubli d'un cas
     impossible.
   - **Constructions non supportées du frontend** : `UnsupportedFeature` /
     `UnsupportedConversion` sont des exceptions qui remontent de loin. Le
     13/08 ça a coûté deux bugs — `convert_func` typait des prototypes qu'il
     jetait ensuite, et il a fallu un `try … with` volontairement étroit sur
     les globaux externes. Avec un `result`, « non géré » devient une valeur
     qui se propage, et le point où l'on décide d'ignorer devient visible dans
     le type. Même esprit que le point 1.
   - **PAS pour `env`** : un reader monad serait plus de cérémonie qu'un
     paramètre explicite et ne règle pas le vrai problème (§1.1).

   Réserves : `let*` dégrade la lisibilité des traces d'erreur, et les
   opérations de `FUNCTION` sont déjà indexées par un contexte (`kind`, `b`,
   `jokers`) qu'aucune monade ne simplifie. Commencer par le frontend : c'est
   là que les exceptions font le plus de dégâts, et c'est isolable sans
   toucher aux domaines.

À ne PAS faire : GADTs pour indexer les arbres (coût de lisibilité > gain,
le point 1 donne 80 % du bénéfice) ; implicites modulaires (pas dans le
langage) ; monadiser les domaines en bloc (cf. point 6).

## 7. Performance

Diagnostic (à confirmer par profiling AVANT d'optimiser — `perf record` sur un
bench lent, la hiérarchie ci-dessous est mon hypothèse) :

1. **Conversions APRON répétées = le point chaud probable.** `AP_Partition`
   stocke une *liste* de contraintes et chaque `is_leq`/`meet`/`is_bot` passe
   par `to_apron_t` = `Abstract1.of_lincons_array` (reconstruction + clôture
   complètes). Or le widening/les unifications de `Decision_Tree` font à
   CHAQUE nœud `B.is_leq (B.inner f_env cs) (B.inner f_env [c1])` avec `cs` =
   le chemin courant (116 sites `B.inner`) → coût quadratique en profondeur
   d'arbre, re-payé à chaque passe. Deux remèdes cumulables :
   - **threader l'abstrait incrémentalement** dans les récursions : au lieu de
     reconstruire depuis la liste `cs`, descendre un `apron_t` et faire UN
     `meet_lincons_array` par niveau ;
   - **mémoïser** la conversion dans le record (`ap : apron_t Lazy.t` à côté
     de `constraints`), invalidée à la construction seulement.
2. **`print` de AP_Partition fait une conversion APRON complète** (aller-retour
   `to_apron_t`/`to_lincons_array`) — avec `tracebwd` activé le tracing coûte
   plus cher que l'analyse. Imprimer la liste brute, ou passer par la mémo de 1.
3. **Redondances recalculées** : les tests « c redondant ? » (`B.is_leq bcs bc`)
   sont refaits pour les mêmes `(cs, c)` dans plusieurs passes → un cache
   (Hashtbl sur les hash des contraintes) au niveau du pipeline §5, vidé par
   appel de widening.
4. **Build release** : vérifier que les benchs tournent en
   `dune build --profile release` (le profil dev actuel désactive surtout des
   warnings, mais ne pas mesurer en dev par accident).
5. **Option pour borner le nombre de partitions de l'arbre** (largeur = nombre
   de feuilles / profondeur = contraintes par chemin). Une option CLI
   `-max-partitions k` : quand l'arbre dépasse la borne, fusionner des
   partitions adjacentes (join des feuilles + suppression du nœud de décision,
   en choisissant les nœuds les moins discriminants — ex. feuilles déjà égales
   ou proches). C'est le levier perf le plus direct puisque TOUT le coût
   (widening, unifications, conversions APRON) est proportionnel à la taille
   de l'arbre ; contrepartie : perte de précision contrôlée — l'analyse reste
   *correcte* (le join sur-approxime), on perd seulement des verdicts.
   S'implémente naturellement comme une passe `Structural` du pipeline §5
   (appliquée après les unifications), la borne portée par `ctx` ; à exposer
   dans les tables de bench (précision vs temps en fonction de k).

Ordre d'attaque : profiler d'abord (0,5 j), puis 1.b (mémo, local à
AP_Partition, sans changement d'API), puis 1.a si besoin (invasif : touche les
récursions de Decision_Tree — à coupler au refactor pipeline §5 pour ne payer
la non-régression qu'une fois).

## 8. Qualité

1. **Réactiver les warnings.** `domains/dune` : `-w -9-27-32-33-35
   -warn-error -A` masque champs de record ignorés (9), variables inutilisées
   (27), valeurs mortes (32/33). Réactiver un warning à la fois, nettoyer, puis
   `-warn-error +a-3` en CI. C'est le meilleur détecteur de code mort gratuit.
2. **Ajouter des `.mli`** aux modules de `domains/` (seul `Main.mli` existe) :
   documente l'API réelle, permet le scellement transparent (§1.2) ET fait
   apparaître le code mort (couplé au point 1).
3. **Dé-dupliquer `AP_Affines.ml`** : le bloc « copie des contraintes de b dans
   un `Lincons1.array` étendu à `#` » est répété ~7× → un helper
   `lincons_array_of_path b env`. Idem pour `Environment.add … [|v|]`
   reconstruit à chaque opération de feuille.
4. **Exceptions de flot de contrôle** : les `Invalid_argument "widen:aux:"`
   internes → les rendre impossibles par types (`unified`, §6.1) ; garder les
   exceptions pour les vraies erreurs d'usage uniquement.
5. **État global** : ~46 `ref` dans `utils/Config.ml` lus au fond des domaines
   (`!tracebwd`, `!retrybwd`…). Ne pas tout refactorer d'un coup : au fil des
   refactors (§5 notamment), faire remonter ces lectures dans les `ctx`/records
   de config passés explicitement.
6. **Hygiène du dépôt** : fichiers parasites à la racine (`q`, `qq`, `=`,
   `'\033O'`, `-vulnerabilitytests/`, `__pycache__`) → supprimer + compléter
   `.gitignore` ; purger les marqueurs `(*REMOVE?*)` et `TODO: normalization`
   en tranchant (faire ou supprimer).
7. **Tests exécutables par dune** : `dune test` ne teste rien aujourd'hui
   (tout passe par `script/*.py`). Brancher au minimum les tests unitaires §4.1
   en dune pour avoir un signal local rapide avant les benchs longs.

## 9. Estimations (code seul)

En jours pleins si l'utilisateur code (support Claude sur les parties
mécaniques) ; ×1,5–2 en temps calendaire :

| Jalon | Contenu | Estimation |
|---|---|---|
| J0 | build vert (revert Main.ml) | 0,5 h |
| J0.5 | baseline de régression (§4.0) | 0,5 j *(réel : 1 j+)* |
| J1 | premier domaine à la main + harnais + scellements | 2–3 j |
| J2 | `Conj_Partition` factorisé sur deux vrais clients | 1–2 j |
| J2.5 | (option) fiabiliser `env` (bijection + renommage) | 0,5–1 j |
| J3 | `Sum_Constraint` (nœuds mixtes) | 2–3 j |
| J4 | `Prod_Partition`/`AP_NUMERIC` + recâblage | 2–4 j |
| J5 | (option) produit d'arbres | +3–5 j |
| J6 | tables de bench avec/sans produit | 1–2 j |
| J7 | widening pipeline + types `unified`/`canonical` | 5–8 j |
| J8 | passe LLM (oracle + cache + check) | 2–4 j |

**Total ~15–27 j pleins hors J5/J2.5** ; cœur J1–J4+J6 ≈ 2 semaines pleines.

⚠️ **Ces estimations sont optimistes.** J0.5 était donné pour une demi-journée
et en a pris plus d'une pleine, parce que toucher au code existant révèle des
problèmes latents à chaque fois (table de groupes morte, quatre limites du
frontend, affichage des rangs, dépendances non déclarées, trois échecs CI
successifs). Appliquer ce facteur surtout à **J7**, qui touche les 2100 lignes
de `Decision_Tree.ml`.
- J7 est le poste le plus *risqué* (pas le plus long) : refactorer le widening
  sans changer son comportement exige une non-régression comportementale
  (mêmes verdicts sur toute la suite ATL avant/après) ≈ la moitié du coût.
- J8 a une queue ouverte : la plomberie est bornée, le temps
  d'*expérimentation* (prompts, taux d'acceptation, ablations) est de la
  recherche — 2 jours comme 2 semaines.

**Si Claude code tout** : ~12–20 h de travail effectif, soit **2–4 jours
calendaires**, bornés par (i) le temps CPU des benchs (`runtest.py` sur
`tests/atl` peut tourner des heures), (ii) les arbitrages sémantiques de
l'utilisateur (ordre inter-variantes, choix de réduction, verdicts de
régression qui changent). Suppose une relecture par gros blocs en fin de
jalon, pas ligne à ligne.

## 10. Jalons

- [x] **J0** Build vert — fait le 13/08/2026 (Main.ml repointé sur
      `Decision_Tree.TS*`).
- [x] **J0.5** Baseline verte et garde-fou actif — fait le 13/08/2026.
      Outillage : `script/harness.py` (lanceur unique, couverture depuis les
      baselines, `expected`/`bless`/`promote`/`compare`), `script/README.md`,
      deux workflows GitHub, `REGRESSION_GATE: "true"`.
      État final : **103 rapports comparés, `no regression found`, couverture
      complète**, 13 échecs déclarés (`status: FAIL`) et 2 régressions
      acceptées (`pending` : P3.c, existential_test4.c).
      Corrections de fond obtenues en chemin :
      - `tests/atl` (139 configs) et `resilience` n'étaient **jamais** rejoués
        — table de groupes en dur, désormais découverte par le système de
        fichiers ;
      - 9 tests CTL récupérés (`#include <stdbool.h>`, `?` → `rand()`), et le
        frontend ne rejette plus un fichier entier à cause d'un prototype de
        `stdio.h` (typedef déréférencé, corps testé avant les types, externes
        inconvertibles filtrés) ;
      - affichage des feuilles affines réparé (`AP_Affines.print` comparait un
        nom APRON à un `var_id` brut, donc tous les termes variables étaient
        silencieusement perdus) ;
      - `mopsa` manquait dans `function.opam` : la CI aurait échoué au build.
      Reste ouvert, suivi par issues : segfault `-Dtrue/-Dfalse`, `break` non
      géré, `input(v,lo,hi)` qui casse la linéarisation, et les deux
      régressions `pending`.

- [ ] **J1** **Un vrai domaine de contraintes, écrit à la main** (recette §2) :
      son `CONSTRAINT`, sa `PARTITION` explicite, son `.c` témoin. Plus le
      harnais de test générique (§4.1, `Domain_laws`/`Partition_laws` sous
      `dune test`) écrit *avec* ce premier client — pas avant lui.
      Y faire aussi les **scellements transparents** (§1.2) : indépendant,
      deux lignes par module, et prérequis dur des produits.
      ⚠️ Garder les `.c` témoins minimaux (une boucle, deux variables) :
      le frontend ne gère ni `break`, ni `input(v,lo,hi)`, ni `unsigned`, ni
      les tableaux/structs — autant de temps perdu sur des bugs qui ne sont
      pas les tiens.
- [ ] **J2** `Conj_Partition` générique, factorisé sur ce que J1 et
      `Bool_Constraint` partagent **réellement**. C'est l'ancien J1, déplacé
      ici : avec un seul client dégénéré, l'abstraction serait spéculative.
- [ ] **J2.5** *(option)* Fiabiliser `env` (§1.1) : bijection
      `apron_of_var`/`var_of_apron` exposée, `ap_env` dédupliqué, renommage.
      À placer ICI : après J1 on a un filet de tests, et juste avant J3.
      Périmètre bien plus étroit que la version « supprimer `env` » qu'il
      remplace — c'est un resserrement d'API, pas une réécriture.
- [ ] **J3** `Sum_Constraint` (produit a) + arbre à nœuds mixtes ; test témoin.
- [ ] **J4** `Prod_Partition` (produit b) = renaissance propre de
      `Partitions_Union` ; `TS_{Box,Oct,Poly}×Cong` recâblés dans Main.ml.
- [ ] **J5** (option) `Prod_Ranking` (produit c) si un besoin concret émerge.
- [ ] **J6** Tables de bench (`runtest.py`) avec/sans produit pour le papier.
- [ ] **J7** Widening en pipeline de passes (§5) + option CLI `-widening` ;
      types `unified`/`canonical` (§6.1) posés à cette occasion.
- [ ] **J8** Passe d'extrapolation LLM guess-and-check (§5.1) avec
      `Llm_oracle` + cache disque ; ablation avec/sans dans les benchs.
- [ ] **J9** Perf (§7) : profiling, puis mémo APRON dans `AP_Partition`,
      puis abstrait incrémental dans les récursions (couplé à J7).
- [ ] **J10** Qualité (§8) : warnings réactivés + `.mli` + dédup `AP_Affines`
      + hygiène dépôt + tests unitaires sous `dune test`.
