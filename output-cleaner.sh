#!/bin/bash

# This script takes the entire output.txt (raw Copilot output)
# and filters out only the snippet lines between:
#    '# Suggestion:'
# and
#    '? Select an option'
# writing them to cleaned_output.txt.

INPUT_FILE="output.txt"
OUTPUT_FILE="cleaned-output.txt"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: $INPUT_FILE not found. Make sure loop_invoke.sh has run first."
    exit 1
fi

# Empty or create cleaned_output.txt
> "$OUTPUT_FILE"

# Process the entire output.txt with AWK
awk '
  BEGIN {
    capturing = 0
  }
  # Start capturing after a line (allowing leading spaces) with "# Suggestion:"
  /^[[:space:]]*# Suggestion:/ {
    capturing = 1
    next
  }

  # If we see "? Select an option" (allowing leading spaces), we stop capturing
  capturing && /^[[:space:]]*\? Select an option/ {
    capturing = 0
    # Let the logic continue in case multiple suggestions appear in the file
    next
  }

  # Print lines only while capturing
  capturing {
    print
  }
' "$INPUT_FILE" >> "$OUTPUT_FILE"

echo "Cleaning complete. Check '$OUTPUT_FILE' for filtered suggestions."
