{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
, llvmPackages_11
, pkg-config
, libpulseaudio
, dbus
, clang
, speechd
}:

rustPlatform.buildRustPackage rec {
  pname = "goxlr-utility";
  version = "v0.12.6";

  src = fetchFromGitHub {
    owner = "GoXLR-on-Linux";
    repo = pname;
    rev = version;
    sha256 = "vvaKCsqncRhag8IrS0AIfNqNHGU2WIvFaYISEVfUB2Y=";
  };

  LIBCLANG_PATH = "${llvmPackages_11.libclang.lib}/lib";

  buildInputs = [
    libpulseaudio
    dbus
    speechd
  ];

  nativeBuildInputs = [
    pkg-config
    clang
    installShellFiles
  ];

  postInstall = ''
    install -Dm644 "50-goxlr.rules" "$out/etc/udev/rules.d/50-goxlr.rules"

    install -Dm644 "daemon/resources/goxlr-utility.png" "$out/share/icons/hicolor/48x48/apps/goxlr-utility.png"
    install -Dm644 "daemon/resources/goxlr-utility.svg" "$out/share/icons/hicolor/scalable/apps/goxlr-utility.svg"
    install -Dm644 "daemon/resources/goxlr-utility-large.png" "$out/share/pixmaps/goxlr-utility.png"
    install -Dm644 "daemon/resources/goxlr-utility.desktop" "$out/share/applications/goxlr-utility.desktop"
    sed -i -e "s#/usr/bin#$out/bin#g" -e "s#goxlr-launcher#goxlr-daemon#" "$out/share/applications/goxlr-utility.desktop"

    install -Dm644 "README.md" "$out/share/doc/${pname}/README.md"
    install -Dm644 "LICENSE" "$out/share/licenses/${pname}/LICENSE"
    install -Dm644 "LICENSE-3RD-PARTY" "$out/share/licenses/${pname}/LICENSE-3RD-PARTY"

    mkdir -p $out/completions/
    find target -name 'goxlr-*.bash' -exec cp "{}" $out/completions/  \;
    find target -name 'goxlr-*.fish' -exec cp "{}" $out/completions/  \;
    find target -name '_goxlr-*' -exec cp "{}" $out/completions/  \;

    installShellCompletion $out/completions/goxlr-client.{bash,fish} --zsh $out/completions/_goxlr-client
    installShellCompletion $out/completions/goxlr-daemon.{bash,fish} --zsh $out/completions/_goxlr-daemon
  '';

  cargoSha256 = "sha256-6Xw+A5l/bg8kHo5X3tc61Y8PagOSPpeF5Kealg7Y0hM=";

  buildFeatures = [ "tts" ];

  meta = with lib; {
    description = "An unofficial GoXLR App replacement for Linux, Windows and MacOS";
    homepage = "https://github.com/GoXLR-on-Linux/goxlr-utility";
    license = licenses.mit;
    maintainers = [ errnoh sporesirius ];
  };
}
