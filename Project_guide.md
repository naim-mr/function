This files is here to guide the exploration of the project.

The termination and CTL analysis is based on the decision tree abstract domain.
The domain and its signature could be find in domains/DecisionTree.ml and domains/Domains.ml.
It uses numerical domain defined in domain/numerical, function abstraction domain defined in domains/Affines.ml and domains/Ordinals.ml and a partition domain which correspond to the linear constraints domain in utils/Constraints.ml.


The file main/Main.ml contain the entry point doit(). It basically parse the arguement and get the right iterator to run.

The iterators are: TerminationIterator.ml/ ReccurrenceIterator.ml / GuranteeIterator.ml / CTLIterator.
They follow the same patterns of a backward iteration computing an abstract semantic and saving each invariant at each label of the program in an InvariantMap (InvMap.t), currently they follow the same module type define in Semantics.ml.

A last iterator is available: Cda.ml. It is a functor that take an other iterator and launch the conflict driven analysis with it.

The vulnerability analysis is mostly defined by the function vulnerable in DecisionTree.ml


A good way to explore the project: start to take a look at the Main.ml function, then to the type of decision tree DecisionTree.ml, then the underlying abstract domains for constraints functions and numerical values, then rest of DecisionTree.ml and finally an iterator such as TerminationIterator.ml

