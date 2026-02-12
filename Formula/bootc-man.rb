# Homebrew Formula for bootc-man
class BootcMan < Formula
  desc "CLI tool for bootable container image testing and verification"
  homepage "https://github.com/tnk4on/bootc-man"
  url "https://github.com/tnk4on/bootc-man/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "7d40fd30ace4bbc020a219c0d7c021a01e616484ac60e340218f1366368eca31"
  license "Apache-2.0"




  depends_on "go" => :build
  depends_on :macos
  depends_on "podman"

  # gvproxy (same pattern as Podman formula)
  resource "gvproxy" do
    on_macos do
      url "https://github.com/containers/gvisor-tap-vsock/archive/refs/tags/v0.8.7.tar.gz"
      sha256 "ef9765d24bc3339014dd4a8f2e2224f039823278c249fb9bd1416ba8bbab590b"
    end
  end

  # vfkit (same pattern as Podman formula)
  resource "vfkit" do
    on_macos do
      url "https://github.com/crc-org/vfkit/archive/refs/tags/v0.6.1.tar.gz"
      sha256 "e35b44338e43d465f76dddbd3def25cbb31e56d822db365df9a79b13fc22698c"
    end
  end

  def install
    system "make", "build", "VERSION=#{version}"
    bin.install "bin/bootc-man"

    # Build and install gvproxy
    resource("gvproxy").stage do
      system "make", "gvproxy"
      (libexec/"bootc-man").install "bin/gvproxy"
    end

    # Build and install vfkit
    resource("vfkit").stage do
      ENV["CGO_ENABLED"] = "1"
      arch = Hardware::CPU.intel? ? "amd64" : Hardware::CPU.arch.to_s
      system "make", "out/vfkit-#{arch}"
      (libexec/"bootc-man").install "out/vfkit-#{arch}" => "vfkit"
    end

    # Shell completions
    generate_completions_from_executable(bin/"bootc-man", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bootc-man version")
  end
end
