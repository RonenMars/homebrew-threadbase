class TbStreamer < Formula
  desc "PTY session management, WebSocket streaming, and REST API for Claude Code"
  homepage "https://github.com/RonenMars/threadbase-streamer"
  license "MIT"
  version "1.6.1"

  depends_on "node@22"

  on_macos do
    on_arm do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.6.1/threadbase-streamer-1.6.1-darwin-arm64.tgz"
      sha256 "cc9fa0478d7afdb660693b8282c9ed6ba157a939e471f1d661a92db7676d2fbf"
    end
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.6.1/threadbase-streamer-1.6.1-darwin-x64.tgz"
      sha256 "dc87de14f8c2d0707de016e3acbf3d0034adcc4c435b9837c9d283a6a2cecfeb"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.6.1/threadbase-streamer-1.6.1-linux-x64.tgz"
      sha256 "54400ba39feeeb09da94611417abef1c1f3e79e0e1c685997356a4cef5077bb2"
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
