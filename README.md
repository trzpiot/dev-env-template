# dev-env-template

[![Maintenance](https://img.shields.io/maintenance/yes/2024)](https://github.com/trzpiot/dev-env-template/commits/main)
[![Nix Flake](https://img.shields.io/badge/Nix%20Flake-%235277C3?logo=snowflake)](https://nix.dev/concepts/flakes.html)

The template provides a pre-configured, consistent development environment for a specific context (such as Rust application development).
Developers only need to have Nix and direnv installed on their systems.
All other necessary tools and dependencies (like Cargo for Rust) are automatically downloaded and managed within the project directory, ensuring a uniform setup across different machines.

> [!WARNING] 
> Please note that only a basic template will be downloaded and knowledge of Nix is required.
> Manual adaptation of the template may be necessary.
> You should be prepared to modify the template based on your specific needs.
>
> For a more convenient option, see [devenv](https://devenv.sh).

## Prerequirements

- [Nix](https://nixos.org/download)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [direnv](https://direnv.net/docs/installation.html)

## Usage

The following command executes a script that downloads the template of the specific context (e.g., Rust).

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/trzpiot/dev-env-template/main/dev-env-template.sh)"
```

> [!NOTE] 
> When adding the template to a Git repository, it is important to stage the template files so that they can be used.

## Templates

There are currently 2 templates.

- Rust
- Web (Node.js + Bun + Playwright)