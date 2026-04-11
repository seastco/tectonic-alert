#!/bin/bash

set -e

# Set up variables
PROJECT_DIR="/Users/stove/sources/tectonic-alert"
PACKAGE_DIR="${PROJECT_DIR}/lambda_package"
ZIP_FILE="${PROJECT_DIR}/lambda_package.zip"
LAMBDA_FUNCTION_NAME="earthquakeAlert"

# Clean up any previous package
rm -rf "$PACKAGE_DIR" "$ZIP_FILE"

# Install dependencies into package directory (targeting Lambda's Python 3.11)
mkdir -p "$PACKAGE_DIR"
pip3 install -r "${PROJECT_DIR}/requirements.txt" \
  --target "$PACKAGE_DIR" \
  --platform manylinux2014_x86_64 \
  --only-binary=:all: \
  --python-version 3.11 \
  --quiet

# Copy source code
cp -r "${PROJECT_DIR}/config" "$PACKAGE_DIR/"
cp -r "${PROJECT_DIR}/storage" "$PACKAGE_DIR/"
cp -r "${PROJECT_DIR}/sms" "$PACKAGE_DIR/"
cp -r "${PROJECT_DIR}/alerts" "$PACKAGE_DIR/"
cp "${PROJECT_DIR}/main.py" "$PACKAGE_DIR/"

# Zip the package
cd "$PACKAGE_DIR"
zip -r "$ZIP_FILE" . -q

# Clean up package directory
cd "$PROJECT_DIR"
rm -rf "$PACKAGE_DIR"

# Upload lambda package & publish
aws lambda update-function-code --function-name "$LAMBDA_FUNCTION_NAME" --zip-file fileb://"$ZIP_FILE"
echo "Waiting for function update to complete..."
aws lambda wait function-updated --function-name "$LAMBDA_FUNCTION_NAME"
aws lambda publish-version --function-name "$LAMBDA_FUNCTION_NAME"

# Clean up zip file
rm -f "$ZIP_FILE"

echo "Deploy complete!"
