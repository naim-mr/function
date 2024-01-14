#!/bin/sh

## conditional termination (CFG)

./function tests/termination/euclid.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x == y" > logs/ctl/euclid_1CFG.log					            # TRUE
#./function tests/euclid.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 0 && y > 0" > logs/ctl/euclid_2CFG.log            # TODO: ?
./function tests/termination/example0.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 10" > logs/ctl/example0CFG.log                   # TRUE
#./function tests/example0.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x <= 10 && x % 2 == 1" > logs/ctl/example0CFG.log   # TODO: needs parity domain
./function tests/termination/example5.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 0" -joinbwd 4 > logs/ctl/example5CFG.log         # TRUE
./function tests/termination/example7.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 6" > logs/ctl/example7_1CFG.log	  			        # TRUE
#./function tests/example7.c -domain polyhedra -ctl-cfg "EF{exit: true}" > logs/ctl/example7_2CFG.log				                                # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x + z >= 0" > logs/ctl/issue8_1CFG.log				        # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "y >= 1" > logs/ctl/issue8_2CFG.log				            # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "-2 * y + z >= 0" > logs/ctl/issue8_3CFG.log				    # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "-x >= 2" > logs/ctl/issue8_4CFG.log				            # TODO: ?
./function tests/termination/sas2014a.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "r <= 0" > logs/ctl/sas2014a_1CFG.log				          # TRUE
#./function tests/sas2014a.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x < y" > logs/ctl/sas2014a_2CFG.log				          # TODO: ?
./function tests/termination/sas2014c.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x <= 0" > logs/ctl/sas2014c_1CFG.log				          # TRUE
#./function tests/sas2014c.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "y > 0" > logs/ctl/sas2014c_2CFG.log				          # TODO: ?
./function tests/termination/tap2008a.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x < 25" > logs/ctl/tap2008a_1CFG.log				          # TRUE
./function tests/termination/tap2008a.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 30" > logs/ctl/tap2008a_2CFG.log				          # TRUE
./function tests/termination/tap2008b.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x < -5" > logs/ctl/tap2008b_1CFG.log				          # TRUE
./function tests/termination/tap2008b.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "0 <= x && x <= 30" > logs/ctl/tap2008b_2CFG.log      # TRUE
./function tests/termination/tap2008b.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 35" > logs/ctl/tap2008b_3CFG.log				          # TRUE
./function tests/termination/tap2008c.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x < 30" > logs/ctl/tap2008cCFG.log				            # TRUE
./function tests/termination/tap2008d.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x <= 0" > logs/ctl/tap2008dCFG.log				            # TRUE
./function tests/termination/tap2008e.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x <= 11" > logs/ctl/tap2008d_1CFG.log				        # TRUE
./function tests/termination/tap2008e.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x >= 40" > logs/ctl/tap2008d_2CFG.log				        # TRUE
#./function tests/tap2008f.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x % 2 == 0" > logs/ctl/tap2008d_2CFG.log				    # TODO: needs parity domain
./function tests/termination/vmcai2004b.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x < 3" > logs/ctl/vmcai2004b_1CFG.log				      # TRUE
./function tests/termination/vmcai2004b.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x > 3" -joinbwd 3 > logs/ctl/vmcai2004b_2CFG.log   # TRUE
./function tests/termination/widening3.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "x <= 0" > logs/ctl/widening3_1CFG.log				        # TRUE
#./function tests/widening3.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "y > 0" > logs/ctl/widening3_2CFG.log               # TODO: ?
#./function tests/zune.c -domain polyhedra -ctl-cfg "AF{exit: true}" -precondition "days <= 365" > logs/ctl/zuneCFG.log				              # TODO: call to unknown functions should be approximated with non-determinism

## conditional termination (AST)

./function tests/termination/euclid.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x == y" > logs/ctl/euclid_1AST.log					           # TRUE
#./function tests/euclid.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 0 && y > 0" > logs/ctl/euclid_2AST.log            # TODO: ?
./function tests/termination/example0.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 10" > logs/ctl/example0AST.log                   # TRUE
#./function tests/example0.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x <= 10 && x % 2 == 1" > logs/ctl/example0AST.log   # TODO: needs parity domain
./function tests/termination/example5.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 0" -joinbwd 5 > logs/ctl/example5AST.log         # TRUE
./function tests/termination/example7.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 6" > logs/ctl/example7_1AST.log	  			         # TRUE
#./function tests/example7.c -domain polyhedra -ctl-ast "EF{exit: true}" > logs/ctl/example7_2AST.log				                               # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x + z >= 0" > logs/ctl/issue8_1AST.log				         # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "y >= 1" > logs/ctl/issue8_2AST.log				             # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "-2 * y + z >= 0" > logs/ctl/issue8_3AST.log				   # TODO: ?
#./function tests/issue8.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "-x >= 2" > logs/ctl/issue8_4AST.log				           # TODO: ?
./function tests/termination/sas2014a.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "r <= 0" > logs/ctl/sas2014a_1AST.log				         # TRUE
#./function tests/sas2014a.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x < y" > logs/ctl/sas2014a_2AST.log				         # TODO: ?
./function tests/termination/sas2014c.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x <= 0" > logs/ctl/sas2014c_1AST.log				         # TRUE
#./function tests/sas2014c.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "y > 0" > logs/ctl/sas2014c_2AST.log				         # TODO: ?
./function tests/termination/tap2008a.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x < 25" > logs/ctl/tap2008a_1AST.log				         # TRUE
./function tests/termination/tap2008a.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 30" > logs/ctl/tap2008a_2AST.log				         # TRUE
./function tests/termination/tap2008b.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x < -5" > logs/ctl/tap2008b_1AST.log				         # TRUE
./function tests/termination/tap2008b.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "0 <= x && x <= 30" > logs/ctl/tap2008b_2AST.log      # TRUE
./function tests/termination/tap2008b.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 35" > logs/ctl/tap2008b_3AST.log				         # TRUE
./function tests/termination/tap2008c.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x < 30" > logs/ctl/tap2008cAST.log				           # TRUE
./function tests/termination/tap2008d.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x <= 0" > logs/ctl/tap2008dAST.log				           # TRUE
./function tests/termination/tap2008e.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x <= 11" > logs/ctl/tap2008d_1AST.log				         # TRUE
./function tests/termination/tap2008e.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x >= 40" > logs/ctl/tap2008d_2AST.log				         # TRUE
#./function tests/tap2008f.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x % 2 == 0" > logs/ctl/tap2008d_2AST.log				     # TODO: needs parity domain
./function tests/termination/vmcai2004b.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x < 3" -joinbwd 3 > logs/ctl/vmcai2004b_1AST.log   # TRUE
./function tests/termination/vmcai2004b.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x > 3" -joinbwd 4 > logs/ctl/vmcai2004b_2AST.log   # TRUE
./function tests/termination/widening3.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "x <= 0" > logs/ctl/widening3_1AST.log				       # TRUE
#./function tests/widening3.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "y > 0" > logs/ctl/widening3_2AST.log               # TODO: ?
#./function tests/zune.c -domain polyhedra -ctl-ast "AF{exit: true}" -precondition "days <= 365" > logs/ctl/zuneAST.log				             # TODO: call to unknown functions should be approximated with non-determinism

