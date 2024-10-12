#!/bin/bash

set -e

# Ensure necessary tools are available
if ! command -v curl &> /dev/null; then
    apt-get update && apt-get install -y curl
fi

if ! command -v jq &> /dev/null; then
    apt-get update && apt-get install -y jq
fi

# Determine latest version and download URL
LATEST_RELEASE=$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest)
VERSION=$(echo $LATEST_RELEASE | jq -r .tag_name)
DOWNLOAD_URL=$(echo $LATEST_RELEASE | jq -r '.assets[] | select(.name | test("x86_64-linux.tar.xz$")) | .browser_download_url')

# Download and extract Helix
curl -L $DOWNLOAD_URL -o helix.tar.xz
tar -xvf helix.tar.xz
rm helix.tar.xz

# Move Helix binary to PATH and set permissions
mv helix-*/hx /usr/local/bin/
chmod 755 /usr/local/bin/hx

# Move runtime files to appropriate location
mkdir -p /usr/local/lib/helix
mv helix-*/runtime /usr/local/lib/helix/
chmod -R 755 /usr/local/lib/helix/runtime

# Cleanup
rm -rf helix-*

# Verify installation
if command -v hx &> /dev/null; then
    echo "Helix editor $VERSION has been successfully installed."
    echo "Binary location: $(which hx)"
    echo "Runtime files: /usr/local/lib/helix/runtime"
else
    echo "Installation failed."
    exit 1
fi