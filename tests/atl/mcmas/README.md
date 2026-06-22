# MCMAS benchmarks (epistemic)

MCMAS ([vas.doc.ic.ac.uk/software/mcmas](https://vas.doc.ic.ac.uk/software/mcmas/))
ships the canonical multi-agent benchmarks. Their interest is mostly
**temporal-epistemic** (knowledge `K_a` operators) rather than purely
strategic — which a numeric C encoding for FuncTion cannot express. We
therefore transcribe only the part that is genuinely strategic/numeric and
document the rest.

| Benchmark | Status here | Reason |
|-----------|-------------|--------|
| [bit_transmission.c](bit_transmission.c) | numeric reachability core | epistemic property (`K_sender recbit`) dropped, see .txt |
| Dining Cryptographers | **not transcribed** | the property is anonymity = common knowledge (`C_Γ`); inherently epistemic |
| Card Game | **not transcribed** | the property is about a player's knowledge of unseen cards; inherently epistemic |

The full epistemic models live in MCMAS as ISPL programs (bundled with the
tool download). To verify these properly you need ATEL / epistemic ATL,
not the numeric ATL fragment used by the FuncTion examples here.

References:
* MCMAS, IJSTTT 2017 — https://link.springer.com/article/10.1007/s10009-015-0378-x
* MCMAS-SLK (Strategy Logic) — https://www.doc.ic.ac.uk/~alessio/papers/14/CAV14-CLM.pdf
