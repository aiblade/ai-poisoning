## What Does It Do

Create an output.txt file to store our data

Store the current size of output.txt in initial_size

Take in a prompt via a command line argument

Then, in an infinite loop:

Query copilot for a suggestion, discarding error messages, and write the output to output.txt

Get the Process ID of the copilot suggestion

If output.txt has been written to, update initial_size and kill the PID

In summary, the script lets us ask Copilot again and again for answers to our prompt. Pretty neat!

I also created output-cleaner.sh to clean the output and write it to a new file, making it easier to read for humans.

## Usage

./copilot-sampler.sh "<PROMPT>"

./output-cleaner.sh

View your results in cleaned-output.txt
