{
  mkShell,
  pkg-config,
  rust-bin,
}:

mkShell {
  nativeBuildInputs = [
    pkg-config
    rust-bin.stable.latest.default
  ];
}
