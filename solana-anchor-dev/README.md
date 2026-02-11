# Dockerfile for local Anchor Solana development

## To build

Build once

```sh
 docker build -f solana.dockerfile -t solana-anchor-dev .
```

Override specific versions

```sh
docker build -f solana.dockerfile -t solana-anchor-dev --build-arg SOLANA_VERSION=2.3.1 --build-arg ANCHOR_VERSION=0.31.1 .
```

Arguments to configure

```sh
--build-arg RUST_VERSION=1.88.0
--build-arg SOLANA_VERSION=2.3.1
--build-arg ANCHOR_VERSION=0.32.1
--build-arg NODE_VERSION=24
```

## To run

Run with your SSH key mounted

```
docker run -it --rm -v  ~/.ssh/id_ed25519_github:/root/.ssh/id_rsa:ro solana-anchor-dev
```

Persist cloned code
```
docker run -it --rm -v  ~/.ssh/id_ed25519_github:/root/.ssh/id_rsa:ro -v $(pwd)/projects:/workspace solana-anchor-dev
```

## Whithin container

To load ssh key to agent

```sh
ssh-add
```

To change version in container

* Rust: `rustup install <version> && rustup default <version>`
* Solana: `agave-install init <version>`
* Anchor: `avm install <version> && avm use <version>`

