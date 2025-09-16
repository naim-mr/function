#!/bin/sh

### termination (AST) with default setting:
### -domain boxes
### -joinbwd 2

./main.exe tests/termination/boolean.c   				# TRUE
./main.exe tests/termination/cacm2009a.c   		# TRUE
# ./main.exe tests/termination/cacm2009b.c   
./main.exe tests/termination/cav2006.c   				# TRUE
./main.exe tests/termination/example1.c   				# TRUE
# ./main.exe tests/termination/example1a.c   
# ./main.exe tests/termination/example1b.c   
# ./main.exe tests/termination/example1c.c   
# ./main.exe tests/termination/example1d.c   
# ./main.exe tests/termination/example1e.c   
# ./main.exe tests/termination/example2.c   
./main.exe tests/termination/example2a.c   			# TRUE
# ./main.exe tests/termination/example2b.c   
# ./main.exe tests/termination/example2c.c   
# ./main.exe tests/termination/example2d.c   
# ./main.exe tests/termination/example2e.c   
# ./main.exe tests/termination/example8.c   
# ./main.exe tests/termination/example10.c   
# ./main.exe tests/termination/mccarthy91.c   
./main.exe tests/termination/postdecrement.c   	# TRUE
./main.exe tests/termination/postincrement.c   	# TRUE
./main.exe tests/termination/predecrement.c   		# TRUE
./main.exe tests/termination/preincrement.c   		# TRUE
# ./main.exe tests/termination/recursion.c   
./main.exe tests/termination/sas2010.c   				# TRUE
# ./main.exe tests/termination/sas2014b.c   
# ./main.exe tests/termination/sorting4.c   
./main.exe tests/termination/tacas2013a.c   			# TRUE
# ./main.exe tests/termination/tacas2013b.c   
# ./main.exe tests/termination/tacas2013c.c   
# ./main.exe tests/termination/tacas2013d.c   
# ./main.exe tests/termination/vijay.c   
# ./main.exe tests/termination/vmcai2004a.c   
# ./main.exe tests/termination/widening1.c   
# ./main.exe tests/termination/widening2.c   

### termination (CFG) with default setting:
### -domain boxes
### -joinbwd 2

./main.exe tests/termination/boolean.c -ctl-ast "AF{exit: true}"   				# TRUE
./main.exe tests/termination/cacm2009a.c -ctl-ast "AF{exit: true}"   			# TRUE
./main.exe tests/termination/cav2006.c -ctl-ast "AF{exit: true}"   				# TRUE
./main.exe tests/termination/example1.c -ctl-ast "AF{exit: true}"   			# TRUE
./main.exe tests/termination/example2a.c -ctl-ast "AF{exit: true}"   			# TRUE
# ./main.exe tests/termination/postdecrement.c -ctl-ast "AF{exit: true}"   	# TODO: fix parser?
# ./main.exe tests/termination/postincrement.c -ctl-ast "AF{exit: true}"   	# TODO: fix parser?
# ./main.exe tests/termination/predecrement.c -ctl-ast "AF{exit: true}"   		# TODO: fix parser?
# ./main.exe tests/termination/preincrement.c -ctl-ast "AF{exit: true}"   		# TODO: fix parser?
 ./main.exe tests/termination/sas2010.c -ctl-ast "AF{exit: true}"   				# TODO: ?
./main.exe tests/termination/tacas2013a.c -ctl-ast "AF{exit: true}"   		# TRUE

## conditional termination

