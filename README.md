
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
  template     Write starting code into this project
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

## Templates

A template is starting code for a project. `vman template` lists the ones that ship with
vman:

```
vman template

# Templates
  cli           A command line tool: options, arguments and shell completion
  hello         A program that prints, to start a project from
  http-server   An HTTP server with a router, JSON replies and a clean shutdown
  package       A package to publish: source, tests, a Makefile and a readme
```

`vman template {name}` writes one into the current project:

```
vman template cli my-tool
cd my-tool
valk build src -o my-tool
```

A template starts a project, so it is written into an empty directory. Without a second
argument that is the current one, or, when there is already work there, a new `./{template}`
next to it:

```
~/code $ vman template hello
# This directory is not empty, writing into ./hello
# Created directory: hello
# Wrote: hello/src/main.valk
```

The directory given as the second argument (`vman template hello apps/greeter`) is created
when it is not there yet. Either way that directory is the project: its `valk.json` is the
one the template writes to and the one packages are installed into.

A directory that holds work is never written into: the command says so and stops.
`valk.json`, `vendor` and hidden entries such as `.git` do not count, so `vman init`,
`vman use` and `git init` can come first. `--force` writes here anyway.

A template that needs a package installs it, and `{name}` in the code becomes the name of
the directory, without the `valk-` prefix a package repository usually carries.

### Templates of your own

The four above ship inside the vman binary. Your own live in `~/.vman/templates/`, one
directory per template, and they are listed with a `*` next to them. A template there with
the name of a built-in one replaces it, so a project can be started the way your team
starts projects rather than the way vman does.

A directory is all it takes: the files to write, optionally a `template.json` beside them:

```json
{
    "description": "How this template is listed",
    "config": { "name": "{{name}}" },
    "dependencies": {
        "cli": { "src": "github.com/ctxcode/valk-cli", "version": "0.2.x" }
    }
}
```

`config` is added to the project's `valk.json` (existing keys are left alone) and every
package under `dependencies` is installed. `template.json` itself is never written into a
project.

To start from a built-in one, copy it out and edit it:

```
vman template package --export
```

That writes `~/.vman/templates/package/`, after which `vman template package` uses your
copy. `self-update` unpacks over `~/.vman` but never writes `templates/`, so what you put
there survives an update.

The built-in templates live in `templates/` in this repository, in exactly the same
layout.

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
