#!/bin/sh

### termination (AST) with default setting:
### -domain boxes
### -joinbwd 2

./function tests/termination/boolean.c -json_output 				# TRUE
./function tests/termination/cacm2009a.c -json_output 		# TRUE
# ./function tests/termination/cacm2009b.c -json_output 
./function tests/termination/cav2006.c -json_output 				# TRUE
./function tests/termination/example1.c -json_output 				# TRUE
# ./function tests/termination/example1a.c -json_output 
# ./function tests/termination/example1b.c -json_output 
# ./function tests/termination/example1c.c -json_output 
# ./function tests/termination/example1d.c -json_output 
# ./function tests/termination/example1e.c -json_output 
# ./function tests/termination/example2.c -json_output 
./function tests/termination/example2a.c -json_output 			# TRUE
# ./function tests/termination/example2b.c -json_output 
# ./function tests/termination/example2c.c -json_output 
# ./function tests/termination/example2d.c -json_output 
# ./function tests/termination/example2e.c -json_output 
# ./function tests/termination/example8.c -json_output 
# ./function tests/termination/example10.c -json_output 
# ./function tests/termination/mccarthy91.c -json_output 
./function tests/termination/postdecrement.c -json_output 	# TRUE
./function tests/termination/postincrement.c -json_output 	# TRUE
./function tests/termination/predecrement.c -json_output 		# TRUE
./function tests/termination/preincrement.c -json_output 		# TRUE
# ./function tests/termination/recursion.c -json_output 
./function tests/termination/sas2010.c -json_output 				# TRUE
# ./function tests/termination/sas2014b.c -json_output 
# ./function tests/termination/sorting4.c -json_output 
./function tests/termination/tacas2013a.c -json_output 			# TRUE
# ./function tests/termination/tacas2013b.c -json_output 
# ./function tests/termination/tacas2013c.c -json_output 
# ./function tests/termination/tacas2013d.c -json_output 
# ./function tests/termination/vijay.c -json_output 
# ./function tests/termination/vmcai2004a.c -json_output 
# ./function tests/termination/widening1.c -json_output 
# ./function tests/termination/widening2.c -json_output 

### termination (CFG) with default setting:
### -domain boxes
### -joinbwd 2

./function tests/termination/boolean.c -ctl-cfg "AF{exit: true}" -json_output 				# TRUE
./function tests/termination/cacm2009a.c -ctl-cfg "AF{exit: true}" -json_output 			# TRUE
./function tests/termination/cav2006.c -ctl-cfg "AF{exit: true}" -json_output 				# TRUE
./function tests/termination/example1.c -ctl-cfg "AF{exit: true}" -json_output 			# TRUE
./function tests/termination/example2a.c -ctl-cfg "AF{exit: true}" -json_output 			# TRUE
# ./function tests/termination/postdecrement.c -ctl-cfg "AF{exit: true}" -json_output 	# TODO: fix parser?
# ./function tests/termination/postincrement.c -ctl-cfg "AF{exit: true}" -json_output 	# TODO: fix parser?
# ./function tests/termination/predecrement.c -ctl-cfg "AF{exit: true}" -json_output 		# TODO: fix parser?
# ./function tests/termination/preincrement.c -ctl-cfg "AF{exit: true}" -json_output 		# TODO: fix parser?
 ./function tests/termination/sas2010.c -ctl-cfg "AF{exit: true}" -json_output 				# TODO: ?
./function tests/termination/tacas2013a.c -ctl-cfg "AF{exit: true}" -json_output 		# TRUE

## conditional termination

