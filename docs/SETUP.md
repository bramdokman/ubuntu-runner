# Setup Guide

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
  - [Using Docker Hub/GitHub Container Registry](#using-docker-hubgithub-container-registry)
  - [Building from Source](#building-from-source)
  - [Using Docker Compose](#using-docker-compose)
- [Initial Configuration](#initial-configuration)
- [Development Environment Setup](#development-environment-setup)
- [IDE Integration](#ide-integration)
- [CI/CD Integration](#cicd-integration)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements

- **Operating System**: Linux, macOS, or Windows with WSL2
- **Docker**: Version 20.10 or higher
- **Memory**: Minimum 4GB RAM (8GB recommended)
- **Storage**: Minimum 20GB free space (50GB recommended for full development)
- **CPU**: 2 cores minimum (4+ cores recommended)

### Software Requirements

1. **Docker Desktop** (Windows/macOS) or **Docker Engine** (Linux)
   ```bash
   # Check Docker version
   docker --version
   # Should output: Docker version 20.10 or higher
   ```

2. **Git** (optional, for building from source)
   ```bash
   git --version
   ```

3. **Docker Compose** (optional, for orchestration)
   ```bash
   docker compose version
   ```

## Installation Methods

### Using Docker Hub/GitHub Container Registry

#### Quick Install

```bash
# Pull the latest image
docker pull ghcr.io/your-org/ubuntu-runner:latest

# Verify the installation
docker run --rm ghcr.io/your-org/ubuntu-runner:latest echo "Installation successful!"
```

#### Specific Version

```bash
# Pull a specific version
docker pull ghcr.io/your-org/ubuntu-runner:v1.2.3

# List available tags
# Visit: https://github.com/your-org/ubuntu-runner/pkgs/container/ubuntu-runner
```

### Building from Source

#### Clone the Repository

```bash
# Clone the repository
git clone https://github.com/your-org/ubuntu-runner.git
cd ubuntu-runner

# Checkout a specific version (optional)
git checkout v1.2.3
```

#### Build the Image

```bash
# Build for current architecture
docker build -t ubuntu-runner:local .

# Build with custom tag
docker build -t myorg/ubuntu-runner:custom .

# Build with build arguments
docker build \
  --build-arg UBUNTU_VERSION=24.04 \
  --build-arg TIMEZONE=America/New_York \
  -t ubuntu-runner:custom .
```

#### Multi-Architecture Build

```bash
# Setup buildx (one-time)
docker buildx create --use

# Build for multiple platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ubuntu-runner:multi \
  --push .
```

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  dev-environment:
    image: ghcr.io/your-org/ubuntu-runner:latest
    container_name: ubuntu-dev
    stdin_open: true
    tty: true
    volumes:
      # Mount current directory
      - .:/workspace
      # Mount SSH keys (read-only)
      - ~/.ssh:/root/.ssh:ro
      # Mount Git config
      - ~/.gitconfig:/root/.gitconfig:ro
      # Docker socket for Docker-in-Docker
      - /var/run/docker.sock:/var/run/docker.sock
    working_dir: /workspace
    environment:
      - DISPLAY=${DISPLAY}
      - TZ=America/New_York
    network_mode: host
    # Uncomment for privileged mode (required for some operations)
    # privileged: true

  # Additional service example
  database:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: mysecretpassword
      POSTGRES_DB: myapp
    ports:
      - "5432:5432"
```

Start the services:

```bash
# Start in background
docker compose up -d

# Attach to the dev environment
docker compose exec dev-environment bash

# Stop services
docker compose down
```

## Initial Configuration

### Basic Configuration

1. **Create an alias for quick access**:
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   alias ubuntu-dev='docker run -it --rm -v $(pwd):/workspace -w /workspace ghcr.io/your-org/ubuntu-runner:latest'

   # Usage
   ubuntu-dev bash
   ubuntu-dev python3 script.py
   ```

2. **Create a configuration script**:
   ```bash
   # Create ~/ubuntu-runner-config.sh
   cat > ~/ubuntu-runner-config.sh << 'EOF'
   #!/bin/bash
   docker run -it --rm \
     -v $(pwd):/workspace \
     -v ~/.ssh:/root/.ssh:ro \
     -v ~/.aws:/root/.aws:ro \
     -v ~/.config:/root/.config \
     -v /var/run/docker.sock:/var/run/docker.sock \
     -w /workspace \
     --network host \
     ghcr.io/your-org/ubuntu-runner:latest \
     "$@"
   EOF

   chmod +x ~/ubuntu-runner-config.sh
   ```

### Advanced Configuration

#### Environment Variables

Create a `.env` file for your project:

```bash
# .env
NODE_ENV=development
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
API_KEY=your-secret-key
DEBUG=true
```

Use with Docker:

```bash
docker run --env-file .env ghcr.io/your-org/ubuntu-runner:latest
```

#### Custom Dockerfile

Extend the base image for your specific needs:

```dockerfile
# Dockerfile.custom
FROM ghcr.io/your-org/ubuntu-runner:latest

# Install additional tools
RUN apt-get update && apt-get install -y \
    postgresql-client \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Install global npm packages
RUN npm install -g typescript ts-node nodemon

# Install Python packages
RUN pip3 install --no-cache-dir \
    django \
    flask \
    fastapi \
    uvicorn

# Set custom environment variables
ENV NODE_ENV=development
ENV PYTHONPATH=/workspace

# Create a non-root user (optional)
RUN useradd -m -s /bin/bash developer
USER developer

WORKDIR /workspace
```

Build and use:

```bash
docker build -f Dockerfile.custom -t my-ubuntu-runner .
docker run -it my-ubuntu-runner bash
```

## Development Environment Setup

### Language-Specific Setup

#### Node.js Development

```bash
# Start container with Node.js project
docker run -it -v $(pwd):/workspace -w /workspace ghcr.io/your-org/ubuntu-runner:latest bash

# Inside container
npm init -y
npm install express typescript @types/node
npx tsc --init
npm run dev
```

#### Python Development

```bash
# Start container with Python project
docker run -it -v $(pwd):/workspace -w /workspace ghcr.io/your-org/ubuntu-runner:latest bash

# Inside container
python3 -m venv venv
source venv/bin/activate
pip install django djangorestframework
django-admin startproject myproject .
python manage.py runserver 0.0.0.0:8000
```

#### Java Development

```bash
# Start container with Java project
docker run -it -v $(pwd):/workspace -w /workspace ghcr.io/your-org/ubuntu-runner:latest bash

# Inside container
mvn archetype:generate -DgroupId=com.example -DartifactId=myapp
cd myapp
mvn clean package
java -jar target/myapp-1.0-SNAPSHOT.jar
```

### Database Setup

#### PostgreSQL Connection

```bash
# Start PostgreSQL container
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  postgres:16

# Connect from ubuntu-runner
docker run -it \
  --link postgres:db \
  ghcr.io/your-org/ubuntu-runner:latest \
  psql -h db -U postgres
```

#### MySQL Connection

```bash
# Start MySQL container
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=mysecretpassword \
  -p 3306:3306 \
  mysql:8.0

# Connect from ubuntu-runner
docker run -it \
  --link mysql:db \
  ghcr.io/your-org/ubuntu-runner:latest \
  mysql -h db -u root -p
```

## IDE Integration

### Visual Studio Code

1. **Install Docker extension**:
   - Open VS Code
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "Docker" and install

2. **Remote Development**:
   ```json
   // .devcontainer/devcontainer.json
   {
     "name": "Ubuntu Runner Dev",
     "image": "ghcr.io/your-org/ubuntu-runner:latest",
     "workspaceFolder": "/workspace",
     "mounts": [
       "source=${localWorkspaceFolder},target=/workspace,type=bind"
     ],
     "customizations": {
       "vscode": {
         "extensions": [
           "ms-python.python",
           "dbaeumer.vscode-eslint",
           "ms-azuretools.vscode-docker"
         ]
       }
     },
     "postCreateCommand": "echo 'Container ready!'",
     "remoteUser": "root"
   }
   ```

### JetBrains IDEs (IntelliJ, PyCharm, WebStorm)

1. **Configure Docker**:
   - Settings → Build, Execution, Deployment → Docker
   - Add Docker configuration
   - Set image: `ghcr.io/your-org/ubuntu-runner:latest`

2. **Run Configuration**:
   - Edit Configurations → Add New → Docker → Image
   - Image ID: `ghcr.io/your-org/ubuntu-runner:latest`
   - Container name: `ubuntu-dev`
   - Bind mounts: `/path/to/project:/workspace`

### Vim/Neovim

```bash
# Start container with vim configuration
docker run -it \
  -v $(pwd):/workspace \
  -v ~/.vimrc:/root/.vimrc:ro \
  -v ~/.vim:/root/.vim:ro \
  ghcr.io/your-org/ubuntu-runner:latest \
  vim
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/your-org/ubuntu-runner:latest
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    steps:
      - uses: actions/checkout@v4

      - name: Run tests
        run: |
          npm install
          npm test

      - name: Build application
        run: |
          npm run build

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-artifacts
          path: dist/
```

### GitLab CI

```yaml
# .gitlab-ci.yml
image: ghcr.io/your-org/ubuntu-runner:latest

stages:
  - test
  - build
  - deploy

test:
  stage: test
  script:
    - npm install
    - npm test
  artifacts:
    reports:
      junit: test-results.xml

build:
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/

deploy:
  stage: deploy
  script:
    - echo "Deploying application"
  only:
    - main
```

### Jenkins

```groovy
// Jenkinsfile
pipeline {
    agent {
        docker {
            image 'ghcr.io/your-org/ubuntu-runner:latest'
            args '-v /var/run/docker.sock:/var/run/docker.sock --privileged'
        }
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                sh 'npm install'
                sh 'npm test'
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'npm run deploy'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
```

## Customization

### Adding Custom Tools

Create a script to install additional tools:

```bash
#!/bin/bash
# setup-custom-tools.sh

# Update package list
apt-get update

# Install additional development tools
apt-get install -y \
    vim-gtk3 \
    tmux \
    htop \
    ncdu \
    tree

# Install Rust tools
cargo install ripgrep fd-find bat exa

# Install Go tools
go install github.com/jesseduffield/lazygit@latest
go install github.com/jesseduffield/lazydocker@latest

# Install Python tools
pip3 install --user \
    ipython \
    jupyter \
    black \
    pylint \
    mypy

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*
```

Run in container:

```bash
docker run -it -v $(pwd)/setup-custom-tools.sh:/setup.sh ghcr.io/your-org/ubuntu-runner:latest bash /setup.sh
```

### Creating Specialized Images

```dockerfile
# Dockerfile.nodejs
FROM ghcr.io/your-org/ubuntu-runner:latest

# Install Node.js development tools
RUN npm install -g \
    @angular/cli \
    @vue/cli \
    create-react-app \
    express-generator \
    nest \
    next

# Install development dependencies
RUN npm install -g \
    webpack \
    webpack-cli \
    babel-cli \
    eslint \
    prettier \
    jest

WORKDIR /workspace
```

## Troubleshooting

### Common Issues and Solutions

#### Issue: Container exits immediately

**Solution**: Use `-it` flags for interactive mode:
```bash
docker run -it ghcr.io/your-org/ubuntu-runner:latest bash
```

#### Issue: Permission denied when accessing files

**Solution**: Check file permissions and user ID:
```bash
# Run with current user ID
docker run -it --user $(id -u):$(id -g) ghcr.io/your-org/ubuntu-runner:latest bash

# Or fix permissions
docker run -it ghcr.io/your-org/ubuntu-runner:latest chown -R $(id -u):$(id -g) /workspace
```

#### Issue: Cannot connect to Docker daemon

**Solution**: Mount Docker socket with proper permissions:
```bash
docker run -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add $(getent group docker | cut -d: -f3) \
  ghcr.io/your-org/ubuntu-runner:latest bash
```

#### Issue: Out of disk space

**Solution**: Clean up Docker resources:
```bash
# Remove unused containers
docker container prune

# Remove unused images
docker image prune -a

# Remove all unused resources
docker system prune -a

# Check disk usage
docker system df
```

#### Issue: Slow performance on macOS/Windows

**Solution**: Optimize Docker Desktop settings:
1. Increase memory allocation in Docker Desktop settings
2. Use named volumes instead of bind mounts for better performance
3. Enable virtiofs on macOS for improved file sharing

```bash
# Use named volume for better performance
docker volume create myproject
docker run -v myproject:/workspace ghcr.io/your-org/ubuntu-runner:latest
```

### Getting Help

1. **Check container logs**:
   ```bash
   docker logs <container-id>
   ```

2. **Inspect container**:
   ```bash
   docker inspect <container-id>
   ```

3. **Debug inside container**:
   ```bash
   docker exec -it <container-id> bash
   ```

4. **Community Support**:
   - GitHub Issues: [Report issues](https://github.com/your-org/ubuntu-runner/issues)
   - Discussions: [Ask questions](https://github.com/your-org/ubuntu-runner/discussions)

## Next Steps

- Review the [API Documentation](API.md) for detailed tool information
- Read the [Contributing Guidelines](../CONTRIBUTING.md) to help improve the project
- Check the [README](../README.md) for quick reference and updates