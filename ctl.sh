#!/bin/sh

## conditional termination (CFG)

./function tests/termination/euclid.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x == y" -json_output 					            # TRUE
#./function tests/euclid.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 0 && y > 0" -json_output             # TODO: ?
./function tests/termination/example0.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 10" -json_output                    # TRUE
#./function tests/example0.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x <= 10 && x % 2 == 1" -json_output    # TODO: needs parity domain
./function tests/termination/example5.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 0" -joinbwd 4 -json_output          # TRUE
./function tests/termination/example7.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 6" -json_output 	  			        # TRUE
#./function tests/example7.c -domain polyhedra -ctl-cfg "EF{exit: true}" -json_output 				                                # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x + z >= 0" -json_output 				        # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "y >= 1" -json_output 				            # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "-2 * y + z >= 0" -json_output 				    # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "-x >= 2" -json_output 				            # TODO: ?
./function tests/termination/sas2014a.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "r <= 0" -json_output 				          # TRUE
#./function tests/sas2014a.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x < y" -json_output 				          # TODO: ?
./function tests/termination/sas2014c.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x <= 0" -json_output 				          # TRUE
#./function tests/sas2014c.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "y > 0" -json_output 				          # TODO: ?
./function tests/termination/tap2008a.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x < 25" -json_output 				          # TRUE
./function tests/termination/tap2008a.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 30" -json_output 				          # TRUE
./function tests/termination/tap2008b.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x < -5" -json_output 				          # TRUE
./function tests/termination/tap2008b.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "0 <= x && x <= 30" -json_output       # TRUE
./function tests/termination/tap2008b.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 35" -json_output 				          # TRUE
./function tests/termination/tap2008c.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x < 30" -json_output 				            # TRUE
./function tests/termination/tap2008d.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x <= 0" -json_output 				            # TRUE
./function tests/termination/tap2008e.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x <= 11" -json_output 				        # TRUE
./function tests/termination/tap2008e.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x >= 40" -json_output 				        # TRUE
#./function tests/tap2008f.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x % 2 == 0" -json_output 				    # TODO: needs parity domain
./function tests/termination/vmcai2004b.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x < 3" -json_output 				      # TRUE
./function tests/termination/vmcai2004b.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 3" -joinbwd 3 -json_output    # TRUE
./function tests/termination/widening3.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x <= 0" -json_output 				        # TRUE
#./function tests/widening3.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "y > 0" -json_output                # TODO: ?
#./function tests/zune.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "days <= 365" -json_output 				              # TODO: call to unknown functions should be approximated with non-determinism

## conditional termination (AST)

./function tests/termination/euclid.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x == y" -json_output 					           # TRUE
#./function tests/euclid.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 0 && y > 0" -json_output             # TODO: ?
./function tests/termination/example0.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 10" -json_output                    # TRUE
#./function tests/example0.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x <= 10 && x % 2 == 1" -json_output    # TODO: needs parity domain
./function tests/termination/example5.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 0" -joinbwd 5 -json_output          # TRUE
./function tests/termination/example7.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 6" -json_output 	  			         # TRUE
#./function tests/example7.c -domain polyhedra -ctl-ast "EF{exit: true}" -json_output 				                               # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x + z >= 0" -json_output 				         # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "y >= 1" -json_output 				             # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "-2 * y + z >= 0" -json_output 				   # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "-x >= 2" -json_output 				           # TODO: ?
./function tests/termination/sas2014a.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "r <= 0" -json_output 				         # TRUE
#./function tests/sas2014a.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x < y" -json_output 				         # TODO: ?
./function tests/termination/sas2014c.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x <= 0" -json_output 				         # TRUE
#./function tests/sas2014c.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "y > 0" -json_output 				         # TODO: ?
./function tests/termination/tap2008a.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x < 25" -json_output 				         # TRUE
./function tests/termination/tap2008a.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 30" -json_output 				         # TRUE
./function tests/termination/tap2008b.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x < -5" -json_output 				         # TRUE
./function tests/termination/tap2008b.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "0 <= x && x <= 30" -json_output       # TRUE
./function tests/termination/tap2008b.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 35" -json_output 				         # TRUE
./function tests/termination/tap2008c.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x < 30" -json_output 				           # TRUE
./function tests/termination/tap2008d.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x <= 0" -json_output 				           # TRUE
./function tests/termination/tap2008e.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x <= 11" -json_output 				         # TRUE
./function tests/termination/tap2008e.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x >= 40" -json_output 				         # TRUE
#./function tests/tap2008f.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x % 2 == 0" -json_output 				     # TODO: needs parity domain
./function tests/termination/vmcai2004b.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x < 3" -joinbwd 3 -json_output    # TRUE
./function tests/termination/vmcai2004b.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 3" -joinbwd 4 -json_output    # TRUE
./function tests/termination/widening3.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x <= 0" -json_output 				       # TRUE
#./function tests/widening3.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "y > 0" -json_output                # TODO: ?
#./function tests/zune.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "days <= 365" -json_output 				             # TODO: call to unknown functions should be approximated with non-determinism