# ./function tests/termination/euclid.c -json_output 					# x = y || (x > 0 && y > 0)
# ./function tests/termination/example0.c -json_output 				# x > 10 OR (x <= 10 AND x odd)
# ./function tests/termination/example5.c -json_output 				# x > 0
# ./function tests/termination/example7.c -json_output 				# x > 6
# ./function tests/termination/issue8.c -json_output 					# x + z >= 0 || y >= 1 || -2y + z >= 0 || -x >= 2
# ./function tests/termination/sas2014a.c -json_output 				# r <= 0 || x < y
# ./function tests/termination/sas2014c.c -json_output 				# x <= 0 OR y > 0
# ./function tests/termination/tap2008a.c -json_output 				# x < 25 OR x > 30
# ./function tests/termination/tap2008b.c -json_output 				# x < -5 OR 0 <= x <= 30 OR x > 35
# ./function tests/termination/tap2008c.c -json_output 				# x < 30
# ./function tests/termination/tap2008d.c -json_output 				# x <= 0
# ./function tests/termination/tap2008e.c -json_output 				# x <= 11 OR x >= 40
# ./function tests/termination/tap2008f.c -json_output 				# x even
# ./function tests/termination/vmcai2004b.c -json_output 			# x != 3
# ./function tests/termination/widening3.c -json_output 				# x <= 0 || y > 0
# ./function tests/termination/zune.c -json_output 

#################################################################################

### termination (AST) with increased widening delay:
### -domain boxes
### -joinbwd 5

# ./function tests/termination/cacm2009b.c -joinbwd 5 -json_output 
# ./function tests/termination/example10.c -joinbwd 5 -json_output 
# ./function tests/termination/example1a.c -joinbwd 5 -json_output 
# ./function tests/termination/example1b.c -joinbwd 5 -json_output 
# ./function tests/termination/example1c.c -joinbwd 5 -json_output 
# ./function tests/termination/example1d.c -joinbwd 5 -json_output 
# ./function tests/termination/example1e.c -joinbwd 5 -json_output 
# ./function tests/termination/example2.c -joinbwd 5 -json_output 
# ./function tests/termination/example2b.c -joinbwd 5 -json_output 
# ./function tests/termination/example2c.c -joinbwd 5 -json_output 
# ./function tests/termination/example2d.c -joinbwd 5 -json_output 
# ./function tests/termination/example2e.c -joinbwd 5 -json_output 
# ./function tests/termination/example8.c -joinbwd 5 -json_output 
# ./function tests/termination/mccarthy91.c -joinbwd 5 -json_output 
# ./function tests/termination/recursion.c -joinbwd 5 -json_output 
# ./function tests/termination/sas2014b.c -joinbwd 5 -json_output 
# ./function tests/termination/sorting4.c -joinbwd 5 -json_output 
# ./function tests/termination/tacas2013b.c -joinbwd 5 -json_output 
# ./function tests/termination/tacas2013c.c -joinbwd 5 -json_output 
# ./function tests/termination/tacas2013d.c -joinbwd 5 -json_output 
# ./function tests/termination/vijay.c -joinbwd 5 -json_output 
./function tests/termination/vmcai2004a.c -joinbwd 5 -json_output 		# TRUE
# ./function tests/termination/widening1.c -joinbwd 5 -json_output 
# ./function tests/termination/widening2.c -joinbwd 5 -json_output 

### termination (CFG) with increased widening delay (5):
### -domain boxes
### -joinbwd 5

./function tests/termination/vmcai2004a.c -joinbwd 5 -ctl-cfg "AF{exit: true}" -json_output 		# TRUE

#################################################################################

### termination (AST) with increased widening delay (7):
### -domain boxes
### -joinbwd 7

./function tests/termination/example8.c -joinbwd 7 -json_output 		# TRUE

### termination (CFG) with increased widening delay (7):
### -domain boxes
### -joinbwd 7

./function tests/termination/example8.c -joinbwd 7 -ctl-cfg "AF{exit: true}" -json_output 		# TRUE

#################################################################################

### termination (AST) with forward refinement:
### -domain boxes
### -joinbwd 2
### -refine

