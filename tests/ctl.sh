#!/bin/sh

## conditional termination (CFG)

./main.exe tests/termination/euclid.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x == y" -json_output -vulnerability  					            # TRUE
#./main.exe tests/euclid.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 0 && y > 0" -json_output -vulnerability              # TODO: ?
./main.exe tests/termination/example0.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 10" -json_output -vulnerability                     # TRUE
#./main.exe tests/example0.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x <= 10 && x % 2 == 1" -json_output -vulnerability     # TODO: needs parity domain
./main.exe tests/termination/example5.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 0" -joinbwd 4 -json_output -vulnerability           # TRUE
./main.exe tests/termination/example7.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 6" -json_output -vulnerability  	  			        # TRUE
#./main.exe tests/example7.c -domain polyhedra -ctl "EF{exit: true}" -json_output -vulnerability  				                                # TODO: ?
#./main.exe tests/issue8.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x + z >= 0" -json_output -vulnerability  				        # TODO: ?
#./main.exe tests/issue8.c -domain polyhedra -ctl "AF{exit: true}" -precondition "y >= 1" -json_output -vulnerability  				            # TODO: ?
#./main.exe tests/issue8.c -domain polyhedra -ctl "AF{exit: true}" -precondition "-2 * y + z >= 0" -json_output -vulnerability  				    # TODO: ?
#./main.exe tests/issue8.c -domain polyhedra -ctl "AF{exit: true}" -precondition "-x >= 2" -json_output -vulnerability  				            # TODO: ?
./main.exe tests/termination/sas2014a.c -domain polyhedra -ctl "AF{exit: true}" -precondition "r <= 0" -json_output -vulnerability  				          # TRUE
#./main.exe tests/sas2014a.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x < y" -json_output -vulnerability  				          # TODO: ?
./main.exe tests/termination/sas2014c.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x <= 0" -json_output -vulnerability  				          # TRUE
#./main.exe tests/sas2014c.c -domain polyhedra -ctl "AF{exit: true}" -precondition "y > 0" -json_output -vulnerability  				          # TODO: ?
./main.exe tests/termination/tap2008a.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x < 25" -json_output -vulnerability  				          # TRUE
./main.exe tests/termination/tap2008a.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 30" -json_output -vulnerability  				          # TRUE
./main.exe tests/termination/tap2008b.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x < -5" -json_output -vulnerability  				          # TRUE
./main.exe tests/termination/tap2008b.c -domain polyhedra -ctl "AF{exit: true}" -precondition "0 <= x && x <= 30" -json_output -vulnerability        # TRUE
./main.exe tests/termination/tap2008b.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 35" -json_output -vulnerability  				          # TRUE
./main.exe tests/termination/tap2008c.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x < 30" -json_output -vulnerability  				            # TRUE
./main.exe tests/termination/tap2008d.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x <= 0" -json_output -vulnerability  				            # TRUE
./main.exe tests/termination/tap2008e.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x <= 11" -json_output -vulnerability  				        # TRUE
./main.exe tests/termination/tap2008e.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x >= 40" -json_output -vulnerability  				        # TRUE
#./main.exe tests/tap2008f.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x % 2 == 0" -json_output -vulnerability  				    # TODO: needs parity domain
./main.exe tests/termination/vmcai2004b.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x < 3" -json_output -vulnerability  				      # TRUE
./main.exe tests/termination/vmcai2004b.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 3" -joinbwd 3 -json_output -vulnerability     # TRUE
./main.exe tests/termination/widening3.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x <= 0" -json_output -vulnerability  				        # TRUE
#./main.exe tests/widening3.c -domain polyhedra -ctl "AF{exit: true}" -precondition "y > 0" -json_output -vulnerability                 # TODO: ?
#./main.exe tests/zune.c -domain polyhedra -ctl "AF{exit: true}" -precondition "days <= 365" -json_output -vulnerability  				              # TODO: call to unknown functions should be approximated with non-determinism

## conditional termination (AST)

