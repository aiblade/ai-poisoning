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

    # Run Copilot suggestions in the background, write to output.txt
    gh copilot suggest "$prompt" -t shell 2>/dev/null >> output.txt &

    pid=$!

    # Wait briefly (adjust as needed)
    sleep 1

    # Check if output.txt has grown
    new_size=$(stat -c %s output.txt)
    if [ "$new_size" -gt "$initial_size" ]; then

        # Update file size
        initial_size=$new_size
        
        # Kill the background process group
        pkill -P "$pid" 2>/dev/null

    fi
done