# conditional guarantee (CFG)

#./function tests/simple.c -ctl-cfg "AF{x == 3}" -domain polyhedra -precondition "x <= 3" > logs/ctl/simple_1CFG.log        # TODO: ?

# conditional guarantee (AST)

./function tests/guarantee/simple.c -ctl-ast "AF{x == 3}" -domain polyhedra -precondition "x <= 3" > logs/ctl/simple_1AST.log    # TRUE

# conditional recurrence (CFG)

# ./function tests/simple.c -ctl-cfg "AG{AF{x == 3}}" -domain polyhedra -joinbwd 3 -precondition "x < 0" > logs/recurrence/simple_2CFG.log      # TODO: ?

# conditional recurrence (AST)

 ./function tests/guarantee/simple.c -ctl-ast "AG{AF{x == 3}}" -domain polyhedra -joinbwd 3 -precondition "x < 0" > logs/ctl/simple_2CFG.log         # TRUE

##########

#### CTL-CFG

./function tests/ctl/and_ef_test.c -domain polyhedra -ctl-cfg "AND{EF{x == 2}}{EF{x==3}}" > logs/ctl/and_ef_testCFG.log
./function tests/ctl/and_test.c -domain polyhedra -ctl-cfg "AND{AG{AF{n==1}}}{AF{n==0}}" -precondition "n > 0" > logs/ctl/and_test_1CFG#TODO.log		# TODO: ?
./function tests/ctl/and_test.c -domain polyhedra -ctl-cfg "EG{AF{n==1}}" -precondition "n > 0" > logs/ctl/and_test_2CFG#TODO.log					# TODO: ?
./function tests/ctl/and_test.c -domain polyhedra -ctl-cfg "AG{EF{n==1}}" -precondition "n > 0" > logs/ctl/and_test_3CFG#TODO.log					# TODO: ?
./function tests/ctl/and_test.c -domain polyhedra -ctl-cfg "EG{EF{n==1}}" -precondition "n > 0" > logs/ctl/and_test_4CFG#TODO.log					# TODO: ?
./function tests/ctl/existential_test1.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "2*x <= y+3" > logs/ctl/existential_test1CFG#TODO.log	# TODO: ?
# ./function tests/ctl/existential_test2.c -domain polyhedra -ctl-cfg "EF{r==1}" > logs/ctl/existential_test2CFG.log							# UNKNOWN
./function tests/ctl/existential_test3.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x > 0" > logs/ctl/existential_test3_1CFG#TODO.log		# TODO: ?
./function tests/ctl/existential_test3.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x > 0" -ctl_existential_equivalence > logs/ctl/existential_test3_1CFG_exeq.log
./function tests/ctl/existential_test3.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x == 2" -joinbwd 3 > logs/ctl/existential_test3_2CFG_join3.log
./function tests/ctl/existential_test4.c -domain polyhedra -ctl-cfg "EF{r==1}" > logs/ctl/existential_test4CFG.log
./function tests/ctl/fin_ex.c -domain polyhedra -ctl-cfg "EF{n==1}" -precondition "n > 0" > logs/ctl/fin_ex_1CFG#TODO.log							# TODO: ?
./function tests/ctl/fin_ex.c -domain polyhedra -ctl-cfg "EG{EF{n==1}}" -precondition "n > 0" > logs/ctl/fin_ex_2CFG#TODO.log						# TODO: ?
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-cfg "AG{AF{x <= -10}}" -joinbwd 6 > logs/ctl/global_test_simple_1CFG#TODO.log		# TODO: ?
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-cfg "EG{AF{x <= -10}}" -joinbwd 6 > logs/ctl/global_test_simple_2CFG#TODO.log		# TODO: ?
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-cfg "AG{EF{x <= -10}}" -joinbwd 6 > logs/ctl/global_test_simple_3CFG#TODO.log		# TODO: ?
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-cfg "EG{EF{x <= -10}}" -joinbwd 6 > logs/ctl/global_test_simple_4CFG#TODO.log		# TODO: ?
./function tests/ctl/multi_branch_choice.c -domain polyhedra -ctl-cfg "AF{OR{x==4}{x==-4}}" > logs/ctl/multi_branch_choice_1CFG.log
./function tests/ctl/multi_branch_choice.c -domain polyhedra -ctl-cfg "EF{x==-4}" > logs/ctl/multi_branch_choice_2CFG.log
./function tests/ctl/multi_branch_choice.c -domain polyhedra -ctl-cfg "AND{EF{x==4}}{EF{x==-4}}" > logs/ctl/multi_branch_choice_3CFG.log
./function tests/ctl/next.c -domain polyhedra -ctl-cfg "AX{AX{AX{x==0}}}" -precondition "x == 1" > logs/ctl/nextCFG.log
./function tests/ctl/or_test.c -domain polyhedra -ctl-cfg "OR{AF{AG{x < -100}}}{AF{x==20}}" > logs/ctl/or_test_1CFG.log
./function tests/ctl/or_test.c -domain polyhedra -ctl-cfg "OR{EF{AG{x < -100}}}{AF{x==20}}" > logs/ctl/or_test_2CFG.log
./function tests/ctl/or_test.c -domain polyhedra -ctl-cfg "OR{AF{EG{x < -100}}}{AF{x==20}}" > logs/ctl/or_test_3CFG.log
./function tests/ctl/or_test.c -domain polyhedra -ctl-cfg "OR{EF{EG{x < -100}}}{AF{x==20}}" > logs/ctl/or_test_4CFG.log
./function tests/ctl/potential_termination_1.c -domain polyhedra -ctl-cfg "EF{exit: true}" > logs/ctl/potential_termination_1CFG#TODO.log			# TODO: ?
./function tests/ctl/until_existential.c -domain polyhedra -ctl-cfg "EU{x >= y}{x == y}" -precondition "x > y" > logs/ctl/until_existential_1CFG#TODO.log	# TODO: ?
./function tests/ctl/until_existential.c -domain polyhedra -ctl-cfg "EF{AG{x == y}}" -precondition "x > y" > logs/ctl/until_existential_2CFG#TODO.log		# TODO: ?
./function tests/ctl/until_test.c -domain polyhedra -ctl-cfg "AU{x >= y}{x==y}" -precondition "x == y + 20" > logs/ctl/until_testCFG.log

