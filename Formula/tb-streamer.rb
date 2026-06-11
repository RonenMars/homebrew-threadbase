class TbStreamer < Formula
  desc "PTY session management, WebSocket streaming, and REST API for Claude Code"
  homepage "https://github.com/RonenMars/threadbase-streamer"
  license "MIT"
  version "1.7.0"

  depends_on "node@22"

  on_macos do
    on_arm do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.7.0/threadbase-streamer-1.7.0-darwin-arm64.tgz"
      sha256 "f3cc9a9f612ead6c648f67eb83b0ecab427659f2c3ee6eb83b301c6dffec7ca2"
    end
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.7.0/threadbase-streamer-1.7.0-darwin-x64.tgz"
      sha256 "561a06b228a0e59be48e1029b024dd01e0436a1d4897fd6b25e18b19be1a558f"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.7.0/threadbase-streamer-1.7.0-linux-x64.tgz"
      sha256 "27cab0f99f178d8c409ba638bfdb2e7b6d9c3f87f6d0538bff4de0528a6352e5"
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
