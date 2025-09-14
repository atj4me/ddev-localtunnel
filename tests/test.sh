#!/bin/bash

# Test script for the ddev-localtunnel addon
# This script performs basic validation of the addon structure

set -eu -o pipefail

echo "🧪 Testing DDEV Localtunnel addon structure..."

# Check required files exist
required_files=(
    "install.yaml"
    "docker-compose.localtunnel.yaml"
    "commands/host/lt"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        exit 1
    fi
done

# Check file permissions
if [[ -x "commands/host/lt" ]]; then
    echo "✅ commands/host/lt is executable"
else
    echo "❌ commands/host/lt is not executable"
    exit 1
fi

# Validate YAML files
echo "🔍 Validating YAML files..."

if python3 -c "import yaml; yaml.safe_load(open('install.yaml'))" 2>/dev/null; then
    echo "✅ install.yaml is valid"
else
    echo "❌ install.yaml has syntax errors"
    exit 1
fi

if python3 -c "import yaml; yaml.safe_load(open('docker-compose.localtunnel.yaml'))" 2>/dev/null; then
    echo "✅ docker-compose.localtunnel.yaml is valid"
else
    echo "❌ docker-compose.localtunnel.yaml has syntax errors"
    exit 1
fi

# Check bash script syntax
echo "🔍 Validating shell script..."
if bash -n commands/host/lt; then
    echo "✅ commands/host/lt has valid syntax"
else
    echo "❌ commands/host/lt has syntax errors"
    exit 1
fi

echo ""
echo "🎉 All tests passed! The addon structure is valid."
echo ""
echo "To test with DDEV:"
echo "1. Navigate to a DDEV project"
echo "2. Run: ddev get /path/to/this/addon"
echo "3. Run: ddev restart"
echo "4. Run: ddev lt share"