# conditional guarantee (CFG)

#./function tests/simple.c -ctl-cfg "AF{x == 3}" -domain polyhedra -precondition "x <= 3" -json_output         # TODO: ?

# conditional guarantee (AST)

./function tests/guarantee/simple.c -ctl-ast "AF{x == 3}" -domain polyhedra -precondition "x <= 3" -json_output     # TRUE

# conditional recurrence (CFG)

# ./function tests/simple.c -ctl-cfg "AG{AF{x == 3}}" -domain polyhedra -joinbwd 3 -precondition "x < 0" -json_output #> logs/recurrence/simple_2CFG.log      # TODO: ?

# conditional recurrence (AST)

 ./function tests/recurrence//simple.c -ctl-ast "AG{AF{x == 3}}" -domain polyhedra -joinbwd 3 -precondition "x < 0" -json_output          # TRUE

##########

#### CTL-CFG

./function tests/ctl/and_ef_test.c -domain polyhedra -ctl-cfg "AND{EF{x == 2}}{EF{x==3}}" -json_output 
./function tests/ctl/and_test.c -domain polyhedra -ctl-cfg "AND{AG{AF{n==1}}}{AF{n==0}}" -precondition "n > 0" -json_output 		# TODO: ?
./function tests/ctl/and_test.c -domain polyhedra -ctl-cfg "EG{AF{n==1}}" -precondition "n > 0" -json_output 					# TODO: ?
./function tests/ctl/and_test.c -domain polyhedra -ctl-cfg "AG{EF{n==1}}" -precondition "n > 0" -json_output 					# TODO: ?
./function tests/ctl/and_test.c -domain polyhedra -ctl-cfg "EG{EF{n==1}}" -precondition "n > 0" -json_output 					# TODO: ?
./function tests/ctl/existential_test1.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "2*x <= y+3" -json_output 	# TODO: ?
# ./function tests/ctl/existential_test2.c -domain polyhedra -ctl-cfg "EF{r==1}" -json_output 							# UNKNOWN
./function tests/ctl/existential_test3.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x > 0" -json_output 		# TODO: ?
./function tests/ctl/existential_test3.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x > 0" -ctl_existential_equivalence -json_output 
./function tests/ctl/existential_test3.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x == 2" -joinbwd 3 -json_output 
./function tests/ctl/existential_test4.c -domain polyhedra -ctl-cfg "EF{r==1}" -json_output 
./function tests/ctl/fin_ex.c -domain polyhedra -ctl-cfg "EF{n==1}" -precondition "n > 0" -json_output 							# TODO: ?
./function tests/ctl/fin_ex.c -domain polyhedra -ctl-cfg "EG{EF{n==1}}" -precondition "n > 0" -json_output 						# TODO: ?
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-cfg "AG{AF{x <= -10}}" -joinbwd 6 -json_output 		# TODO: ?
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-cfg "EG{AF{x <= -10}}" -joinbwd 6 -json_output 		# TODO: ?
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-cfg "AG{EF{x <= -10}}" -joinbwd 6 -json_output 		# TODO: ?
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-cfg "EG{EF{x <= -10}}" -joinbwd 6 -json_output 		# TODO: ?
./function tests/ctl/multi_branch_choice.c -domain polyhedra -ctl-cfg "AF{OR{x==4}{x==-4}}" -json_output 
./function tests/ctl/multi_branch_choice.c -domain polyhedra -ctl-cfg "EF{x==-4}" -json_output 
./function tests/ctl/multi_branch_choice.c -domain polyhedra -ctl-cfg "AND{EF{x==4}}{EF{x==-4}}" -json_output 
./function tests/ctl/next.c -domain polyhedra -ctl-cfg "AX{AX{AX{x==0}}}" -precondition "x == 1" -json_output 
./function tests/ctl/or_test.c -domain polyhedra -ctl-cfg "OR{AF{AG{x < -100}}}{AF{x==20}}" -json_output 
./function tests/ctl/or_test.c -domain polyhedra -ctl-cfg "OR{EF{AG{x < -100}}}{AF{x==20}}" -json_output 
./function tests/ctl/or_test.c -domain polyhedra -ctl-cfg "OR{AF{EG{x < -100}}}{AF{x==20}}" -json_output 
./function tests/ctl/or_test.c -domain polyhedra -ctl-cfg "OR{EF{EG{x < -100}}}{AF{x==20}}" -json_output 
./function tests/ctl/potential_termination_1.c -domain polyhedra -ctl-cfg "EF{exit: true}" -json_output 			# TODO: ?
./function tests/ctl/until_existential.c -domain polyhedra -ctl-cfg "EU{x >= y}{x == y}" -precondition "x > y" -json_output 	# TODO: ?
./function tests/ctl/until_existential.c -domain polyhedra -ctl-cfg "EF{AG{x == y}}" -precondition "x > y" -json_output 		# TODO: ?
./function tests/ctl/until_test.c -domain polyhedra -ctl-cfg "AU{x >= y}{x==y}" -precondition "x == y + 20" -json_output 

