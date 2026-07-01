import os
import sys
import re
import itertools

def generate_combinations(content, pattern):
    """All combinations of assigning each nondet occurrence to one agent."""
    occurrences = re.findall(pattern, content)
    print(occurrences)
    n = len(occurrences)
    options = ['input("env")', 'input("adv")']
    combinations = []
    for combo in itertools.product(options, repeat=n):
        it = iter(combo)
        # re.sub scans left-to-right; the lambda pops the next replacement.
        # Rebuilt from the ORIGINAL content each time -> no cross-contamination,
        # and no manual offset math (so replacements may differ in length).
        new_content = re.sub(pattern, lambda _m: next(it), content)
        combinations.append(new_content)
    return combinations

def process_file(file_path, pattern):
    """Process a file to generate all possible combinations of the pattern replacement."""
    
    if file_path.endswith('.c'):  # Only process .c files
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
        
        # Generate all combinations by replacing the pattern
        combinations = generate_combinations(content, pattern)
        print("combination-è---------------------------\n\n")
        print(combinations)
        for i, comb in enumerate(combinations):
        # Save each combination as a new file with a modified name to avoid overwriting
            new_file_name = f"{os.path.splitext(file_path)[0]}_combination_{i+1}.c"
            with open(new_file_name, 'w', encoding='utf-8') as new_file:
                    new_file.write(comb)
            print(f"Combination {i+1} saved as {new_file_name}")

def process_directory(directory, pattern):
    """Process all .c files in the given directory."""
    i = 0
    for file_name in sorted(os.listdir(directory)):
        file_path = os.path.join(directory, file_name)
        # Only expand .c source files; never touch .json (or other) files,
        # and skip already-generated combinations.
        if (os.path.isfile(file_path)
                and file_name.endswith('.c')
                and '_combination_' not in file_name):
            process_file(file_path, pattern)
            os.remove(file_path)  # remove only the expanded .c source
        i=i+1
# Example usage:
fod = sys.argv[1]  # Set this to the path of your repository
print("fod "+fod)
path = sys.argv[2]  # Set this to the path of your repository

pattern = r'(?:__VERIFIER_nondet_.*?|rand)\s*\(\)'

if fod == '-f': 
    process_file(path, pattern)
elif fod == '-d':
    process_directory(path,pattern) 
elif fod =='-r':
    for current_dir, subdirs, files in os.walk(path):
        process_directory(current_dir,pattern)
        for dirname in subdirs:
            process_directory(current_dir+"/"+dirname,pattern)
    
else:
    raise Exception("Should be -f or -d") 