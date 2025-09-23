# Ubuntu Runner Docker Image

[![Docker Image CI](https://github.com/your-org/ubuntu-runner/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/your-org/ubuntu-runner/actions/workflows/build-and-push.yml)
[![Weekly Updates](https://github.com/your-org/ubuntu-runner/actions/workflows/update-image.yml/badge.svg)](https://github.com/your-org/ubuntu-runner/actions/workflows/update-image.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/ghcr.io/your-org/ubuntu-runner)](https://github.com/your-org/ubuntu-runner/pkgs/container/ubuntu-runner)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Ubuntu 24.04 Docker image with development tools, languages, and CLI utilities - automatically updated via GitHub Actions.

## 📚 Documentation

- [API Documentation](docs/API.md) - Detailed API and environment variable reference
- [Setup Guide](docs/SETUP.md) - Installation and configuration instructions
- [Contributing Guidelines](CONTRIBUTING.md) - How to contribute to the project
- [Changelog](CHANGELOG.md) - Version history and updates

## 🚀 Quick Start

```bash
# Pull the latest image
docker pull ghcr.io/your-org/ubuntu-runner:latest

# Run interactively
docker run -it ghcr.io/your-org/ubuntu-runner:latest bash

# Run with volume mounting
docker run -it -v $(pwd):/workspace ghcr.io/your-org/ubuntu-runner:latest bash
```

## ✨ Features

This image includes all the software from the Ubuntu 24.04 GitHub Actions runner:

### Languages & Runtimes
- **Node.js** 20.19.2 with npm and yarn
- **Python** 3.12.3 with pip and pipx
- **Go** 1.23.9
- **Rust** 1.87.0 with Cargo
- **Java** 8, 11, 17, 21 (OpenJDK)
- **Ruby** 3.2.3 with RubyGems
- **Julia** 1.11.5
- **Kotlin** 2.1.10
- **Swift** 6.1.2
- **C/C++** (GCC 12, 13, 14 & Clang 16, 17, 18)
- **PowerShell** 7.4.10

### Development Tools
- **Docker** 28.0.4 with Compose and Buildx
- **Kubernetes** tools (kubectl, helm, kind, minikube)
- **Cloud CLIs** (AWS, Azure, Google Cloud)
- **Git** 2.49.0 with LFS
- **GitHub CLI** 2.74.0
- **Terraform** and Packer
- **CMake** 3.31.6
- **Bazel** 8.2.1

### Package Managers
- **Homebrew** (pre-installed but not in PATH)
- **Conda/Miniconda** 25.3.1
- **vcpkg** and various language-specific managers

### Databases
- **PostgreSQL** 16.9
- **MySQL** 8.0.42
- **SQLite** 3.45.1

## 📦 Installation & Usage

For detailed setup instructions, see the [Setup Guide](docs/SETUP.md).

### Pull and Run
```bash
docker pull ghcr.io/your-org/ubuntu-runner:latest
docker run -it ghcr.io/your-org/ubuntu-runner:latest
```

### Use in GitHub Actions
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/your-org/ubuntu-runner:latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          # Your build commands here
          npm install
          npm test
```

### Use in Docker Compose
```yaml
version: '3.8'
services:
  dev:
    image: ghcr.io/your-org/ubuntu-runner:latest
    volumes:
      - .:/workspace
    working_dir: /workspace
    command: bash
```

## 🔄 Automatic Updates

This image is automatically updated every Monday at 6 AM UTC via GitHub Actions:

- **Package Updates**: Checks for Ubuntu package updates
- **Tool Updates**: Monitors GitHub releases for development tools
- **Security Scanning**: Runs vulnerability scans on built images
- **Multi-arch Support**: Builds for both AMD64 and ARM64

### Manual Update
You can trigger an update manually:
```bash
gh workflow run update-image.yml
```

## 🔧 Configuration

### Environment Variables

Key environment variables set in the image:

```bash
CONDA=/usr/share/miniconda
VCPKG_INSTALLATION_ROOT=/usr/local/share/vcpkg
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ANDROID_HOME=/usr/local/lib/android/sdk
CHROMEWEBDRIVER=/usr/local/share/chromedriver-linux64
```

## Activating Homebrew
Homebrew is installed but not in PATH by default:
```bash
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### Available Tools & Versions

For a complete list of installed tools and their versions, see the [API Documentation](docs/API.md).

## 🏗️ Building Locally

```bash
git clone <this-repo>
cd ubuntu-runner
docker build -t ubuntu-runner .
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for detailed instructions on how to:

- Report bugs and request features
- Set up your development environment
- Submit pull requests
- Follow our coding standards

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💬 Support

- **Issues**: [Report bugs or request features](../../issues)
- **Discussions**: [Ask questions and share ideas](../../discussions)
- **Build Status**: [GitHub Actions logs](../../actions)
- **Security**: [Security advisories](../../security/advisories) for known vulnerabilities

## 🙏 Acknowledgments

This project is inspired by the GitHub Actions runner images and aims to provide a similar environment for local development and CI/CD pipelines.

## 🔗 Related Projects

- [GitHub Actions Virtual Environments](https://github.com/actions/virtual-environments)
- [Docker Official Images](https://github.com/docker-library/official-images)