# ./main.exe tests/termination/euclid.c   					# x = y || (x > 0 && y > 0)
# ./main.exe tests/termination/example0.c   				# x > 10 OR (x <= 10 AND x odd)
# ./main.exe tests/termination/example5.c   				# x > 0
# ./main.exe tests/termination/example7.c   				# x > 6
# ./main.exe tests/termination/issue8.c   					# x + z >= 0 || y >= 1 || -2y + z >= 0 || -x >= 2
# ./main.exe tests/termination/sas2014a.c   				# r <= 0 || x < y
# ./main.exe tests/termination/sas2014c.c   				# x <= 0 OR y > 0
# ./main.exe tests/termination/tap2008a.c   				# x < 25 OR x > 30
# ./main.exe tests/termination/tap2008b.c   				# x < -5 OR 0 <= x <= 30 OR x > 35
# ./main.exe tests/termination/tap2008c.c   				# x < 30
# ./main.exe tests/termination/tap2008d.c   				# x <= 0
# ./main.exe tests/termination/tap2008e.c   				# x <= 11 OR x >= 40
# ./main.exe tests/termination/tap2008f.c   				# x even
# ./main.exe tests/termination/vmcai2004b.c   			# x != 3
# ./main.exe tests/termination/widening3.c   				# x <= 0 || y > 0
# ./main.exe tests/termination/zune.c   

#################################################################################

### termination (AST) with increased widening delay:
### -domain boxes
### -joinbwd 5

# ./main.exe tests/termination/cacm2009b.c -joinbwd 5   
# ./main.exe tests/termination/example10.c -joinbwd 5   
# ./main.exe tests/termination/example1a.c -joinbwd 5   
# ./main.exe tests/termination/example1b.c -joinbwd 5   
# ./main.exe tests/termination/example1c.c -joinbwd 5   
# ./main.exe tests/termination/example1d.c -joinbwd 5   
# ./main.exe tests/termination/example1e.c -joinbwd 5   
# ./main.exe tests/termination/example2.c -joinbwd 5   
# ./main.exe tests/termination/example2b.c -joinbwd 5   
# ./main.exe tests/termination/example2c.c -joinbwd 5   
# ./main.exe tests/termination/example2d.c -joinbwd 5   
# ./main.exe tests/termination/example2e.c -joinbwd 5   
# ./main.exe tests/termination/example8.c -joinbwd 5   
# ./main.exe tests/termination/mccarthy91.c -joinbwd 5   
# ./main.exe tests/termination/recursion.c -joinbwd 5   
# ./main.exe tests/termination/sas2014b.c -joinbwd 5   
# ./main.exe tests/termination/sorting4.c -joinbwd 5   
# ./main.exe tests/termination/tacas2013b.c -joinbwd 5   
# ./main.exe tests/termination/tacas2013c.c -joinbwd 5   
# ./main.exe tests/termination/tacas2013d.c -joinbwd 5   
# ./main.exe tests/termination/vijay.c -joinbwd 5   
./main.exe tests/termination/vmcai2004a.c -joinbwd 5   		# TRUE
# ./main.exe tests/termination/widening1.c -joinbwd 5   
# ./main.exe tests/termination/widening2.c -joinbwd 5   

### termination (CFG) with increased widening delay (5):
### -domain boxes
### -joinbwd 5

./main.exe tests/termination/vmcai2004a.c -joinbwd 5 -ctl-ast "AF{exit: true}"   		# TRUE

#################################################################################

### termination (AST) with increased widening delay (7):
### -domain boxes
### -joinbwd 7

./main.exe tests/termination/example8.c -joinbwd 7   		# TRUE

### termination (CFG) with increased widening delay (7):
### -domain boxes
### -joinbwd 7

./main.exe tests/termination/example8.c -joinbwd 7 -ctl-ast "AF{exit: true}"   		# TRUE

#################################################################################

### termination (AST) with forward refinement:
### -domain boxes
### -joinbwd 2
### -refine

