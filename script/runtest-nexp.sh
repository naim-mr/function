#!/bin/bash
declare -A optmap=( ["ctl"]="-ctl " ["termination"]="-termination"  ["robust_reachability"]="-ctl")
RED="\e[91m"
GREEN="\e[92m"
BOLD="\e[1m"
RESET="\e[0m"
BLUE="\e[94m"
fill="                                                     "
list=( 
  #"-domain polyhedra -refine -vulnerability" 
  "-domain boxes -refine -resilience" 
  "-domain boxes -refine"
  "-domain boxes -ordinals 3  -refine -resilience" 
  "-domain boxes -ordinals 3 -refine"
  "-domain polyhedra -refine -resilience" 
  "-domain polyhedra -refine"
  "-domain polyhedra -ordinals 3  -refine -resilience" 
  "-domain polyhedra -ordinals 3 -refine"
  #"-domain polyhedra -joinbwd 5 -refine -resilience" 
  #"-domain polyhedra -joinbwd 5 -refine"
  "-domain polyhedra -joinbwd 5 -ordinals 3  -refine -resilience" 
  "-domain polyhedra -joinbwd 5 -ordinals 3 -refine"
  #"-domain boxes -joinbwd 5 -ordinals 3  -refine -resilience" 
  #"-domain boxes -joinbwd 5 -ordinals 3 -refine"
  #"-domain boxes -joinbwd 5 -refine -resilience" 
  #"-domain boxes -joinbwd 5 -refine"
  #"-domain polyhedra -joinbwd 8 -refine -resilience" 
  #"-domain polyhedra -joinbwd 8 -refine"
  "-domain polyhedra -joinbwd 8 -ordinals 3  -refine -resilience" 
  "-domain polyhedra -joinbwd 8 -ordinals 3 -refine"
  #"-domain boxes -joinbwd 8 -ordinals 3  -refine -resilience" 
  #"-domain boxes -joinbwd 8 -ordinals 3 -refine"
  #"-domain boxes -joinbwd 8 -refine -resilience" 
  #"-domain boxes -joinbwd 8 -refine"
  # "-domain polyhedra -cda 1  -ordinals 3 -vulnerability" 
  #"-domain polyhedra -ordinals 3 -cda 0 -vulnerability" 
  # "-domain boxes -cda 3 -robust_termination" 
  # "-domain boxes -ordinals 3 -robust_termination"  
  # "-domain boxes -retrybwd 3 -robust_termination"  
  # "-domain boxes -joinbwd 3 -cda 3 -robust_termination"  
  # "-domain boxes -joinbwd 3 -ordinals 3 -robust_termination"  
  # "-domain boxes -joinbwd 3 -retrybwd 3 -robust_termination"  
  # "-domain boxes -cda 3 -ordinals 3 -robust_termination"  
  # "-domain boxes -cda 3 -retrybwd 3 -robust_termination"  
  # "-domain boxes -ordinals 3 -retrybwd 3 -robust_termination"  
  # "-domain boxes -joinbwd 3 -cda 3 -ordinals 3 -robust_termination"  
  # "-domain boxes -joinbwd 3 -cda 3 -retrybwd 3 -robust_termination"  
  # "-domain boxes -joinbwd 3 -ordinals 3 -retrybwd 3 -robust_termination"  
  # "-domain boxes -cda 3 -ordinals 3 -retrybwd 3 -robust_termination"  
  # "-domain boxes -ordinals 3 -cda 3 -joinbwd 3 -retrybwd 3 -robust_termination"  
  # "-domain polyhedra -robust_termination"  
  # "-domain polyhedra -joinbwd 3 -robust_termination"  
  # "-domain polyhedra -cda 3 -robust_termination"  
  # "-domain polyhedra -ordinals 3 -robust_termination"  
  #  "-domain polyhedra -retrybwd 3 -robust_termination"  
  # "-domain polyhedra -joinbwd 3 -cda 3 -robust_termination"  
  # "-domain polyhedra -joinbwd 3 -ordinals 3 -robust_termination"  
  # "-domain polyhedra -joinbwd 3 -retrybwd 3 -robust_termination"  
  # "-domain polyhedra -cda 3 -ordinals 3 -robust_termination"  
  # "-domain polyhedra -cda 3 -retrybwd 3 -robust_termination"  
  # "-domain polyhedra -ordinals 3 -retrybwd 3 -robust_termination"  
  # "-domain polyhedra -joinbwd 3 -cda 3 -ordinals 3 -robust_termination"  
  # "-domain polyhedra -joinbwd 3 -cda 3 -retrybwd 3 -robust_termination"  
  # "-domain polyhedra -joinbwd 3 -ordinals 3 -retrybwd 3 -robust_termination"  
  # "-domain polyhedra -cda 3 -ordinals 3 -retrybwd 3 -robust_termination"  
  # "-domain polyhedra -ordinals 3 -cda 3 -joinbwd 3 -retrybwd 3 -robust_termination"  )
 )

