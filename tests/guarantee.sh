#!/bin/sh

### guarantee with polyhedra:
### -domain polyhedra
### -joinbwd 2

./main.exe tests/guarantee/countdown.c -guarantee tests/guarantee/countdown.txt -domain polyhedra -json_output -vulnerability  #> logs/guarantee/countdown.log
./main.exe tests/guarantee/mnav.c -guarantee tests/guarantee/mnav.txt -domain polyhedra -json_output -vulnerability  #> logs/guarantee/mnav.log
./main.exe tests/guarantee/peterson.c -guarantee tests/guarantee/peterson.txt -domain polyhedra -json_output -vulnerability  #> logs/guarantee/peterson.log
./main.exe tests/guarantee/pingpong.c -guarantee tests/guarantee/pingpong.txt -domain polyhedra -json_output -vulnerability  #> logs/guarantee/pingpong.log

### guarantee with polyhedra and ordinals:
### -domain polyhedra
### -joinbwd 2
### -ordinals 1

./main.exe tests/guarantee/sink.c -guarantee tests/guarantee/sink.txt -domain polyhedra -ordinals 1 -json_output -vulnerability  #> logs/guarantee/sink.log

# conditional guarantee

./main.exe tests/guarantee/simple.c -guarantee tests/guarantee/simple.txt -domain polyhedra -json_output -vulnerability  #> logs/guarantee/simple.log          # x <= 3

###

### guarantee (CTL-CFG) with polyhedra:
### -domain polyhedra
### -joinbwd 2

./main.exe tests/guarantee/countdown.c -ctl-cfg "AF{x == 0}" -domain polyhedra -json_output -vulnerability  #> logs/guarantee/countdownCFG#TODO.log           # TODO: ?
./main.exe tests/guarantee/peterson.c -ctl-cfg "AF{C1: true}" -domain polyhedra -json_output -vulnerability  #> logs/guarantee/petersonCFG.log
./main.exe tests/guarantee/pingpong.c -ctl-cfg "AF{z == 1}" -domain polyhedra -json_output -vulnerability  #> logs/guarantee/pingpongCFG.log

### guarantee (CTL-CFG) with polyhedra and ordinals:
### -domain polyhedra
### -joinbwd 2
### -ordinals 1

./main.exe tests/guarantee/sink.c -ctl-cfg "AF{x == 0}" -domain polyhedra -ordinals 1 -json_output -vulnerability  #> logs/guarantee/sinkCFG#TODO.log         # TODO: ?

# conditional guarantee (CTL-CFG)

./main.exe tests/guarantee/simple.c -ctl-cfg "AF{x == 3}" -domain polyhedra -json_output -vulnerability  #> logs/guarantee/simpleCFG#TODO.log                 # TODO: ?

###

### guarantee (CTL-AST) with polyhedra:
### -domain polyhedra
### -joinbwd 2

./main.exe tests/guarantee/countdown.c -ctl-ast "AF{x == 0}" -domain polyhedra -json_output -vulnerability  #> logs/guarantee/countdownAST.log
./main.exe tests/guarantee/peterson.c -ctl-ast "AF{C1: true}" -domain polyhedra -json_output -vulnerability  #> logs/guarantee/petersonAST.log
./main.exe tests/guarantee/pingpong.c -ctl-ast "AF{z == 1}" -domain polyhedra -json_output -vulnerability  #> logs/guarantee/pingpongAST.log

### guarantee (CTL-AST) with polyhedra and ordinals:
### -domain polyhedra
### -joinbwd 2
### -ordinals 1

./main.exe tests/guarantee/sink.c -ctl-ast "AF{x == 0}" -domain polyhedra -ordinals 1 -json_output -vulnerability  #> logs/guarantee/sinkAST.log

# conditional guarantee (CTL-AST)

./main.exe tests/guarantee/simple.c -ctl-ast "AF{x == 3}" -domain polyhedra -json_output -vulnerability  #> logs/guarantee/simpleAST.log            # x <= 3