./function tests/ctl/koskinen/acqrel.c -domain polyhedra -ctl-cfg "AG{OR{A!=1}{AF{R==1}}}" -precondition "A!=1" -ordinals 1 -json_output 
./function tests/ctl/koskinen/acqrel_mod.c -domain polyhedra -ctl-cfg "AG{OR{a!=1}{AF{r==1}}}" -precondition "a!=1" -ordinals 1 -json_output 
#./function tests/ctl/koskinen/fig8-2007.c -domain polyhedra -ctl-cfg "OR{set==0}{AF{unset == 1}}" -json_output 
#./function tests/ctl/koskinen/fig8-2007_mod.c -domain polyhedra -ctl-cfg "OR{set==0}{AF{unset == 1}}" -json_output 
# ./function tests/ctl/koskinen/toylin1.c -domain polyhedra -ctl-cfg "AF{resp > 5}" -precondition "c > 5" -json_output 					# TODO: ?
 ./function tests/ctl/koskinen/win4.c -domain polyhedra -ctl-cfg "AF{AG{WItemsNum >= 1}}" -json_output 										# TODO: ?

./function tests/ctl/ltl_automizer/Bug_NoLoopAtEndForTerminatingPrograms_safe.c -domain polyhedra -ctl-cfg "NOT{AF{ap > 2}}" -precondition "ap == 0" -json_output 
./function tests/ctl/ltl_automizer/PotentialMinimizeSEVPABug.c -domain polyhedra -ctl-cfg "AG{OR{x <= 0}{AF{y == 0}}}" -precondition "x < 0"  -json_output 
./function tests/ctl/ltl_automizer/cav2015.c -domain polyhedra -ctl-cfg "AG{OR{x <= 0}{AF{y == 0}}}" -precondition "x < 0" -json_output 
./function tests/ctl/ltl_automizer/coolant_basis_1_safe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{chainBroken != 1}{AG{chainBroken == 1}}}" -precondition "chainBroken == 0" -json_output 
./function tests/ctl/ltl_automizer/coolant_basis_1_unsafe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{chainBroken != 1}{AG{chainBroken == 1}}}" -precondition "chainBroken == 0" -json_output 		# TODO: not supposed to be true?
./function tests/ctl/ltl_automizer/coolant_basis_2_safe_lifeness.c -domain polyhedra -ctl-cfg "AG{AF{otime < time}}" -json_output 	# TODO: ?
#./function tests/ctl/ltl_automizer/coolant_basis_2_unsafe_lifeness.c -domain polyhedra -ctl-cfg "AG{AF{otime < time}}"  -json_output 	# UNKNOWN
./function tests/ctl/ltl_automizer/coolant_basis_3_safe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{init != 3}{AG{AF{time > otime}}}}" -precondition "init == 0" -json_output 
./function tests/ctl/ltl_automizer/coolant_basis_3_unsafe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{init != 3}{AG{AF{time > otime}}}}" -precondition "init == 0" -json_output 	# TODO: not supposed to be true?
./function tests/ctl/ltl_automizer/coolant_basis_4_safe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{init != 3}{OR{temp <= limit}{AF{AG{chainBroken == 1}}}}}" -precondition "init == 0 && temp < limit" -json_output 
# ./function tests/ctl/ltl_automizer/coolant_basis_4_unsafe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{init != 3}{OR{temp <= limit}{AF{AG{chainBroken == 1}}}}}" -precondition "init == 0 && temp < limit" -json_output 	# TODO: not supposed to be true? + very bad performance 
./function tests/ctl/ltl_automizer/coolant_basis_5_safe_cheat.c -domain polyhedra -ctl-cfg "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" -json_output 	# TODO: ?
./function tests/ctl/ltl_automizer/coolant_basis_5_safe_sfty.c -domain polyhedra -ctl-cfg "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" -json_output 	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_5_unsafe_sfty.c -domain polyhedra -ctl-cfg "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" -json_output 	# UNKNOWN ?
./function tests/ctl/ltl_automizer/coolant_basis_6_safe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" -json_output 	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_6_unsafe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" -json_output 	# UNKNOWN ?
./function tests/ctl/ltl_automizer/nestedRandomLoop_true-valid-ltl.c -domain polyhedra -ctl-cfg "AG{i >= n}" -precondition "i == 1 && n >= 0 && i > n" -json_output 
./function tests/ctl/ltl_automizer/simple-1.c -domain polyhedra -ctl-cfg "AF{x > 10000}" -json_output 
./function tests/ctl/ltl_automizer/simple-2.c -domain polyhedra -ctl-cfg "AF{x > 100}" -json_output 
# ./function tests/ctl/ltl_automizer/someNonterminating.c -domain polyhedra -ctl-cfg "EG{x > 0}" -precondition "x > 0" -json_output 	# TODO: cda?
# ./function tests/ctl/ltl_automizer/timer-intermediate.c -domain polyhedra -ctl-cfg "AG{OR{input_1 >= 1000}{AF{output_1 == 1}}}" -json_output 	# TODO: assume
# ./function tests/ctl/ltl_automizer/timer-simple.c -domain polyhedra -ctl-cfg "NOT{AG{OR{timer_1 != 0}{AF{output_1 == 1}}}}" -json_output 		# TODO: ?
# ./function tests/ctl/ltl_automizer/togglecounter_true-valid-ltl.c -domain polyhedra -ctl-cfg "AG{AND{AF{t == 1}}{AF{t == 0}}}" -json_output 	# TODO: ?
./function tests/ctl/ltl_automizer/toggletoggle_true-valid-ltl.c -domain polyhedra -ctl-cfg "AG{AND{AF{t==1}}{AF{t==0}}}" -precondition "t >= 0" -json_output 

