class TbStreamer < Formula
  desc "PTY session management, WebSocket streaming, and REST API for Claude Code"
  homepage "https://github.com/RonenMars/threadbase-streamer"
  license "MIT"
  version "1.5.0"

  depends_on "node@22"

  on_macos do
    on_arm do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.5.0/threadbase-streamer-1.5.0-darwin-arm64.tgz"
      sha256 "4c86e20fd2e418d5a2ac68c5a7c24cf0e0c80cc7a8b1ec3f00895f6fb5f5e58e"
    end
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.5.0/threadbase-streamer-1.5.0-darwin-x64.tgz"
      sha256 "e8129820573d15a2dffa324bd62f572a8495e6c5ac8add344e2c183b945bbf9e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.5.0/threadbase-streamer-1.5.0-linux-x64.tgz"
      sha256 "3a8df351ded10d9023c18b93a0ce04fd6a06e8b14e8d040815c102846337b61c"
    end
  end

  def install
    libexec.install Dir["*"]

    # Stamp the runtime version next to dist/cli.cjs so getVersion() reports
    # the formula's version (not whatever package.json says inside the tarball,
    # which is frozen at the previous release because semantic-release bumps
    # the version after the matrix has already packed the artifacts).
    (libexec/"dist/version.txt").write("#{version}+brew\n")

    # All native deps that dist/cli.cjs requires at runtime (node-pty and
    # better-sqlite3) are pre-bundled in the tarball under node_modules/,
    # already built for this arch. No npm install needed.
    (bin/"tb-streamer").write_env_script libexec/"dist/cli.cjs",
      PATH: "#{Formula["node@22"].opt_bin}:$PATH"
  end

  service do
    run [opt_bin/"tb-streamer", "serve", "--port", "8766"]
    keep_alive true
    log_path       var/"log/tb-streamer.log"
    error_log_path var/"log/tb-streamer.err"
    environment_variables PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      Next steps to finish setup:

        1. Set your API key (one-time):
           tb-streamer set-key <YOUR_API_KEY>

        2. Start the service (also starts on login):
           brew services start tb-streamer

        3. (Optional) Enable automatic updates:
           tb-streamer update --enable-auto-update

      Note: Homebrew install is mutually exclusive with the
      manual scripts/deploy.sh install. If you previously
      installed via that path, run:
        launchctl bootout gui/$UID/com.threadbase.streamer
      before starting the Homebrew service.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tb-streamer --version")
  end
end
