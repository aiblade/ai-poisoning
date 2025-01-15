#!/bin/bash

# Create or touch the output file if it doesn't exist
>> output.txt

# Record the initial size of output.txt
initial_size=$(stat -c %s output.txt)

# Check if a prompt was provided
if [ -z "$1" ]; then
    echo "Error: No prompt provided."
    echo "Usage: $0 \"prompt\""
    exit 1
fi

prompt="$1"

# Loop indefinitely
while true; do
    # Run Copilot suggestions in the background and pipe through AWK
    gh copilot suggest "$prompt" -t shell 2>/dev/null | awk '
        BEGIN {
            capturing = 0
        }
        # If we see a line with "# Suggestion:" (allowing leading spaces),
        # start capturing from the next line onward.
        /^[[:space:]]*# Suggestion:/ {
            capturing = 1
            next
        }
        # While capturing, if we see a line that starts with "? Select an option",
        # exit AWK (thus stopping output).
        capturing && /^[[:space:]]*\? Select an option/ {
            exit
        }
        # Print captured lines
        capturing {
            print
        }
    ' >> output.txt &

    # Get the PID of the background pipeline
    pid=$!

    # Wait briefly (adjust as needed)
    sleep 1

    # Check if output.txt has grown
    new_size=$(stat -c %s output.txt)
    if [ "$new_size" -gt "$initial_size" ]; then
        # Update the file size
        initial_size=$new_size

        # Kill the background process group
        pkill -P "$pid" 2>/dev/null
    fi
done
