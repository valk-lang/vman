
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
---------------------------
 Valk package manager 0.1.0
---------------------------

📦 Package commands

 vman init              Initialize a valk.json config
 vman install           Install packages defined in valk.json
 vman install {pkg} [{version-mask}]
                        Install a package in the current project
 vman update            Update packages to the latest matching versions
 vman remove {pkg}      Remove a package by name
 vman versions {pkg}    List package versions and the valk versions they support

💿 Valk version control

 vman use 0.3.4         Install valk version 0.3.4
 vman use               Install the version from valk.json
 vman use latest        Install latest version
 vman use dev           Install the dev valk version
 vman unuse {version}   Remove an installed Valk version

⚙️ Other

 vman version           Show vman version
 vman self-update       Update vman itself

 vman clean packages    Remove unused vendor packages
 vman clean cache       Clear cached requests and downloads
 vman clean repos       Remove cloned package repositories
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