./function tests/ctl/report/test_existential2.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x < 200" -json_output 
./function tests/ctl/report/test_existential3.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x == 2" -json_output 
./function tests/ctl/report/test_existential3.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x > 0" -json_output 
./function tests/ctl/report/test_existential3.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x > 0" -ctl_existential_equivalence -json_output 
./function tests/ctl/report/test_global.c -domain polyhedra -ctl-cfg "AF{AG{y > 0}}" -precondition "x < 10" -json_output 		# TODO: ?
./function tests/ctl/report/test_until.c -domain polyhedra -ctl-cfg "AU{x >= y}{x==y}" -precondition "x >= y" -json_output 

./function tests/ctl/t2_cav13/P25.c -domain polyhedra -ctl-cfg "OR{varC <= 5}{AF{varR > 5}}" -joinbwd 6 -json_output 
# ./function tests/ctl/t2_cav13/P26.c -domain polyhedra -ctl-cfg "OR{varC > 5}{EG{varR <= 5}}" -precondition "varC >= 1" -json_output 	# TODO: may not be possible to fix
./function tests/ctl/t2_cav13/P3.c -domain polyhedra -ctl-cfg "OR{varA != 1}{EF{varR==1}}" -precondition "varA == 0" -json_output 	# TODO: ?
./function tests/ctl/t2_cav13/P3_cheat.c -domain polyhedra -ctl-cfg "OR{varA != 1}{EF{varR==1}}" -precondition "varA == 0" -json_output 
./function tests/ctl/t2_cav13/P4.c -domain polyhedra -ctl-cfg "EF{AND{varA == 1}{AG{varR != 1}}}" -precondition "varN > 0" -json_output 

 ./function tests/ctl/sv_comp/Bangalore_false-no-overflow.c -domain polyhedra -ctl-cfg "EF{x < 0}" -json_output 		# TODO: ?
