import os
import sys

def check_and_delete_files(repo_dir):
    # Define the line to search for in the .yml files
    target_line = "  - property_file: ../properties/termination.prp\n    expected_verdict: false"

    # Iterate over files in the repository directory
    for root, dirs, files in os.walk(repo_dir):
        # Create a list of all .c files
        c_files = [f for f in files if f.endswith('.c')]
        
        for c_file in c_files:
            # Get the corresponding .yml file
            yml_file = c_file.replace('.c', '.yml')
            c_file_path = os.path.join(root, c_file)
            yml_file_path = os.path.join(root, yml_file)
            
            # Check if the corresponding .yml file exists
            if os.path.exists(yml_file_path):
                with open(yml_file_path, 'r') as yml:
                    content = yml.read()
                    
                    # If the target line appears in the .yml file, keep the .c file
                    if target_line in content:
                        print(f"Keeping {c_file} because {yml_file} contains the target line.")
                    else:
                        # If the target line is not found, delete both the .c and .yml files
                        os.remove(c_file_path)
                        os.remove(yml_file_path)
                        print(f"Deleted {c_file} and {yml_file} because {yml_file} does not contain the target line.")
            else:
                print(f"No corresponding {yml_file} for {c_file}. Skipping.")

print("ici")
print(sys.argv[0])
repo_directory = sys.argv[0] # Change this to your repository path
check_and_delete_files(repo_directory) 
