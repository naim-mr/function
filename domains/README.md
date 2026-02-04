`Domains`
==========

The `Domains` module contains the abstract domain necessary for `FuncTion`.
These modules are provides the abstract transfer function for the language defined in Frontend/parser.mly.

--------------

| Module | Description |
|:------:|:-----------:|
| `Domain.ml` | Signature for a ranking function abstract domain, defining RANKING_FUNCTION |
| `DecisionTree.ml` | Decision tree abstract domain, implementing the signature RANKING_FUNCTION |
| `Function.ml` |  Abstract domain signature for the leaf value as function valuation in the decision tree abstract domain |
| `Numerical.ml` |  Abstract domain signature numerical domain |
| `Affine.ml` |  Implementation for the Function.ml signature as Affine function |
| `Ordinals.ml` |  Implementation for the Function.ml signature as Lexicographic function (polynom with ordinals) |
| `Partition.ml` |  Implementations of polyhedra, octagons, boxes abstract domain with apron |
| `TerminationIterator.ml` |  Iterator for termination properties based on AST |
| `ForwardIterator.ml` |  Iterator for numerical forward reachability analysis|