./function tests/ctl/sv_comp/Bangalore_false-no-overflow.c -domain polyhedra -ctl-cfg "EF{x < 0}" -ctl_existential_equivalence -json_output 
./function tests/ctl/sv_comp/Ex02_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "OR{i >= 5}{AF{exit: true}}" -json_output 
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "AF{AG{i==0}}" -json_output 
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "EF{EG{i==0}}" -json_output 
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "EF{AG{i==0}}" -json_output 
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "AF{EG{i==0}}" -json_output 
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "AF{AND{AF{j >= 21}}{i==100}}" -json_output 	# TODO: ?
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "AF{AND{EF{j >= 21}}{i==100}}" -json_output 	# TODO: ?
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "EF{AND{AF{j >= 21}}{i==100}}" -json_output 	# TODO: ?
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "EF{AND{EF{j >= 21}}{i==100}}" -json_output 	# TODO: ?
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-cfg "AF{AND{x==7}{AF{AG{x==2}}}}" -json_output 
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-cfg "AF{AND{x==7}{AF{EG{x==2}}}}" -json_output 
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-cfg "AF{AND{x==7}{EF{AG{x==2}}}}" -json_output 
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-cfg "AF{AND{x==7}{EF{EG{x==2}}}}" -json_output 
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "AF{AG{j==0}}" -json_output 	# TODO: ?
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "EF{AG{j==0}}" -json_output 	# TODO: ?
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "AF{EG{j==0}}" -json_output 	# TODO: ?
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "EF{EG{j==0}}" -json_output 	# TODO: ?

#### CTL-AST

