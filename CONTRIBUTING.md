# Contributing to Ubuntu Runner

First off, thank you for considering contributing to Ubuntu Runner! It's people like you that make Ubuntu Runner such a great tool for the developer community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Your First Code Contribution](#your-first-code-contribution)
  - [Pull Requests](#pull-requests)
- [Development Setup](#development-setup)
- [Style Guides](#style-guides)
  - [Git Commit Messages](#git-commit-messages)
  - [Dockerfile Style Guide](#dockerfile-style-guide)
  - [Documentation Style Guide](#documentation-style-guide)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to [project-email@example.com].

### Our Standards

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Create a branch** for your feature or fix
4. **Make your changes** and test thoroughly
5. **Push to your fork** and submit a pull request

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible.

**Bug Report Template:**

```markdown
### Description
[A clear and concise description of what the bug is]

### Steps To Reproduce
1. Pull the image: `docker pull ghcr.io/your-org/ubuntu-runner:latest`
2. Run command: `docker run ...`
3. See error

### Expected Behavior
[What you expected to happen]

### Actual Behavior
[What actually happened]

### Environment
- Docker version: [e.g., 24.0.5]
- Operating System: [e.g., Ubuntu 22.04]
- Architecture: [e.g., amd64, arm64]

### Additional Context
[Add any other context about the problem here]

### Logs
```
[Paste any relevant logs here]
```
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

**Enhancement Template:**

```markdown
### Is your feature request related to a problem?
[A clear description of the problem]

### Describe the solution you'd like
[A clear description of what you want to happen]

### Describe alternatives you've considered
[Any alternative solutions or features you've considered]

### Additional context
[Add any other context or screenshots about the feature request]
```

### Your First Code Contribution

Unsure where to begin contributing? You can start by looking through these issues:

- Issues labeled `good first issue` - issues which should only require a few lines of code
- Issues labeled `help wanted` - issues which should be a bit more involved
- Issues labeled `documentation` - issues related to improving documentation

### Pull Requests

1. **Follow the style guides**
2. **Include tests** when adding new features
3. **Update documentation** as necessary
4. **Write clear commit messages**
5. **Include a description** of your changes

**Pull Request Template:**

```markdown
### Description
[Brief description of the changes]

### Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

### Testing
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have tested the Docker image locally
- [ ] I have updated the documentation accordingly
- [ ] My changes generate no new warnings

### Checklist
- [ ] Image builds successfully
- [ ] All installed tools work as expected
- [ ] Documentation is updated
- [ ] Tests pass (if applicable)

### Screenshots (if applicable)
[Add screenshots to help explain your changes]
```

## Development Setup

### Prerequisites

- Docker 20.10+
- Docker Buildx (for multi-platform builds)
- Git
- GitHub CLI (optional, for workflow testing)

### Local Development

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/ubuntu-runner.git
   cd ubuntu-runner
   ```

2. **Create a development branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes to the Dockerfile**

4. **Build the image locally:**
   ```bash
   # Standard build
   docker build -t ubuntu-runner:dev .

   # Multi-platform build (requires buildx)
   docker buildx build --platform linux/amd64,linux/arm64 -t ubuntu-runner:dev .
   ```

5. **Test the image:**
   ```bash
   # Basic test
   docker run --rm ubuntu-runner:dev echo "Test successful"

   # Interactive testing
   docker run -it --rm ubuntu-runner:dev bash

   # Test specific tools
   docker run --rm ubuntu-runner:dev node --version
   docker run --rm ubuntu-runner:dev python3 --version
   docker run --rm ubuntu-runner:dev go version
   ```

6. **Run the test script:**
   ```bash
   ./scripts/test-image.sh ubuntu-runner:dev
   ```

### Testing Workflow Changes

1. **Test GitHub Actions locally with act:**
   ```bash
   # Install act
   brew install act  # macOS
   # or
   curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash  # Linux

   # Test workflows
   act -j build
   act -j update
   ```

2. **Validate workflow syntax:**
   ```bash
   # Using GitHub CLI
   gh workflow list
   gh workflow view build-and-push.yml
   ```

## Style Guides

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

**Commit Message Format:**

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that don't affect functionality
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Code change that improves performance
- `test`: Adding missing tests
- `chore`: Changes to the build process or auxiliary tools

**Examples:**
```
feat(python): upgrade to Python 3.12.3

Upgrades the Python installation to version 3.12.3 for improved
performance and security. This version includes important bug fixes
and performance improvements.

Closes #123
```

```
fix(docker): resolve ARM64 build failures

Add retry logic for Microsoft package installation on ARM64
architectures to handle intermittent network issues during builds.

Fixes #456
```

### Dockerfile Style Guide

1. **Use specific versions** for base images and tools
   ```dockerfile
   # Good
   FROM ubuntu:24.04

   # Bad
   FROM ubuntu:latest
   ```

2. **Combine RUN commands** to reduce layers
   ```dockerfile
   # Good
   RUN apt-get update && apt-get install -y \
       package1 \
       package2 \
       && rm -rf /var/lib/apt/lists/*

   # Bad
   RUN apt-get update
   RUN apt-get install -y package1
   RUN apt-get install -y package2
   ```

3. **Clean up in the same layer**
   ```dockerfile
   RUN apt-get update && apt-get install -y \
       build-essential \
       && make install \
       && apt-get remove -y build-essential \
       && apt-get autoremove -y \
       && rm -rf /var/lib/apt/lists/*
   ```

4. **Use COPY instead of ADD** when possible
   ```dockerfile
   # Good
   COPY scripts/install.sh /tmp/

   # Use ADD only for URLs or tar extraction
   ADD https://example.com/file.tar.gz /tmp/
   ```

5. **Set appropriate environment variables**
   ```dockerfile
   ENV DEBIAN_FRONTEND=noninteractive \
       TZ=UTC \
       LANG=en_US.UTF-8
   ```

6. **Add helpful comments**
   ```dockerfile
   # Install Node.js 20 LTS
   RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
       && apt-get install -y nodejs
   ```

### Documentation Style Guide

1. **Use clear, concise language**
2. **Include code examples** where appropriate
3. **Keep line length under 100 characters** for better readability
4. **Use proper markdown formatting**
5. **Include table of contents** for long documents
6. **Test all commands and examples**

## Testing

### Image Testing Script

Create a `scripts/test-image.sh`:

```bash
#!/bin/bash
set -e

IMAGE=${1:-"ubuntu-runner:dev"}

echo "Testing image: $IMAGE"

# Test basic functionality
echo "Testing basic commands..."
docker run --rm $IMAGE echo "Echo test: OK"
docker run --rm $IMAGE whoami

# Test programming languages
echo "Testing programming languages..."
docker run --rm $IMAGE node --version
docker run --rm $IMAGE python3 --version
docker run --rm $IMAGE go version
docker run --rm $IMAGE java -version
docker run --rm $IMAGE ruby --version
docker run --rm $IMAGE rustc --version

# Test development tools
echo "Testing development tools..."
docker run --rm $IMAGE git --version
docker run --rm $IMAGE docker --version
docker run --rm $IMAGE cmake --version

# Test package managers
echo "Testing package managers..."
docker run --rm $IMAGE npm --version
docker run --rm $IMAGE pip3 --version
docker run --rm $IMAGE cargo --version

echo "All tests passed!"
```

### Automated Testing

The project uses GitHub Actions for automated testing:

- **Build Test**: Builds the image on every push
- **Tool Verification**: Verifies all tools are properly installed
- **Multi-platform Test**: Tests on both amd64 and arm64
- **Security Scan**: Scans for vulnerabilities using Trivy

## Project Structure

```
ubuntu-runner/
├── .github/
│   └── workflows/
│       ├── build-and-push.yml    # Main CI/CD workflow
│       └── update-image.yml      # Automated update workflow
├── docs/
│   ├── API.md                    # API documentation
│   └── SETUP.md                   # Setup guide
├── scripts/
│   ├── check-external-updates.sh # Check for tool updates
│   └── test-image.sh             # Test script
├── .dockerignore                 # Docker ignore file
├── CONTRIBUTING.md               # This file
├── Dockerfile                    # Main Dockerfile
├── LICENSE                       # MIT License
└── README.md                     # Project documentation
```

### Key Files

- **Dockerfile**: The main image definition
- **.github/workflows/**: GitHub Actions workflows
- **scripts/**: Utility scripts for testing and updates
- **docs/**: Additional documentation

## Community

### Getting Help

- **GitHub Issues**: [Report bugs or request features](https://github.com/your-org/ubuntu-runner/issues)
- **Discussions**: [Ask questions and share ideas](https://github.com/your-org/ubuntu-runner/discussions)
- **Stack Overflow**: Tag your questions with `ubuntu-runner`

### Communication Channels

- **Discord**: [Join our Discord server](https://discord.gg/ubuntu-runner)
- **Slack**: [Join our Slack workspace](https://ubuntu-runner.slack.com)
- **Twitter**: [@ubuntu_runner](https://twitter.com/ubuntu_runner)

### Recognition

Contributors who have made significant contributions will be recognized in:

1. The project README
2. Release notes
3. Our Contributors page

### Contributor License Agreement

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

## Additional Notes

### Security

If you discover a security vulnerability, please do NOT open an issue. Instead, email [security@example.com] with:

1. Description of the vulnerability
2. Steps to reproduce
3. Potential impact
4. Suggested fix (if any)

### Release Process

1. Update version in relevant files
2. Update CHANGELOG.md
3. Create a pull request with changes
4. After merge, tag the release
5. GitHub Actions will automatically build and publish

### Versioning

We use [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: Backwards-compatible functionality additions
- **PATCH**: Backwards-compatible bug fixes

## Thank You!

Thank you for taking the time to contribute to Ubuntu Runner! Your efforts help make this project better for everyone in the developer community.