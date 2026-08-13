# Outillage de test — `script/`

Trois outils, une responsabilité chacun.

| Outil | Rôle | Sort quoi |
|---|---|---|
| **`harness.py`** | lance les benchmarks (source de vérité de *comment* on invoque l'analyseur) | rapports JSON + un résumé `<out>.run.json` |
| **`function-diff.py`** | compare deux **arbres de rapports** (vendoré depuis MOPSA, non modifié) | le diff, code ≠ 0 si régression |
| **`runtest.py`** | rendu HTML / LaTeX / CSV pour le papier | `results/index.html`, `results/index.tex`, `results/stats.csv` |

`runtest.py` s'appuie sur `harness.py` : il n'y a **qu'une** implémentation de la
découverte et de l'invocation. C'est délibéré — la duplication précédente avait
silencieusement divergé (voir « Pièges » plus bas).

---

## 1. Régression : « est-ce que j'ai cassé quelque chose ? »

```bash
script/harness.py run -o regression_out --layout flat --cover logs
python3 script/function-diff.py logs regression_out --regression --ignore-time
```

- `--layout flat` reproduit l'arborescence des baselines de `logs/`, sans quoi
  aucun chemin ne correspond.
- `--cover logs` fait deux choses : il **restreint** le run aux tests qui ont une
  baseline, et il **vérifie** qu'aucune baseline n'a été oubliée.

La restriction n'est pas un détail de performance : la découverte complète sort
**223 482 paires** (test, config), la matrice résilience croisant à elle seule
37 116 sources avec 6 propriétés. Un run non restreint tourne des heures.

## 2. Attentes par test : `expected`

Chaque config `tests/**/<nom>.json` peut épingler ce qu'on attend d'elle.

```json
"expected": "TRUE"
"expected": { "result": "TRUE", "suff": 3, "leaves": 7, "time": 1.23 }
"expected": { "status": "FAIL", "reason": "frontend: undeclared identifier 'true'" }
```

La chaîne est la forme héritée (= `{"result": ...}`). Tous les champs sont
optionnels : **on ne vérifie que ce qui est épinglé**.

| Champ | Sens | Comparaison | Fait échouer ? |
|---|---|---|---|
| `result` | verdict `TRUE`/`UNKNOWN` | égalité | oui |
| `suff` | feuilles **définies** = nb de préconditions suffisantes | écart absolu (`--tol-suff`, 0) | oui |
| `leaves` | feuilles totales = taille de l'arbre | écart absolu (`--tol-leaves`, 0) | oui |
| `time` | secondes | facteur (`--tol-time`, ×3) | **non**, sauf `--strict-time` |
| `status` | `OK`/`FAIL`/`TO` | égalité | oui |

Les tolérances sont **globales**, pas par test : `suff`/`leaves` sont
déterministes pour un binaire donné (aucun bruit à absorber), et quand un bouton
comme `-max-partitions` les déplace, il les déplace sur toute la suite.

Épingler `"status": "FAIL"` déclare un échec **connu** : la suite redevient
verte, mais si le test se remet à réussir l'outil le signale — le bug ne
disparaît pas du radar.

Autre champ utile : `"timeout": 300` sur un test lent, pour que le `-t` global
n'ait pas à être calé sur le pire cas.

### Promouvoir un run en référence

```bash
script/harness.py bless regression_out.run.json -n   # ce qui changerait
script/harness.py bless regression_out.run.json      # écrit dans les configs
```

`bless` **refuse** de promouvoir un test en échec ou en timeout (sinon on fige un
crash comme attendu — ceux-là se déclarent à la main avec `status`/`reason`), et
saute les configs partagées de `tests/atl/resilience/` : 6 configs pour 37 116
sources, un `expected` plat y est structurellement impossible.

## 3. Ablations : `compare`

Une ablation est une propriété du **run**, pas d'un test — d'où `--force` :

```bash
script/harness.py run --force "-max-partitions 4" -o run_k4
script/harness.py run --force "-max-partitions 8" -o run_k8
script/harness.py compare run_k4.run.json run_k8.run.json --csv sweep.csv
```

**La précédence passe par l'ordre des options** :

| Option | Position | Effet |
|---|---|---|
| `--report-flags` | *avant* `-config` | un défaut, que la config du test peut écraser |
| `--force` | *après* `-config` | gagne sur la config du test — l'ablation s'impose partout |

`compare` sort le mouvement des verdicts (perdus / gagnés, avec la liste), le
delta de `suff` et `leaves`, le facteur de temps, et la couverture. Précision et
temps ne sont mesurés que sur les tests **décidés des deux côtés** : sinon un run
qui plante plus tôt paraît plus rapide. `--csv` ajoute une ligne agrégée par
point d'ablation — c'est directement le tableau de balayage de k.

L'en-tête `meta` de `run.json` (git, options forcées, layout) étiquette les deux
côtés et avertit s'ils diffèrent par autre chose que le bouton étudié.

## 4. Rendu pour le papier

```bash
script/runtest.py                  # html + latex + csv
script/runtest.py --csv -f termination
script/runtest.py --short          # élague les gros sous-arbres SV-COMP
```

⚠️ `runtest.py` **écrase `results/stats.csv`** avec le périmètre du run : un
`-f example1` réduit le CSV à une ligne. `results*` est dans `.gitignore`, donc
non restaurable par git — relancer la suite complète pour le régénérer.

---

## Pièges (chacun a coûté un bug)

**Les deux façades n'invoquent pas l'analyseur pareil, et c'est voulu.**
`runtest.py` ajoute `-domain polyhedra -refine -ordinals 3 -joinbwd 7`
(`REPORT_FLAGS`) ; la régression invoque `-config` nu, comme ce qui a produit
`logs/`. L'analyseur **encode ses options dans le nom du rapport** : avec les
options de rendu on obtient `foo.c-domainpolyhedra-ordinals3-refine.json` là où
la baseline est `foo.c-domainpolyhedra.json` — plus aucune correspondance.

**La découverte vient du système de fichiers, pas d'une table.** Une table de
groupes doit être tenue en phase avec les noms de répertoires ; quand elle dérive
le groupe manquant est sauté **sans erreur**. C'est ainsi que `tests/atl`
(139 configs, toutes baselinées) n'a jamais été testé en régression, et que
renommer `tests/resilience` en `tests/resilience_excluded` a fait disparaître ce
groupe aussi.

**La couverture se calcule depuis les baselines, pas depuis la découverte.**
`function-diff` compare l'**intersection** des chemins de rapports : un test qui
plante ne produit aucun JSON et sort donc silencieusement de la comparaison au
lieu de la faire échouer. L'inverse — vérifier depuis `logs/` — attrape aussi le
cas d'un groupe entier jamais visité.

**Le résumé `run.json` vit à côté de l'arbre, jamais dedans.** `function-diff`
globe tous les `*.json` du répertoire et les parse comme des rapports : un
résumé posé à l'intérieur le fait planter.

**Le temps rapporté par l'analyseur est quantifié à la seconde** (`"time": "1"`).
Une suite de 66 tests totalisait exactement 65,0 s des deux côtés d'une ablation
qui divise pourtant le temps par cinq. `harness.py` mesure donc l'**horloge
murale** : plus bruitée (démarrage du process, gonflée par `-j`), mais c'est la
seule qui porte du signal.

**Les configs partagées ne peuvent pas porter d'attente.** `tests/atl/resilience/`
suit le régime « matrice » : chaque `.c` du sous-arbre est croisé avec chacune des
6 propriétés racine. Un `expected` dans ces 6 fichiers vaudrait pour des milliers
de résultats différents.

## 5. Intégration continue

Deux workflows dans `.github/workflows/` :

| Workflow | Déclencheur | Rôle |
|---|---|---|
| `ci.yml` | chaque push / PR | build (**bloquant**) + régression sur le sous-ensemble baseliné (`--short`, informative) |
| `regression-report.yml` | lundi 03:00 UTC + manuel | run complet, artefacts 90 j, et **tient à jour une issue** de dérive |

**Le garde-fou de régression est désactivé** (`REGRESSION_GATE: "false"` dans
`ci.yml`). Raison : la baseline n'est pas verte au HEAD courant, et un CI rouge
en permanence s'apprend à s'ignorer. Une fois les régressions tranchées et
`bless` passé, mettre `REGRESSION_GATE: "true"` — c'est le seul endroit à
changer. Le build, lui, bloque déjà.

**L'issue automatique** ne s'ouvre qu'une fois : le corps porte un marqueur
invariant (`<!-- baseline-drift-tracker -->`), que le workflow recherche pour
**mettre à jour** l'issue existante au lieu d'en créer une nouvelle à chaque
exécution hebdomadaire. Quand la dérive disparaît, l'issue est commentée puis
fermée automatiquement. Elle est créée dans le dépôt qui héberge le workflow —
attention, `origin` pointe ici sur le dépôt amont (`caterinaurban/function`) et
`fork0` sur le fork ; les issues suivent le dépôt où le workflow s'exécute.

⚠️ Ces workflows n'ont **jamais été exécutés** : ils sont validés
syntaxiquement et leur logique de comptage a été testée hors ligne sur un vrai
diff, mais l'installation d'APRON via opam sur un runner GitHub reste à
confirmer au premier run.

## Fichiers

| | |
|---|---|
| `harness.py` | lanceur + couverture + `bless` + `compare` |
| `runtest.py` | rendu HTML/LaTeX/CSV (bâti sur `harness`) |
| `function-diff.py` | comparateur d'arbres de rapports (MOPSA, LGPL, non modifié) |
| `logs.bash` | boucle historique ayant produit `logs/` ; gardée comme référence |
| `generate.py`, `clean_subset.py`, `lift_ctl.py` | génération et transformation de benchmarks |
| `logs/` | baselines de référence (versionnées) |
| `regression_out/`, `*.run.json` | sorties de run (ignorées par git) |
