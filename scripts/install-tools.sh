#!/bin/bash
# Helper script to install development tools in Docker image
set -euo pipefail

# Source versions configuration
# shellcheck source=versions.conf
source "$(dirname "$0")/versions.conf"

# Function to install with retry mechanism
install_with_retry() {
    local max_attempts=3
    local attempt=1
    local cmd="$1"
    local description="${2:-command}"

    while [ $attempt -le $max_attempts ]; do
        echo "Installing $description (attempt $attempt/$max_attempts)..."
        if eval "$cmd"; then
            echo "✅ Successfully installed $description"
            return 0
        fi
        echo "⚠️  Attempt $attempt failed, retrying..."
        sleep 5
        ((attempt++))
    done

    echo "❌ Failed to install $description after $max_attempts attempts"
    return 1
}

# Function to download and verify file
download_file() {
    local url="$1"
    local output="$2"
    local description="${3:-file}"

    echo "Downloading $description from $url..."
    if wget -q --show-progress "$url" -O "$output"; then
        echo "✅ Successfully downloaded $description"
        return 0
    else
        echo "❌ Failed to download $description"
        return 1
    fi
}

# Function to install Go
install_go() {
    local tarball="/tmp/go.tar.gz"
    download_file \
        "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
        "$tarball" \
        "Go ${GO_VERSION}"

    tar -C /usr/local -xzf "$tarball"
    rm "$tarball"
    export PATH=$PATH:/usr/local/go/bin
}

# Function to install Julia
install_julia() {
    local tarball="/tmp/julia.tar.gz"
    download_file \
        "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" \
        "$tarball" \
        "Julia ${JULIA_VERSION}"

    tar -C /opt -xzf "$tarball"
    ln -s "/opt/julia-${JULIA_VERSION}/bin/julia" /usr/local/bin/julia
    rm "$tarball"
}

# Function to install Kotlin
install_kotlin() {
    local zipfile="/tmp/kotlin.zip"
    download_file \
        "https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip" \
        "$zipfile" \
        "Kotlin ${KOTLIN_VERSION}"

    unzip -q "$zipfile" -d /opt
    ln -s /opt/kotlinc/bin/kotlin /usr/local/bin/kotlin
    ln -s /opt/kotlinc/bin/kotlinc /usr/local/bin/kotlinc
    rm "$zipfile"
}

# Function to install CMake
install_cmake() {
    local tarball="/tmp/cmake.tar.gz"
    download_file \
        "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz" \
        "$tarball" \
        "CMake ${CMAKE_VERSION}"

    tar -C /opt -xzf "$tarball"
    ln -s "/opt/cmake-${CMAKE_VERSION}-linux-x86_64/bin/cmake" /usr/local/bin/cmake
    rm "$tarball"
}

# Function to install Bazel
install_bazel() {
    local installer="/tmp/bazel.sh"
    if ! download_file \
        "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh" \
        "$installer" \
        "Bazel ${BAZEL_VERSION}"; then

        # Fallback to previous version
        echo "Trying fallback Bazel version..."
        download_file \
            "https://github.com/bazelbuild/bazel/releases/download/7.4.1/bazel-7.4.1-installer-linux-x86_64.sh" \
            "$installer" \
            "Bazel 7.4.1"
    fi

    chmod +x "$installer"
    "$installer"
    rm "$installer"
}

# Function to install Kind
install_kind() {
    download_file \
        "https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64" \
        "/usr/local/bin/kind" \
        "Kind ${KIND_VERSION}"

    chmod +x /usr/local/bin/kind
}

# Function to install Helm
install_helm() {
    local tarball="/tmp/helm.tar.gz"
    download_file \
        "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
        "$tarball" \
        "Helm ${HELM_VERSION}"

    tar -xzC /tmp -f "$tarball"
    mv /tmp/linux-amd64/helm /usr/local/bin/helm
    rm -rf /tmp/linux-amd64 "$tarball"
}

# Main installation logic
main() {
    echo "Starting tool installation..."

    # Parse command line arguments
    case "${1:-all}" in
        go)
            install_go
            ;;
        julia)
            install_julia
            ;;
        kotlin)
            install_kotlin
            ;;
        cmake)
            install_cmake
            ;;
        bazel)
            install_bazel
            ;;
        kind)
            install_kind
            ;;
        helm)
            install_helm
            ;;
        all)
            install_go
            install_julia
            install_kotlin
            install_cmake
            install_bazel
            install_kind
            install_helm
            ;;
        *)
            echo "Unknown installation target: $1"
            echo "Usage: $0 [go|julia|kotlin|cmake|bazel|kind|helm|all]"
            exit 1
            ;;
    esac

    echo "✅ Tool installation completed"
}

# Run main function
main "$@"