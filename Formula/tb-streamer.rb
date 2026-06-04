class TbStreamer < Formula
  desc "PTY session management, WebSocket streaming, and REST API for Claude Code"
  homepage "https://github.com/RonenMars/threadbase-streamer"
  license "MIT"
  version "1.4.0"

  depends_on "node@22"

  on_macos do
    on_arm do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.4.0/threadbase-streamer-1.4.0-darwin-arm64.tgz"
      sha256 "27476e472d88cc32964870a282332a532c7b6b00f423af8c7c85198e6bfccbaf"
    end
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.4.0/threadbase-streamer-1.4.0-darwin-x64.tgz"
      sha256 "c26c59719e63a497619ca40d1d5d95aa580a3088d9994528709f8cf21ca7c423"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.4.0/threadbase-streamer-1.4.0-linux-x64.tgz"
      sha256 "392013684365bcedb7abdb08bde81859bfbe721aaf3bd601396346a364377142"
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
