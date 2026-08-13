
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
 Valk package manager 0.0.6
---------------------------

📦 Package commands

 vman init              Initialize a valk.json config
 vman install           Install packages defined in valk.json
 vman install {pkg} [{version-mask}]
                        Install a package in the current project
 vman update            Update packages to the latest matching versions
 vman remove {pkg}      Remove a package by name

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

## Testing

```sh
make test
```
