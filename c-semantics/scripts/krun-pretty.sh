#!/bin/bash
# krun-pretty.sh - Pretty print K AST files
# Usage: ./krun-pretty.sh --input <file> --output <file> --uuid <uuid>

set -e

# Setup environment
eval $(opam config env) 2>/dev/null || true
eval $(perl -I "~/perl5/lib/perl5" -Mlocal::lib) 2>/dev/null || true
export PATH=$K_BIN:$PATH

# Save current directory
ORIGINAL_DIR="$(pwd)"

# Get script directory (absolute path)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
C_SEMANTICS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Initialize variables
INPUT_FILE=""
OUTPUT_FILE=""
UUID=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --input)
            INPUT_FILE="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --uuid)
            UUID="$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 --input <file> --output <file> --uuid <uuid>"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$INPUT_FILE" || -z "$OUTPUT_FILE" || -z "$UUID" ]]; then
    echo "Error: All arguments are required"
    echo "Usage: $0 --input <file> --output <file> --uuid <uuid>"
    exit 1
fi

# Convert relative paths to absolute paths
# Input file
if [[ "$INPUT_FILE" != /* ]]; then
    # Relative path - make it absolute from current directory
    INPUT_FILE="${ORIGINAL_DIR}/${INPUT_FILE}"
fi

# Output file
if [[ "$OUTPUT_FILE" != /* ]]; then
    # Relative path - make it absolute from current directory
    OUTPUT_FILE="${ORIGINAL_DIR}/${OUTPUT_FILE}"
fi

# Normalize paths (remove ./ and ../)
INPUT_FILE="$(cd "$(dirname "$INPUT_FILE")" 2>/dev/null && pwd)/$(basename "$INPUT_FILE")" || {
    echo "Error: Cannot resolve input file path: $INPUT_FILE"
    exit 1
}

OUTPUT_DIR="$(dirname "$OUTPUT_FILE")"
OUTPUT_BASE="$(basename "$OUTPUT_FILE")"

# Check input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: Input file does not exist: $INPUT_FILE"
    exit 1
fi

# Create output directory if needed
mkdir -p "$OUTPUT_DIR"

# Normalize output directory path
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
OUTPUT_FILE="${OUTPUT_DIR}/${OUTPUT_BASE}"

# Run krun
cd "$C_SEMANTICS_DIR"

krun "$INPUT_FILE" \
    --directory "${C_SEMANTICS_DIR}/dist/profiles/x86-gcc-limited-libc/c-translation-kompiled" \
    --output-file "$OUTPUT_FILE" \
    --parser "cat" \
    --config-parser OPTIONS="echo" \
    --config-parser JSON="echo" \
    --config-parser UUID="echo" \
    -c OPTIONS='`.Set`(.KList)' \
    -c JSON='#token("\"{\\\"suppressions\\\": [],\\\"message_length\\\": 80,\\\"format\\\": \\\"Console\\\",\\\"previous_errors\\\": [],\\\"fatal_errors\\\": false,\\\"rv_error\\\": \\\"\\\"}\"", "String")' \
    -c UUID="#token(\"\\d${UUID}\", \"String\")"

# Return to original directory
cd "$ORIGINAL_DIR"

echo "Done: $OUTPUT_FILE"
