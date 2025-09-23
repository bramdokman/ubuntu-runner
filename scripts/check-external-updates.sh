#!/bin/bash
# Script to check for updates to external tools and packages
# This script checks GitHub releases and other sources for newer versions

set -euo pipefail

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly VERSION_FILE="${SCRIPT_DIR}/../versions.env"

# Color codes for output formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Counters
declare -i updates_found=0
declare -i checks_performed=0
declare -a update_messages=()

# Error handling
trap 'error_handler $? $LINENO' ERR

error_handler() {
    local exit_code=$1
    local line_number=$2
    echo -e "${RED}Error occurred on line $line_number with exit code $exit_code${NC}" >&2
    exit "$exit_code"
}

# Logging functions
log_info() {
    echo -e "${GREEN}ℹ️ $*${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️ $*${NC}"
}

log_error() {
    echo -e "${RED}❌ $*${NC}" >&2
}

log_update() {
    echo -e "${GREEN}📦 $*${NC}"
    update_messages+=("$*")
}

# Function to check GitHub releases for latest version
check_github_release() {
    local repo="${1}"
    local current_version="${2}"
    local name="${3:-$repo}"

    ((checks_performed++))

    # Rate limiting protection
    sleep 0.5

    # Fetch latest release info
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    local response

    if ! response=$(curl -s -f -H "Accept: application/vnd.github.v3+json" "$api_url" 2>/dev/null); then
        log_warning "Failed to fetch release info for ${name}"
        return 1
    fi

    # Parse version from response
    local latest_version
    latest_version=$(echo "$response" | jq -r '.tag_name // empty' | sed 's/^v//')

    if [[ -z "$latest_version" ]]; then
        log_warning "Could not determine latest version for ${name}"
        return 1
    fi

    # Compare versions
    if [[ "$latest_version" != "$current_version" ]]; then
        log_update "${name}: ${current_version} → ${latest_version}"
        ((updates_found++))
        return 0
    fi

    return 1
}

# Function to check versions with custom API endpoints
check_custom_version() {
    local name="$1"
    local check_command="$2"
    local current_version="$3"

    ((checks_performed++))

    local latest_version
    if ! latest_version=$(eval "$check_command" 2>/dev/null); then
        log_warning "Could not check version for ${name}"
        return 1
    fi

    if [[ -n "$latest_version" && "$latest_version" != "$current_version" ]]; then
        log_update "${name}: ${current_version} → ${latest_version}"
        ((updates_found++))
        return 0
    fi

    return 1
}

# Load version configuration if available
load_versions() {
    if [[ -f "$VERSION_FILE" ]]; then
        # shellcheck source=/dev/null
        source "$VERSION_FILE"
        log_info "Loaded version configuration from ${VERSION_FILE}"
    else
        log_warning "Version file not found at ${VERSION_FILE}, using hardcoded values"
    fi
}

# Main update checking logic
main() {
    echo "======================================"
    echo " External Tool Update Check"
    echo " $(date '+%Y-%m-%d %H:%M:%S')"
    echo "======================================"
    echo

    # Load version configuration
    load_versions

    log_info "Starting external tool update checks..."
    echo

    # Define tools to check with their repositories and current versions
    declare -A github_tools=(
        ["golang/go"]="${GO_VERSION:-1.23.9}"
        ["nodejs/node"]="${NODE_VERSION:-20}.19.2"
        ["rust-lang/rust"]="${RUST_VERSION:-1.87.0}"
        ["JetBrains/kotlin"]="${KOTLIN_VERSION:-2.1.10}"
        ["JuliaLang/julia"]="${JULIA_VERSION:-1.11.5}"
        ["docker/cli"]="${DOCKER_VERSION:-28.0.4}"
        ["kubernetes/kubernetes"]="${KUBECTL_VERSION:-1.33.1}"
        ["helm/helm"]="${HELM_VERSION:-3.18.1}"
        ["bazelbuild/bazel"]="${BAZEL_VERSION:-8.2.1}"
        ["kubernetes-sigs/kind"]="${KIND_VERSION:-0.29.0}"
        ["cli/cli"]="${GH_VERSION:-2.74.0}"
        ["Kitware/CMake"]="${CMAKE_VERSION:-3.31.6}"
        ["nvm-sh/nvm"]="${NVM_VERSION:-0.40.3}"
    )

    # Check GitHub releases
    echo "🔍 Checking GitHub releases..."
    for repo in "${!github_tools[@]}"; do
        check_github_release "$repo" "${github_tools[$repo]}" || true
    done
    echo

    # Check cloud CLIs (these need custom checking)
    echo "☁️ Checking Cloud CLI versions..."

    # AWS CLI
    check_custom_version "AWS CLI" \
        "curl -s 'https://api.github.com/repos/aws/aws-cli/tags' | jq -r '.[0].name // empty' | sed 's/^v//'" \
        "${AWS_CLI_VERSION:-2.27.27}" || true

    # Note: Azure CLI and Google Cloud CLI checks would require specific APIs
    log_info "Azure CLI (current: ${AZURE_CLI_VERSION:-2.73.0}) - manual verification needed"
    log_info "Google Cloud CLI (current: ${GCP_CLI_VERSION:-524.0.0}) - manual verification needed"
    echo

    # Check browser versions
    echo "🌐 Checking browser versions..."
    log_info "Chrome (current: ${CHROME_VERSION:-137.0.7151.55}) - auto-updated in Dockerfile"
    log_info "Firefox (current: ${FIREFOX_VERSION:-139.0.1}) - auto-updated in Dockerfile"
    echo

    # Summary
    echo "======================================"
    echo " Update Check Summary"
    echo "======================================"
    echo
    echo "Checks performed: ${checks_performed}"
    echo "Updates found: ${updates_found}"
    echo

    if [[ ${updates_found} -gt 0 ]]; then
        echo "📋 Available Updates:"
        for msg in "${update_messages[@]}"; do
            echo "  - $msg"
        done
        echo
        log_info "✅ Found ${updates_found} potential updates"

        # Set output for GitHub Actions if available
        if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
            {
                echo "has_external_updates=true"
                echo "update_count=${updates_found}"
                echo "update_summary=Found ${updates_found} tool updates available"
            } >> "$GITHUB_OUTPUT"
        fi
    else
        log_info "No external tool updates detected"

        # Set output for GitHub Actions if available
        if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
            {
                echo "has_external_updates=false"
                echo "update_count=0"
                echo "update_summary=No tool updates available"
            } >> "$GITHUB_OUTPUT"
        fi
    fi

    echo
    echo "Check completed successfully."
}

# Run main function
main "$@"