# ./function tests/termination/cacm2009b.c -refine -json_output 
# ./function tests/termination/example10.c -refine -json_output 
# ./function tests/termination/example1a.c -refine -json_output 
# ./function tests/termination/example1b.c -refine -json_output 
# ./function tests/termination/example1c.c -refine -json_output 
# ./function tests/termination/example1d.c -refine -json_output 
# ./function tests/termination/example1e.c -refine -json_output 
# ./function tests/termination/example2.c -refine -json_output 
./function tests/termination/example2b.c -refine -json_output 		# TRUE
./function tests/termination/example2c.c -refine -json_output 		# TRUE
./function tests/termination/example2d.c -refine -json_output 		# TRUE
./function tests/termination/example2e.c -refine -json_output 		# TRUE
# ./function tests/termination/mccarthy91.c -refine -json_output 
# ./function tests/termination/recursion.c -refine -json_output 
./function tests/termination/sas2014b.c -refine -json_output 			# TRUE
# ./function tests/termination/sorting4.c -refine -json_output 
# ./function tests/termination/tacas2013b.c -refine -json_output 
# ./function tests/termination/tacas2013c.c -refine -json_output 
# ./function tests/termination/tacas2013d.c -refine -json_output 
# ./function tests/termination/vijay.c -refine -json_output 
# ./function tests/termination/widening1.c -refine -json_output 
# ./function tests/termination/widening2.c -refine -json_output 

### termination (CFG) with forward refinement:
### -domain boxes
### -joinbwd 2
### -refine

./function tests/termination/example2b.c -refine -ctl-cfg "AF{exit: true}" -json_output 		# TODO: ?
./function tests/termination/example2c.c -refine -ctl-cfg "AF{exit: true}" -json_output 		# TODO: ?> logs
./function tests/termination/example2d.c -refine -ctl-cfg "AF{exit: true}" -json_output 		# TODO: ?
./function tests/termination/example2e.c -refine -ctl-cfg "AF{exit: true}" -json_output 		# TODO: ?
./function tests/termination/sas2014b.c -refine -ctl-cfg "AF{exit: true}" -json_output 			# TODO: ?

#################################################################################

### termination (AST) with polyhedra:
### -domain polyhedra
### -joinbwd 2

# ./function tests/termination/cacm2009b.c -domain polyhedra -json_output 
# ./function tests/termination/example10.c -domain polyhedra -json_output 
# ./function tests/termination/example1a.c -domain polyhedra -json_output 
# ./function tests/termination/example1b.c -domain polyhedra -json_output 
# ./function tests/termination/example1c.c -domain polyhedra -json_output 
# ./function tests/termination/example1d.c -domain polyhedra -json_output 
# ./function tests/termination/example1e.c -domain polyhedra -json_output 
# ./function tests/termination/example2.c -domain polyhedra -json_output 
# ./function tests/termination/mccarthy91.c -domain polyhedra -json_output 
# ./function tests/termination/recursion.c -domain polyhedra -json_output 
./function tests/termination/sorting4.c -domain polyhedra -json_output 			# TRUE
./function tests/termination/tacas2013b.c -domain polyhedra -json_output 		# TRUE
# ./function tests/termination/tacas2013c.c -domain polyhedra -json_output 
# ./function tests/termination/tacas2013d.c -domain polyhedra -json_output 
# ./function tests/termination/vijay.c -domain polyhedra -json_output 
# ./function tests/termination/widening1.c -domain polyhedra -json_output 
# ./function tests/termination/widening2.c -domain polyhedra -json_output 

### termination (CFG) with polyhedra:
### -domain polyhedra
### -joinbwd 2

./function tests/termination/sorting4.c -domain polyhedra -ctl-cfg "AF{exit: true}" -json_output 			# TRUE
./function tests/termination/tacas2013b.c -domain polyhedra -ctl-cfg "AF{exit: true}" -json_output 		# TRUE

#################################################################################

### termination (AST) with ordinals (2):
### -domain boxes
### -joinbwd 2
### -ordinals 2