./main.exe tests/termination/euclid.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x == y" -json_output -vulnerability  					           # TRUE
#./main.exe tests/euclid.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 0 && y > 0" -json_output -vulnerability              # TODO: ?
./main.exe tests/termination/example0.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 10" -json_output -vulnerability                     # TRUE
#./main.exe tests/example0.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x <= 10 && x % 2 == 1" -json_output -vulnerability     # TODO: needs parity domain
./main.exe tests/termination/example5.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 0" -joinbwd 5 -json_output -vulnerability           # TRUE
./main.exe tests/termination/example7.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 6" -json_output -vulnerability  	  			         # TRUE
#./main.exe tests/example7.c -domain polyhedra -ctl "EF{exit: true}" -json_output -vulnerability  				                               # TODO: ?
#./main.exe tests/issue8.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x + z >= 0" -json_output -vulnerability  				         # TODO: ?
#./main.exe tests/issue8.c -domain polyhedra -ctl "AF{exit: true}" -precondition "y >= 1" -json_output -vulnerability  				             # TODO: ?
#./main.exe tests/issue8.c -domain polyhedra -ctl "AF{exit: true}" -precondition "-2 * y + z >= 0" -json_output -vulnerability  				   # TODO: ?
#./main.exe tests/issue8.c -domain polyhedra -ctl "AF{exit: true}" -precondition "-x >= 2" -json_output -vulnerability  				           # TODO: ?
./main.exe tests/termination/sas2014a.c -domain polyhedra -ctl "AF{exit: true}" -precondition "r <= 0" -json_output -vulnerability  				         # TRUE
#./main.exe tests/sas2014a.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x < y" -json_output -vulnerability  				         # TODO: ?
./main.exe tests/termination/sas2014c.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x <= 0" -json_output -vulnerability  				         # TRUE
#./main.exe tests/sas2014c.c -domain polyhedra -ctl "AF{exit: true}" -precondition "y > 0" -json_output -vulnerability  				         # TODO: ?
./main.exe tests/termination/tap2008a.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x < 25" -json_output -vulnerability  				         # TRUE
./main.exe tests/termination/tap2008a.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 30" -json_output -vulnerability  				         # TRUE
./main.exe tests/termination/tap2008b.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x < -5" -json_output -vulnerability  				         # TRUE
./main.exe tests/termination/tap2008b.c -domain polyhedra -ctl "AF{exit: true}" -precondition "0 <= x && x <= 30" -json_output -vulnerability        # TRUE
./main.exe tests/termination/tap2008b.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 35" -json_output -vulnerability  				         # TRUE
./main.exe tests/termination/tap2008c.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x < 30" -json_output -vulnerability  				           # TRUE
./main.exe tests/termination/tap2008d.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x <= 0" -json_output -vulnerability  				           # TRUE
./main.exe tests/termination/tap2008e.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x <= 11" -json_output -vulnerability  				         # TRUE
./main.exe tests/termination/tap2008e.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x >= 40" -json_output -vulnerability  				         # TRUE
#./main.exe tests/tap2008f.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x % 2 == 0" -json_output -vulnerability  				     # TODO: needs parity domain
./main.exe tests/termination/vmcai2004b.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x < 3" -joinbwd 3 -json_output -vulnerability     # TRUE
./main.exe tests/termination/vmcai2004b.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x > 3" -joinbwd 4 -json_output -vulnerability     # TRUE
./main.exe tests/termination/widening3.c -domain polyhedra -ctl "AF{exit: true}" -precondition "x <= 0" -json_output -vulnerability  				       # TRUE
#./main.exe tests/widening3.c -domain polyhedra -ctl "AF{exit: true}" -precondition "y > 0" -json_output -vulnerability                 # TODO: ?
#./main.exe tests/zune.c -domain polyhedra -ctl "AF{exit: true}" -precondition "days <= 365" -json_output -vulnerability  				             # TODO: call to unknown functions should be approximated with non-determinism

# conditional guarantee (CFG)

#./main.exe tests/simple.c -ctl "AF{x == 3}" -domain polyhedra -precondition "x <= 3" -json_output -vulnerability          # TODO: ?

# conditional guarantee (AST)

./main.exe tests/guarantee/simple.c -ctl "AF{x == 3}" -domain polyhedra -precondition "x <= 3" -json_output -vulnerability      # TRUE

# conditional recurrence (CFG)

# ./main.exe tests/simple.c -ctl "AG{AF{x == 3}}" -domain polyhedra -joinbwd 3 -precondition "x < 0" -json_output -vulnerability  #> logs/recurrence/simple_2CFG.log      # TODO: ?

# conditional recurrence (AST)

 ./main.exe tests/recurrence//simple.c -ctl "AG{AF{x == 3}}" -domain polyhedra -joinbwd 3 -precondition "x < 0" -json_output -vulnerability           # TRUE

##########

