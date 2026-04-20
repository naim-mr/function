import subprocess
import re
from pathlib import Path

def run_tool(executable: str, source_file: Path) -> str:
    """Run the analysis tool on one file and return the result (true/false/unknown/failure)."""
    cmd = [executable, str(source_file), "-domain", "polyhedra", "-joinbwd", "10", "-ordinals", "3", "-minimal"]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        output = result.stdout.strip()
    except Exception as e:
        print(f"[FAILURE] {source_file.name}: tool crashed ({e})")
        return "failure"

    if not output or "Final Analysis Result:" not in output:
        return "failure"
    if re.search(r"Final\s+Analysis\s+Result:\s*false\(TERM\)", output, re.IGNORECASE):
        return "false"
    elif re.search(r"Final\s+Analysis\s+Result:\s*TRUE", output, re.IGNORECASE):
        return "true"
    elif re.search(r"Final\s+Analysis\s+Result:\s*UNKNOWN", output, re.IGNORECASE):
        return "unknown"
    else:
        return "failure"


def get_expected_result(yml_file: Path) -> str:
    """Extract expected termination result from the .yml file."""
    try:
        with open(yml_file, "r") as f:
            content = f.read()
    except FileNotFoundError:
        print(f"[WARNING] Missing YML for {yml_file.stem}, defaulting to true.")
        return "true"

    text = yml_file.read_text()

    # Regex to match the two-line block allowing arbitrary leading indentation
    # - first line: optional spaces, a hyphen, optional spaces, property_file: ../properties/termination.prp
    # - second line: same indentation or more, expected_verdict: false|true
    pattern_false = re.compile(
        r"^[ \t]*-[ \t]*property_file:[ \t]*\.\./properties/termination\.prp[ \t]*\r?\n[ \t]*expected_verdict:[ \t]*false[ \t]*$",
        re.MULTILINE
    )
    pattern_true = re.compile(
        r"^[ \t]*-[ \t]*property_file:[ \t]*\.\./properties/termination\.prp[ \t]*\r?\n[ \t]*expected_verdict:[ \t]*true[ \t]*$",
        re.MULTILINE
    )

    if pattern_false.search(text):
        return "false"
    if pattern_true.search(text):
        return "true"

    # Default if exact block not found
    return "not"


def main(executable: str, root: str):
    root = Path(root)
    if not root.is_dir():
        print(f"Error: {root} is not a directory.")
        sys.exit(2)
    all_c_files = list(root.rglob("*.c"))
    count = 0 
    malus = 0
    wrong = []
    for c_file in all_c_files:
        yml_file = c_file.with_suffix(".yml")
        expected = get_expected_result(yml_file)
        actual = run_tool(executable, c_file)
        # Report mismatches only between true/false (ignore unknown/failure)
        if actual in ("true", "false") and expected in ("true", "false"):
            if actual == expected:
                if actual == "true":
                    count = count + 2
                else:
                    count = count + 1 
                print(f"✅ {c_file.name}: expected={expected}, got={actual}")
                print(f": Current score {count}")
            else:
                if expected == "true":
                    malus = malus - 32
                else:
                    malus = malus - 16
                print(f"❌ {c_file.name}: expected={expected}, got={actual}")
                wrong.append(f"❌ {c_file.name}: expected={expected}, got={actual}")
        if actual in ("true", "false") and expected in ("not"):
                if actual == "true":
                    count = count + 2
                else:
                    count = count + 1 
                print(f"✅ {c_file.name}: expected={expected}, got={actual}")
                print(f": Current score {count}")
    for str in wrong:
        print(str)
if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: python test_runner.py <path_to_main.exe> <directory>")
        sys.exit(1)

    main(sys.argv[1], sys.argv[2])
