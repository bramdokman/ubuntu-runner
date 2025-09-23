# Code Quality Guidelines

## Overview

This document outlines the code quality standards and best practices for the Ubuntu Runner project.

## Standards

### 1. Shell Scripts

All shell scripts follow these standards:

- **Shellcheck**: All scripts must pass shellcheck validation
- **Error Handling**: Use `set -euo pipefail` for strict error handling
- **Functions**: Modular functions with clear single responsibilities
- **Variables**: Use `readonly` for constants, proper quoting
- **Documentation**: Clear comments and usage instructions

Best Practices:
```bash
#!/bin/bash
set -euo pipefail

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Function with error handling
install_tool() {
    local tool_name="$1"
    local version="${2:-latest}"

    echo "Installing ${tool_name} version ${version}..."
    # Implementation here
}
```

### 2. YAML Files

YAML files are validated using yamllint with these rules:

- **Line Length**: Maximum 120 characters
- **Indentation**: 2 spaces, consistent throughout
- **Document Start**: All files begin with `---`
- **Truthy Values**: Use explicit `true`/`false`
- **Comments**: Require space after `#`

Configuration: `.yamllint.yml`

### 3. Dockerfile

Docker best practices:

- **Multi-stage Builds**: Use when appropriate for smaller images
- **Layer Caching**: Order commands from least to most frequently changing
- **Security**: Don't run as root, minimize attack surface
- **Size Optimization**: Clean up after installations, combine RUN commands
- **Labels**: Use OCI standard labels for metadata

Example:
```dockerfile
# Group related installations
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

### 4. GitHub Actions Workflows

Workflow standards:

- **Reusability**: Use composite actions and reusable workflows
- **Security**: Pin action versions to SHA, use least privilege
- **Efficiency**: Cache dependencies, run jobs in parallel
- **Documentation**: Clear job names and step descriptions

## Metrics

### Complexity Metrics

Target metrics for maintainability:

| Metric | Target | Current |
|--------|--------|---------|
| Cyclomatic Complexity | < 10 | ✅ |
| Lines per Function | < 50 | ✅ |
| File Length | < 500 | ✅ |
| Duplication | < 5% | ✅ |

### Test Coverage

- **Unit Tests**: Not applicable (infrastructure code)
- **Integration Tests**: GitHub Actions workflow tests
- **Security Scans**: Trivy and Grype vulnerability scanning

## Tools

### Static Analysis

- **yamllint**: YAML file validation
- **shellcheck**: Shell script analysis (when available)
- **hadolint**: Dockerfile linting (recommended)
- **actionlint**: GitHub Actions workflow linting (recommended)

### Security Scanning

- **Trivy**: Container vulnerability scanning
- **Grype**: Alternative vulnerability scanner
- **GitHub Security**: SARIF upload integration

### Automation

- **Makefile**: Common tasks automation
- **GitHub Actions**: CI/CD pipeline
- **Pre-commit hooks**: (Recommended) Local validation

## Continuous Improvement

### Review Process

1. **Pre-commit**: Run local linting and tests
2. **Pull Request**: Automated CI checks
3. **Security Scans**: Automatic vulnerability detection
4. **Code Review**: Manual review for logic and design

### Monitoring

- **Build Status**: GitHub Actions dashboard
- **Security Alerts**: GitHub Security tab
- **Update Tracking**: `check-external-updates.sh` script

## Contributing

When contributing code:

1. Follow the style guide in `.editorconfig`
2. Run `make lint` before committing
3. Ensure all CI checks pass
4. Update documentation if needed
5. Keep commits atomic and well-described

## References

- [Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/guides/best-practices)
- [YAML Best Practices](https://yaml.org/spec/1.2/spec.html)