# ./main.exe tests/termination/cacm2009b.c -refine   
# ./main.exe tests/termination/example10.c -refine   
# ./main.exe tests/termination/example1a.c -refine   
# ./main.exe tests/termination/example1b.c -refine   
# ./main.exe tests/termination/example1c.c -refine   
# ./main.exe tests/termination/example1d.c -refine   
# ./main.exe tests/termination/example1e.c -refine   
# ./main.exe tests/termination/example2.c -refine   
./main.exe tests/termination/example2b.c -refine   		# TRUE
./main.exe tests/termination/example2c.c -refine   		# TRUE
./main.exe tests/termination/example2d.c -refine   		# TRUE
./main.exe tests/termination/example2e.c -refine   		# TRUE
# ./main.exe tests/termination/mccarthy91.c -refine   
# ./main.exe tests/termination/recursion.c -refine   
./main.exe tests/termination/sas2014b.c -refine   			# TRUE
# ./main.exe tests/termination/sorting4.c -refine   
# ./main.exe tests/termination/tacas2013b.c -refine   
# ./main.exe tests/termination/tacas2013c.c -refine   
# ./main.exe tests/termination/tacas2013d.c -refine   
# ./main.exe tests/termination/vijay.c -refine   
# ./main.exe tests/termination/widening1.c -refine   
# ./main.exe tests/termination/widening2.c -refine   

### termination (CFG) with forward refinement:
### -domain boxes
### -joinbwd 2
### -refine

./main.exe tests/termination/example2b.c -refine -ctl-ast "AF{exit: true}"   		# TODO: ?
./main.exe tests/termination/example2c.c -refine -ctl-ast "AF{exit: true}"   		# TODO: ?> logs
./main.exe tests/termination/example2d.c -refine -ctl-ast "AF{exit: true}"   		# TODO: ?
./main.exe tests/termination/example2e.c -refine -ctl-ast "AF{exit: true}"   		# TODO: ?
./main.exe tests/termination/sas2014b.c -refine -ctl-ast "AF{exit: true}"   			# TODO: ?

#################################################################################

### termination (AST) with polyhedra:
### -domain polyhedra
### -joinbwd 2

# ./main.exe tests/termination/cacm2009b.c -domain polyhedra   
# ./main.exe tests/termination/example10.c -domain polyhedra   
# ./main.exe tests/termination/example1a.c -domain polyhedra   
# ./main.exe tests/termination/example1b.c -domain polyhedra   
# ./main.exe tests/termination/example1c.c -domain polyhedra   
# ./main.exe tests/termination/example1d.c -domain polyhedra   
# ./main.exe tests/termination/example1e.c -domain polyhedra   
# ./main.exe tests/termination/example2.c -domain polyhedra   
# ./main.exe tests/termination/mccarthy91.c -domain polyhedra   
# ./main.exe tests/termination/recursion.c -domain polyhedra   
./main.exe tests/termination/sorting4.c -domain polyhedra   			# TRUE
./main.exe tests/termination/tacas2013b.c -domain polyhedra   		# TRUE
# ./main.exe tests/termination/tacas2013c.c -domain polyhedra   
# ./main.exe tests/termination/tacas2013d.c -domain polyhedra   
# ./main.exe tests/termination/vijay.c -domain polyhedra   
# ./main.exe tests/termination/widening1.c -domain polyhedra   
# ./main.exe tests/termination/widening2.c -domain polyhedra   

### termination (CFG) with polyhedra:
### -domain polyhedra
### -joinbwd 2

./main.exe tests/termination/sorting4.c -domain polyhedra -ctl-ast "AF{exit: true}"   			# TRUE
./main.exe tests/termination/tacas2013b.c -domain polyhedra -ctl-ast "AF{exit: true}"   		# TRUE

#################################################################################

### termination (AST) with ordinals (2):
### -domain boxes
### -joinbwd 2
### -ordinals 2

