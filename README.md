# FuncTion

FuncTion is a research prototype static analyzer designed for proving conditional termination and conditional guarantee and recurrence properties of C programs. The tool automatically infers piecewise-defined ranking functions and sufficient preconditions for termination, guarantee and recurrence properties by means of abstract interpretation.

FuncTion's main website is: http://www.di.ens.fr/~urban/FuncTion.html

# Installation

FuncTion requires the following applications and libraries:

* OCaml: compiler version >= 4.14
	```
		https://ocaml.org/docs/installing-ocaml
	```

* Opam: https://opam.ocaml.org/doc/Install.html

	```
	(sudo) apt-get install opam
	```
* Ounit:

	```
	(sudo) opam install ounit
* Menhir: LR(1) parser generator (v.3.0.0)

	```
	 opam install menhir
	```
* Dune: Ocaml build system (v.3.12)
	```
	(sudo) opam install dune
	```		
* APRON: numerical abstract domain library

	```
	opam install apron
	```

* Zarith: arbitrary-precision integer operations

	```
	opam install zarith
	```
If you have a former version of dune and menhir you can update the dune-project file. You can check the version of your packages 
with 
```
opam list
```

# Compiling FuncTion

Once all required libraries are installed, FuncTion can be compiled with 'dune':

```
dune build
```

You can clean the genereted files with:


```
dune clean
```

# Usage

The command-line analyzer can be invoked using the following call pattern:

	./main.exe <file> <analysis> [options] 

where "file" is the path to the C file to be analyzed and "analysis" the type of the analysis to perform. 

The analyzer first performs a forward reachability analysis, and then a backward analysis to find a 
piecewise-defined ranking function and sufficient preconditions at the entry point for the program 
to satisfy the given analyzed property.

The following general command-line options are recognized
(showing their default value):

	 -main main                         set the analyzer entry point (defaults to main)
	 -domain boxes|octagons|polyhedra   set the abstract domain (defaults to boxes)
	 -joinfwd 2                         set the widening delay in forward analysis
	 -joinbwd 2                         set the widening delay in backward analysis
	 -meetbwd 2			                set the dual widening delay in backward analysis
	 -ordinals 2                        set the maximum ordinal value for the ranking functions
	 -refine            			    reduces the backward analysis to the reachabile states

The analyzer answers TRUE in case it can successfully prove the property. Otherwise, it answers UNKNOWN.

FuncTion can analyze the following properties:

* Termination
* Guarantee / Recurrence 
* Computation-Tree-Logic (CTL) 

## Termination

To check for termination, call the analyzer with the following call pattern:

	./main.exe <file> -termination [options]

## Guarantee / Recurrence

The following call pattern can be used for guarantee properties or recurrence properties:

	./main.exe <file> -guarantee <property_file> [options]
	./main.exe <file> -recurrence <property_file> [options] 

where "property\_file" is the path to the file containing the guarantee or recurrence property.

## CTL

CTL properties can be analyzed using the following call pattern:

	./main.exe <file> -ctl <property> [options]

where "property" is the CTL property to be analyzed. 

The following additional command-line options exist for the CTL analysis:
(showing their default value):

	 -precondition true                 a precondition that is assumed to hold at the start of the program
	 -noinline			                disable inlining of function calls
     -ast                               run the analysis on the abstract-syntax-tree instead of the control-flow-graph,
                                        note that in that case function calls and goto/break/continue are not supported
     -dot                               print out control-flow-graph and decision trees in graphviz dot format

## Benchmark:
To reproduce the benchmarks of the analysis you have to call : 
	`./script/runtest.sh .` 
It generates then a table in a html file and in csv in result/ folder. See  script/README.md, for more details.
