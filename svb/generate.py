import os
import sys
import re
import itertools

def generate_combinations(content, pattern):
    print("""Generate all combinations of replacing occurrences of the pattern with 'input' or 'rand'.""")
    # Find all occurrences of the pattern in the content


    # Find all occurrences of the pattern in the content
    occurrences = re.findall(pattern, content)
    print(occurrences)
    positions = [(m.group(),m.start(),m.end()) for m in re.finditer(pattern, content)]
    print("---pos---")
    print(positions)
    # Generate all possible combinations of 'input' or 'rand' for each occurrence
    replacements = list(itertools.product(['input;', 'rand;'], repeat=len(positions)))
    combination = []
    # Create all versions of the content based on the combinations
    for replacement in replacements:       
        for idx, (g,s,e) in enumerate(positions):
            # Replace the occurrence at the position with the corresponding replacement
            # print("start : "+ str(s))
            # print("end : "+ str(e))
            # print("content")
            # print(content[s:e])
            # print("replacement")
            # print(replacement[idx])

            l=len(replacement[idx])
            add = ""

            for i in range(0,(e-s)-l):
                 add  = add+' '
            
            content = content[:s]+ replacement[idx] + add + content[e:]
        combination.append(''.join(content))

    return combination

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
    for file_name in os.listdir(directory):
        file_path = os.path.join(directory, file_name)
        if os.path.isfile(file_path):  # Check if it's a file (not a subdirectory)
             process_file(file_path, pattern)
             os.remove(file_path)
        i=i+1
# Example usage:
directory_path = sys.argv[1]  # Set this to the path of your repository
pattern=r'__VERIFIER_nondet_.*?\(\);'
process_directory(directory_path, pattern)
