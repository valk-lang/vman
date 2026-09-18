
# Valk package manager

Used for installing Valk packages and managing compiler versions

## Install

```
curl -s https://valk-lang.dev/install.sh | bash
```

## Usage

```
vman -h
```

```
Valk package manager

Usage:
  vman <command>

Installs packages for a project, and the valk versions to build it with.

Commands:
  install      Install the packages of this project, or add one
  update       Update the packages to the newest versions they allow
  remove       Remove a package from this project
  versions     List the versions of a package, and the valk versions they need
  init         Write a valk.json for this project
  use          Install a valk version and make it the one in use
  unuse        Remove an installed valk version
  self-update  Update vman itself
  clean        Remove what is no longer needed
  version      Show the version of vman
  fetch        Save the list of released versions
  completion   Print the script that completes this program in your shell

Options:
  -h, --help     Show this help
      --version  Show the version
```

Every command explains itself with `vman <command> -h`, for example:

```
vman use -h
vman clean -h
```

## Compiler version requirements

A package declares the lowest valk version it supports in its `valk.json`. A
package without a `require` block supports every version.

```json
{
    "name": "mysql",
    "require": {
        "valk": {
            "min": "0.7.0"
        }
    }
}
```

`vman install {pkg}` reads this from every tagged version and installs the
highest one matching the version mask that supports the `use` version of the
project. `vman versions {pkg}` lists every tagged version with its requirement, and
`vman use` / `vman install` warn when an installed dependency does not support
the project's valk version.

## Testing

```sh
make test
```

## Tab completion

```sh
vman completion bash > /etc/bash_completion.d/vman
vman completion zsh  > ~/.zfunc/_vman
vman completion fish > ~/.config/fish/completions/vman.fish
```

`vman use <tab>` then offers the valk versions that are installed, `vman remove <tab>` the
packages this project uses, and `vman clean <tab>` what can be cleaned.

## Building it

vman reads its command line with [valk-cli](https://github.com/ctxcode/valk-cli), which lives in
`vendor/` in this repository so that vman builds without a package manager to install it. To
move to a newer valk-cli, run `vman install github.com/ctxcode/valk-cli` and commit what lands
in `vendor/`.