./function tests/ctl/koskinen/acqrel.c -domain polyhedra -ctl-cfg "AG{OR{A!=1}{AF{R==1}}}" -precondition "A!=1" -ordinals 1 > logs/ctl/acqrelCFG.log
./function tests/ctl/koskinen/acqrel_mod.c -domain polyhedra -ctl-cfg "AG{OR{a!=1}{AF{r==1}}}" -precondition "a!=1" -ordinals 1 > logs/ctl/acqrel_modCFG.log
./function tests/ctl/koskinen/fig8-2007.c -domain polyhedra -ctl-cfg "OR{set==0}{AF{unset == 1}}" > logs/ctl/fig8-2007CFG.log
./function tests/ctl/koskinen/fig8-2007_mod.c -domain polyhedra -ctl-cfg "OR{set==0}{AF{unset == 1}}" > logs/ctl/fig8-2007_modCFG.log
# ./function tests/ctl/koskinen/toylin1.c -domain polyhedra -ctl-cfg "AF{resp > 5}" -precondition "c > 5" > logs/ctl/toylin1CFG.log					# TODO: ?
 ./function tests/ctl/koskinen/win4.c -domain polyhedra -ctl-cfg "AF{AG{WItemsNum >= 1}}" > logs/ctl/win4CFG#TODO.log										# TODO: ?

