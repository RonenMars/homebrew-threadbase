class TbStreamer < Formula
  desc "PTY session management, WebSocket streaming, and REST API for Claude Code"
  homepage "https://github.com/RonenMars/threadbase-streamer"
  license "MIT"
  version "1.2.1"

  depends_on "node@22"

  on_macos do
    on_arm do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.2.1/threadbase-streamer-1.2.1-darwin-arm64.tgz"
      sha256 "11631a11f92bade2e54eecfd7a37c8c3a6d2f9dd292a2d0b2e76d68b913c721e"
    end
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.2.1/threadbase-streamer-1.2.1-darwin-x64.tgz"
      sha256 "3b4af1d2a54c8d385d5f93c1a7c0ab34db7afacdeec30f725ee69f00690f8b91"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.2.1/threadbase-streamer-1.2.1-linux-x64.tgz"
      sha256 "5c0ebca4ea06ca62637533a5284783b649084ec7e0b62fb9d60fd9151973d5c0"
    end
  end

  def install
    libexec.install Dir["*"]

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
