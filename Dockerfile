FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install basic dependencies
RUN apt-get update && apt-get install -y \
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

# Install Microsoft packages repository (with retry for ARM64 builds)
RUN for i in 1 2 3; do \
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg && break || \
        (echo "Attempt $i failed, retrying..." && sleep 5); \
    done
RUN echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/microsoft-ubuntu-noble-prod noble main" | tee /etc/apt/sources.list.d/microsoft-prod.list

# Install Docker repository
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu noble stable" | tee /etc/apt/sources.list.d/docker.list

# Install Google Cloud SDK repository
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Install Kubernetes repository
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
RUN echo 'deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

# Install HashiCorp repository
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" | tee /etc/apt/sources.list.d/hashicorp.list

# Update package list
RUN apt-get update

# Install core system packages
RUN apt-get install -y \
    acl \
    aria2 \
    autoconf \
    automake \
    binutils \
    bison \
    brotli \
    bzip2 \
    coreutils \
    curl \
    dbus \
    dnsutils \
    dpkg \
    dpkg-dev \
    fakeroot \
    file \
    findutils \
    flex \
    fonts-noto-color-emoji \
    ftp \
    g++ \
    gcc \
    gnupg2 \
    haveged \
    iproute2 \
    iputils-ping \
    jq \
    libsqlite3-dev \
    libssl-dev \
    libtool \
    libyaml-dev \
    locales \
    lz4 \
    m4 \
    make \
    mediainfo \
    mercurial \
    net-tools \
    netcat-openbsd \
    openssh-client \
    p7zip-full \
    p7zip-rar \
    parallel \
    patchelf \
    pigz \
    pkg-config \
    pollinate \
    python-is-python3 \
    rpm \
    rsync \
    shellcheck \
    sphinxsearch \
    sqlite3 \
    ssh \
    sshpass \
    sudo \
    swig \
    systemd-coredump \
    tar \
    telnet \
    texinfo \
    time \
    tk \
    tree \
    tzdata \
    unzip \
    upx \
    wget \
    xvfb \
    xz-utils \
    zip \
    zsync

# Install language runtimes and compilers
RUN apt-get install -y \
    clang-16 \
    clang-17 \
    clang-18 \
    clang-format-16 \
    clang-format-17 \
    clang-format-18 \
    clang-tidy-16 \
    clang-tidy-17 \
    clang-tidy-18 \
    dash \
    gfortran-12 \
    gfortran-13 \
    gfortran-14 \
    perl \
    python3.12 \
    ruby \
    ruby-dev

# Install databases
RUN apt-get install -y \
    postgresql-16 \
    postgresql-client-16 \
    mysql-server-8.0 \
    mysql-client-8.0

# Install Docker
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Google Cloud SDK
RUN apt-get install -y google-cloud-cli

# Install Kubernetes tools
RUN apt-get install -y kubectl

# Install HashiCorp tools
RUN apt-get install -y terraform packer

# Install .NET
RUN apt-get install -y dotnet-sdk-8.0

# Install PowerShell
RUN apt-get install -y powershell

# Install Node.js via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

# Install Yarn
RUN npm install -g yarn

# Install Go
RUN wget https://go.dev/dl/go1.23.9.linux-amd64.tar.gz -O /tmp/go.tar.gz
RUN tar -C /usr/local -xzf /tmp/go.tar.gz
RUN rm /tmp/go.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=$PATH:/root/.cargo/bin

# Install Julia
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.11/julia-1.11.5-linux-x86_64.tar.gz -O /tmp/julia.tar.gz
RUN tar -C /opt -xzf /tmp/julia.tar.gz
RUN ln -s /opt/julia-1.11.5/bin/julia /usr/local/bin/julia
RUN rm /tmp/julia.tar.gz

# Install Kotlin
RUN wget https://github.com/JetBrains/kotlin/releases/download/v2.1.10/kotlin-compiler-2.1.10.zip -O /tmp/kotlin.zip
RUN unzip /tmp/kotlin.zip -d /opt
RUN ln -s /opt/kotlinc/bin/kotlin /usr/local/bin/kotlin
RUN ln -s /opt/kotlinc/bin/kotlinc /usr/local/bin/kotlinc
RUN rm /tmp/kotlin.zip

