# tailscale-derp

Automatically built and published container images for [Tailscale's DERP relay server](https://tailscale.com/kb/1232/derp-servers) (`derper`, from `tailscale/tailscale`).

This repo doesn't vendor DERP source — it tracks upstream [tailscale/tailscale releases](https://github.com/tailscale/tailscale/releases) and builds `cmd/derper` at each new tag.

## How it works

1. `check-upstream.yml` polls the latest `tailscale/tailscale` release every 6 hours. On a new version it bumps `VERSION`, opens a PR, merges it, and triggers a build.
2. `build-publish.yml` builds a multi-arch (`amd64`/`arm64`) image from `Dockerfile`, smoke-tests it, scans it with Trivy, pushes it to GHCR, and cuts a GitHub release.

## Images

```
ghcr.io/loq9/tailscale-derp:latest
ghcr.io/loq9/tailscale-derp:<tailscale-version>   # e.g. v1.98.9
ghcr.io/loq9/tailscale-derp:sha-<short-sha>
```

## Running it

```bash
docker run -d --name derper \
  -p 443:443 -p 8080:8080 -p 3478:3478/udp \
  ghcr.io/loq9/tailscale-derp:latest \
  --hostname=derp.example.com \
  --a=:443 \
  --http-port=8080 \
  --stun=true
```

By default the container expects TLS to be terminated in front of it (e.g. by a reverse proxy) or you can let `derper` manage Let's Encrypt certs itself with `--certmode=letsencrypt` and a writable `--certdir` volume.

Common flags (see `derper --help` for the full list):

| Flag | Purpose |
|---|---|
| `--hostname` | Public hostname clients use to reach this DERP node |
| `--certmode` | `letsencrypt` or `manual` |
| `--certdir` | Directory to store/read TLS certs |
| `--stun` | Enable the bundled STUN server (UDP 3478) |
| `--verify-clients` | Restrict use to nodes in your own tailnet |

## Local build

```bash
docker build --build-arg TAILSCALE_VERSION=$(cat VERSION) -t tailscale-derp:local .
```

## Manually triggering a build

```bash
gh workflow run build-publish.yml -f version=v1.98.9
```
