# homebrew-threadbase

Homebrew tap for [tb-streamer](https://github.com/RonenMars/threadbase-streamer) — PTY session management, WebSocket streaming, and REST API server for Claude Code conversations.

## Install

```sh
brew install RonenMars/threadbase/tb-streamer
```

This installs the `tb-streamer` command and registers a `brew services` definition. The release tarballs are pre-built per platform (`darwin-arm64`, `darwin-x64`, `linux-x64`) and include all native dependencies (`node-pty`, `better-sqlite3`), so no `npm install` runs at install time.

## Setup

```sh
# 1. Set your API key (one-time):
tb-streamer set-key <YOUR_API_KEY>

# 2. Start the service (also starts on login):
brew services start tb-streamer

# 3. (Optional) Enable automatic updates:
tb-streamer update --enable-auto-update
```

The service binds `http://127.0.0.1:8766` by default. Edit `~/.threadbase/server.yaml` to customize, then `brew services restart tb-streamer`.

## Upgrade

```sh
brew update && brew upgrade tb-streamer
```

New stable releases of `threadbase-streamer` are auto-published to this tap by the release workflow. Pre-releases (`next` channel) are **not** published here — use the GitHub release tarball directly.

## Uninstall

```sh
brew services stop tb-streamer
brew uninstall tb-streamer
brew untap RonenMars/threadbase
```

## Compatibility note

The Homebrew install is mutually exclusive with the manual `scripts/deploy.sh` install from the streamer repo — both bind port 8766 with different launchd/systemd labels. If you previously installed via that path, tear it down before starting the Homebrew service:

```sh
# macOS
launchctl bootout gui/$UID/com.threadbase.streamer

# Linux (systemd --user)
systemctl --user disable --now tb-streamer
```

## Links

- Streamer source: <https://github.com/RonenMars/threadbase-streamer>
- Issue tracker: <https://github.com/RonenMars/threadbase-streamer/issues>
- License: MIT