./function tests/ctl/ltl_automizer/Bug_NoLoopAtEndForTerminatingPrograms_safe.c -domain polyhedra -ctl-cfg "NOT{AF{ap > 2}}" -precondition "ap == 0" > logs/ctl/Bug_NoLoopAtEndForTerminatingPrograms_safeCFG.log
./function tests/ctl/ltl_automizer/PotentialMinimizeSEVPABug.c -domain polyhedra -ctl-cfg "AG{OR{x <= 0}{AF{y == 0}}}" -precondition "x < 0"  > logs/ctl/PotentialMinimizeSEVPABugCFG.log
./function tests/ctl/ltl_automizer/cav2015.c -domain polyhedra -ctl-cfg "AG{OR{x <= 0}{AF{y == 0}}}" -precondition "x < 0" > logs/ctl/cav2015CFG.log
./function tests/ctl/ltl_automizer/coolant_basis_1_safe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{chainBroken != 1}{AG{chainBroken == 1}}}" -precondition "chainBroken == 0" > logs/ctl/coolant_basis_1_safe_sftyCFG.log
./function tests/ctl/ltl_automizer/coolant_basis_1_unsafe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{chainBroken != 1}{AG{chainBroken == 1}}}" -precondition "chainBroken == 0" > logs/ctl/coolant_basis_1_unsafe_sftyCFG#FIX.log		# TODO: not supposed to be true?
./function tests/ctl/ltl_automizer/coolant_basis_2_safe_lifeness.c -domain polyhedra -ctl-cfg "AG{AF{otime < time}}" > logs/ctl/coolant_basis_2_safe_lifenessCFG#TODO.log	# TODO: ?
#./function tests/ctl/ltl_automizer/coolant_basis_2_unsafe_lifeness.c -domain polyhedra -ctl-cfg "AG{AF{otime < time}}"  > logs/ctl/coolant_basis_2_unsafe_lifenessCFG.log	# UNKNOWN
./function tests/ctl/ltl_automizer/coolant_basis_3_safe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{init != 3}{AG{AF{time > otime}}}}" -precondition "init == 0" > logs/ctl/coolant_basis_3_safe_sftyCFG.log
./function tests/ctl/ltl_automizer/coolant_basis_3_unsafe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{init != 3}{AG{AF{time > otime}}}}" -precondition "init == 0" > logs/ctl/coolant_basis_3_unsafe_sftyCFG#FIX.log	# TODO: not supposed to be true?
./function tests/ctl/ltl_automizer/coolant_basis_4_safe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{init != 3}{OR{temp <= limit}{AF{AG{chainBroken == 1}}}}}" -precondition "init == 0 && temp < limit" > logs/ctl/coolant_basis_4_safe_sftyCFG.log
# ./function tests/ctl/ltl_automizer/coolant_basis_4_unsafe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{init != 3}{OR{temp <= limit}{AF{AG{chainBroken == 1}}}}}" -precondition "init == 0 && temp < limit" > logs/ctl/coolant_basis_4_unsafe_sftyCFG.log	# TODO: not supposed to be true? + very bad performance 
./function tests/ctl/ltl_automizer/coolant_basis_5_safe_cheat.c -domain polyhedra -ctl-cfg "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" > logs/ctl/coolant_basis_5_safe_cheatCFG#TODO.log	# TODO: ?
./function tests/ctl/ltl_automizer/coolant_basis_5_safe_sfty.c -domain polyhedra -ctl-cfg "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" > logs/ctl/coolant_basis_5_safe_sftyCFG#TODO.log	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_5_unsafe_sfty.c -domain polyhedra -ctl-cfg "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" > logs/ctl/coolant_basis_5_unsafe_sftyCFG.log	# UNKNOWN ?
./function tests/ctl/ltl_automizer/coolant_basis_6_safe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" > logs/ctl/coolant_basis_6_safe_sftyCFG#TODO.log	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_6_unsafe_sfty.c -domain polyhedra -ctl-cfg "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" > logs/ctl/coolant_basis_6_unsafe_sftyCFG.log	# UNKNOWN ?
./function tests/ctl/ltl_automizer/nestedRandomLoop_true-valid-ltl.c -domain polyhedra -ctl-cfg "AG{i >= n}" -precondition "i == 1 && n >= 0 && i > n" > logs/ctl/nestedRandomLoop_true-valid-ltlCFG.log
./function tests/ctl/ltl_automizer/simple-1.c -domain polyhedra -ctl-cfg "AF{x > 10000}" > logs/ctl/simple-1CFG.log
./function tests/ctl/ltl_automizer/simple-2.c -domain polyhedra -ctl-cfg "AF{x > 100}" > logs/ctl/simple-2CFG.log
# ./function tests/ctl/ltl_automizer/someNonterminating.c -domain polyhedra -ctl-cfg "EG{x > 0}" -precondition "x > 0" > logs/ctl/someNonterminatingCFG.log	# TODO: cda?
# ./function tests/ctl/ltl_automizer/timer-intermediate.c -domain polyhedra -ctl-cfg "AG{OR{input_1 >= 1000}{AF{output_1 == 1}}}" > logs/ctl/timer-intermediateCFG.log	# TODO: assume
# ./function tests/ctl/ltl_automizer/timer-simple.c -domain polyhedra -ctl-cfg "NOT{AG{OR{timer_1 != 0}{AF{output_1 == 1}}}}" > logs/ctl/timer-simpleCFG.log		# TODO: ?
# ./function tests/ctl/ltl_automizer/togglecounter_true-valid-ltl.c -domain polyhedra -ctl-cfg "AG{AND{AF{t == 1}}{AF{t == 0}}}" > logs/ctl/togglecounter_true-valid-ltlCFG.log	# TODO: ?
./function tests/ctl/ltl_automizer/toggletoggle_true-valid-ltl.c -domain polyhedra -ctl-cfg "AG{AND{AF{t==1}}{AF{t==0}}}" -precondition "t >= 0" > logs/ctl/toggletoggle_true-valid-ltlCFG.log

./function tests/ctl/report/test_existential2.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x < 200" > logs/ctl/test_existential2CFG.log
./function tests/ctl/report/test_existential3.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x == 2" > logs/ctl/test_existential3_1CFG.log
./function tests/ctl/report/test_existential3.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x > 0" > logs/ctl/test_existential3_2CFG#TODO.log
./function tests/ctl/report/test_existential3.c -domain polyhedra -ctl-cfg "EF{r==1}" -precondition "x > 0" -ctl_existential_equivalence > logs/ctl/test_existential3_2CFG_exeq.log
./function tests/ctl/report/test_global.c -domain polyhedra -ctl-cfg "AF{AG{y > 0}}" -precondition "x < 10" > logs/ctl/test_globalCFG#TODO.log		# TODO: ?
./function tests/ctl/report/test_until.c -domain polyhedra -ctl-cfg "AU{x >= y}{x==y}" -precondition "x >= y" > logs/ctl/test_untilCFG.log

