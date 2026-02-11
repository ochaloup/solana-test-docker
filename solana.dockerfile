## HOWTO
# Build once
#  docker build -f solana.dockerfile -t solana-anchor-dev .
# # Override specific versions
# docker build -f solana.dockerfile -t solana-anchor-dev \
#     --build-arg SOLANA_VERSION=2.2.0 \
#     --build-arg ANCHOR_VERSION=0.29.0 \
#     --build-arg RUST_VERSION=1.79.0
#
# Run with your SSH key mounted
# docker run -it --rm \
#     -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro \
#     solana-anchor-dev
#
# Persist cloned code
#  docker run -it --rm \
#     -v ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro \
#     -v $(pwd)/projects:/workspace \
#     solana-anchor-dev

FROM ubuntu:24.04

# Build arguments with default versions
ARG SOLANA_VERSION=2.3.1
ARG ANCHOR_VERSION=0.30.1
ARG RUST_VERSION=1.88.0

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    curl \
    git \
    openssh-client \
    ca-certificates \
    build-essential \
    pkg-config \
    libssl-dev \
    libudev-dev \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install specific Rust version
RUN rustup install ${RUST_VERSION} && \
    rustup default ${RUST_VERSION}

# Install pnpm
ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"
RUN curl -fsSL https://get.pnpm.io/install.sh | SHELL=/bin/bash bash -

# Install Solana CLI
RUN sh -c "$(curl -sSfL https://release.anza.xyz/v${SOLANA_VERSION}/install)"
ENV PATH="/root/.local/share/solana/install/active_release/bin:${PATH}"

# Install Anchor Version Manager (avm) and Anchor
RUN cargo install --git https://github.com/solana-foundation/anchor avm --force && \
    avm install ${ANCHOR_VERSION} && \
    avm use ${ANCHOR_VERSION}

# Setup SSH directory structure and add GitHub to known hosts
# The actual key will be mounted at runtime
RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    chmod 644 /root/.ssh/known_hosts

# Set working directory
WORKDIR /workspace

# Default shell
SHELL ["/bin/bash", "-c"]

# Keep container running interactively
CMD ["/bin/bash"]