./function tests/ctl/and_ef_test.c -domain polyhedra -ctl-ast "AND{EF{x == 2}}{EF{x==3}}" -json_output 
./function tests/ctl/and_test.c -domain polyhedra -ctl-ast "AND{AG{AF{n==1}}}{AF{n==0}}" -precondition "n > 0" -json_output 
./function tests/ctl/and_test.c -domain polyhedra -ctl-ast "EG{AF{n==1}}" -precondition "n > 0" -json_output 
./function tests/ctl/and_test.c -domain polyhedra -ctl-ast "AG{EF{n==1}}" -precondition "n > 0" -json_output 
./function tests/ctl/and_test.c -domain polyhedra -ctl-ast "EG{EF{n==1}}" -precondition "n > 0" -json_output 
./function tests/ctl/existential_test1.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "2*x <= y+3" -json_output 
#./function tests/ctl/existential_test2.c -domain polyhedra -ctl-ast "EF{r==1}" -json_output 								# UNKNOWN
./function tests/ctl/existential_test3.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x > 0" -json_output 		# TODO: ?
./function tests/ctl/existential_test3.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x > 0" -ctl_existential_equivalence -json_output 
./function tests/ctl/existential_test3.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x == 2" -joinbwd 3 -json_output 
./function tests/ctl/existential_test4.c -domain polyhedra -ctl-ast "EF{r==1}" -json_output 
./function tests/ctl/fin_ex.c -domain polyhedra -ctl-ast "EF{n==1}" -precondition "n > 0" -json_output 
./function tests/ctl/fin_ex.c -domain polyhedra -ctl-ast "EG{EF{n==1}}" -precondition "n > 0" -json_output 
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-ast "AG{AF{x <= -10}}" -joinbwd 4 -json_output 
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-ast "EG{AF{x <= -10}}" -joinbwd 4 -json_output 
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-ast "AG{EF{x <= -10}}" -joinbwd 4 -json_output 
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-ast "EG{EF{x <= -10}}" -joinbwd 4 -json_output 
./function tests/ctl/multi_branch_choice.c -domain polyhedra -ctl-ast "AF{OR{x==4}{x==-4}}" -json_output 
./function tests/ctl/multi_branch_choice.c -domain polyhedra -ctl-ast "EF{x==-4}" -json_output 
./function tests/ctl/multi_branch_choice.c -domain polyhedra -ctl-ast "AND{EF{x==4}}{EF{x==-4}}" -json_output 
./function tests/ctl/next.c -domain polyhedra -ctl-ast "AX{x==0}" -precondition "x == 1" -json_output 
./function tests/ctl/or_test.c -domain polyhedra -ctl-ast "OR{AF{AG{x < -100}}}{AF{x==20}}" -json_output 
./function tests/ctl/or_test.c -domain polyhedra -ctl-ast "OR{EF{AG{x < -100}}}{AF{x==20}}" -json_output 
./function tests/ctl/or_test.c -domain polyhedra -ctl-ast "OR{AF{EG{x < -100}}}{AF{x==20}}" -json_output 
./function tests/ctl/or_test.c -domain polyhedra -ctl-ast "OR{EF{EG{x < -100}}}{AF{x==20}}" -json_output 
./function tests/ctl/potential_termination_1.c -domain polyhedra -ctl-ast "EF{exit: true}" -json_output 		# TODO: ?
./function tests/ctl/until_existential.c -domain polyhedra -ctl-ast "EU{x >= y}{x == y}" -precondition "x > y" -json_output 
./function tests/ctl/until_existential.c -domain polyhedra -ctl-ast "EF{AG{x == y}}" -precondition "x > y" -json_output 
./function tests/ctl/until_test.c -domain polyhedra -ctl-ast "AU{x >= y}{x==y}" -precondition "x == y + 20" -json_output 

./function tests/ctl/koskinen/acqrel.c -domain polyhedra -ctl-ast "AG{OR{A!=1}{AF{R==1}}}" -precondition "A!=1" -ordinals 1 -json_output 
./function tests/ctl/koskinen/acqrel_mod.c -domain polyhedra -ctl-ast "AG{OR{a!=1}{AF{r==1}}}" -precondition "a!=1" -ordinals 1 -json_output 
# ./function tests/ctl/koskinen/fig8-2007.c -domain polyhedra -ctl-ast "OR{set==0}{AF{unset == 1}}" -json_output 					# TODO: goto support
# ./function tests/ctl/koskinen/fig8-2007_mod.c -domain polyhedra -ctl-ast "OR{set==0}{AF{unset == 1}}" -json_output 			# TODO: goto support
# ./function tests/ctl/koskinen/toylin1.c -domain polyhedra -ctl-ast "AF{resp > 5}" -precondition "c > 5" -json_output 					# TODO: ?
./function tests/ctl/koskinen/win4.c -domain polyhedra -ctl-ast "AF{AG{WItemsNum >= 1}}" -json_output 

