# FuncTion

FuncTion is a research prototype static analyzer designed for proving conditional termination and conditional CTL properties of C programs.
It is also capable of inferring minimal set of variable with an associate sufficient precondition to ensure a CTL property and a maximal set of variable for which a valuation might falsify the CTL property.

The tool automatically infers piecewise-defined ranking functions and sufficient preconditions by means of abstract interpretation.


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
* Ounit:og


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
## Compiling FuncTion

Once all required libraries are installed, FuncTion can be compiled with 'dune':

```
dune build
```

You can clean the generated files with:


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
	 -json_ouput						To output a summary of the analaysis as a  json in a file `filename.json` (it disables the output on std_output)
	 -output_std						To output on std_output even with json_ouput

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
# Vulnerability 
Automatic detection of potentially vulnerable variables that
could be controlled to violate a CTL property of programs can be done using the option: 
	 
	 -vulnerability
	
This analyzes output sets of potentially vulnerable variable, sets
of definitely non-vulnerable variables. It also provides sufficient constraints on the vulnerable variables that "protect" the program and ensure the property.
## Benchmark:
To reproduce the benchmarks of the analysis you have to call : 
	`./script/runtest.sh .` 
It generates then a table in a HTML file and in CSV in result/ folder. See script/README.md, for more details.


# Docker installation 
## To create the image
> docker build -t function. 

## To run the analysis
> docker run -it function

It will open an interactive shell as:
root@id$

The id, is the id of the container.

You can then use the analysis with the commands explained in this README.
Or run the benchmark (see also the README in script/)
