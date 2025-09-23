# Ubuntu Runner - Development Environment Container
# Version: 2.0.0
# Description: Comprehensive Ubuntu 24.04 image with development tools

FROM ubuntu:24.04

# Metadata labels
LABEL maintainer="github-actions[bot]"
LABEL org.opencontainers.image.title="Ubuntu Runner"
LABEL org.opencontainers.image.description="Ubuntu 24.04 with comprehensive development tools"
LABEL org.opencontainers.image.version="2.0.0"
LABEL org.opencontainers.image.source="https://github.com/your-org/ubuntu-runner"
LABEL org.opencontainers.image.licenses="MIT"

# Build arguments for customization
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=UTC

# Environment variables
ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND} \
    TZ=${TZ} \
    PATH=$PATH:/usr/local/go/bin:/root/.cargo/bin:/home/linuxbrew/.linuxbrew/bin:/usr/share/miniconda/bin \
    CONDA=/usr/share/miniconda \
    VCPKG_INSTALLATION_ROOT=/usr/local/share/vcpkg \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    ANDROID_HOME=/usr/local/lib/android/sdk \
    CHROMEWEBDRIVER=/usr/local/share/chromedriver-linux64

# Copy version configuration
COPY versions.env /versions.env

# Copy installation scripts
COPY scripts/install-base.sh /tmp/install-base.sh
COPY scripts/install-languages.sh /tmp/install-languages.sh
COPY scripts/install-tools.sh /tmp/install-tools.sh

# Make scripts executable
RUN chmod +x /tmp/install-*.sh

# Stage 1: Install base dependencies and configure repositories
RUN /tmp/install-base.sh

# Stage 2: Install core system packages
RUN apt-get install -y \
    acl aria2 autoconf automake binutils bison brotli bzip2 \
    coreutils curl dbus dnsutils dpkg dpkg-dev fakeroot file \
    findutils flex fonts-noto-color-emoji ftp g++ gcc gnupg2 \
    haveged iproute2 iputils-ping jq libsqlite3-dev libssl-dev \
    libtool libyaml-dev locales lz4 m4 make mediainfo mercurial \
    net-tools netcat-openbsd openssh-client p7zip-full p7zip-rar \
    parallel patchelf pigz pkg-config pollinate python-is-python3 \
    python3.12 rpm rsync shellcheck sphinxsearch sqlite3 ssh \
    sshpass sudo swig systemd-coredump tar telnet texinfo time \
    tk tree tzdata unzip upx wget xvfb xz-utils zip zsync \
    && rm -rf /var/lib/apt/lists/*

# Stage 3: Install compilers and language tools from APT
RUN apt-get update && apt-get install -y \
    clang-16 clang-17 clang-18 \
    clang-format-16 clang-format-17 clang-format-18 \
    clang-tidy-16 clang-tidy-17 clang-tidy-18 \
    dash gfortran-12 gfortran-13 gfortran-14 \
    perl ruby ruby-dev \
    && rm -rf /var/lib/apt/lists/*

# Stage 4: Install databases
RUN apt-get update && apt-get install -y \
    postgresql-16 postgresql-client-16 \
    mysql-server-8.0 mysql-client-8.0 \
    && rm -rf /var/lib/apt/lists/*

# Stage 5: Install cloud tools and container tools
RUN apt-get update && apt-get install -y \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin \
    google-cloud-cli kubectl \
    terraform packer \
    dotnet-sdk-8.0 powershell gh \
    && rm -rf /var/lib/apt/lists/*

# Stage 6: Install browsers
RUN apt-get update && apt-get install -y \
    google-chrome-stable firefox \
    && rm -rf /var/lib/apt/lists/*

# Stage 7: Install programming languages
RUN /tmp/install-languages.sh

# Stage 8: Install development tools
RUN /tmp/install-tools.sh

# Stage 9: Cleanup
RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -f /versions.env

# Set working directory
WORKDIR /workspace

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD command -v git && command -v docker && command -v node || exit 1

# Default command
CMD ["/bin/bash"]