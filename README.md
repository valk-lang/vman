
# Valk package manager

Used for installing valk packages, compiler version control and managing toolchains for cross-compiling.

## Install

```
curl -s https://valk-lang.dev/install.sh | bash
```

## Usage

```
📦 Package commands

 vman install         Install pacakages defined in the valk.json config
 vman install {pkg}   Install pacakage globally
 vman remove {pkg}    Remove pacakage

💿 Valk version control

 vman use 0.0.1       Install valk version 0.0.1
 vman use latest      Install latest version
 vman use             Install valk version defined in project valk.json
                      Expected config: { "valk": "0.0.5" }

⚙️ Other

 vman self-update     Update vman itself
 vman version         Show vman version
 vman {command} -h    Show help for a command
 ```