./function tests/ctl/t2_cav13/P25.c -domain polyhedra -ctl-cfg "OR{varC <= 5}{AF{varR > 5}}" -joinbwd 6 > logs/ctl/P25CFG.log
# ./function tests/ctl/t2_cav13/P26.c -domain polyhedra -ctl-cfg "OR{varC > 5}{EG{varR <= 5}}" -precondition "varC >= 1" > logs/ctl/P25CFG.log	# TODO: may not be possible to fix
./function tests/ctl/t2_cav13/P3.c -domain polyhedra -ctl-cfg "OR{varA != 1}{EF{varR==1}}" -precondition "varA == 0" > logs/ctl/P3CFG#TODO.log	# TODO: ?
./function tests/ctl/t2_cav13/P3_cheat.c -domain polyhedra -ctl-cfg "OR{varA != 1}{EF{varR==1}}" -precondition "varA == 0" > logs/ctl/P3_cheatCFG.log
./function tests/ctl/t2_cav13/P4.c -domain polyhedra -ctl-cfg "EF{AND{varA == 1}{AG{varR != 1}}}" -precondition "varN > 0" > logs/ctl/P4CFG.log

 ./function tests/ctl/sv_comp/Bangalore_false-no-overflow.c -domain polyhedra -ctl-cfg "EF{x < 0}" > logs/ctl/Bangalore_false-no-overflowCFG#TODO.log		# TODO: ?
./function tests/ctl/sv_comp/Bangalore_false-no-overflow.c -domain polyhedra -ctl-cfg "EF{x < 0}" -ctl_existential_equivalence > logs/ctl/Bangalore_false-no-overflowCFG_exeq.log
./function tests/ctl/sv_comp/Ex02_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "OR{i >= 5}{AF{exit: true}}" > logs/ctl/Ex02_false-termination_true-no-overflowCFG.log
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "AF{AG{i==0}}" > logs/ctl/Ex07_false-termination_true-no-overflow_1CFG.log
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "EF{EG{i==0}}" > logs/ctl/Ex07_false-termination_true-no-overflow_2CFG.log
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "EF{AG{i==0}}" > logs/ctl/Ex07_false-termination_true-no-overflow_3CFG.log
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "AF{EG{i==0}}" > logs/ctl/Ex07_false-termination_true-no-overflow_4CFG.log
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "AF{AND{AF{j >= 21}}{i==100}}" > logs/ctl/java_Sequence_true-termination_true-no-overflow_1CFG#TODO.log	# TODO: ?
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "AF{AND{EF{j >= 21}}{i==100}}" > logs/ctl/java_Sequence_true-termination_true-no-overflow_2CFG#TODO.log	# TODO: ?
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "EF{AND{AF{j >= 21}}{i==100}}" > logs/ctl/java_Sequence_true-termination_true-no-overflow_3CFG#TODO.log	# TODO: ?
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "EF{AND{EF{j >= 21}}{i==100}}" > logs/ctl/java_Sequence_true-termination_true-no-overflow_4CFG#TODO.log	# TODO: ?
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-cfg "AF{AND{x==7}{AF{AG{x==2}}}}" > logs/ctl/Madrid_true-no-overflow_false-termination_true-valid-memsafety_1CFG.log
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-cfg "AF{AND{x==7}{AF{EG{x==2}}}}" > logs/ctl/Madrid_true-no-overflow_false-termination_true-valid-memsafety_2CFG.log
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-cfg "AF{AND{x==7}{EF{AG{x==2}}}}" > logs/ctl/Madrid_true-no-overflow_false-termination_true-valid-memsafety_3CFG.log
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-cfg "AF{AND{x==7}{EF{EG{x==2}}}}" > logs/ctl/Madrid_true-no-overflow_false-termination_true-valid-memsafety_4CFG.log
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "AF{AG{j==0}}" > logs/ctl/NO_02_false-termination_true-no-overflow_1CFG#TODO.log	# TODO: ?
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "EF{AG{j==0}}" > logs/ctl/NO_02_false-termination_true-no-overflow_2CFG#TODO.log	# TODO: ?
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "AF{EG{j==0}}" > logs/ctl/NO_02_false-termination_true-no-overflow_3CFG#TODO.log	# TODO: ?
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-cfg "EF{EG{j==0}}" > logs/ctl/NO_02_false-termination_true-no-overflow_4CFG#TODO.log	# TODO: ?

#### CTL-AST

