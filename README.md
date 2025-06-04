# Ubuntu Runner Docker Image

A comprehensive Ubuntu 24.04 Docker image with development tools, languages, and CLI utilities - automatically updated via GitHub Actions.

## Features

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

## Usage

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

## Automatic Updates

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

## Environment Variables

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

## Building Locally

```bash
git clone <this-repo>
cd ubuntu-runner
docker build -t ubuntu-runner .
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with the provided workflows
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

- Create an issue for bug reports or feature requests
- Check the [GitHub Actions logs](../../actions) for build status
- Review [security advisories](../../security/advisories) for known vulnerabilities