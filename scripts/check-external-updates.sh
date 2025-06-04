#!/bin/bash

# Script to check for updates to external tools and packages
set -euo pipefail

echo "Checking for external tool updates..."

# Function to check GitHub releases for latest version
check_github_release() {
    local repo="$1"
    local current_version="$2"
    
    latest=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r '.tag_name' | sed 's/^v//')
    if [ "$latest" != "$current_version" ]; then
        echo "📦 $repo: $current_version → $latest"
        return 0
    fi
    return 1
}

# Function to check direct download versions
check_direct_version() {
    local name="$1"
    local url="$2"
    local current_version="$3"
    
    # This is a simplified check - in practice you'd parse the version from the URL response
    echo "ℹ️ Checking $name (current: $current_version) - manual verification needed"
}

updates_found=0

# Check major tools for updates
echo "🔍 Checking GitHub releases..."

# Go
if check_github_release "golang/go" "1.23.9"; then
    ((updates_found++))
fi

# Node.js (check via NodeSource)
if check_github_release "nodejs/node" "20.19.2"; then
    ((updates_found++))
fi

# Rust
if check_github_release "rust-lang/rust" "1.87.0"; then
    ((updates_found++))
fi

# Kotlin
if check_github_release "JetBrains/kotlin" "2.1.10"; then
    ((updates_found++))
fi

# Julia
if check_github_release "JuliaLang/julia" "1.11.5"; then
    ((updates_found++))
fi

# Docker
if check_github_release "docker/cli" "28.0.4"; then
    ((updates_found++))
fi

# Kubernetes
if check_github_release "kubernetes/kubernetes" "1.33.1"; then
    ((updates_found++))
fi

# Helm
if check_github_release "helm/helm" "3.18.1"; then
    ((updates_found++))
fi

# Bazel
if check_github_release "bazelbuild/bazel" "8.2.1"; then
    ((updates_found++))
fi

# Kind
if check_github_release "kubernetes-sigs/kind" "0.29.0"; then
    ((updates_found++))
fi

# GitHub CLI
if check_github_release "cli/cli" "2.74.0"; then
    ((updates_found++))
fi

# CMake
if check_github_release "Kitware/CMake" "3.31.6"; then
    ((updates_found++))
fi

# AWS CLI (check via their API or releases page)
echo "ℹ️ Checking AWS CLI (current: 2.27.27) - manual verification needed"

# Azure CLI (check via their releases)
echo "ℹ️ Checking Azure CLI (current: 2.73.0) - manual verification needed"

# Google Cloud CLI (check via their releases)
echo "ℹ️ Checking Google Cloud CLI (current: 524.0.0) - manual verification needed"

# Browser versions
echo "🌐 Checking browser versions..."
echo "ℹ️ Chrome (current: 137.0.7151.55) - auto-updated in Dockerfile"
echo "ℹ️ Firefox (current: 139.0.1) - auto-updated in Dockerfile"

# Language version managers
echo "🔧 Checking version managers..."
if check_github_release "nvm-sh/nvm" "0.40.3"; then
    ((updates_found++))
fi

echo ""
if [ $updates_found -gt 0 ]; then
    echo "✅ Found $updates_found potential updates"
    echo "has_external_updates=true" >> "$GITHUB_OUTPUT" 2>/dev/null || true
else
    echo "ℹ️ No external tool updates detected"
    echo "has_external_updates=false" >> "$GITHUB_OUTPUT" 2>/dev/null || true
fi

exit 0