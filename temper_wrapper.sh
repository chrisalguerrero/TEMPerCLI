#!/bin/bash
# Wrapper script for temper-read that adds timestamp

# Get current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Run temper-read and prepend timestamp to each line
/usr/local/bin/temper-read --force 3553:a001 "$@" | while IFS= read -r line; do
    echo "[$TIMESTAMP] $line"
done
