# API Documentation

## Table of Contents

- [Environment Variables](#environment-variables)
- [Installed Tools](#installed-tools)
- [Language Runtimes](#language-runtimes)
- [Package Managers](#package-managers)
- [Docker Integration](#docker-integration)
- [Cloud CLI Tools](#cloud-cli-tools)
- [Build Tools](#build-tools)
- [Database Clients](#database-clients)
- [Volume Mounts](#volume-mounts)
- [Network Configuration](#network-configuration)

## Environment Variables

The Docker image provides numerous pre-configured environment variables for various tools and utilities:

### Core Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `DEBIAN_FRONTEND` | `noninteractive` | Prevents interactive prompts during package installation |
| `TZ` | `UTC` | Default timezone |
| `PATH` | Extended PATH | Includes various tool directories |
| `LANG` | `en_US.UTF-8` | Default locale |
| `LC_ALL` | `en_US.UTF-8` | Default locale override |

### Development Tools

| Variable | Value | Description |
|----------|-------|-------------|
| `JAVA_HOME` | `/usr/lib/jvm/java-17-openjdk-amd64` | Default Java 17 installation |
| `JAVA_8_HOME` | `/usr/lib/jvm/java-8-openjdk-amd64` | Java 8 installation |
| `JAVA_11_HOME` | `/usr/lib/jvm/java-11-openjdk-amd64` | Java 11 installation |
| `JAVA_17_HOME` | `/usr/lib/jvm/java-17-openjdk-amd64` | Java 17 installation |
| `JAVA_21_HOME` | `/usr/lib/jvm/java-21-openjdk-amd64` | Java 21 installation |
| `ANDROID_HOME` | `/usr/local/lib/android/sdk` | Android SDK location |
| `ANDROID_SDK_ROOT` | `/usr/local/lib/android/sdk` | Android SDK root |

### Package Managers

| Variable | Value | Description |
|----------|-------|-------------|
| `CONDA` | `/usr/share/miniconda` | Miniconda installation |
| `VCPKG_INSTALLATION_ROOT` | `/usr/local/share/vcpkg` | vcpkg installation |
| `HOMEBREW_PREFIX` | `/home/linuxbrew/.linuxbrew` | Homebrew prefix (not in PATH by default) |
| `HOMEBREW_CELLAR` | `/home/linuxbrew/.linuxbrew/Cellar` | Homebrew cellar |
| `HOMEBREW_REPOSITORY` | `/home/linuxbrew/.linuxbrew/Homebrew` | Homebrew repository |

### Browser Drivers

| Variable | Value | Description |
|----------|-------|-------------|
| `CHROMEWEBDRIVER` | `/usr/local/share/chromedriver-linux64` | ChromeDriver location |
| `GECKODRIVER` | `/usr/local/share/gecko_driver` | GeckoDriver location |
| `SELENIUM_JAR_PATH` | `/usr/share/java/selenium-server.jar` | Selenium server JAR |

## Installed Tools

### Version Information

The image includes the following major tools with their respective versions:

#### Programming Languages

| Language | Version | Command | Notes |
|----------|---------|---------|-------|
| **Node.js** | 20.19.2 | `node --version` | LTS version |
| **Python** | 3.12.3 | `python3 --version` | Default system Python |
| **Go** | 1.23.9 | `go version` | Latest stable |
| **Rust** | 1.87.0 | `rustc --version` | With Cargo |
| **Java** | 8, 11, 17, 21 | `java -version` | Multiple versions available |
| **Ruby** | 3.2.3 | `ruby --version` | With RubyGems |
| **Julia** | 1.11.5 | `julia --version` | Latest stable |
| **Kotlin** | 2.1.10 | `kotlin -version` | JVM language |
| **Swift** | 6.1.2 | `swift --version` | Apple's language |
| **C/C++** | GCC 12, 13, 14 | `gcc --version` | Multiple versions |
| **Clang** | 16, 17, 18 | `clang --version` | LLVM compiler |
| **PowerShell** | 7.4.10 | `pwsh --version` | Cross-platform PowerShell |

#### Development Tools

| Tool | Version | Command | Description |
|------|---------|---------|-------------|
| **Git** | 2.49.0 | `git --version` | Version control |
| **GitHub CLI** | 2.74.0 | `gh --version` | GitHub command line |
| **Docker** | 28.0.4 | `docker --version` | Container runtime |
| **Docker Compose** | 2.x | `docker compose version` | Container orchestration |
| **CMake** | 3.31.6 | `cmake --version` | Build system |
| **Bazel** | 8.2.1 | `bazel --version` | Build tool |
| **Make** | 4.3 | `make --version` | Build automation |
| **Maven** | 3.9.x | `mvn --version` | Java build tool |
| **Gradle** | 8.x | `gradle --version` | Build automation |

## Language Runtimes

### Node.js

Multiple Node.js versions can be managed through `nvm` (Node Version Manager):

```bash
# List available versions
nvm list

# Install a specific version
nvm install 18

# Switch between versions
nvm use 20
```

### Python

Python environments can be managed through:

- **System Python**: Python 3.12.3
- **Conda**: Create isolated environments
- **pyenv**: Multiple Python versions (if needed)

```bash
# Create a conda environment
conda create -n myenv python=3.11

# Activate environment
conda activate myenv

# Install packages
pip install numpy pandas
```

### Java

Switch between Java versions:

```bash
# Set Java 11
export JAVA_HOME=$JAVA_11_HOME
export PATH=$JAVA_HOME/bin:$PATH

# Set Java 17
export JAVA_HOME=$JAVA_17_HOME
export PATH=$JAVA_HOME/bin:$PATH

# Set Java 21
export JAVA_HOME=$JAVA_21_HOME
export PATH=$JAVA_HOME/bin:$PATH
```

## Package Managers

### System Package Managers

| Manager | Command | Purpose |
|---------|---------|---------|
| **apt** | `apt install` | Ubuntu system packages |
| **snap** | `snap install` | Snap packages |
| **flatpak** | `flatpak install` | Flatpak applications |

### Language-Specific Package Managers

| Language | Manager | Command | Config File |
|----------|---------|---------|-------------|
| **Node.js** | npm | `npm install` | `package.json` |
| **Node.js** | yarn | `yarn add` | `package.json` |
| **Python** | pip | `pip install` | `requirements.txt` |
| **Python** | conda | `conda install` | `environment.yml` |
| **Ruby** | gem | `gem install` | `Gemfile` |
| **Ruby** | bundler | `bundle install` | `Gemfile` |
| **Rust** | cargo | `cargo add` | `Cargo.toml` |
| **Go** | go mod | `go get` | `go.mod` |
| **Java** | maven | `mvn install` | `pom.xml` |
| **Java** | gradle | `gradle build` | `build.gradle` |
| **C++** | vcpkg | `vcpkg install` | `vcpkg.json` |

### Homebrew

Homebrew is installed but not in PATH by default. To activate:

```bash
# Add Homebrew to your PATH
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Install packages
brew install jq yq

# List installed packages
brew list
```

## Docker Integration

### Docker-in-Docker (DinD)

The image supports Docker-in-Docker operations:

```bash
# Start Docker daemon (requires privileged mode)
docker run --privileged ghcr.io/your-org/ubuntu-runner:latest

# Inside container
service docker start
docker run hello-world
```

### Docker Compose

```yaml
# Example docker-compose.yml
version: '3.8'
services:
  app:
    image: ghcr.io/your-org/ubuntu-runner:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: docker ps
```

## Cloud CLI Tools

### AWS CLI

```bash
# Configure AWS credentials
aws configure

# Example usage
aws s3 ls
aws ec2 describe-instances
```

### Azure CLI

```bash
# Login to Azure
az login

# Example usage
az vm list
az storage account list
```

### Google Cloud SDK

```bash
# Initialize gcloud
gcloud init

# Example usage
gcloud compute instances list
gcloud storage ls
```

## Build Tools

### CMake

```bash
# Basic CMake workflow
mkdir build && cd build
cmake ..
make
make install
```

### Bazel

```bash
# Build a target
bazel build //main:app

# Run tests
bazel test //test:all

# Clean build
bazel clean
```

### Make

```bash
# Run default target
make

# Run specific target
make install

# Clean build artifacts
make clean
```

## Database Clients

### PostgreSQL

```bash
# Connect to PostgreSQL
psql -h localhost -U postgres -d mydb

# Version
psql --version
# PostgreSQL 16.9
```

### MySQL

```bash
# Connect to MySQL
mysql -h localhost -u root -p

# Version
mysql --version
# mysql Ver 8.0.42
```

### SQLite

```bash
# Open SQLite database
sqlite3 mydatabase.db

# Version
sqlite3 --version
# SQLite 3.45.1
```

## Volume Mounts

### Recommended Volume Mount Points

| Mount Point | Purpose | Example |
|-------------|---------|---------|
| `/workspace` | Project files | `-v $(pwd):/workspace` |
| `/root/.ssh` | SSH keys | `-v ~/.ssh:/root/.ssh:ro` |
| `/root/.aws` | AWS credentials | `-v ~/.aws:/root/.aws:ro` |
| `/root/.config` | User configs | `-v ~/.config:/root/.config` |
| `/var/run/docker.sock` | Docker socket | `-v /var/run/docker.sock:/var/run/docker.sock` |

### Example Usage

```bash
# Development environment with all common mounts
docker run -it \
  -v $(pwd):/workspace \
  -v ~/.ssh:/root/.ssh:ro \
  -v ~/.aws:/root/.aws:ro \
  -v ~/.config:/root/.config \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -w /workspace \
  ghcr.io/your-org/ubuntu-runner:latest \
  bash
```

## Network Configuration

### Port Mapping

```bash
# Map container port to host
docker run -p 8080:8080 ghcr.io/your-org/ubuntu-runner:latest

# Map multiple ports
docker run -p 3000:3000 -p 5432:5432 ghcr.io/your-org/ubuntu-runner:latest

# Map to specific interface
docker run -p 127.0.0.1:8080:8080 ghcr.io/your-org/ubuntu-runner:latest
```

### Network Modes

| Mode | Command | Use Case |
|------|---------|----------|
| **bridge** | `--network bridge` | Default, isolated network |
| **host** | `--network host` | Use host networking |
| **none** | `--network none` | No networking |
| **custom** | `--network mynet` | User-defined network |

## API Examples

### Running Scripts

```bash
# Python script
docker run -v $(pwd):/workspace ghcr.io/your-org/ubuntu-runner:latest python3 /workspace/script.py

# Node.js application
docker run -v $(pwd):/workspace ghcr.io/your-org/ubuntu-runner:latest node /workspace/app.js

# Go program
docker run -v $(pwd):/workspace ghcr.io/your-org/ubuntu-runner:latest go run /workspace/main.go
```

### Building Projects

```bash
# Java Maven project
docker run -v $(pwd):/workspace -w /workspace ghcr.io/your-org/ubuntu-runner:latest mvn clean package

# Node.js project
docker run -v $(pwd):/workspace -w /workspace ghcr.io/your-org/ubuntu-runner:latest npm install && npm test

# Rust project
docker run -v $(pwd):/workspace -w /workspace ghcr.io/your-org/ubuntu-runner:latest cargo build --release
```

### CI/CD Integration

```yaml
# GitHub Actions
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/your-org/ubuntu-runner:latest
      options: --privileged
    steps:
      - uses: actions/checkout@v4
      - run: |
          npm install
          npm test
          npm run build
```

```groovy
// Jenkins Pipeline
pipeline {
    agent {
        docker {
            image 'ghcr.io/your-org/ubuntu-runner:latest'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm test'
            }
        }
    }
}
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **Docker daemon not running** | Run container with `--privileged` flag |
| **Permission denied** | Check volume mount permissions or run as root |
| **Command not found** | Tool might not be in PATH, check installation path |
| **Out of memory** | Increase container memory limits with `-m` flag |
| **Homebrew not working** | Run `eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"` first |

### Getting Help

```bash
# Check installed versions
docker run ghcr.io/your-org/ubuntu-runner:latest cat /etc/os-release

# List all installed packages
docker run ghcr.io/your-org/ubuntu-runner:latest dpkg -l

# Check specific tool installation
docker run ghcr.io/your-org/ubuntu-runner:latest which python3
```

## Security Considerations

- Always use read-only mounts (`:ro`) for sensitive directories like SSH keys
- Avoid running containers with `--privileged` unless necessary
- Use specific user IDs instead of root when possible
- Regularly update the base image for security patches
- Scan images for vulnerabilities using tools like Trivy or Snyk

## Performance Tips

- Use volume mounts instead of copying files into the container
- Enable BuildKit for faster Docker builds
- Use multi-stage builds to reduce image size
- Cache dependencies in separate layers
- Use `.dockerignore` to exclude unnecessary files

## Related Documentation

- [Setup Guide](SETUP.md) - Installation and configuration
- [Contributing Guidelines](../CONTRIBUTING.md) - How to contribute
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com/)