./function tests/ctl/ltl_automizer/Bug_NoLoopAtEndForTerminatingPrograms_safe.c -domain polyhedra -ctl-ast "NOT{AF{ap > 2}}" -precondition "ap == 0" -json_output 
./function tests/ctl/ltl_automizer/PotentialMinimizeSEVPABug.c -domain polyhedra -ctl-ast "AG{OR{x <= 0}{AF{y == 0}}}" -precondition "x < 0" -ordinals 1 -json_output 
./function tests/ctl/ltl_automizer/cav2015.c -domain polyhedra -ctl-ast "AG{OR{x <= 0}{AF{y == 0}}}" -precondition "x < 0" -ordinals 1 -json_output 
 ./function tests/ctl/ltl_automizer/coolant_basis_1_safe_sfty.c -domain polyhedra -ctl-ast "AG{OR{chainBroken != 1}{AG{chainBroken == 1}}}" -precondition "chainBroken == 0" -json_output  # TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_1_unsafe_sfty.c -domain polyhedra -ctl-ast "AG{OR{chainBroken != 1}{AG{chainBroken == 1}}}" -precondition "chainBroken == 0" -json_output 		# UNKNOWN?
 ./function tests/ctl/ltl_automizer/coolant_basis_2_safe_lifeness.c -domain polyhedra -ctl-ast "AG{AF{otime < time}}" -json_output 	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_2_unsafe_lifeness.c -domain polyhedra -ctl-ast "AG{AF{otime < time}}" -json_output 	# UNKNOWN
 ./function tests/ctl/ltl_automizer/coolant_basis_3_safe_sfty.c -domain polyhedra -ctl-ast "AG{OR{init != 3}{AG{AF{time > otime}}}}" -precondition "init == 0" -json_output 	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_3_unsafe_sfty.c -domain polyhedra -ctl-ast "AG{OR{init != 3}{AG{AF{time > otime}}}}" -precondition "init == 0" -json_output 	# UNKNOWN?
 ./function tests/ctl/ltl_automizer/coolant_basis_4_safe_sfty.c -domain polyhedra -ctl-ast "AG{OR{init != 3}{OR{temp <= limit}{AF{AG{chainBroken == 1}}}}}" -precondition "init == 0 && temp < limit" -json_output 	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_4_unsafe_sfty.c -domain polyhedra -ctl-ast "AG{OR{init != 3}{OR{temp <= limit}{AF{AG{chainBroken == 1}}}}}" -precondition "init == 0 && temp < limit" -json_output 	# TODO: UNKNOWN? + bad performance 
 ./function tests/ctl/ltl_automizer/coolant_basis_5_safe_cheat.c -domain polyhedra -ctl-ast "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" -json_output 	# TODO: ?
 ./function tests/ctl/ltl_automizer/coolant_basis_5_safe_sfty.c -domain polyhedra -ctl-ast "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" -json_output 	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_5_unsafe_sfty.c -domain polyhedra -ctl-ast "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" -json_output 	# UNKNOWN ?
 ./function tests/ctl/ltl_automizer/coolant_basis_6_safe_sfty.c -domain polyhedra -ctl-ast "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" -json_output 	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_6_unsafe_sfty.c -domain polyhedra -ctl-ast "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" -json_output 	# UNKNOWN ?
./function tests/ctl/ltl_automizer/nestedRandomLoop_true-valid-ltl.c -domain polyhedra -ctl-ast "AG{i >= n}" -precondition "i == 1 && n >= 0 && i > n" -json_output 
./function tests/ctl/ltl_automizer/simple-1.c -domain polyhedra -ctl-ast "AF{x > 10000}" -json_output 
./function tests/ctl/ltl_automizer/simple-2.c -domain polyhedra -ctl-ast "AF{x > 100}" -json_output 
# ./function tests/ctl/ltl_automizer/someNonterminating.c -domain polyhedra -ctl-ast "EG{x > 0}" -precondition "x > 0" -json_output 	# TODO: cda?
# ./function tests/ctl/ltl_automizer/timer-intermediate.c -domain polyhedra -ctl-ast "AG{OR{input_1 >= 1000}{AF{output_1 == 1}}}" -json_output 	# TODO: assume
# ./function tests/ctl/ltl_automizer/timer-simple.c -domain polyhedra -ctl-ast "NOT{AG{OR{timer_1 != 0}{AF{output_1 == 1}}}}" -json_output 		# TODO: ?
# ./function tests/ctl/ltl_automizer/togglecounter_true-valid-ltl.c -domain polyhedra -ctl-ast "AG{AND{AF{t == 1}}{AF{t == 0}}}" -json_output 	# TODO: ?
./function tests/ctl/ltl_automizer/toggletoggle_true-valid-ltl.c -domain polyhedra -ctl-ast "AG{AND{AF{t==1}}{AF{t==0}}}" -precondition "t >= 0" -json_output 

