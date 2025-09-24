
# Docker Cleanup Utility

A minimal, safe, and professional **Docker cleanup helper** for Linux, macOS, and Windows.
Supports rootless Docker, rootful Docker Engine, and Docker Desktop.

---

## Features

- **Safe defaults**: removes unused containers, images, volumes, and networks
- **Full cleanup**: wipes everything except system defaults (`bridge`, `host`, `none`)
- **Rootless support**: auto-detects user socket
- **Tested**: comes with shell-based sanity checks
- **Bin helper**: run from anywhere with `bin/docker-cleanup`

---

## Installation

Download and install the latest release without cloning:

```bash
curl -L https://github.com/freddiedfre/docker-cleanup/releases/latest/download/docker-cleanup-$(uname -s | tr '[:upper:]' '[:lower:]')-amd64.tar.gz \
  | sudo tar -xz -C /usr/local/bin
```

### ⚡ Usage

```bash
docker-cleanup --help
```

## Development

Clone the repo and add `bin/` to your PATH:

```bash
git clone https://github.com/freddiedfre/docker-cleanup.git
cd docker-cleanup
chmod +x bin/docker-cleanup scripts/docker-cleanup.sh
export PATH="$PWD/bin:$PATH"
```

(Optionally, add the `export PATH=...` line to your `~/.bashrc` or `~/.zshrc`.)

```bash
make lint
make test
make install
```

## Release

To cut a new release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will build tarballs and publish them automatically.

---

## License

[MIT](./LICENSE)
