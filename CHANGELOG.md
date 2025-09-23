# Changelog

All notable changes to the Ubuntu Runner Docker image will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive documentation including API reference, setup guide, and contributing guidelines
- Automated weekly updates via GitHub Actions
- Multi-architecture support (AMD64 and ARM64)
- Security vulnerability scanning with Trivy
- Retry logic for Microsoft packages installation on ARM64
- Dynamic ChromeDriver version detection based on installed Chrome

### Changed
- Updated base image to Ubuntu 24.04
- Improved Dockerfile organization and layer optimization
- Enhanced Swift installation with multiple version fallback
- Updated Miniconda to latest version
- Replaced netcat with netcat-openbsd for better compatibility

### Fixed
- ARM64 build failures due to Microsoft package repository timeouts
- ChromeDriver installation issues with version mismatches
- Swift installation failures on certain architectures

## [1.0.0] - 2024-12-01

### Added
- Initial release based on Ubuntu 24.04
- Core development tools and languages:
  - Node.js 20.19.2 (LTS)
  - Python 3.12.3
  - Go 1.23.9
  - Rust 1.87.0
  - Java 8, 11, 17, 21 (OpenJDK)
  - Ruby 3.2.3
  - Julia 1.11.5
  - Kotlin 2.1.10
  - Swift 6.1.2
  - GCC 12, 13, 14
  - Clang 16, 17, 18
  - PowerShell 7.4.10
- Development tools:
  - Docker 28.0.4 with Compose and Buildx
  - Kubernetes tools (kubectl, helm, kind, minikube)
  - Cloud CLIs (AWS, Azure, Google Cloud)
  - Git 2.49.0 with LFS
  - GitHub CLI 2.74.0
  - Terraform and Packer
  - CMake 3.31.6
  - Bazel 8.2.1
- Package managers:
  - Homebrew (pre-installed)
  - Conda/Miniconda 25.3.1
  - vcpkg
- Database clients:
  - PostgreSQL 16.9
  - MySQL 8.0.42
  - SQLite 3.45.1
- GitHub Actions workflows for automated builds and updates
- Docker Hub and GitHub Container Registry publishing

## Version History

### Versioning Strategy

This project follows semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes or significant Ubuntu base image updates (e.g., 22.04 → 24.04)
- **MINOR**: New tools, languages, or significant feature additions
- **PATCH**: Bug fixes, tool version updates, and minor improvements

### Upgrade Guide

#### From 0.x to 1.0.0

1. **Base Image Change**: Updated from Ubuntu 22.04 to Ubuntu 24.04
   - Some system libraries may have different versions
   - Check compatibility with your applications

2. **Tool Version Updates**: Major version updates for many tools
   - Node.js: 18.x → 20.x
   - Python: 3.10 → 3.12
   - Review your code for compatibility

3. **Environment Variables**: Some paths have changed
   - Update scripts that rely on specific tool paths
   - Use the provided environment variables when possible

## Upcoming Features

### Planned for Next Release

- [ ] GPU support for machine learning workloads
- [ ] Additional language support (Zig, Nim, Crystal)
- [ ] Integrated development environment options
- [ ] Smaller, specialized variant images
- [ ] Improved caching mechanisms
- [ ] Health check endpoints
- [ ] Metrics and monitoring integration

### Under Consideration

- Kubernetes operator for managing development environments
- Web-based terminal interface
- Integration with cloud development environments
- Support for additional architectures (RISC-V)
- Development container templates

## Migration Guides

### Migrating from GitHub Actions Runner

If you're migrating from GitHub Actions runner to this Docker image:

1. **Environment Variables**: Most GitHub Actions environment variables are not set by default
   ```bash
   # Add to your scripts if needed
   export CI=true
   export GITHUB_ACTIONS=true
   ```

2. **Tool Paths**: Tools are installed in standard locations
   ```bash
   # GitHub Actions uses tool cache
   # This image uses standard system paths
   ```

3. **User Permissions**: Container runs as root by default
   ```bash
   # To run as non-root user
   docker run --user 1000:1000 ubuntu-runner
   ```

### Migrating from Other Base Images

If you're migrating from other development containers:

1. **From `node:latest`**:
   ```dockerfile
   # Replace
   FROM node:latest
   # With
   FROM ghcr.io/your-org/ubuntu-runner:latest
   ```

2. **From `python:3.12`**:
   ```dockerfile
   # Replace
   FROM python:3.12
   # With
   FROM ghcr.io/your-org/ubuntu-runner:latest
   # Python 3.12 is already installed
   ```

3. **From custom Ubuntu images**:
   - Review installed packages
   - Check for compatibility
   - Test thoroughly before switching

## Support Policy

### Version Support

| Version | Status | Support Until | Notes |
|---------|--------|---------------|-------|
| 1.0.x | Active | 2025-12-01 | Current stable release |
| 0.x.x | EOL | 2024-12-01 | No longer supported |

### Security Updates

- Security patches are released as soon as vulnerabilities are identified
- Critical security updates trigger immediate patch releases
- Regular security scans are performed weekly

### Tool Version Updates

- Major tool updates are bundled in minor releases
- Critical tool updates may trigger patch releases
- Tool versions are pinned for reproducibility

## Release Notes Format

Each release includes:

1. **Summary**: Brief overview of changes
2. **Breaking Changes**: Any backwards-incompatible changes
3. **New Features**: New capabilities added
4. **Improvements**: Enhancements to existing features
5. **Bug Fixes**: Resolved issues
6. **Security**: Security-related updates
7. **Dependencies**: Updated tool versions

## Contributing to Changelog

When contributing, please:

1. Add entries under "Unreleased" section
2. Use past tense for descriptions
3. Group changes by category (Added, Changed, Deprecated, Removed, Fixed, Security)
4. Include issue/PR numbers where applicable
5. Keep descriptions concise but informative

Example entry:
```markdown
### Fixed
- Fixed Node.js installation failure on ARM64 architectures (#123)
```

[Unreleased]: https://github.com/your-org/ubuntu-runner/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/your-org/ubuntu-runner/releases/tag/v1.0.0