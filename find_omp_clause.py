import os
import argparse

def find_files_with_OMPForClauseExpression(directory, search_term="ForClauseExpression"):
    """
    Recursively walk through `directory` and print file paths
    that contain the `search_term`.
    """
    for root, _, files in os.walk(directory):
        for filename in files:
            filepath = os.path.join(root, filename)
            try:
                with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                    for line in f:
                        if search_term in line:
                            print(filepath)
                            break
            except Exception as e:
                # Skip files that can't be read or other errors
                continue

def main():
    parser = argparse.ArgumentParser(description="Search for files containing 'ForClauseExpression'.")
    parser.add_argument('directory', help="Path to the directory to search recursively.")
    parser.add_argument('--term', default="ForClauseExpression", help="Search term to look for in files (default: 'OMPForClauseExpression').")
    args = parser.parse_args()
    
    find_files_with_OMPForClauseExpression(args.directory, args.term)

if __name__ == "__main__":
    main()