#### CTL-CFG
echo "ECHO 1"
./main.exe tests/ctl/and_ef_test.c -domain polyhedra -ctl "AND{EF{x == 2}}{EF{x==3}}" -json_output -vulnerability  
./main.exe tests/ctl/and_test.c -domain polyhedra -ctl "AND{AG{AF{n==1}}}{AF{n==0}}" -precondition "n > 0" -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/and_test.c -domain polyhedra -ctl "EG{AF{n==1}}" -precondition "n > 0" -json_output -vulnerability  					# TODO: ?
./main.exe tests/ctl/and_test.c -domain polyhedra -ctl "AG{EF{n==1}}" -precondition "n > 0" -json_output -vulnerability  					# TODO: ?
./main.exe tests/ctl/and_test.c -domain polyhedra -ctl "EG{EF{n==1}}" -precondition "n > 0" -json_output -vulnerability  					# TODO: ?
./main.exe tests/ctl/existential_test1.c -domain polyhedra -ctl "EF{r==1}" -precondition "2*x <= y+3" -json_output -vulnerability  	# TODO: ?
# ./main.exe tests/ctl/existential_test2.c -domain polyhedra -ctl "EF{r==1}" -json_output -vulnerability  							# UNKNOWN
./main.exe tests/ctl/existential_test3.c -domain polyhedra -ctl "EF{r==1}" -precondition "x > 0" -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/existential_test3.c -domain polyhedra -ctl "EF{r==1}" -precondition "x > 0" -ctl_existential_equivalence -json_output -vulnerability  
./main.exe tests/ctl/existential_test3.c -domain polyhedra -ctl "EF{r==1}" -precondition "x == 2" -joinbwd 3 -json_output -vulnerability  
./main.exe tests/ctl/existential_test4.c -domain polyhedra -ctl "EF{r==1}" -json_output -vulnerability  
./main.exe tests/ctl/fin_ex.c -domain polyhedra -ctl "EF{n==1}" -precondition "n > 0" -json_output -vulnerability  							# TODO: ?
./main.exe tests/ctl/fin_ex.c -domain polyhedra -ctl "EG{EF{n==1}}" -precondition "n > 0" -json_output -vulnerability  						# TODO: ?
./main.exe tests/ctl/global_test_simple.c -domain polyhedra -ctl "AG{AF{x <= -10}}" -joinbwd 6 -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/global_test_simple.c -domain polyhedra -ctl "EG{AF{x <= -10}}" -joinbwd 6 -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/global_test_simple.c -domain polyhedra -ctl "AG{EF{x <= -10}}" -joinbwd 6 -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/global_test_simple.c -domain polyhedra -ctl "EG{EF{x <= -10}}" -joinbwd 6 -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/multi_branch_choice.c -domain polyhedra -ctl "AF{OR{x==4}{x==-4}}" -json_output -vulnerability  
./main.exe tests/ctl/multi_branch_choice.c -domain polyhedra -ctl "EF{x==-4}" -json_output -vulnerability  
./main.exe tests/ctl/multi_branch_choice.c -domain polyhedra -ctl "AND{EF{x==4}}{EF{x==-4}}" -json_output -vulnerability  
./main.exe tests/ctl/next.c -domain polyhedra -ctl "AX{AX{AX{x==0}}}" -precondition "x == 1" -json_output -vulnerability  
./main.exe tests/ctl/or_test.c -domain polyhedra -ctl "OR{AF{AG{x < -100}}}{AF{x==20}}" -json_output -vulnerability  
./main.exe tests/ctl/or_test.c -domain polyhedra -ctl "OR{EF{AG{x < -100}}}{AF{x==20}}" -json_output -vulnerability  
./main.exe tests/ctl/or_test.c -domain polyhedra -ctl "OR{AF{EG{x < -100}}}{AF{x==20}}" -json_output -vulnerability  
./main.exe tests/ctl/or_test.c -domain polyhedra -ctl "OR{EF{EG{x < -100}}}{AF{x==20}}" -json_output -vulnerability  
./main.exe tests/ctl/potential_termination_1.c -domain polyhedra -ctl "EF{exit: true}" -json_output -vulnerability  			# TODO: ?
./main.exe tests/ctl/until_existential.c -domain polyhedra -ctl "EU{x >= y}{x == y}" -precondition "x > y" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/until_existential.c -domain polyhedra -ctl "EF{AG{x == y}}" -precondition "x > y" -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/until_test.c -domain polyhedra -ctl "AU{x >= y}{x==y}" -precondition "x == y + 20" -json_output -vulnerability  

./main.exe tests/ctl/koskinen/acqrel.c -domain polyhedra -ctl "AG{OR{A!=1}{AF{R==1}}}" -precondition "A!=1" -ordinals 1 -json_output -vulnerability  
./main.exe tests/ctl/koskinen/acqrel_mod.c -domain polyhedra -ctl "AG{OR{a!=1}{AF{r==1}}}" -precondition "a!=1" -ordinals 1 -json_output -vulnerability  
#./main.exe tests/ctl/koskinen/fig8-2007.c -domain polyhedra -ctl "OR{set==0}{AF{unset == 1}}" -json_output -vulnerability  
#./main.exe tests/ctl/koskinen/fig8-2007_mod.c -domain polyhedra -ctl "OR{set==0}{AF{unset == 1}}" -json_output -vulnerability  
# ./main.exe tests/ctl/koskinen/toylin1.c -domain polyhedra -ctl "AF{resp > 5}" -precondition "c > 5" -json_output -vulnerability  					# TODO: ?
 ./main.exe tests/ctl/koskinen/win4.c -domain polyhedra -ctl "AF{AG{WItemsNum >= 1}}" -json_output -vulnerability  										# TODO: ?