./function tests/ctl/report/test_existential2.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x < 200" -json_output 	# TODO: ?
./function tests/ctl/report/test_existential3.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x == 2" -json_output 		# TODO: ?
./function tests/ctl/report/test_existential3.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x > 0" -json_output 		# TODO: ?
./function tests/ctl/report/test_existential3.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x > 0" -ctl_existential_equivalence -json_output 		# TODO: ?
./function tests/ctl/report/test_global.c -domain polyhedra -ctl-ast "AF{AG{y > 0}}" -precondition "x < 10" -json_output 
./function tests/ctl/report/test_until.c -domain polyhedra -ctl-ast "AU{x >= y}{x==y}" -precondition "x >= y" -json_output 

./function tests/ctl/t2_cav13/P25.c -domain polyhedra -ctl-ast "OR{varC <= 5}{AF{varR > 5}}" -joinbwd 6 -json_output 
# ./function tests/ctl/t2_cav13/P26.c -domain polyhedra -ctl-ast "OR{varC > 5}{EG{varR <= 5}}" -precondition "varC >= 1" -json_output 	# TODO: may not be possible to fix
./function tests/ctl/t2_cav13/P3.c -domain polyhedra -ctl-ast "OR{varA != 1}{EF{varR==1}}" -precondition "varA == 0" -json_output 
./function tests/ctl/t2_cav13/P3_cheat.c -domain polyhedra -ctl-ast "OR{varA != 1}{EF{varR==1}}" -precondition "varA == 0" -json_output 
./function tests/ctl/t2_cav13/P4.c -domain polyhedra -ctl-ast "EF{AND{varA == 1}{AG{varR != 1}}}" -precondition "varN > 0" -json_output 

./function tests/ctl/sv_comp/Bangalore_false-no-overflow.c -domain polyhedra -ctl-ast "EF{x < 0}" -json_output 		# TODO: ?
./function tests/ctl/sv_comp/Bangalore_false-no-overflow.c -domain polyhedra -ctl-ast "EF{x < 0}" -ctl_existential_equivalence -json_output 
./function tests/ctl/sv_comp/Ex02_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "OR{i >= 5}{AF{exit: true}}" -json_output 
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "AF{AG{i==0}}" -json_output 
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "EF{EG{i==0}}" -json_output 
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "EF{AG{i==0}}" -json_output 
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "AF{EG{i==0}}" -json_output 
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-ast "AF{AND{AF{j >= 21}}{i==100}}" -json_output 
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-ast "AF{AND{EF{j >= 21}}{i==100}}" -json_output 
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-ast "EF{AND{AF{j >= 21}}{i==100}}" -json_output 
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-ast "EF{AND{EF{j >= 21}}{i==100}}" -json_output 
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-ast "AF{AND{x==7}{AF{AG{x==2}}}}" -json_output 
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-ast "AF{AND{x==7}{AF{EG{x==2}}}}" -json_output 
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-ast "AF{AND{x==7}{EF{AG{x==2}}}}" -json_output 
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-ast "AF{AND{x==7}{EF{EG{x==2}}}}" -json_output 
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "AF{AG{j==0}}" -json_output 
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "EF{AG{j==0}}" -json_output 
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "AF{EG{j==0}}" -json_output 
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "EF{EG{j==0}}" -json_output 