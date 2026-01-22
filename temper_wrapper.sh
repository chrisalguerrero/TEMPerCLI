#!/bin/bash
# Continuous temperature monitoring wrapper for TEMPer devices
# Supports both TEMPerHUM_V4.1 and TEMPer1F_V4.1
# Logs to file and displays output, runs every second

# Configuration
LOG_FILE="$HOME/temper_log.txt"
DECODER_SCRIPT="/usr/local/bin/temper-decode"
INTERVAL=1  # seconds between readings

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Stopping temperature monitoring..."
    echo "Log file saved: $LOG_FILE"
    exit 0
}

# Trap SIGINT (Ctrl+C) and SIGTERM
trap cleanup SIGINT SIGTERM

# Check if decoder script exists
if [ ! -f "$DECODER_SCRIPT" ]; then
    echo "Error: Decoder script not found at $DECODER_SCRIPT"
    echo "Please install it first"
    exit 1
fi

# Clear/create the log file (overwrites existing content)
> "$LOG_FILE"

echo "Starting temperature monitoring..."
echo "Logging to: $LOG_FILE"
echo "Press Ctrl+C to stop"
echo "=========================================="

# Continuous loop
while true; do
    # Get current timestamp
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Read temperature/humidity using decoder
    SENSOR_OUTPUT=$("$DECODER_SCRIPT" 2>/dev/null)
    
    if [ -n "$SENSOR_OUTPUT" ]; then
        # Process each line of output (for multiple devices)
        while IFS= read -r line; do
            OUTPUT="$TIMESTAMP $line"
            
            # Display to console
            echo "$OUTPUT"
            
            # Append to log file
            echo "$OUTPUT" >> "$LOG_FILE"
        done <<< "$SENSOR_OUTPUT"
    else
        ERROR_MSG="$TIMESTAMP Error: Could not read from devices"
        echo "$ERROR_MSG"
        echo "$ERROR_MSG" >> "$LOG_FILE"
    fi
    
    # Wait before next reading
    sleep "$INTERVAL"
done