./main.exe tests/termination/cacm2009b.c -ordinals 2   		# TRUE
# ./main.exe tests/termination/example1a.c -ordinals 2   
# ./main.exe tests/termination/example1b.c -ordinals 2   
# ./main.exe tests/termination/example1c.c -ordinals 2   
# ./main.exe tests/termination/example1d.c -ordinals 2   
# ./main.exe tests/termination/example1e.c -ordinals 2   
./main.exe tests/termination/example2.c -ordinals 2   		# TRUE
./main.exe tests/termination/example10.c -ordinals 2   		# TRUE
# ./main.exe tests/termination/mccarthy91.c -ordinals 2   
# ./main.exe tests/termination/recursion.c -ordinals 2   
# ./main.exe tests/termination/tacas2013c.c -ordinals 2   
./main.exe tests/termination/tacas2013d.c -ordinals 2   	# TRUE
# ./main.exe tests/termination/vijay.c -ordinals 2   
./main.exe tests/termination/widening1.c -ordinals 2   		# TRUE
./main.exe tests/termination/widening2.c -ordinals 2   		# TRUE

### termination (CFG) with ordinals (2):
### -domain boxes
### -joinbwd 2
### -ordinals 2

./main.exe tests/termination/cacm2009b.c -ordinals 2 -ctl-ast "AF{exit: true}"   		# TRUE
./main.exe tests/termination/example2.c -ordinals 2 -ctl-ast "AF{exit: true}"   			# TRUE
./main.exe tests/termination/example10.c -ordinals 2 -ctl-ast "AF{exit: true}"   		# TRUE
./main.exe tests/termination/tacas2013d.c -ordinals 2 -ctl-ast "AF{exit: true}"   		# TRUE
./main.exe tests/termination/widening1.c -ordinals 2 -ctl-ast "AF{exit: true}"   		# TRUE
./main.exe tests/termination/widening2.c -ordinals 2 -ctl-ast "AF{exit: true}"   		# TRUE

#################################################################################

### termination (AST) with increased widening delay (3) and ordinals (2):
### -domain boxes
### -joinbwd 3
### -ordinals 2

# ./main.exe tests/termination/example1a.c -joinbwd 3 -ordinals 2   
# ./main.exe tests/termination/example1b.c -joinbwd 3 -ordinals 2   
# ./main.exe tests/termination/example1c.c -joinbwd 3 -ordinals 2   
# ./main.exe tests/termination/example1d.c -joinbwd 3 -ordinals 2   
# ./main.exe tests/termination/example1e.c -joinbwd 3 -ordinals 2   
# ./main.exe tests/termination/mccarthy91.c -joinbwd 3 -ordinals 2   
# ./main.exe tests/termination/recursion.c -joinbwd 3 -ordinals 2   
./main.exe tests/termination/tacas2013c.c -joinbwd 3 -ordinals 2   		# TRUE
# ./main.exe tests/termination/vijay.c -joinbwd 3 -ordinals 2   

### termination (CFG) with increased widening delay (3) ordinals (2):
### -domain boxes
### -joinbwd 3
### -ordinals 2

./main.exe tests/termination/tacas2013c.c -joinbwd 3 -ordinals 2 -ctl-ast "AF{exit: true}"   	# TRUE

#################################################################################

### TODO

# ./main.exe tests/termination/example1a.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra   
# ./main.exe tests/termination/example1b.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra   
# ./main.exe tests/termination/example1c.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra   
# ./main.exe tests/termination/example1d.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra   
# ./main.exe tests/termination/example1e.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra   
# ./main.exe tests/termination/mccarthy91.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra   
# ./main.exe tests/termination/recursion.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra   
# ./main.exe tests/termination/vijay.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra   

# ./main.exe tests/termination/example1a.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-ast "AF{exit: true}"   
# ./main.exe tests/termination/example1b.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-ast "AF{exit: true}"   
# ./main.exe tests/termination/example1c.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-ast "AF{exit: true}"   
# ./main.exe tests/termination/example1d.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-ast "AF{exit: true}"   
# ./main.exe tests/termination/example1e.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-ast "AF{exit: true}"   
# ./main.exe tests/termination/mccarthy91.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-ast "AF{exit: true}"   
# ./main.exe tests/termination/recursion.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-ast "AF{exit: true}"   
# ./main.exe tests/termination/vijay.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-ast "AF{exit: true}"   
