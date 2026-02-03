#!/usr/bin/env bash
# Usage: ./run_tests.sh ./main.exe

EXEC=$1
CTL_CONFIGS=("config/poly-ctl.json")           # Configurations CTL
TERM_CONFIGS=("config/poly-term.json")         # Configurations Termination
OUT_DIR=$2

if [[ ! -x "$EXEC" ]]; then
    echo "Error: $EXEC not found or not executable"
    exit 1
fi

mkdir -p "$OUT_DIR"

# --- Function to run CTL tests ---
run_tests_ctl() {
    opt=$1
    CTL_TEST_DIR=$2
    
    echo "=== Running CTL tests (+ $opt) in $CTL_TEST_DIR ==="
    echo "--- Using CTL config: $CONFIG ---"
    for cfile in $(find "$CTL_TEST_DIR" -name "*.c"); do
       base="${cfile%.c}"
       jsonfile="${base}.json"
       PROP=$(jq -r '.property' "$jsonfile" 2>/dev/null)
       # Options spécifiques CTL
       echo "Running CTL: ./$EXEC -config $jsonfile $cfile -ctl $PROP"
       ./"$EXEC" -config "$jsonfile" "$cfile" -ctl "$PROP" -json_output "$OUT_DIR" > /dev/null 2>&1  || true
    done
}

# --- Function to run Termination tests ---
run_tests_term() {
    opt=$1
    TERM_TEST_DIR=$2
    echo "=== Running Termination (+ $opt) tests in $TERM_TEST_DIR ==="
    for cfile in $(find "$TERM_TEST_DIR" -name "*.c"); do
            if [[ -e "$cfile" ]]; then
                base="${cfile%.c}"
                jsonfile="${base}.json"
                if [[ ! -f "$jsonfile" ]]; then
                    echo "Warning: JSON file $jsonfile not found, skipping $cfile"
                    continue
                fi
                # Options spécifiques CTL
                echo "Running TERMINATION: ./$EXEC -config $CONFIG $jsonfile $cfile"
                ./"$EXEC" -config "$jsonfile" "$cfile" -json_output "$OUT_DIR" > /dev/null 2>&1  || true
            fi
   done
}

# run_tests_vuln() {
#     run_tests_ctl "-vulnerability" "test_vuln/ctl"
#     run_tests_ctl "-vulnerability" "test_vuln/robust_reachability"
#     run_tests_term "-vulnerability" "test_vuln/termination"
# }
# run_test_resilience() {  
#     run_tests_term "-resilience" "test_res"
# }



# run_tests_vuln  ""

run_tests_term "" "tests/termination"
#run_tests_ctl "" "tests/ctl/"
# run_test_resilience ""

