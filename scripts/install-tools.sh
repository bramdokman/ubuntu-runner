#!/bin/bash
# Install development tools
set -euo pipefail

# Source versions if available
if [ -f /versions.env ]; then
    source /versions.env
fi

echo "Installing development tools..."

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

# Install CMake
echo "Installing CMake ${CMAKE_VERSION}..."
download_and_install \
    "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz" \
    "/tmp/cmake.tar.gz"
tar -C /opt -xzf /tmp/cmake.tar.gz
ln -s "/opt/cmake-${CMAKE_VERSION}-linux-x86_64/bin/cmake" /usr/local/bin/cmake
rm /tmp/cmake.tar.gz

# Install Bazel
echo "Installing Bazel ${BAZEL_VERSION}..."
BAZEL_URLS=(
    "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh"
    "https://github.com/bazelbuild/bazel/releases/download/7.4.1/bazel-7.4.1-installer-linux-x86_64.sh"
)

for url in "${BAZEL_URLS[@]}"; do
    if download_and_install "$url" "/tmp/bazel.sh"; then
        chmod +x /tmp/bazel.sh
        /tmp/bazel.sh
        rm /tmp/bazel.sh
        break
    fi
done

# Install Kind
echo "Installing Kind ${KIND_VERSION}..."
curl -Lo /usr/local/bin/kind "https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64"
chmod +x /usr/local/bin/kind

# Install Helm
echo "Installing Helm ${HELM_VERSION}..."
curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar -xzC /tmp
mv /tmp/linux-amd64/helm /usr/local/bin/helm
rm -rf /tmp/linux-amd64

# Install Miniconda
echo "Installing Miniconda..."
MINICONDA_URLS=(
    "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    "https://repo.anaconda.com/miniconda/Miniconda3-py312_24.11.1-0-Linux-x86_64.sh"
)

for url in "${MINICONDA_URLS[@]}"; do
    if download_and_install "$url" "/tmp/miniconda.sh"; then
        bash /tmp/miniconda.sh -b -p /usr/share/miniconda
        rm /tmp/miniconda.sh
        break
    fi
done

# Install AWS CLI
echo "Installing AWS CLI..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip

# Install Azure CLI
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Homebrew
echo "Installing Homebrew..."
useradd -m linuxbrew || true
su - linuxbrew -c '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' || true

# Install Node.js global packages
echo "Installing Node.js global packages..."
npm install -g newman n parcel lerna

# Install ChromeDriver
echo "Installing ChromeDriver..."
mkdir -p /usr/local/share/chromedriver-linux64

# Try to get Chrome version and install matching ChromeDriver
if command -v google-chrome &> /dev/null; then
    CHROME_VERSION=$(google-chrome --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
    CHROMEDRIVER_URLS=(
        "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chromedriver-linux64.zip"
        "https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.204/linux64/chromedriver-linux64.zip"
        "https://storage.googleapis.com/chrome-for-testing-public/130.0.6723.116/linux64/chromedriver-linux64.zip"
    )

    for url in "${CHROMEDRIVER_URLS[@]}"; do
        if download_and_install "$url" "/tmp/chromedriver.zip"; then
            unzip -q /tmp/chromedriver.zip -d /tmp/
            mv /tmp/chromedriver-linux64/chromedriver /usr/local/share/chromedriver-linux64/
            chmod +x /usr/local/share/chromedriver-linux64/chromedriver
            rm -rf /tmp/chromedriver.zip /tmp/chromedriver-linux64
            break
        fi
    done
fi

echo "Tools installation complete."