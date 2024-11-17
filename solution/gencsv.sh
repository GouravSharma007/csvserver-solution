#!/bin/bash

# Start index and end index are passed as arguments to the script
start_index=$1
end_index=$2

# Generate CSV with random numbers
for ((i=start_index; i<=end_index; i++))
do
    # Generate a random number (between 0 and 999)
    random_number=$((RANDOM % 1000))

    # Print the index and random number to the file
    echo "$i, $random_number" >> inputFile
done
