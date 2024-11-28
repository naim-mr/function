#!/bin/sh

### recurrence with polyhedra:
### -domain polyhedra
### -joinbwd 2

#./main.exe tests/recurrence/countdown.c -recurrence tests/recurrence/countdown.txt -domain polyhedra -json_output -vulnerability  
./main.exe tests/recurrence/peterson.c -recurrence tests/recurrence/peterson.txt -domain polyhedra -json_output -vulnerability  

### recurrence with polyhedra and ordinals:
### -domain polyhedra
### -joinbwd 2
### -ordinals 1

./main.exe tests/recurrence/sink.c -recurrence tests/recurrence/sink.txt -domain polyhedra -ordinals 1 -json_output -vulnerability  

# conditional recurrence

./main.exe tests/recurrence/simple.c -recurrence tests/recurrence/simple.txt -domain polyhedra -joinbwd 3 -json_output -vulnerability   # x < 0

###

### recurrence (CTL-CFG) with polyhedra:
### -domain polyhedra
### -joinbwd 2

#./main.exe tests/recurrence/countdown.c -ctl-cfg "AG{AF{x == 0}}" -domain polyhedra -json_output -vulnerability  		  # TODO: ?
./main.exe tests/recurrence/peterson.c -ctl-cfg "AG{AF{C1: true}}" -domain polyhedra -json_output -vulnerability 

### recurrence (CTL-CFG) with polyhedra and ordinals:
### -domain polyhedra
### -joinbwd 2
### -ordinals 1

./main.exe tests/recurrence/sink.c -ctl-cfg "AG{AF{x == 0}}" -domain polyhedra -ordinals 1 -json_output -vulnerability    # TODO: ?

# conditional recurrence (CTL-CFG)

./main.exe tests/recurrence/simple.c -ctl-cfg "AG{AF{x == 3}}" -domain polyhedra -joinbwd 3 -json_output -vulnerability   # TODO: ?

###

### recurrence (CTL-AST) with polyhedra:
### -domain polyhedra
### -joinbwd 2

#./main.exe tests/recurrence/countdown.c -ctl-ast "AG{AF{x == 0}}" -domain polyhedra -json_output -vulnerability  
./main.exe tests/recurrence/peterson.c -ctl-ast "AG{AF{C1: true}}" -domain polyhedra -json_output -vulnerability  

### recurrence (CTL-AST) with polyhedra and ordinals:
### -domain polyhedra
### -joinbwd 2
### -ordinals 1

./main.exe tests/recurrence/sink.c -ctl-ast "AG{AF{x == 0}}" -domain polyhedra -ordinals 1 -json_output -vulnerability  

# conditional recurrence (CTL-AST)

./main.exe tests/recurrence/simple.c -ctl-ast "AG{AF{x == 3}}" -domain polyhedra -joinbwd 3 -json_output -vulnerability      # x < 0