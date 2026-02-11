FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

ARG RUST_VERSION=""
ARG SOLANA_VERSION=""
ARG ANCHOR_VERSION=""
ARG NODE_VERSION=22

ENV HOME=/root

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    libudev-dev \
    git \
    openssh-client \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs

# Install pnpm
RUN npm install -g pnpm

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="$HOME/.cargo/bin:$PATH"

RUN if [ -n "$RUST_VERSION" ]; then rustup install $RUST_VERSION && rustup default $RUST_VERSION; fi

# Install Solana + Anchor
RUN curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash
ENV PATH="$HOME/.local/share/solana/install/active_release/bin:$HOME/.avm/bin:$PATH"

RUN if [ -n "$SOLANA_VERSION" ]; then agave-install init $SOLANA_VERSION; fi

RUN if [ -n "$ANCHOR_VERSION" ]; then avm install $ANCHOR_VERSION && avm use $ANCHOR_VERSION; fi

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="$HOME/.local/bin:$PATH"

# Copy git aliases
COPY gitconfig $HOME/.gitconfig

# Install git completion
RUN curl -o /etc/bash_completion.d/git-completion.bash \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash && \
    curl -o /etc/bash_completion.d/git-prompt.sh \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

# Configure bashrc: ssh-agent + git completion + prompt (no colors)
RUN echo 'eval "$(ssh-agent -s)"' >> $HOME/.bashrc && \
    echo 'source /etc/bash_completion.d/git-completion.bash' >> $HOME/.bashrc && \
    echo 'source /etc/bash_completion.d/git-prompt.sh' >> $HOME/.bashrc && \
    echo 'export PS1="\u@\h:\w\$(__git_ps1 \" (%s)\")\$ "' >> $HOME/.bashrc

WORKDIR /workspace

CMD ["/bin/bash"]
