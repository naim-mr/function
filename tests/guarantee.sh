
###

### guarantee (CTL-AST) with polyhedra:
### -domain polyhedra
### -joinbwd 2

./main.exe tests/guarantee/countdown.c -ctl "AF{x == 0}" -domain polyhedra -json_output -vulnerability  #> logs/guarantee/countdownAST.log
./main.exe tests/guarantee/peterson.c -ctl "AF{C1: true}" -domain polyhedra -json_output -vulnerability  #> logs/guarantee/petersonAST.log
./main.exe tests/guarantee/pingpong.c -ctl "AF{z == 1}" -domain polyhedra -json_output -vulnerability  #> logs/guarantee/pingpongAST.log

### guarantee (CTL-AST) with polyhedra and ordinals:
### -domain polyhedra
### -joinbwd 2
### -ordinals 1

./main.exe tests/guarantee/sink.c -ctl "AF{x == 0}" -domain polyhedra -ordinals 1 -json_output -vulnerability  #> logs/guarantee/sinkAST.log

# conditional guarantee (CTL-AST)

./main.exe tests/guarantee/simple.c -ctl "AF{x == 3}" -domain polyhedra -json_output -vulnerability  #> logs/guarantee/simpleAST.log            # x <= 3