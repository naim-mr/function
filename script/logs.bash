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
    for CONFIG in "${CTL_CONFIGS[@]}"; do
        if [[ ! -f "$CONFIG" ]]; then
            echo "Warning: Config file $CONFIG not found, skipping"
            continue
        fi
        echo "--- Using CTL config: $CONFIG ---"
        for cfile in $(find "$CTL_TEST_DIR" -type f -name "*.c"); do
            if [[ -f "$cfile" ]]; then
                base="${cfile%.c}"
                jsonfile="${base}.json"
                if [[ ! -f "$jsonfile" ]]; then
                    echo "Warning: JSON file $jsonfile not found, skipping $cfile"
                    continue
                fi
                PROP=$(jq -r '.property' "$jsonfile" 2>/dev/null)
                if [[ -z "$PROP" || "$PROP" == "null" ]]; then
                    echo "Warning: No 'property' field in $jsonfile, skipping $cfile"
                    continue
                fi
                # Options spécifiques CTL
                echo "Running CTL: $EXEC -config $CONFIG $cfile -ctl $PROP $opt"
                ./"$EXEC" -config "$CONFIG" "$cfile" -ctl "$PROP" $opt -json_output "$OUT_DIR" > /dev/null 2>&1 || true
            fi
        done
    done
}

# --- Function to run Termination tests ---
run_tests_term() {
    opt=$1
    TERM_TEST_DIR=$2
    
    echo "=== Running Termination (+ $opt) tests in $TERM_TEST_DIR ==="
    for CONFIG in "${TERM_CONFIGS[@]}"; do
        if [[ ! -f "$CONFIG" ]]; then
            echo "Warning: Config file $CONFIG not found, skipping"
            continue
        fi
        echo "--- Using Termination config: $CONFIG ---"

        for cfile in $(find "$TERM_TEST_DIR" -type f -name "*.c"); do
            if [[ -f "$cfile" ]]; then
                base="${cfile%.c}"
                # Options spécifiques Termination
                echo "Running Termination: $EXEC --config $CONFIG $cfile $opt"
                ./"$EXEC" "$cfile" -config "$CONFIG" $opt -json_output "$OUT_DIR" > /dev/null 2>&1 || true
            fi
        done
    done
}

run_tests_vuln() {
    run_tests_ctl "-vulnerability" "test_vuln/ctl"
    run_tests_ctl "-vulnerability" "test_vuln/robust_reachability"
    run_tests_term "-vulnerability" "test_vuln/termination"
}
run_test_resilience() {  
    run_tests_term "-resilience" "test_res"
}
# run_tests_ctl "" "tests/ctl"
# run_tests_term "" "tests/termination"
# run_tests_vuln 
run_test_resilience