# Install Swift (try multiple known versions)
RUN wget https://download.swift.org/swift-6.0.2-release/ubuntu2204/swift-6.0.2-RELEASE-ubuntu22.04.tar.gz -O /tmp/swift.tar.gz || \
    wget https://download.swift.org/swift-5.10.1-release/ubuntu2204/swift-5.10.1-RELEASE-ubuntu22.04.tar.gz -O /tmp/swift.tar.gz || \
    (echo "Swift installation failed, continuing without Swift" && touch /tmp/swift.tar.gz)
RUN if [ -s /tmp/swift.tar.gz ]; then \
        tar -C /opt -xzf /tmp/swift.tar.gz && \
        SWIFT_DIR=$(ls /opt | grep swift | head -1) && \
        [ ! -z "$SWIFT_DIR" ] && ln -s /opt/${SWIFT_DIR}/usr/bin/swift /usr/local/bin/swift || true; \
    fi
RUN rm -f /tmp/swift.tar.gz

# Install Homebrew
RUN useradd -m linuxbrew
RUN su - linuxbrew -c '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
ENV PATH=$PATH:/home/linuxbrew/.linuxbrew/bin

# Install Miniconda (try latest available version)
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh || \
    wget https://repo.anaconda.com/miniconda/Miniconda3-py312_24.11.1-0-Linux-x86_64.sh -O /tmp/miniconda.sh
RUN bash /tmp/miniconda.sh -b -p /usr/share/miniconda
RUN rm /tmp/miniconda.sh
ENV PATH=$PATH:/usr/share/miniconda/bin
ENV CONDA=/usr/share/miniconda

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
RUN unzip /tmp/awscliv2.zip -d /tmp
RUN /tmp/aws/install
RUN rm -rf /tmp/aws /tmp/awscliv2.zip

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list
RUN apt-get update && apt-get install -y gh

# Install additional development tools
RUN npm install -g newman n parcel lerna

# Install Python tools
RUN pip3 install --upgrade pip pipx

# Install Haskell Stack
RUN curl -sSL https://get.haskellstack.org/ | sh

# Install CMake (latest version)
RUN wget https://github.com/Kitware/CMake/releases/download/v3.31.6/cmake-3.31.6-linux-x86_64.tar.gz -O /tmp/cmake.tar.gz
RUN tar -C /opt -xzf /tmp/cmake.tar.gz
RUN ln -s /opt/cmake-3.31.6-linux-x86_64/bin/cmake /usr/local/bin/cmake
RUN rm /tmp/cmake.tar.gz

# Install additional tools
RUN wget https://github.com/bazelbuild/bazel/releases/download/8.2.1/bazel-8.2.1-installer-linux-x86_64.sh -O /tmp/bazel.sh || \
    wget https://github.com/bazelbuild/bazel/releases/download/7.4.1/bazel-7.4.1-installer-linux-x86_64.sh -O /tmp/bazel.sh
RUN chmod +x /tmp/bazel.sh && /tmp/bazel.sh && rm /tmp/bazel.sh

# Install Kind
RUN curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64
RUN chmod +x /usr/local/bin/kind

# Install Helm
RUN curl -fsSL https://get.helm.sh/helm-v3.18.1-linux-amd64.tar.gz | tar -xzC /tmp
RUN mv /tmp/linux-amd64/helm /usr/local/bin/helm

# Install browsers and drivers
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update && apt-get install -y google-chrome-stable

# Install Firefox
RUN apt-get install -y firefox

# Install WebDrivers
RUN mkdir -p /usr/local/share/chromedriver-linux64
RUN CHROME_VERSION=$(google-chrome --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+') && \
    wget "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chromedriver-linux64.zip" -O /tmp/chromedriver.zip || \
    wget "https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.204/linux64/chromedriver-linux64.zip" -O /tmp/chromedriver.zip || \
    wget "https://storage.googleapis.com/chrome-for-testing-public/130.0.6723.116/linux64/chromedriver-linux64.zip" -O /tmp/chromedriver.zip
RUN unzip /tmp/chromedriver.zip -d /tmp/ && \
    mv /tmp/chromedriver-linux64/chromedriver /usr/local/share/chromedriver-linux64/ && \
    chmod +x /usr/local/share/chromedriver-linux64/chromedriver
RUN rm -rf /tmp/chromedriver.zip /tmp/chromedriver-linux64

# Set environment variables
ENV CHROMEWEBDRIVER=/usr/local/share/chromedriver-linux64
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV ANDROID_HOME=/usr/local/lib/android/sdk
ENV VCPKG_INSTALLATION_ROOT=/usr/local/share/vcpkg

# Clean up
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
CMD ["/bin/bash"]