./function tests/ctl/and_ef_test.c -domain polyhedra -ctl-ast "AND{EF{x == 2}}{EF{x==3}}" > logs/ctl/and_ef_testAST.log
./function tests/ctl/and_test.c -domain polyhedra -ctl-ast "AND{AG{AF{n==1}}}{AF{n==0}}" -precondition "n > 0" > logs/ctl/and_test_1AST.log
./function tests/ctl/and_test.c -domain polyhedra -ctl-ast "EG{AF{n==1}}" -precondition "n > 0" > logs/ctl/and_test_2AST.log
./function tests/ctl/and_test.c -domain polyhedra -ctl-ast "AG{EF{n==1}}" -precondition "n > 0" > logs/ctl/and_test_3AST.log
./function tests/ctl/and_test.c -domain polyhedra -ctl-ast "EG{EF{n==1}}" -precondition "n > 0" > logs/ctl/and_test_4AST.log
./function tests/ctl/existential_test1.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "2*x <= y+3" > logs/ctl/existential_test1AST.log
#./function tests/ctl/existential_test2.c -domain polyhedra -ctl-ast "EF{r==1}" > logs/ctl/existential_test2AST.log								# UNKNOWN
./function tests/ctl/existential_test3.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x > 0" > logs/ctl/existential_test3_1AST#TODO.log		# TODO: ?
./function tests/ctl/existential_test3.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x > 0" -ctl_existential_equivalence > logs/ctl/existential_test3_1AST_exeq.log
./function tests/ctl/existential_test3.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x == 2" -joinbwd 3 > logs/ctl/existential_test3_2AST_join3.log
./function tests/ctl/existential_test4.c -domain polyhedra -ctl-ast "EF{r==1}" > logs/ctl/existential_test4AST.log
./function tests/ctl/fin_ex.c -domain polyhedra -ctl-ast "EF{n==1}" -precondition "n > 0" > logs/ctl/fin_ex_1AST.log
./function tests/ctl/fin_ex.c -domain polyhedra -ctl-ast "EG{EF{n==1}}" -precondition "n > 0" > logs/ctl/fin_ex_2AST.log
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-ast "AG{AF{x <= -10}}" -joinbwd 4 > logs/ctl/global_test_simple_1AST.log
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-ast "EG{AF{x <= -10}}" -joinbwd 4 > logs/ctl/global_test_simple_2AST.log
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-ast "AG{EF{x <= -10}}" -joinbwd 4 > logs/ctl/global_test_simple_3AST.log
./function tests/ctl/global_test_simple.c -domain polyhedra -ctl-ast "EG{EF{x <= -10}}" -joinbwd 4 > logs/ctl/global_test_simple_4AST.log
./function tests/ctl/multi_branch_choice.c -domain polyhedra -ctl-ast "AF{OR{x==4}{x==-4}}" > logs/ctl/multi_branch_choice_1AST.log
./function tests/ctl/multi_branch_choice.c -domain polyhedra -ctl-ast "EF{x==-4}" > logs/ctl/multi_branch_choice_2AST.log
./function tests/ctl/multi_branch_choice.c -domain polyhedra -ctl-ast "AND{EF{x==4}}{EF{x==-4}}" > logs/ctl/multi_branch_choice_3AST.log
./function tests/ctl/next.c -domain polyhedra -ctl-ast "AX{x==0}" -precondition "x == 1" > logs/ctl/nextAST.log
./function tests/ctl/or_test.c -domain polyhedra -ctl-ast "OR{AF{AG{x < -100}}}{AF{x==20}}" > logs/ctl/or_test_1AST.log
./function tests/ctl/or_test.c -domain polyhedra -ctl-ast "OR{EF{AG{x < -100}}}{AF{x==20}}" > logs/ctl/or_test_2AST.log
./function tests/ctl/or_test.c -domain polyhedra -ctl-ast "OR{AF{EG{x < -100}}}{AF{x==20}}" > logs/ctl/or_test_3AST.log
./function tests/ctl/or_test.c -domain polyhedra -ctl-ast "OR{EF{EG{x < -100}}}{AF{x==20}}" > logs/ctl/or_test_4AST.log
./function tests/ctl/potential_termination_1.c -domain polyhedra -ctl-ast "EF{exit: true}" > logs/ctl/potential_termination_1AST#TODO.log		# TODO: ?
./function tests/ctl/until_existential.c -domain polyhedra -ctl-ast "EU{x >= y}{x == y}" -precondition "x > y" > logs/ctl/until_existential_1AST.log
./function tests/ctl/until_existential.c -domain polyhedra -ctl-ast "EF{AG{x == y}}" -precondition "x > y" > logs/ctl/until_existential_2AST.log
./function tests/ctl/until_test.c -domain polyhedra -ctl-ast "AU{x >= y}{x==y}" -precondition "x == y + 20" > logs/ctl/until_testAST.log

./function tests/ctl/koskinen/acqrel.c -domain polyhedra -ctl-ast "AG{OR{A!=1}{AF{R==1}}}" -precondition "A!=1" -ordinals 1 > logs/ctl/acqrelAST.log
./function tests/ctl/koskinen/acqrel_mod.c -domain polyhedra -ctl-ast "AG{OR{a!=1}{AF{r==1}}}" -precondition "a!=1" -ordinals 1 > logs/ctl/acqrel_modAST.log
# ./function tests/ctl/koskinen/fig8-2007.c -domain polyhedra -ctl-ast "OR{set==0}{AF{unset == 1}}" > logs/ctl/fig8-2007AST.log					# TODO: goto support
# ./function tests/ctl/koskinen/fig8-2007_mod.c -domain polyhedra -ctl-ast "OR{set==0}{AF{unset == 1}}" > logs/ctl/fig8-2007_modAST.log			# TODO: goto support
# ./function tests/ctl/koskinen/toylin1.c -domain polyhedra -ctl-ast "AF{resp > 5}" -precondition "c > 5" > logs/ctl/toylin1AST.log					# TODO: ?
./function tests/ctl/koskinen/win4.c -domain polyhedra -ctl-ast "AF{AG{WItemsNum >= 1}}" > logs/ctl/win4AST.log

