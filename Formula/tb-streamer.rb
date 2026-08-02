class TbStreamer < Formula
  desc "PTY session management, WebSocket streaming, and REST API for Claude Code"
  homepage "https://github.com/RonenMars/threadbase-streamer"
  license "MIT"
  version "1.37.0"

  depends_on "node@22"

  on_macos do
    on_arm do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.37.0/threadbase-streamer-1.37.0-darwin-arm64.tgz"
      sha256 "091d75af0ce9131d8675e605a9c7ed04bf5ec66940b0381bad40982c6d5bb470"
    end
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.37.0/threadbase-streamer-1.37.0-darwin-x64.tgz"
      sha256 "a6daa2cac1c28e5fb53182110fb86d3dabbece211b60c7393be04f25e11aec97"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/RonenMars/threadbase-streamer/releases/download/v1.37.0/threadbase-streamer-1.37.0-linux-x64.tgz"
      sha256 "0b61ff9d27d3d898d1572da8a3eaed30c5d85144873040556f28f064f709bc98"
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
