#!/bin/bash
# Install base dependencies and configure repositories
set -euo pipefail

echo "Installing base dependencies..."

# Update package list and install essential packages
apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    wget \
    git \
    sudo \
    unzip \
    build-essential

echo "Configuring package repositories..."

# Function to add repository with retry logic
add_repository_with_retry() {
    local key_url="$1"
    local key_path="$2"
    local repo_line="$3"
    local repo_file="$4"
    local max_attempts=3

    for i in $(seq 1 $max_attempts); do
        if curl -fsSL "$key_url" | gpg --dearmor -o "$key_path"; then
            echo "$repo_line" | tee "$repo_file"
            return 0
        else
            echo "Attempt $i failed for $key_url, retrying..." >&2
            sleep 5
        fi
    done
    return 1
}

# Microsoft packages repository
add_repository_with_retry \
    "https://packages.microsoft.com/keys/microsoft.asc" \
    "/usr/share/keyrings/microsoft-archive-keyring.gpg" \
    "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-noble-prod noble main" \
    "/etc/apt/sources.list.d/microsoft-prod.list"

# Docker repository
add_repository_with_retry \
    "https://download.docker.com/linux/ubuntu/gpg" \
    "/usr/share/keyrings/docker-archive-keyring.gpg" \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu noble stable" \
    "/etc/apt/sources.list.d/docker.list"

# Google Cloud SDK repository
add_repository_with_retry \
    "https://packages.cloud.google.com/apt/doc/apt-key.gpg" \
    "/usr/share/keyrings/cloud.google.gpg" \
    "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    "/etc/apt/sources.list.d/google-cloud-sdk.list"

# Kubernetes repository
add_repository_with_retry \
    "https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key" \
    "/usr/share/keyrings/kubernetes-apt-keyring.gpg" \
    "deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" \
    "/etc/apt/sources.list.d/kubernetes.list"

# HashiCorp repository
add_repository_with_retry \
    "https://apt.releases.hashicorp.com/gpg" \
    "/usr/share/keyrings/hashicorp-archive-keyring.gpg" \
    "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" \
    "/etc/apt/sources.list.d/hashicorp.list"

# GitHub CLI repository
add_repository_with_retry \
    "https://cli.github.com/packages/githubcli-archive-keyring.gpg" \
    "/usr/share/keyrings/githubcli-archive-keyring.gpg" \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    "/etc/apt/sources.list.d/github-cli.list"

# Chrome repository
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

# Update package list with new repositories
apt-get update

echo "Base installation complete."