./function tests/ctl/ltl_automizer/Bug_NoLoopAtEndForTerminatingPrograms_safe.c -domain polyhedra -ctl-ast "NOT{AF{ap > 2}}" -precondition "ap == 0" > logs/ctl/Bug_NoLoopAtEndForTerminatingPrograms_safeAST.log
./function tests/ctl/ltl_automizer/PotentialMinimizeSEVPABug.c -domain polyhedra -ctl-ast "AG{OR{x <= 0}{AF{y == 0}}}" -precondition "x < 0" -ordinals 1 > logs/ctl/PotentialMinimizeSEVPABugAST.log
./function tests/ctl/ltl_automizer/cav2015.c -domain polyhedra -ctl-ast "AG{OR{x <= 0}{AF{y == 0}}}" -precondition "x < 0" -ordinals 1 > logs/ctl/cav2015AST.log
 ./function tests/ctl/ltl_automizer/coolant_basis_1_safe_sfty.c -domain polyhedra -ctl-ast "AG{OR{chainBroken != 1}{AG{chainBroken == 1}}}" -precondition "chainBroken == 0" > logs/ctl/coolant_basis_1_safe_sftyAST#TODO.log # TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_1_unsafe_sfty.c -domain polyhedra -ctl-ast "AG{OR{chainBroken != 1}{AG{chainBroken == 1}}}" -precondition "chainBroken == 0" > logs/ctl/coolant_basis_1_unsafe_sftyAST.log		# UNKNOWN?
 ./function tests/ctl/ltl_automizer/coolant_basis_2_safe_lifeness.c -domain polyhedra -ctl-ast "AG{AF{otime < time}}" > logs/ctl/coolant_basis_2_safe_lifenessAST#TODO.log	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_2_unsafe_lifeness.c -domain polyhedra -ctl-ast "AG{AF{otime < time}}" > logs/ctl/coolant_basis_2_unsafe_lifenessAST.log	# UNKNOWN
 ./function tests/ctl/ltl_automizer/coolant_basis_3_safe_sfty.c -domain polyhedra -ctl-ast "AG{OR{init != 3}{AG{AF{time > otime}}}}" -precondition "init == 0" > logs/ctl/coolant_basis_3_safe_sftyAST#TODO.log	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_3_unsafe_sfty.c -domain polyhedra -ctl-ast "AG{OR{init != 3}{AG{AF{time > otime}}}}" -precondition "init == 0" > logs/ctl/coolant_basis_3_unsafe_sftyAST.log	# UNKNOWN?
 ./function tests/ctl/ltl_automizer/coolant_basis_4_safe_sfty.c -domain polyhedra -ctl-ast "AG{OR{init != 3}{OR{temp <= limit}{AF{AG{chainBroken == 1}}}}}" -precondition "init == 0 && temp < limit" > logs/ctl/coolant_basis_4_safe_sftyAST#TODO.log	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_4_unsafe_sfty.c -domain polyhedra -ctl-ast "AG{OR{init != 3}{OR{temp <= limit}{AF{AG{chainBroken == 1}}}}}" -precondition "init == 0 && temp < limit" > logs/ctl/coolant_basis_4_unsafe_sftyAST.log	# TODO: UNKNOWN? + bad performance 
 ./function tests/ctl/ltl_automizer/coolant_basis_5_safe_cheat.c -domain polyhedra -ctl-ast "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" > logs/ctl/coolant_basis_5_safe_cheatAST#TODO.log	# TODO: ?
 ./function tests/ctl/ltl_automizer/coolant_basis_5_safe_sfty.c -domain polyhedra -ctl-ast "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" > logs/ctl/coolant_basis_5_safe_sftyAST#TODO.log	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_5_unsafe_sfty.c -domain polyhedra -ctl-ast "AU{init == 0}{OR{AU{init == 1}{AG{init == 3}}}{AG{init == 1}}}" -precondition "init == 0" > logs/ctl/coolant_basis_5_unsafe_sftyAST.log	# UNKNOWN ?
 ./function tests/ctl/ltl_automizer/coolant_basis_6_safe_sfty.c -domain polyhedra -ctl-ast "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" > logs/ctl/coolant_basis_6_safe_sftyAST#TODO.log	# TODO: ?
# ./function tests/ctl/ltl_automizer/coolant_basis_6_unsafe_sfty.c -domain polyhedra -ctl-ast "AG{OR{limit <= -273 && limit >= 10}{OR{tempIn >= 0}{AF{ warnLED == 1}}}}" -precondition "init == 0 && temp < limit" > logs/ctl/coolant_basis_6_unsafe_sftyAST.log	# UNKNOWN ?
./function tests/ctl/ltl_automizer/nestedRandomLoop_true-valid-ltl.c -domain polyhedra -ctl-ast "AG{i >= n}" -precondition "i == 1 && n >= 0 && i > n" > logs/ctl/nestedRandomLoop_true-valid-ltlAST.log
./function tests/ctl/ltl_automizer/simple-1.c -domain polyhedra -ctl-ast "AF{x > 10000}" > logs/ctl/simple-1AST.log
./function tests/ctl/ltl_automizer/simple-2.c -domain polyhedra -ctl-ast "AF{x > 100}" > logs/ctl/simple-2AST.log
# ./function tests/ctl/ltl_automizer/someNonterminating.c -domain polyhedra -ctl-ast "EG{x > 0}" -precondition "x > 0" > logs/ctl/someNonterminatingAST.log	# TODO: cda?
# ./function tests/ctl/ltl_automizer/timer-intermediate.c -domain polyhedra -ctl-ast "AG{OR{input_1 >= 1000}{AF{output_1 == 1}}}" > logs/ctl/timer-intermediateAST.log	# TODO: assume
# ./function tests/ctl/ltl_automizer/timer-simple.c -domain polyhedra -ctl-ast "NOT{AG{OR{timer_1 != 0}{AF{output_1 == 1}}}}" > logs/ctl/timer-simpleAST.log		# TODO: ?
# ./function tests/ctl/ltl_automizer/togglecounter_true-valid-ltl.c -domain polyhedra -ctl-ast "AG{AND{AF{t == 1}}{AF{t == 0}}}" > logs/ctl/togglecounter_true-valid-ltlAST.log	# TODO: ?
./function tests/ctl/ltl_automizer/toggletoggle_true-valid-ltl.c -domain polyhedra -ctl-ast "AG{AND{AF{t==1}}{AF{t==0}}}" -precondition "t >= 0" > logs/ctl/toggletoggle_true-valid-ltlAST.log

