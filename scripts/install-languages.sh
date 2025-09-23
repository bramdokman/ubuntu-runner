#!/bin/bash
# Install programming languages and runtimes
set -euo pipefail

# Source versions if available
if [ -f /versions.env ]; then
    source /versions.env
fi

echo "Installing programming languages..."

# Function to download and install with retry
download_and_install() {
    local url="$1"
    local output="$2"
    local max_attempts=3

    for i in $(seq 1 $max_attempts); do
        if wget -q "$url" -O "$output"; then
            return 0
        else
            echo "Download attempt $i failed for $url, retrying..." >&2
            sleep 5
        fi
    done
    return 1
}

# Install Node.js
echo "Installing Node.js ${NODE_VERSION}..."
curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | bash -
apt-get install -y nodejs
npm install -g yarn

# Install Go
echo "Installing Go ${GO_VERSION}..."
download_and_install "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" "/tmp/go.tar.gz"
tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz

# Install Rust
echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain "${RUST_VERSION}"

# Install Julia
echo "Installing Julia ${JULIA_VERSION}..."
download_and_install \
    "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" \
    "/tmp/julia.tar.gz"
tar -C /opt -xzf /tmp/julia.tar.gz
ln -s "/opt/julia-${JULIA_VERSION}/bin/julia" /usr/local/bin/julia
rm /tmp/julia.tar.gz

# Install Kotlin
echo "Installing Kotlin ${KOTLIN_VERSION}..."
download_and_install \
    "https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip" \
    "/tmp/kotlin.zip"
unzip -q /tmp/kotlin.zip -d /opt
ln -s /opt/kotlinc/bin/kotlin /usr/local/bin/kotlin
ln -s /opt/kotlinc/bin/kotlinc /usr/local/bin/kotlinc
rm /tmp/kotlin.zip

# Install Swift (with fallback)
echo "Installing Swift..."
SWIFT_URLS=(
    "https://download.swift.org/swift-${SWIFT_VERSION}-release/ubuntu2204/swift-${SWIFT_VERSION}-RELEASE-ubuntu22.04.tar.gz"
    "https://download.swift.org/swift-5.10.1-release/ubuntu2204/swift-5.10.1-RELEASE-ubuntu22.04.tar.gz"
)

for url in "${SWIFT_URLS[@]}"; do
    if download_and_install "$url" "/tmp/swift.tar.gz"; then
        tar -C /opt -xzf /tmp/swift.tar.gz
        SWIFT_DIR=$(ls /opt | grep swift | head -1)
        if [ -n "$SWIFT_DIR" ]; then
            ln -s "/opt/${SWIFT_DIR}/usr/bin/swift" /usr/local/bin/swift
        fi
        rm -f /tmp/swift.tar.gz
        break
    fi
done

# Install Python tools
echo "Installing Python tools..."
pip3 install --upgrade pip pipx

# Install Haskell Stack
echo "Installing Haskell Stack..."
curl -sSL https://get.haskellstack.org/ | sh

echo "Language installation complete."