./main.exe tests/ctl/ltl_automizer/Bug_NoLoopAtEndForTerminatingPrograms_safe.c -domain polyhedra -ctl "NOT{AF{ap > 2}}" -precondition "ap == 0" -json_output -vulnerability  
./main.exe tests/ctl/ltl_automizer/PotentialMinimizeSEVPABug.c -domain polyhedra -ctl "AG{OR{x <= 0}{AF{y == 0}}}" -precondition "x < 0"  -json_output -vulnerability  
./main.exe tests/ctl/ltl_automizer/cav2015.c -domain polyhedra -ctl "AG{OR{x <= 0}{AF{y == 0}}}" -precondition "x < 0" -json_output -vulnerability  
./main.exe tests/ctl/ltl_automizer/coolant_basis_1_safe_sfty.c -domain polyhedra -ctl "AG{OR{chainBroken != 1}{AG{chainBroken == 1}}}" -precondition "chainBroken == 0" -json_output -vulnerability  
./main.exe tests/ctl/ltl_automizer/coolant_basis_1_unsafe_sfty.c -domain polyhedra -ctl "AG{OR{chainBroken != 1}{AG{chainBroken == 1}}}" -precondition "chainBroken == 0" -json_output -vulnerability  		# TODO: not supposed to be true?
./main.exe tests/ctl/ltl_automizer/coolant_basis_2_safe_lifeness.c -domain polyhedra -ctl "AG{AF{otime < time}}" -json_output -vulnerability  	# TODO: ?
#./main.exe tests/ctl/ltl_automizer/coolant_basis_2_unsafe_lifeness.c -domain polyhedra -ctl "AG{AF{otime < time}}"  -json_output -vulnerability  	# UNKNOWN
./main.exe tests/ctl/ltl_automizer/coolant_basis_3_safe_sfty.c -domain polyhedra -ctl "AG{OR{init != 3}{AG{AF{time > otime}}}}" -precondition "init == 0" -json_output -vulnerability  
./main.exe tests/ctl/ltl_automizer/coolant_basis_3_unsafe_sfty.c -domain polyhedra -ctl "AG{OR{init != 3}{AG{AF{time > otime}}}}" -precondition "init == 0" -json_output -vulnerability  	# TODO: not supposed to be true?
./main.exe tests/ctl/ltl_automizer/coolant_basis_4_safe_sfty.c -domain polyhedra -ctl "AG{OR{init != 3}{OR{temp <= limit}{AF{AG{chainBroken == 1}}}}}" -precondition "init == 0 && temp < limit" -json_output -vulnerability  
# ./main.exe tests/ctl/ltl_automizer/coolant_basis_4_unsafe_sfty.c -domain polyhedra -ctl "AG{OR{init != 3}{OR{temp <= limit}{AF{AG{chainBroken == 1}}}}}" -precondition "init == 0 && temp < limit" -json_output -vulnerability  	# TODO: not supposed to be true? + very bad performance 
./main.exe tests/ctl/ltl_automizer/coolant_basis_5_safe_cheat.c -domain polyhedra -ctl "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/ltl_automizer/coolant_basis_5_safe_sfty.c -domain polyhedra -ctl "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" -json_output -vulnerability  	# TODO: ?
# ./main.exe tests/ctl/ltl_automizer/coolant_basis_5_unsafe_sfty.c -domain polyhedra -ctl "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" -json_output -vulnerability  	# UNKNOWN ?
./main.exe tests/ctl/ltl_automizer/coolant_basis_6_safe_sfty.c -domain polyhedra -ctl "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" -json_output -vulnerability  	# TODO: ?
# ./main.exe tests/ctl/ltl_automizer/coolant_basis_6_unsafe_sfty.c -domain polyhedra -ctl "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" -json_output -vulnerability  	# UNKNOWN ?
./main.exe tests/ctl/ltl_automizer/nestedRandomLoop_true-valid-ltl.c -domain polyhedra -ctl "AG{i >= n}" -precondition "i == 1 && n >= 0 && i > n" -json_output -vulnerability  
./main.exe tests/ctl/ltl_automizer/simple-1.c -domain polyhedra -ctl "AF{x > 10000}" -json_output -vulnerability  
./main.exe tests/ctl/ltl_automizer/simple-2.c -domain polyhedra -ctl "AF{x > 100}" -json_output -vulnerability  
# ./main.exe tests/ctl/ltl_automizer/someNonterminating.c -domain polyhedra -ctl "EG{x > 0}" -precondition "x > 0" -json_output -vulnerability  	# TODO: cda?
# ./main.exe tests/ctl/ltl_automizer/timer-intermediate.c -domain polyhedra -ctl "AG{OR{input_1 >= 1000}{AF{output_1 == 1}}}" -json_output -vulnerability  	# TODO: assume
# ./main.exe tests/ctl/ltl_automizer/timer-simple.c -domain polyhedra -ctl "NOT{AG{OR{timer_1 != 0}{AF{output_1 == 1}}}}" -json_output -vulnerability  		# TODO: ?
# ./main.exe tests/ctl/ltl_automizer/togglecounter_true-valid-ltl.c -domain polyhedra -ctl "AG{AND{AF{t == 1}}{AF{t == 0}}}" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/ltl_automizer/toggletoggle_true-valid-ltl.c -domain polyhedra -ctl "AG{AND{AF{t==1}}{AF{t==0}}}" -precondition "t >= 0" -json_output -vulnerability  

