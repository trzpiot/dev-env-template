{
  mkShell,
  pkgs,
}:

mkShell {
  nativeBuildInputs = [
    pkgs.bun
    pkgs.nodejs
    pkgs.playwright-driver
  ];

  shellHook = ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
  '';
}
