class TbStreamer < Formula
  desc "PTY session management, WebSocket streaming, and REST API for Claude Code"
  homepage "https://github.com/RonenMars/threadbase-streamer"
  license "MIT"
  version "1.91.0"

  depends_on "node@22"

  on_macos do
    on_arm do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.91.0/threadbase-streamer-1.91.0-darwin-arm64.tgz"
      sha256 "1f77e0df4c04a6da6b696b514a0694a61c5b3438ac3545bdb065208545806249"
    end
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.91.0/threadbase-streamer-1.91.0-darwin-x64.tgz"
      sha256 "e8bffc77fc5b24fbd5c2194a894b11e55626938e7f42dffdb4506ab7637e1544"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.91.0/threadbase-streamer-1.91.0-linux-x64.tgz"
      sha256 "0d24204a0e68b8fa0c3aefb5bb0b1b00766f518a33a4993ebd1a0332bf3c87de"
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
    run [opt_bin/"tb-streamer", "serve", "--port", "8766", "--prod"]
    keep_alive true
    log_path       var/"log/tb-streamer.log"
    error_log_path var/"log/tb-streamer.err"
    # Prepend Homebrew's bin so node-pty's execvp("claude", …) resolves
    # /opt/homebrew/bin/claude (Apple Silicon) — std_service_path_env omits it.
    # resolveClaudeExe() in src/platform.ts has an absolute fallback too, so
    # this is defense-in-depth.
    environment_variables PATH: "#{HOMEBREW_PREFIX}/bin:#{std_service_path_env}"
  end

  def caveats
    <<~EOS
      Next steps to finish setup:

        1. Set your API key (one-time):
           tb-streamer set-key <YOUR_API_KEY>

        2. Start the service (also starts on login):
           brew services start tb-streamer

        3. To update later:
           brew upgrade tb-streamer

      Note: Homebrew install is mutually exclusive with the
      manual scripts/deploy.sh install. If you previously
      installed via that path, run:
        launchctl bootout gui/$UID/com.ronen.threadbase
      before starting the Homebrew service.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tb-streamer --version")
  end
end
