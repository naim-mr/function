#!/bin/sh

### recurrence with polyhedra:
### -domain polyhedra
### -joinbwd 2

./function tests/recurrence/countdown.c -recurrence tests/recurrence/countdown.txt -domain polyhedra -json_output 
./function tests/recurrence/peterson.c -recurrence tests/recurrence/peterson.txt -domain polyhedra -json_output 

### recurrence with polyhedra and ordinals:
### -domain polyhedra
### -joinbwd 2
### -ordinals 1

./function tests/recurrence/sink.c -recurrence tests/recurrence/sink.txt -domain polyhedra -ordinals 1 -json_output 

# conditional recurrence

./function tests/recurrence/simple.c -recurrence tests/recurrence/simple.txt -domain polyhedra -joinbwd 3 -json_output  # x < 0

###

### recurrence (CTL-CFG) with polyhedra:
### -domain polyhedra
### -joinbwd 2

./function tests/recurrence/countdown.c -ctl-cfg "AG{AF{x == 0}}" -domain polyhedra -json_output 		  # TODO: ?
./function tests/recurrence/peterson.c -ctl-cfg "AG{AF{C1: true}}" -domain polyhedra -json_output

### recurrence (CTL-CFG) with polyhedra and ordinals:
### -domain polyhedra
### -joinbwd 2
### -ordinals 1

./function tests/recurrence/sink.c -ctl-cfg "AG{AF{x == 0}}" -domain polyhedra -ordinals 1 -json_output   # TODO: ?

# conditional recurrence (CTL-CFG)

./function tests/recurrence/simple.c -ctl-cfg "AG{AF{x == 3}}" -domain polyhedra -joinbwd 3 -json_output  # TODO: ?

###

### recurrence (CTL-AST) with polyhedra:
### -domain polyhedra
### -joinbwd 2

./function tests/recurrence/countdown.c -ctl-ast "AG{AF{x == 0}}" -domain polyhedra -json_output 
./function tests/recurrence/peterson.c -ctl-ast "AG{AF{C1: true}}" -domain polyhedra -json_output 

### recurrence (CTL-AST) with polyhedra and ordinals:
### -domain polyhedra
### -joinbwd 2
### -ordinals 1

./function tests/recurrence/sink.c -ctl-ast "AG{AF{x == 0}}" -domain polyhedra -ordinals 1 -json_output 

# conditional recurrence (CTL-AST)

./function tests/recurrence/simple.c -ctl-ast "AG{AF{x == 3}}" -domain polyhedra -joinbwd 3 -json_output     # x < 0