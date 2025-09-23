#!/bin/bash

# Test script for Ubuntu Runner Docker image
# Usage: ./scripts/test-image.sh [image-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default image name
IMAGE=${1:-"ghcr.io/your-org/ubuntu-runner:latest"}

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

echo "==========================================="
echo "Testing Ubuntu Runner Docker Image"
echo "Image: $IMAGE"
echo "==========================================="
echo ""

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"

    echo -n "Testing $test_name... "

    if output=$(docker run --rm $IMAGE sh -c "$test_command" 2>&1); then
        if [[ -z "$expected_pattern" ]] || echo "$output" | grep -q "$expected_pattern"; then
            echo -e "${GREEN}✓${NC}"
            ((TESTS_PASSED++))
            return 0
        else
            echo -e "${RED}✗${NC} (pattern not found: $expected_pattern)"
            echo "  Output: $output"
            ((TESTS_FAILED++))
            return 1
        fi
    else
        echo -e "${RED}✗${NC} (command failed)"
        echo "  Error: $output"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Function to test version output
test_version() {
    local tool_name="$1"
    local version_command="$2"
    local min_version="$3"

    echo -n "Testing $tool_name... "

    if output=$(docker run --rm $IMAGE sh -c "$version_command" 2>&1); then
        # Extract version number (handles various formats)
        if version=$(echo "$output" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1); then
            echo -e "${GREEN}✓${NC} (version: $version)"
            ((TESTS_PASSED++))
            return 0
        else
            echo -e "${GREEN}✓${NC} (installed)"
            ((TESTS_PASSED++))
            return 0
        fi
    else
        echo -e "${RED}✗${NC} (not found)"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Basic functionality tests
echo "=== Basic Functionality ==="
run_test "Echo command" "echo 'Hello World'" "Hello World"
run_test "Working directory" "pwd" "/workspace"
run_test "User check" "whoami" "root"
run_test "OS version" "cat /etc/os-release | grep VERSION_ID" "24.04"
echo ""

# Programming Languages
echo "=== Programming Languages ==="
test_version "Node.js" "node --version"
test_version "npm" "npm --version"
test_version "Python 3" "python3 --version"
test_version "pip3" "pip3 --version"
test_version "Go" "go version"
test_version "Rust" "rustc --version"
test_version "Cargo" "cargo --version"
test_version "Java" "java --version"
test_version "Ruby" "ruby --version"
test_version "Julia" "julia --version"
test_version "Kotlin" "kotlin -version"
test_version "Swift" "swift --version"
test_version "GCC" "gcc --version"
test_version "Clang" "clang --version"
test_version "PowerShell" "pwsh --version"
echo ""

# Development Tools
echo "=== Development Tools ==="
test_version "Git" "git --version"
test_version "GitHub CLI" "gh --version"
test_version "Docker" "docker --version"
test_version "Docker Compose" "docker compose version"
test_version "CMake" "cmake --version"
test_version "Make" "make --version"
test_version "Maven" "mvn --version"
test_version "Gradle" "gradle --version"
test_version "Bazel" "bazel --version"
echo ""

# Package Managers
echo "=== Package Managers ==="
test_version "apt" "apt --version"
test_version "yarn" "yarn --version"
test_version "Conda" "conda --version"
run_test "vcpkg" "test -d $VCPKG_INSTALLATION_ROOT" ""
run_test "Homebrew" "test -d /home/linuxbrew/.linuxbrew" ""
echo ""

# Cloud CLIs
echo "=== Cloud CLIs ==="
test_version "AWS CLI" "aws --version"
test_version "Azure CLI" "az --version"
test_version "Google Cloud SDK" "gcloud --version"
echo ""

# Kubernetes Tools
echo "=== Kubernetes Tools ==="
test_version "kubectl" "kubectl version --client=true"
test_version "Helm" "helm version --short"
test_version "kind" "kind --version"
test_version "Minikube" "minikube version"
echo ""

# Database Clients
echo "=== Database Clients ==="
test_version "PostgreSQL client" "psql --version"
test_version "MySQL client" "mysql --version"
test_version "SQLite" "sqlite3 --version"
echo ""

# Environment Variables
echo "=== Environment Variables ==="
run_test "JAVA_HOME" "test -n \"\$JAVA_HOME\"" ""
run_test "ANDROID_HOME" "test -n \"\$ANDROID_HOME\"" ""
run_test "CONDA" "test -n \"\$CONDA\"" ""
run_test "VCPKG_INSTALLATION_ROOT" "test -n \"\$VCPKG_INSTALLATION_ROOT\"" ""
run_test "CHROMEWEBDRIVER" "test -n \"\$CHROMEWEBDRIVER\"" ""
echo ""

# File System
echo "=== File System ==="
run_test "/workspace directory" "test -d /workspace" ""
run_test "/tmp directory" "test -d /tmp && test -w /tmp" ""
echo ""

# Network Tools
echo "=== Network Tools ==="
run_test "curl" "curl --version" "curl"
run_test "wget" "wget --version" "GNU Wget"
run_test "netcat" "nc -h 2>&1" ""
echo ""

# Compression Tools
echo "=== Compression Tools ==="
run_test "tar" "tar --version" "tar"
run_test "gzip" "gzip --version" "gzip"
run_test "unzip" "unzip -v" "UnZip"
run_test "7zip" "7z" "7-Zip"
echo ""

# Additional Tools
echo "=== Additional Tools ==="
test_version "jq" "jq --version"
test_version "yq" "yq --version"
run_test "parallel" "parallel --version" "GNU parallel"
run_test "rsync" "rsync --version" "rsync"
echo ""

# Advanced Tests
echo "=== Advanced Tests ==="

# Test Python package installation
run_test "Python pip install" "pip3 install --no-cache-dir requests && python3 -c 'import requests; print(\"OK\")'" "OK"

# Test Node.js package installation
run_test "Node npm install" "cd /tmp && npm init -y >/dev/null 2>&1 && npm install lodash >/dev/null 2>&1 && node -e 'require(\"lodash\"); console.log(\"OK\")'" "OK"

# Test Go module
run_test "Go module" "cd /tmp && go mod init test >/dev/null 2>&1 && echo 'OK'" "OK"

# Test Java compilation
run_test "Java compilation" "echo 'public class Test { public static void main(String[] args) { System.out.println(\"OK\"); } }' > /tmp/Test.java && cd /tmp && javac Test.java && java Test" "OK"

# Test Ruby gem
run_test "Ruby gem" "gem list | grep -q bundler && echo 'OK'" "OK"

# Test Rust cargo
run_test "Rust cargo new" "cd /tmp && cargo new test_project >/dev/null 2>&1 && test -d test_project && echo 'OK'" "OK"

echo ""

# Summary
echo "==========================================="
echo "Test Summary"
echo "==========================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed successfully!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed. Please review the output above.${NC}"
    exit 1
fi