./function tests/termination/cacm2009b.c -ordinals 2 -json_output 		# TRUE
# ./function tests/termination/example1a.c -ordinals 2 -json_output 
# ./function tests/termination/example1b.c -ordinals 2 -json_output 
# ./function tests/termination/example1c.c -ordinals 2 -json_output 
# ./function tests/termination/example1d.c -ordinals 2 -json_output 
# ./function tests/termination/example1e.c -ordinals 2 -json_output 
./function tests/termination/example2.c -ordinals 2 -json_output 		# TRUE
./function tests/termination/example10.c -ordinals 2 -json_output 		# TRUE
# ./function tests/termination/mccarthy91.c -ordinals 2 -json_output 
# ./function tests/termination/recursion.c -ordinals 2 -json_output 
# ./function tests/termination/tacas2013c.c -ordinals 2 -json_output 
./function tests/termination/tacas2013d.c -ordinals 2 -json_output 	# TRUE
# ./function tests/termination/vijay.c -ordinals 2 -json_output 
./function tests/termination/widening1.c -ordinals 2 -json_output 		# TRUE
./function tests/termination/widening2.c -ordinals 2 -json_output 		# TRUE

### termination (CFG) with ordinals (2):
### -domain boxes
### -joinbwd 2
### -ordinals 2

./function tests/termination/cacm2009b.c -ordinals 2 -ctl-cfg "AF{exit: true}" -json_output 		# TRUE
./function tests/termination/example2.c -ordinals 2 -ctl-cfg "AF{exit: true}" -json_output 			# TRUE
./function tests/termination/example10.c -ordinals 2 -ctl-cfg "AF{exit: true}" -json_output 		# TRUE
./function tests/termination/tacas2013d.c -ordinals 2 -ctl-cfg "AF{exit: true}" -json_output 		# TRUE
./function tests/termination/widening1.c -ordinals 2 -ctl-cfg "AF{exit: true}" -json_output 		# TRUE
./function tests/termination/widening2.c -ordinals 2 -ctl-cfg "AF{exit: true}" -json_output 		# TRUE

#################################################################################

### termination (AST) with increased widening delay (3) and ordinals (2):
### -domain boxes
### -joinbwd 3
### -ordinals 2

# ./function tests/termination/example1a.c -joinbwd 3 -ordinals 2 -json_output 
# ./function tests/termination/example1b.c -joinbwd 3 -ordinals 2 -json_output 
# ./function tests/termination/example1c.c -joinbwd 3 -ordinals 2 -json_output 
# ./function tests/termination/example1d.c -joinbwd 3 -ordinals 2 -json_output 
# ./function tests/termination/example1e.c -joinbwd 3 -ordinals 2 -json_output 
# ./function tests/termination/mccarthy91.c -joinbwd 3 -ordinals 2 -json_output 
# ./function tests/termination/recursion.c -joinbwd 3 -ordinals 2 -json_output 
./function tests/termination/tacas2013c.c -joinbwd 3 -ordinals 2 -json_output 		# TRUE
# ./function tests/termination/vijay.c -joinbwd 3 -ordinals 2 -json_output 

### termination (CFG) with increased widening delay (3) ordinals (2):
### -domain boxes
### -joinbwd 3
### -ordinals 2

./function tests/termination/tacas2013c.c -joinbwd 3 -ordinals 2 -ctl-cfg "AF{exit: true}" -json_output 	# TRUE

#################################################################################

### TODO

# ./function tests/termination/example1a.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -json_output 
# ./function tests/termination/example1b.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -json_output 
# ./function tests/termination/example1c.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -json_output 
# ./function tests/termination/example1d.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -json_output 
# ./function tests/termination/example1e.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -json_output 
# ./function tests/termination/mccarthy91.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -json_output 
# ./function tests/termination/recursion.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -json_output 
# ./function tests/termination/vijay.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -json_output 

# ./function tests/termination/example1a.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-cfg "AF{exit: true}" -json_output 
# ./function tests/termination/example1b.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-cfg "AF{exit: true}" -json_output 
# ./function tests/termination/example1c.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-cfg "AF{exit: true}" -json_output 
# ./function tests/termination/example1d.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-cfg "AF{exit: true}" -json_output 
# ./function tests/termination/example1e.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-cfg "AF{exit: true}" -json_output 
# ./function tests/termination/mccarthy91.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-cfg "AF{exit: true}" -json_output 
# ./function tests/termination/recursion.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-cfg "AF{exit: true}" -json_output 
# ./function tests/termination/vijay.c -joinbwd 3 -ordinals 2 -refine -domain polyhedra -ctl-cfg "AF{exit: true}" -json_output 
