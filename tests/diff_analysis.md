
__SAFE__:
tap2008*.c: New is true and it's alright. Old was not taking into account the precondition.
sas2014a.c, example7.c,widening3,increment_twoa,multiply_two,example*.c : New is alright because of the precondition.
vmcai.2004a.c: Old wasnt increasing widening delay



__BECAREFUL__:
tacas2013*.c: semantcis of rand() changed
squeez_inteval.c,example2c: Interprocedural analysis
cav2006.c: EXTENDS pb. does not produces the same constraints.