./main.exe tests/ctl/report/test_existential2.c -domain polyhedra -ctl "EF{r==1}" -precondition "x < 200" -json_output -vulnerability  
./main.exe tests/ctl/report/test_existential3.c -domain polyhedra -ctl "EF{r==1}" -precondition "x == 2" -json_output -vulnerability  
./main.exe tests/ctl/report/test_existential3.c -domain polyhedra -ctl "EF{r==1}" -precondition "x > 0" -json_output -vulnerability  
./main.exe tests/ctl/report/test_existential3.c -domain polyhedra -ctl "EF{r==1}" -precondition "x > 0" -ctl_existential_equivalence -json_output -vulnerability  
./main.exe tests/ctl/report/test_global.c -domain polyhedra -ctl "AF{AG{y > 0}}" -precondition "x < 10" -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/report/test_until.c -domain polyhedra -ctl "AU{x >= y}{x==y}" -precondition "x >= y" -json_output -vulnerability  

./main.exe tests/ctl/t2_cav13/P25.c -domain polyhedra -ctl "OR{varC <= 5}{AF{varR > 5}}" -joinbwd 6 -json_output -vulnerability  
# ./main.exe tests/ctl/t2_cav13/P26.c -domain polyhedra -ctl "OR{varC > 5}{EG{varR <= 5}}" -precondition "varC >= 1" -json_output -vulnerability  	# TODO: may not be possible to fix
./main.exe tests/ctl/t2_cav13/P3.c -domain polyhedra -ctl "OR{varA != 1}{EF{varR==1}}" -precondition "varA == 0" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/t2_cav13/P3_cheat.c -domain polyhedra -ctl "OR{varA != 1}{EF{varR==1}}" -precondition "varA == 0" -json_output -vulnerability  
./main.exe tests/ctl/t2_cav13/P4.c -domain polyhedra -ctl "EF{AND{varA == 1}{AG{varR != 1}}}" -precondition "varN > 0" -json_output -vulnerability  

 ./main.exe tests/ctl/sv_comp/Bangalore_false-no-overflow.c -domain polyhedra -ctl "EF{x < 0}" -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/sv_comp/Bangalore_false-no-overflow.c -domain polyhedra -ctl "EF{x < 0}" -ctl_existential_equivalence -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Ex02_false-termination_true-no-overflow.c -domain polyhedra -ctl "OR{i >= 5}{AF{exit: true}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl "AF{AG{i==0}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl "EF{EG{i==0}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl "EF{AG{i==0}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl "AF{EG{i==0}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl "AF{AND{AF{j >= 21}}{i==100}}" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl "AF{AND{EF{j >= 21}}{i==100}}" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl "EF{AND{AF{j >= 21}}{i==100}}" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl "EF{AND{EF{j >= 21}}{i==100}}" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl "AF{AND{x==7}{AF{AG{x==2}}}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl "AF{AND{x==7}{AF{EG{x==2}}}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl "AF{AND{x==7}{EF{AG{x==2}}}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl "AF{AND{x==7}{EF{EG{x==2}}}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl "AF{AG{j==0}}" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl "EF{AG{j==0}}" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl "AF{EG{j==0}}" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl "EF{EG{j==0}}" -json_output -vulnerability  	# TODO: ?
echo "ECHO 2"
#### CTL-AST

./main.exe tests/ctl/and_ef_test.c -domain polyhedra -ctl "AND{EF{x == 2}}{EF{x==3}}" -json_output -vulnerability  
./main.exe tests/ctl/and_test.c -domain polyhedra -ctl "AND{AG{AF{n==1}}}{AF{n==0}}" -precondition "n > 0" -json_output -vulnerability  
./main.exe tests/ctl/and_test.c -domain polyhedra -ctl "EG{AF{n==1}}" -precondition "n > 0" -json_output -vulnerability  
./main.exe tests/ctl/and_test.c -domain polyhedra -ctl "AG{EF{n==1}}" -precondition "n > 0" -json_output -vulnerability  
./main.exe tests/ctl/and_test.c -domain polyhedra -ctl "EG{EF{n==1}}" -precondition "n > 0" -json_output -vulnerability  
./main.exe tests/ctl/existential_test1.c -domain polyhedra -ctl "EF{r==1}" -precondition "2*x <= y+3" -json_output -vulnerability  
#./main.exe tests/ctl/existential_test2.c -domain polyhedra -ctl "EF{r==1}" -json_output -vulnerability  								# UNKNOWN
./main.exe tests/ctl/existential_test3.c -domain polyhedra -ctl "EF{r==1}" -precondition "x > 0" -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/existential_test3.c -domain polyhedra -ctl "EF{r==1}" -precondition "x > 0" -ctl_existential_equivalence -json_output -vulnerability  
./main.exe tests/ctl/existential_test3.c -domain polyhedra -ctl "EF{r==1}" -precondition "x == 2" -joinbwd 3 -json_output -vulnerability  
./main.exe tests/ctl/existential_test4.c -domain polyhedra -ctl "EF{r==1}" -json_output -vulnerability  
./main.exe tests/ctl/fin_ex.c -domain polyhedra -ctl "EF{n==1}" -precondition "n > 0" -json_output -vulnerability  
./main.exe tests/ctl/fin_ex.c -domain polyhedra -ctl "EG{EF{n==1}}" -precondition "n > 0" -json_output -vulnerability  
./main.exe tests/ctl/global_test_simple.c -domain polyhedra -ctl "AG{AF{x <= -10}}" -joinbwd 4 -json_output -vulnerability  
./main.exe tests/ctl/global_test_simple.c -domain polyhedra -ctl "EG{AF{x <= -10}}" -joinbwd 4 -json_output -vulnerability  
./main.exe tests/ctl/global_test_simple.c -domain polyhedra -ctl "AG{EF{x <= -10}}" -joinbwd 4 -json_output -vulnerability  
./main.exe tests/ctl/global_test_simple.c -domain polyhedra -ctl "EG{EF{x <= -10}}" -joinbwd 4 -json_output -vulnerability  
./main.exe tests/ctl/multi_branch_choice.c -domain polyhedra -ctl "AF{OR{x==4}{x==-4}}" -json_output -vulnerability  
./main.exe tests/ctl/multi_branch_choice.c -domain polyhedra -ctl "EF{x==-4}" -json_output -vulnerability  
./main.exe tests/ctl/multi_branch_choice.c -domain polyhedra -ctl "AND{EF{x==4}}{EF{x==-4}}" -json_output -vulnerability  
./main.exe tests/ctl/next.c -domain polyhedra -ctl "AX{x==0}" -precondition "x == 1" -json_output -vulnerability  
./main.exe tests/ctl/or_test.c -domain polyhedra -ctl "OR{AF{AG{x < -100}}}{AF{x==20}}" -json_output -vulnerability  
./main.exe tests/ctl/or_test.c -domain polyhedra -ctl "OR{EF{AG{x < -100}}}{AF{x==20}}" -json_output -vulnerability  
./main.exe tests/ctl/or_test.c -domain polyhedra -ctl "OR{AF{EG{x < -100}}}{AF{x==20}}" -json_output -vulnerability  
./main.exe tests/ctl/or_test.c -domain polyhedra -ctl "OR{EF{EG{x < -100}}}{AF{x==20}}" -json_output -vulnerability  
./main.exe tests/ctl/potential_termination_1.c -domain polyhedra -ctl "EF{exit: true}" -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/until_existential.c -domain polyhedra -ctl "EU{x >= y}{x == y}" -precondition "x > y" -json_output -vulnerability  
./main.exe tests/ctl/until_existential.c -domain polyhedra -ctl "EF{AG{x == y}}" -precondition "x > y" -json_output -vulnerability  
./main.exe tests/ctl/until_test.c -domain polyhedra -ctl "AU{x >= y}{x==y}" -precondition "x == y + 20" -json_output -vulnerability  

./main.exe tests/ctl/koskinen/acqrel.c -domain polyhedra -ctl "AG{OR{A!=1}{AF{R==1}}}" -precondition "A!=1" -ordinals 1 -json_output -vulnerability  
./main.exe tests/ctl/koskinen/acqrel_mod.c -domain polyhedra -ctl "AG{OR{a!=1}{AF{r==1}}}" -precondition "a!=1" -ordinals 1 -json_output -vulnerability  
# ./main.exe tests/ctl/koskinen/fig8-2007.c -domain polyhedra -ctl "OR{set==0}{AF{unset == 1}}" -json_output -vulnerability  					# TODO: goto support
# ./main.exe tests/ctl/koskinen/fig8-2007_mod.c -domain polyhedra -ctl "OR{set==0}{AF{unset == 1}}" -json_output -vulnerability  			# TODO: goto support
# ./main.exe tests/ctl/koskinen/toylin1.c -domain polyhedra -ctl "AF{resp > 5}" -precondition "c > 5" -json_output -vulnerability  					# TODO: ?
./main.exe tests/ctl/koskinen/win4.c -domain polyhedra -ctl "AF{AG{WItemsNum >= 1}}" -json_output -vulnerability  

./main.exe tests/ctl/ltl_automizer/Bug_NoLoopAtEndForTerminatingPrograms_safe.c -domain polyhedra -ctl "NOT{AF{ap > 2}}" -precondition "ap == 0" -json_output -vulnerability  
./main.exe tests/ctl/ltl_automizer/PotentialMinimizeSEVPABug.c -domain polyhedra -ctl "AG{OR{x <= 0}{AF{y == 0}}}" -precondition "x < 0" -ordinals 1 -json_output -vulnerability  
./main.exe tests/ctl/ltl_automizer/cav2015.c -domain polyhedra -ctl "AG{OR{x <= 0}{AF{y == 0}}}" -precondition "x < 0" -ordinals 1 -json_output -vulnerability  
# big over-head
# ./main.exe tests/ctl/ltl_automizer/coolant_basis_1_safe_sfty.c -domain polyhedra -ctl "AG{OR{chainBroken != 1}{AG{chainBroken == 1}}}" -precondition "chainBroken == 0" -json_output -vulnerability   # TODO: ?
## ./main.exe tests/ctl/ltl_automizer/coolant_basis_1_unsafe_sfty.c -domain polyhedra -ctl "AG{OR{chainBroken != 1}{AG{chainBroken == 1}}}" -precondition "chainBroken == 0" -json_output -vulnerability  		# UNKNOWN?
# ./main.exe tests/ctl/ltl_automizer/coolant_basis_2_safe_lifeness.c -domain polyhedra -ctl "AG{AF{otime < time}}" -json_output -vulnerability  	# TODO: ?
## ./main.exe tests/ctl/ltl_automizer/coolant_basis_2_unsafe_lifeness.c -domain polyhedra -ctl "AG{AF{otime < time}}" -json_output -vulnerability  	# UNKNOWN
# ./main.exe tests/ctl/ltl_automizer/coolant_basis_3_safe_sfty.c -domain polyhedra -ctl "AG{OR{init != 3}{AG{AF{time > otime}}}}" -precondition "init == 0" -json_output -vulnerability  	# TODO: ?
## ./main.exe tests/ctl/ltl_automizer/coolant_basis_3_unsafe_sfty.c -domain polyhedra -ctl "AG{OR{init != 3}{AG{AF{time > otime}}}}" -precondition "init == 0" -json_output -vulnerability  	# UNKNOWN?
# ./main.exe tests/ctl/ltl_automizer/coolant_basis_4_safe_sfty.c -domain polyhedra -ctl "AG{OR{init != 3}{OR{temp <= limit}{AF{AG{chainBroken == 1}}}}}" -precondition "init == 0 && temp < limit" -json_output -vulnerability  	# TODO: ?
## ./main.exe tests/ctl/ltl_automizer/coolant_basis_4_unsafe_sfty.c -domain polyhedra -ctl "AG{OR{init != 3}{OR{temp <= limit}{AF{AG{chainBroken == 1}}}}}" -precondition "init == 0 && temp < limit" -json_output -vulnerability  	# TODO: UNKNOWN? + bad performance 
# ./main.exe tests/ctl/ltl_automizer/coolant_basis_5_safe_cheat.c -domain polyhedra -ctl "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" -json_output -vulnerability  	# TODO: ?
##./main.exe tests/ctl/ltl_automizer/coolant_basis_6_safe_sfty.c -domain polyhedra -ctl "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" -json_output -vulnerability  	# TODO: ?
# ./main.exe tests/ctl/ltl_automizer/coolant_basis_5_unsafe_sfty.c -domain polyhedra -ctl "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" -json_output -vulnerability  	# UNKNOWN ?
# ./main.exe tests/ctl/ltl_automizer/coolant_basis_6_safe_sfty.c -domain polyhedra -ctl "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" -json_output -vulnerability  	# TODO: ?
# ./main.exe tests/ctl/ltl_automizer/coolant_basis_6_unsafe_sfty.c -domain polyhedra -ctl "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" -json_output -vulnerability  	# UNKNOWN ?
./main.exe tests/ctl/ltl_automizer/nestedRandomLoop_true-valid-ltl.c -domain polyhedra -ctl "AG{i >= n}" -precondition "i == 1 && n >= 0 && i > n" -json_output -vulnerability  
./main.exe tests/ctl/ltl_automizer/simple-1.c -domain polyhedra -ctl "AF{x > 10000}" -json_output -vulnerability  
./main.exe tests/ctl/ltl_automizer/simple-2.c -domain polyhedra -ctl "AF{x > 100}" -json_output -vulnerability  
# ./main.exe tests/ctl/ltl_automizer/someNonterminating.c -domain polyhedra -ctl "EG{x > 0}" -precondition "x > 0" -json_output -vulnerability  	# TODO: cda?
# ./main.exe tests/ctl/ltl_automizer/timer-intermediate.c -domain polyhedra -ctl "AG{OR{input_1 >= 1000}{AF{output_1 == 1}}}" -json_output -vulnerability  	# TODO: assume
# ./main.exe tests/ctl/ltl_automizer/timer-simple.c -domain polyhedra -ctl "NOT{AG{OR{timer_1 != 0}{AF{output_1 == 1}}}}" -json_output -vulnerability  		# TODO: ?
# ./main.exe tests/ctl/ltl_automizer/togglecounter_true-valid-ltl.c -domain polyhedra -ctl "AG{AND{AF{t == 1}}{AF{t == 0}}}" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/ltl_automizer/toggletoggle_true-valid-ltl.c -domain polyhedra -ctl "AG{AND{AF{t==1}}{AF{t==0}}}" -precondition "t >= 0" -json_output -vulnerability  
echo "ECHO 3"
./main.exe tests/ctl/report/test_existential2.c -domain polyhedra -ctl "EF{r==1}" -precondition "x < 200" -json_output -vulnerability  	# TODO: ?
./main.exe tests/ctl/report/test_existential3.c -domain polyhedra -ctl "EF{r==1}" -precondition "x == 2" -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/report/test_existential3.c -domain polyhedra -ctl "EF{r==1}" -precondition "x > 0" -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/report/test_existential3.c -domain polyhedra -ctl "EF{r==1}" -precondition "x > 0" -ctl_existential_equivalence -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/report/test_global.c -domain polyhedra -ctl "AF{AG{y > 0}}" -precondition "x < 10" -json_output -vulnerability  
./main.exe tests/ctl/report/test_until.c -domain polyhedra -ctl "AU{x >= y}{x==y}" -precondition "x >= y" -json_output -vulnerability  

./main.exe tests/ctl/t2_cav13/P25.c -domain polyhedra -ctl "OR{varC <= 5}{AF{varR > 5}}" -joinbwd 6 -json_output -vulnerability  
# ./main.exe tests/ctl/t2_cav13/P26.c -domain polyhedra -ctl "OR{varC > 5}{EG{varR <= 5}}" -precondition "varC >= 1" -json_output -vulnerability  	# TODO: may not be possible to fix
./main.exe tests/ctl/t2_cav13/P3.c -domain polyhedra -ctl "OR{varA != 1}{EF{varR==1}}" -precondition "varA == 0" -json_output -vulnerability  
./main.exe tests/ctl/t2_cav13/P3_cheat.c -domain polyhedra -ctl "OR{varA != 1}{EF{varR==1}}" -precondition "varA == 0" -json_output -vulnerability  
./main.exe tests/ctl/t2_cav13/P4.c -domain polyhedra -ctl "EF{AND{varA == 1}{AG{varR != 1}}}" -precondition "varN > 0" -json_output -vulnerability  

./main.exe tests/ctl/sv_comp/Bangalore_false-no-overflow.c -domain polyhedra -ctl "EF{x < 0}" -json_output -vulnerability  		# TODO: ?
./main.exe tests/ctl/sv_comp/Bangalore_false-no-overflow.c -domain polyhedra -ctl "EF{x < 0}" -ctl_existential_equivalence -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Ex02_false-termination_true-no-overflow.c -domain polyhedra -ctl "OR{i >= 5}{AF{exit: true}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl "AF{AG{i==0}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl "EF{EG{i==0}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl "EF{AG{i==0}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl "AF{EG{i==0}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl "AF{AND{AF{j >= 21}}{i==100}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl "AF{AND{EF{j >= 21}}{i==100}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl "EF{AND{AF{j >= 21}}{i==100}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl "EF{AND{EF{j >= 21}}{i==100}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl "AF{AND{x==7}{AF{AG{x==2}}}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl "AF{AND{x==7}{AF{EG{x==2}}}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl "AF{AND{x==7}{EF{AG{x==2}}}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl "AF{AND{x==7}{EF{EG{x==2}}}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl "AF{AG{j==0}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl "EF{AG{j==0}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl "AF{EG{j==0}}" -json_output -vulnerability  
./main.exe tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl "EF{EG{j==0}}" -json_output -vulnerability  
echo "ECHO 4"