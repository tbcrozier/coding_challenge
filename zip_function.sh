#!/bin/bash

# Define the directory containing the Cloud Function code
FUNCTION_DIR="cloud-function"

# Define the name of the output ZIP file
OUTPUT_ZIP="function.zip"

# Navigate to the Cloud Function directory
if [ -d "$FUNCTION_DIR" ]; then
    cd "$FUNCTION_DIR"
else
    echo "Error: Directory '$FUNCTION_DIR' does not exist."
    exit 1
fi

# Remove any existing ZIP file
if [ -f "$OUTPUT_ZIP" ]; then
    echo "Removing existing $OUTPUT_ZIP..."
    rm "$OUTPUT_ZIP"
fi

# Create a new ZIP file with all contents of the directory
echo "Creating $OUTPUT_ZIP..."
zip -r "$OUTPUT_ZIP" . > /dev/null

# Move back to the original directory
cd - > /dev/null

# Confirm completion
echo "$OUTPUT_ZIP has been created successfully in $FUNCTION_DIR."

