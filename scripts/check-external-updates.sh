#!/bin/bash

# Script to check for updates to external tools and packages
set -euo pipefail

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly GITHUB_API_URL="https://api.github.com/repos"

echo "Checking for external tool updates..."

# Function to check GitHub releases for latest version
check_github_release() {
    local repo="$1"
    local current_version="$2"
    local latest

    # Fetch latest release version from GitHub API
    if ! latest=$(curl -s --connect-timeout 5 --max-time 10 \
                  "${GITHUB_API_URL}/$repo/releases/latest" | \
                  jq -r '.tag_name' 2>/dev/null | sed 's/^v//'); then
        echo "⚠️  Failed to fetch version for $repo" >&2
        return 1
    fi

    # Check if version is different
    if [ "$latest" != "$current_version" ] && [ -n "$latest" ]; then
        echo "📦 $repo: $current_version → $latest"
        return 0
    fi
    return 1
}

# Function to check direct download versions
check_direct_version() {
    local name="$1"
    local current_version="$2"

    # Log manual verification needed
    echo "ℹ️  $name (current: $current_version) - manual verification needed"
}

# Initialize counters
declare -i updates_found=0
declare -i checks_performed=0

# Check major tools for updates
echo "🔍 Checking GitHub releases..."

# Define tools to check with their current versions
declare -A TOOLS=(
    ["golang/go"]="1.23.9"
    ["nodejs/node"]="20.19.2"
    ["rust-lang/rust"]="1.87.0"
    ["JetBrains/kotlin"]="2.1.10"
    ["JuliaLang/julia"]="1.11.5"
    ["docker/cli"]="28.0.4"
    ["kubernetes/kubernetes"]="1.33.1"
    ["helm/helm"]="3.18.1"
    ["bazelbuild/bazel"]="8.2.1"
    ["kubernetes-sigs/kind"]="0.29.0"
    ["cli/cli"]="2.74.0"
    ["Kitware/CMake"]="3.31.6"
    ["nvm-sh/nvm"]="0.40.3"
)

# Check all defined tools
for repo in "${!TOOLS[@]}"; do
    ((checks_performed++))
    if check_github_release "$repo" "${TOOLS[$repo]}"; then
        ((updates_found++))
    fi
done


# Check cloud CLIs that require manual verification
echo ""
echo "📋 Cloud CLIs (manual verification required):"
check_direct_version "AWS CLI" "2.27.27"
check_direct_version "Azure CLI" "2.73.0"
check_direct_version "Google Cloud CLI" "524.0.0"

# Browser versions
echo ""
echo "🌐 Browser versions (auto-updated in Dockerfile):"
echo "  • Chrome: 137.0.7151.55"
echo "  • Firefox: 139.0.1"


# Summary
echo ""
echo "════════════════════════════════════════════"
echo "📊 Summary: $checks_performed tools checked"
if [ $updates_found -gt 0 ]; then
    echo "✅ Found $updates_found potential updates"
    # Write to GitHub output if available
    if [ -n "${GITHUB_OUTPUT:-}" ]; then
        echo "has_external_updates=true" >> "$GITHUB_OUTPUT"
    fi
else
    echo "ℹ️  No external tool updates detected"
    # Write to GitHub output if available
    if [ -n "${GITHUB_OUTPUT:-}" ]; then
        echo "has_external_updates=false" >> "$GITHUB_OUTPUT"
    fi
fi
echo "════════════════════════════════════════════"

exit 0