# J2ME Development Environment

Docker images for building legacy J2ME / Java ME projects with JDK 6, Sun Java Wireless Toolkit 2.5.2, and Apache Ant.

## Images

This repository provides two images:

- `j2me-deps`: downloads and preserves legacy dependency files in `/deps`
- `j2me-env`: builds the actual J2ME development environment from `j2me-deps`

The split image design helps keep builds reproducible even if old upstream download servers become unavailable.

## Usage

```bash
docker pull ghcr.io/labac-dev/j2me-env:latest
docker run --rm -it -v "$PWD:/workspace" ghcr.io/labac-dev/j2me-env:latest
```

## Devcontainer

```json
{
  "name": "J2ME Env",
  "image": "ghcr.io/labac-dev/j2me-env:latest",
  "remoteUser": "vscode",
  "workspaceFolder": "/workspace"
}
```

## Included Tools

- JDK 6
- Sun Java Wireless Toolkit 2.5.2
- Apache Ant
- Git
- Python 3
- SQLite
- Ripgrep

## Build Locally

```bash
docker build -f Dockerfile.deps -t j2me-deps:local .

docker build \
  -f Dockerfile \
  --build-arg DEPS_IMAGE=j2me-deps:local \
  -t j2me-env:local .
```
