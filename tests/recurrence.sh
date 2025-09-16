

### recurrence (CTL-AST) with polyhedra:
### -domain polyhedra
### -joinbwd 2

#./main.exe tests/recurrence/countdown.c -ctl "AG{AF{x == 0}}" -domain polyhedra -json_output -vulnerability  
./main.exe tests/recurrence/peterson.c -ctl "AG{AF{C1: true}}" -domain polyhedra -json_output -vulnerability  

### recurrence (CTL-AST) with polyhedra and ordinals:
### -domain polyhedra
### -joinbwd 2
### -ordinals 1

./main.exe tests/recurrence/sink.c -ctl "AG{AF{x == 0}}" -domain polyhedra -ordinals 1 -json_output -vulnerability  

# conditional recurrence (CTL-AST)

./main.exe tests/recurrence/simple.c -ctl "AG{AF{x == 3}}" -domain polyhedra -joinbwd 3 -json_output -vulnerability      # x < 0