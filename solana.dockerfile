## HOWTO
# Build once
#  docker build -f solana.dockerfile -t solana-anchor-dev .
# # Override specific versions
#  docker build -f solana.dockerfile -t solana-anchor-dev --build-arg SOLANA_VERSION=2.3.1 --build-arg ANCHOR_VERSION=0.31.1 .
#
# Run with your SSH key mounted
#  docker run -it --rm -v  ~/.ssh/id_ed25519_github:/root/.ssh/id_rsa:ro solana-anchor-dev

# Persist cloned code
#  docker run -it --rm -v  ~/.ssh/id_ed25519_github:/root/.ssh/id_rsa:ro -v $(pwd)/projects:/workspace solana-anchor-dev

# Before cloning
# ssh-add

# ----- Change of version within the container -----
# Rust: rustup install <version> && rustup default <version>
# Solana: agave-install init <version>
# Anchor: avm install <version> && avm use <version>
# ---------------------------------------------------

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ARG RUST_VERSION=""
ARG SOLANA_VERSION=""
ARG ANCHOR_VERSION=""
ARG NODE_VERSION=22

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    libudev-dev \
    git \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs

# Install pnpm
RUN npm install -g pnpm

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"

RUN if [ -n "$RUST_VERSION" ]; then rustup install $RUST_VERSION && rustup default $RUST_VERSION; fi

# Install Solana + Anchor
RUN curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash
ENV PATH="/root/.local/share/solana/install/active_release/bin:/root/.avm/bin:$PATH"

RUN if [ -n "$SOLANA_VERSION" ]; then agave-install init $SOLANA_VERSION; fi

RUN if [ -n "$ANCHOR_VERSION" ]; then avm install $ANCHOR_VERSION && avm use $ANCHOR_VERSION; fi

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/root/.local/bin:$PATH"

# Start ssh-agent automatically
RUN echo 'eval "$(ssh-agent -s)"' >> /root/.bashrc

WORKDIR /workspace

CMD ["/bin/bash"]