listlatex=( 
    "\tool-Polyhedra-Delay2"
    "\tool-Polyhedra-Lex-Delay2"
    "\tool-Boxes-Lex-Delay2"
    "\tool-Polyhedra-Lex-Delay5"
    "\tool-Polyhedra-Lex-Delay5"
   # "\$\\triangledown\$"
  )

# Default solver path. You can change it if you need
analyzer_path=$1
tex=$2
robust=$2
analyzer=$analyzer_path/main.exe
options=$analyzer_path/options.txt
result_folder="results/"
result_tex="results/"

index_html="${result_folder}index.html"
stats_csv="${result_folder}stats.csv"
index_tex="${result_tex}index.tex"
prop_tex="${result_tex}index2.tex"

nb_test=0
timeout=0
failure=0
completness=0 
soundness=0



# max time allowed
max_time="120s"

# Pattern for failure in log
patt_robust="Potentially vulnerable:"
patt_assert="Final Analysis Result: UNKNOWN"

# Pattern for expected failure in file
patt_ko=".*//@KO"

create_file() {
  file=$1
  opt_replaced=$2
  filename=$(basename $file)
  file_html="${result_folder}/${filename}.${opt_replaced}.html"
  cat "script/header.html" > $file_html
  sed -i "s@TITLE@${filename}@" $file_html
  echo "<h1>${filename}</h1>" >> $file_html
  echo "<div class=\"c\">" >> $file_html
  cat $file >> $file_html
  echo "</div>" >> $file_html
  file_svg=$(basename ${file})".svg"
  echo "<img src=\"./${file_svg}\" alt=\"graph\">" >> $file_html
}

end_file() {
  # After the analysis the cfg.dot should correspond to the current test
  dot -Tsvg cfg.dot -o ${result_folder}/${filename}.svg
  cat "script/footer.html" >> $file_html
}

get_nth_line() {
  line=$1
  file=$2
  sed "${line}q;d" $file
}