./function tests/ctl/report/test_existential2.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x < 200" > logs/ctl/test_existential2AST#TODO.log	# TODO: ?
./function tests/ctl/report/test_existential3.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x == 2" > logs/ctl/test_existential3_1AST#TODO.log		# TODO: ?
./function tests/ctl/report/test_existential3.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x > 0" > logs/ctl/test_existential3_2AST#TODO.log		# TODO: ?
./function tests/ctl/report/test_existential3.c -domain polyhedra -ctl-ast "EF{r==1}" -precondition "x > 0" -ctl_existential_equivalence > logs/ctl/test_existential3_2AST_exeq#TODO.log		# TODO: ?
./function tests/ctl/report/test_global.c -domain polyhedra -ctl-ast "AF{AG{y > 0}}" -precondition "x < 10" > logs/ctl/test_globalAST.log
./function tests/ctl/report/test_until.c -domain polyhedra -ctl-ast "AU{x >= y}{x==y}" -precondition "x >= y" > logs/ctl/test_untilAST.log

./function tests/ctl/t2_cav13/P25.c -domain polyhedra -ctl-ast "OR{varC <= 5}{AF{varR > 5}}" -joinbwd 6 > logs/ctl/P25AST.log
# ./function tests/ctl/t2_cav13/P26.c -domain polyhedra -ctl-ast "OR{varC > 5}{EG{varR <= 5}}" -precondition "varC >= 1" > logs/ctl/P25AST.log	# TODO: may not be possible to fix
./function tests/ctl/t2_cav13/P3.c -domain polyhedra -ctl-ast "OR{varA != 1}{EF{varR==1}}" -precondition "varA == 0" > logs/ctl/P3AST.log
./function tests/ctl/t2_cav13/P3_cheat.c -domain polyhedra -ctl-ast "OR{varA != 1}{EF{varR==1}}" -precondition "varA == 0" > logs/ctl/P3_cheatAST.log
./function tests/ctl/t2_cav13/P4.c -domain polyhedra -ctl-ast "EF{AND{varA == 1}{AG{varR != 1}}}" -precondition "varN > 0" > logs/ctl/P4AST.log

./function tests/ctl/sv_comp/Bangalore_false-no-overflow.c -domain polyhedra -ctl-ast "EF{x < 0}" > logs/ctl/Bangalore_false-no-overflowAST#TODO.log		# TODO: ?
./function tests/ctl/sv_comp/Bangalore_false-no-overflow.c -domain polyhedra -ctl-ast "EF{x < 0}" -ctl_existential_equivalence > logs/ctl/Bangalore_false-no-overflowAST_exeq.log
./function tests/ctl/sv_comp/Ex02_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "OR{i >= 5}{AF{exit: true}}" > logs/ctl/Ex02_false-termination_true-no-overflowAST.log
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "AF{AG{i==0}}" > logs/ctl/Ex07_false-termination_true-no-overflow_1AST.log
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "EF{EG{i==0}}" > logs/ctl/Ex07_false-termination_true-no-overflow_2AST.log
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "EF{AG{i==0}}" > logs/ctl/Ex07_false-termination_true-no-overflow_3AST.log
./function tests/ctl/sv_comp/Ex07_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "AF{EG{i==0}}" > logs/ctl/Ex07_false-termination_true-no-overflow_4AST.log
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-ast "AF{AND{AF{j >= 21}}{i==100}}" > logs/ctl/java_Sequence_true-termination_true-no-overflow_1AST.log
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-ast "AF{AND{EF{j >= 21}}{i==100}}" > logs/ctl/java_Sequence_true-termination_true-no-overflow_2AST.log
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-ast "EF{AND{AF{j >= 21}}{i==100}}" > logs/ctl/java_Sequence_true-termination_true-no-overflow_3AST.log
./function tests/ctl/sv_comp/java_Sequence_true-termination_true-no-overflow.c -domain polyhedra -ctl-ast "EF{AND{EF{j >= 21}}{i==100}}" > logs/ctl/java_Sequence_true-termination_true-no-overflow_4AST.log
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-ast "AF{AND{x==7}{AF{AG{x==2}}}}" > logs/ctl/Madrid_true-no-overflow_false-termination_true-valid-memsafety_1AST.log
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-ast "AF{AND{x==7}{AF{EG{x==2}}}}" > logs/ctl/Madrid_true-no-overflow_false-termination_true-valid-memsafety_2AST.log
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-ast "AF{AND{x==7}{EF{AG{x==2}}}}" > logs/ctl/Madrid_true-no-overflow_false-termination_true-valid-memsafety_3AST.log
./function tests/ctl/sv_comp/Madrid_true-no-overflow_false-termination_true-valid-memsafety.c -domain polyhedra -ctl-ast "AF{AND{x==7}{EF{EG{x==2}}}}" > logs/ctl/Madrid_true-no-overflow_false-termination_true-valid-memsafety_4AST.log
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "AF{AG{j==0}}" > logs/ctl/NO_02_false-termination_true-no-overflow_1AST.log
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "EF{AG{j==0}}" > logs/ctl/NO_02_false-termination_true-no-overflow_2AST.log
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "AF{EG{j==0}}" > logs/ctl/NO_02_false-termination_true-no-overflow_3AST.log
./function tests/ctl/sv_comp/NO_02_false-termination_true-no-overflow.c -domain polyhedra -ctl-ast "EF{EG{j==0}}" > logs/ctl/NO_02_false-termination_true-no-overflow_4AST.log