treat_file() {
  file=$1
  log=$2
  expected_folder=$3
  need_new_line=true
  #for now it's not use could be use if we do a forward safety analysis
  sound_loc=0
  compl_loc=0
  #color for print (to move as global)
  col_sound="blue"
  col_compl="gray"
  
  # Unused for now: first, we compute the expected failures
  # if [[ $expected_folder == "" ]]
  # then
  #   nb_expected=$(grep -n "${patt_ko}" $file| wc -l)
  #   expected=$(grep -n "${patt_ko}" $file | grep -o "^[0-9]*")
  # else
  #   file_folder=$(dirname $file)
  #   file=$(basename $file)
  #   res="${file_folder}/${expected_folder}/${file}.log"
  #   echo "" >> $res
  #   nb_failures=$(grep "${patt_assert}" $res | wc -l)
  #   failures=$(grep "${patt_assert}" $res )
  # fi


  # then, we compute the failed assertions
  nb_failures=$(grep "${patt_assert}" $log| wc -l)
  nb_vars=$(grep "environnment" $log | cut -c14- | sed s/"$."/""/g )
  failuresnr=$(grep -A 1  "${patt_assert}" $log)
  vulnerabilities=$(grep -A 1  "${patt_robust}" $log | sed s/"Potentially vulnerable"//g)
  #| sed s/".1..1."/""/g| sed s/\\$./" "/g)
  safe=$(grep -A 1 -w  "Non-vulnerable" $log | sed s/"Non-vulnerable"//g)
  #| sed s/"1..1."/""/g | sed s/\\$./" "/g)
  vulnerabilities=$(echo $vulnerabilities | sed s/":"/""/g )
  safe=$(echo $safe | sed s/":"/""/g )
  replacement=";"
  safe=$(echo $safe | sed --expression "s@"--"@$replacement@" | sed s/"-"/""/g )
  vulnerabilities=$(echo $vulnerabilities | sed --expression "s@"--"@$replacement@" | sed s/"-"/""/g )
  vulnerabilities=$(echo $vulnerabilities | sed 's/$.{$.}//g' | sed 's/$..{$..}//g' | sed 's/{}//g'| sed s/$.{/{/g | sed s/$..{/{/g | sed s/{{/{/g | tr -d '{' | sed s/}/"-"/g | sed 's/\(.*\)-/\1 /')
  safe=$(echo $safe | sed 's/$.{$.}//g'  | sed 's/$..{$..}//g'| sed 's/{}//g' | sed s/$.{/{/g | sed s/$..{/{/g | sed s/{{/{/g | tr -d '{' | sed s/}/"-"/g )
  safe=(${safe//;/})
  vulnerabilities=(${vulnerabilities//;/})
  #echo "<p><span style=\"color: blue;\">Expected failure lines:</span> ${expected} </p>" >> $file_html
  #echo "<p><span style=\"color: blue;\">Failure lines:</span> ${vulnerabilities} </p>" >> $file_html

  # THIS PARS WILL BE NECESSARY IF WE WANT TO USE EXPECTED RESULTS
  #     Soundness part: for line number in expected,
  #     we search for it in failures
      #  for nb in `seq 1 $nb_expected`;
      #  do
      #    cmd="echo \"${expected}\" | head -${nb} | tail -1"
      #    line_nb=$(eval "${cmd}")
      #    echo "${failuresnr}" | grep -q "^${line_nb}$"
      #    found=$?
      #    if [[ $found -ne 0 ]]
      #    then
      #      line=$(get_nth_line $line_nb $file)
      #     col_sound="red"
	    #  	  soundness=$((soundness+1))
	    #  	  sound_loc=$((sound_loc+1))
      #     # if [ "$need_new_line" = true ]
      #     # then
      #     #   echo -e "\n${BOLD}${RED} SOUNDNESS ERRORS${RESET}"
      #     #   need_new_line=false
      #     # else
      #     #   #echo -e "${BOLD}${RED} SOUNDNESS ERRORS${RESET}"
      #     # fi
      #      #echo -e "${RED}missing fail assertions:${RESET}${line}"
      #      echo "<p>${line_nb}<span style=\"color: red;\">${line}</span></p>" >> $file_html
      #    fi
      #  done
  #     Completness part: for each line number in failures,
  #     we search for it in expected
       for nb in `seq 1 $nb_failures`;
       do
         cmd="echo \"${failuresnr}\" | head -${nb} | tail -1"
         line_nb=$(eval "${cmd}")
         echo "${expected}" | grep -q "^${line_nb}$"
         found=$?
         if [[ $found -ne 0 ]]
         then
	     	  completness=$((completness+1))
	     	  compl_loc=$((compl_loc+1))
          line=$(grep "${patt_assert}" $log | head -${nb} | tail -1)
           #if [ "$need_new_line" = true ]
           #then
           #  #echo -e "\n${BOLD}${BLUE} COMPLETNESS ERROR${RESET}"
           #  need_new_line=false
           ##else
           #  #echo -e "${BOLD}${RED} COMPLETNESS ERROR${RESET}"
           #fi
           #echo -e "${BLUE}unexpected fail assertions:${RESET} ${line}"
           #echo "<p><span style=\"color: blue;\">${line}</span></p>" >> $file_html
         fi
       done
  
  # Start writing log in the dedicated html file
  echo "<h3>LOG</h3>" >> $file_html
  
  echo "<pre>" >> $file_html
  cat $log >> $file_html
  echo "</pre>" >> $file_html
  if [ "$need_new_line" = false ]
  then
    echo -e ""
  fi

  echo -n "<a href=\"../${log}\" target=\"_parent\">" >> $index_html
  echo -n "<a href=\"../${log}\" target=\"_parent\">" >> $index_html
  # Number of vulnerable and non-vulnerable variables
  lenu=${#vulnerabilities[@]}
  lenc=${#safe[@]}
    
  if (( $compl_loc > 0));
  then
    # Here the analysis lack precision
    echo -n "<span style=\"color: ${col_compl};\">UNKNOWN</span>" >> $index_html
    echo "UNKNOWN"
  else
    # Property has been inferred !!
    echo "TRUE"
    echo -n "<span style=\"color: ${col_sound};\">TRUE</span>" >> $index_html
    
  fi
  echo "</a>" >> $index_html
  echo "<br />" >> $index_html
  # Output the vulnerabilities inferred! 
  if (($lenc==0)) && (($lenu>0))
  then
      u="{${vulnerabilities[0]}}"
      u=$(echo $u | sed 's/\(.*\)-}/\1}/g' | tr -d '$' )
      echo -n "<span style=\"color: #0000FF\">$u</span>" >> $index_html
      #echo -n "\{\textcolor{red}{$u}\} " >> $index_tex
  else 
    if (($lenu==0)) && (($lenc>0))
    then 
      c="{${safe[0]}}"
      c=$(echo $c | sed 's/\(.*\)-}/\1}/g' | tr -d '$')
      echo -n "<span >$c</span>" >> $index_html
      #echo -n "\{\text{$c}\} " >> $index_tex
    else 
      for i in ${!safe[@]}
      do
        c="{${safe[$i]}}"
        c=$(echo $c | sed 's/\(.*\)-}/\1}/g' | tr -d '$' )
        u="{${vulnerabilities[$i]}}"
        u=$(echo $u | sed 's/\(.*\)-}/\1}/g' | tr -d '$' )
        echo -n "<span >$c</span>" >> $index_html
        echo -n "<span style=\"color: #0000FF\">$u</span>" >> $index_html
        #echo -n "\{\textcolor{red}{$u} " >> $index_tex
        #echo -n "\text{$c}\} " >> $index_tex
        echo "<br/>" >> $index_html     
      done
    fi
  fi
  echo "</a>" >> $index_html
}

min(){
  arg1=$1
  arg2=$2
  if ((arg1 < 1 ))
  then 
    echo $arg2
  else
    if ((arg1 < arg2))
    then 
      echo $arg1
    else
      echo $arg2
    fi
  fi
}

treat_examples() {
  # Number of non-vulnerable inferred per analysis and per options
  inferred_glob=("${list[@]/*/0}")
  alarm_glob=("${list[@]/*/0}")
  # Average of min vulnerable inferred per analysis and per options
  average_glob=("${list[@]/*/0}")
  # Total number of variables per analysis and per options
  total_glob=("${list[@]/*/0}")
  # Time global per analysis and per options
  elapsed_glob=("${list[@]/*/0}")
  fileidx=0
  folder="test_nexp/"
  bench_name=$2 
  expected_folder=$3             # subfolder containing expected result
  bench_regexp="${folder}/*.c"

  nb_file=$(find $folder -iname "*.c" | wc -l)
  file_arr=$(find "${folder}" -iname "*.c" | sort)
  file_arr=(${file_arr//' '/})
  # Max number of different vulnerabilities inferred per file 
  nb_of_vuln=("${file_arr[@]/*/0}")
  
  nb_test=$(( nb_test + nb_file ))
  
  echo "Input C file,Analysis t"
  
	if [[ $nb_file -eq 0 ]]
	then
    echo "bench ${bench_name}: No files found (${bench_regexp})"
    return
	fi
  echo "<tr><th colspan=\"100\" class=\"bench\"> ${bench_name} </th></tr>" >> $index_html
  echo "<tr><th></th>" >> $index_html
  
  # Print the options for column titles
  for i in "${!list[@]}";
  do
    echo "<td><strong>${list[i]}</strong></td>" >> $index_html
  done
  
  # Column title: number of vulns
  echo "<td><strong> Number of vulnerabilities </strong></td>" >> $index_html
  echo "</tr>" >> $index_html
  # Iterate analysis on all files 
	for file in $(find "${folder}" -iname "*.c" | sort)
	do
    
    filename=$(basename $file)
    # Get property file for ctl/guarante/recurrence...
    prop_name=$(echo ${file}|cut -d'.' -f1)
    prop_name="${prop_name}.txt"
    create_file $file $opt_replaced
    echo "<tr>" >> $index_html
    echo "<td><pre>${filename}</pre></td>" >> $index_html
    echo  "\\\\" >> $index_tex
    echo -n "${filename} & " >> $index_tex
    solvopt=0
    index=0
    if [[ ${1} == "ctl" ]] || [[ ${1} == "robust_reachability" ]]
      then  
        ctl=$(cat $prop_name)        
        prop="$ctl"
        proptex=$(echo $ctl | sed s/{/'\{'/g | sed s/}/'\}'/g | sed s/\&/'\\&'/g)
        # Look for the precondition in the program but we dont use it yet
        precond=$(cat $file | grep -oP -e '-precondition\s\K.*')
        if [[ $precond == "" ]] 
        then 
          precond="true"
        fi
    else
        prop="termination"
        proptex="termination"
    fi
    echo -n "$filename & $proptex \\\\
            "  >> $prop_tex
    # Iterate on analysis options
    for opt in "${list[@]}"
    do
      opt_replaced=$(echo "${opt}" | sed "s/ /_/g")
      echo "<td>" >> $index_html
      solved=$(($solved+1))
      echo -ne "\r$fill$fill\r\t$file $opt"


      # Create log files
      log="${result_folder}/${filename}.${opt_replaced}.txt"
      addr="${result_folder}/${filename}.${opt_replaced}.html"
      echo "<h2><a href=\"../${addr}\">${opt}</a></h2>" >> $file_html
      start_time=$(date +%s.%3N)
      if [[ ${1} == "ctl" ]] ||[[ ${1} == "robust_reachability" ]]
      then  
        timeout $max_time $analyzer $file $opt ${optmap[$1]} "$ctl"  > $log 2>&1
      else
        timeout $max_time $analyzer $file $opt  ${optmap[$1]} > $log 2>&1              
      fi
      out=$?
      end_time=$(date +%s.%3N)
      # time for the current file
      subst=$(echo "scale=3; $end_time - $start_time" | bc)
      # last total time
      last_time=${elapsed_glob[$index]}
      # new  total time
      elapsed_glob[$index]=$(echo "scale=3; $last_time + $subst" | bc)
      # total number of variable
      total=$(grep  "Total: " ${log})
      total=${total#*:}
      # allpot = "" if there are some defined part in the domain the decision tree, otherwise all variables are potentially vulnerable.
      allpot=$(grep "All potentially vulnerables" ${log})   
      # inferred -> max number of safe var in the current test
      # inferred -> min number of potentially vulnerable var in the current test
      # nb_vulns -> number of potentially vulnerable set in the current test
      allb="False"
      if [[ "$allpot" == "" ]] 
      then
        # Defined part in the dtree
        inferred=$(grep "MaxInf: " ${log})
        inferred=${inferred#*:}
        mininf=$(grep "MinInf: " ${log})
        mininf=${mininf#*:}
        vulns=$(grep  "Nb vuln: " ${log})
        vulns=${vulns#*:}
      else 
        # all varaible vulnerable
        allb="True"
        mininf=0
        vulns=1
        inferred=0
      fi
     result=$(grep "$patt_assert" ${log})
     if [[ "$result" == "" ]] 
      then
        nb_alarm=0
      else 
        nb_alarm=1
      fi
      # inferred_glob-> max number of safe var for each test for all options
      # inferred_glob-> max number of var for each test for all optionstest
      # nb_vulns -> number of potentially vulnerable set in the current test
      inferred_glob[$index]=$(($inferred + ${inferred_glob[$index]}))
      alarm_glob[$index]=$(($nb_alarm + ${alarm_glob[$index]}))
      total_glob[$index]=$(($total + ${total_glob[$index]}))
      # Lines of code in file
      loc=$(cat $file | wc -l)
      if [[ $out -eq 124 ]]
      then
        timeout=$((timeout+1))
        res="TO"
        echo "<a href=\"../${log}\"><span style=\"color: red;\">TO</span></a>" >> $index_html
        echo -n "\textcolor{red}{TO} " >> $index_tex
        echo "<span style=\"color: red;\">TO</span>" >> $file_html
        echo -e "\n  ${BOLD}${RED}TO ${RESET}\n"
        echo "<h3>LOG</h3>" >> $file_html
        echo "<pre>" >> $file_html
        cat $log >> $file_html
        echo "</pre>" >> $file_html
      elif [[ $out -ne 0 ]]
      then
        res="FAIL"
        failure=$((failure+1))
        echo "<a href=\"../${log}\"><span style=\"color: red;\">FAIL</span></a>" >> $index_html
        echo -n "\textcolor{red}{FAIL}  " >> $index_tex
        echo "<span style=\"color: red;\">FAIL</span>" >>$file_html
        echo -e "\n  ${BOLD}${RED}FAILED ($out) ${RESET}\n"
        echo "<h3>LOG</h3>" >> $file_html
        echo "<pre>" >> $file_html
        cat $log >> $file_html
        echo "</pre>" >> $file_html
      else
        nb_of_vuln[$fileidx]=$(min ${nb_of_vuln[$fileidx]}  $vulns)
        # res = TRUE OR UNKNOWN i.e. result of the CTL analysis 
        res=$(treat_file $file $log $expected_folder)
      fi
      if (($solvopt + 1 < ${#list[@]})) 
      then
          echo -n  " & " >> $index_tex
      fi
      index=$(($index+1))
      solvopt=$(($solvopt + 1))
      # create csv files with the result
      echo "$filename,$prop,$opt,$res,$loc,$subst,$nb_alarm">> $stats_csv
   done   
   echo "<td> ${nb_of_vuln[$fileidx]} </td>" >> $index_html
   fileidx=$(($fileidx + 1))
   

	done

  # echo "<tr><th></th>" >> $index_html
  # # for i in "${!total_glob[@]}";
  # # do
  # #   pr=$(echo "scale=3; 100*(${inferred_glob[$i]} /${total_glob[$i]})" |bc -l )
  # #   echo "<th class=\"bench\"> Max of safe variable: ${inferred_glob[$i]} out of  ${total_glob[$i]} : ${pr} </th>" >> $index_html
  # # done
  # echo "</tr>" >> $index_html
  echo "<tr><th></th>" >> $index_html
  for i in "${!total_glob[@]}";
  do
    echo "<th class=\"bench\"> Alarms : ${alarm_glob[$i]}</th>" >> $index_html
  done
  echo "</tr>" >> $index_html
  echo "<tr><th></th>" >> $index_html
  for i in "${!total_glob[@]}";
  do
    pr=$(echo "scale=3; 100*(${inferred_glob[$i]} /${total_glob[$i]})" |bc -l )
    echo "<th class=\"bench\"> Time: ${elapsed_glob[$i]} </th>" >> $index_html
  done
  echo "</tr>" >> $index_html
  end_file $file
}

print_end() {
  echo " "
  echo -e "  test:\t${nb_test} (files: ${total})"
  if [[ $timeout != 0 ]]
  then
    echo -e "  ${BOLD}Timeout${RED}\tKO (${timeout}) ${RESET}"
  fi
  if [[ $failure != 0 ]]
  then
    echo -e "  ${BOLD}Failure${RED}\tKO (${failure}) ${RESET}"
  fi
  if [[ $soundness != 0 ]]
  then
    echo -e "  ${BOLD}Soudness${RED}\tKO (${soundness}) ${RESET}"
  else
	  echo -e "  ${BOLD}Soudness${GREEN}\tOK ${RESET}"
  fi
  if [[ $completness != 0 ]]
  then
    echo -e "  ${BOLD}Completness${RED}\tKO (${completness}) ${RESET}"
  else
	  echo -e "  ${BOLD}Completness${GREEN}\tOK ${RESET}"
  fi
  echo -e "${BOLD}${BLUE}Results written in${RESET}: ${index_html}"
}

mkdir ${result_folder}
cat "script/header_main.html"                    > $index_html
echo "<h1>Overview</h1>"                          >> $index_html
echo "<table>"                                    >> $index_html
echo -n "  \begin{longtblr}{colspec={|X[4]" > $index_tex
echo -n "  \begin{longtblr}{colspec={|X[4]|X[5]},hlines,vlines}" > $prop_tex
for i in "${list[@]}"
do
echo -n "|X[5]" >> $index_tex
done
echo "},
      hlines,
      vlines
      }
     " >> $index_tex
echo -n "\textbf{Filename} &" >> $index_tex
for i in "${!list[@]}";
do
  sign=${listlatex[i]}
  echo -n "$sign" >> $index_tex
  if (($i + 1 < ${#list[@]})) 
    then
        echo -n  " & " >> $index_tex
  fi
done
# Create a csv file
echo "filename,property,options,result,loc,time,alarms" > $stats_csv
total=$(find $bench -iname "*.c" | wc -l)
solved=0

treat_examples "termination" "Termination"  ""



echo "\end{longtblr}" >> $index_tex 
echo "\end{longtblr}" >> $prop_tex 
cat $prop_tex >> $index_tex
echo "</body>"                                    >> $index_html
echo "</html>"                                    >> $index_html
print_end