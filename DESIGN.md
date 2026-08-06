
# Design

DO NOT MODIFY THIS FILE

## Guidelines

- Version syntax is `{0-9}.{0-9}{0-9}`, it can have a `v` in front of it.
- Version strings should always be converted to Version objects, this removes the `v` character for us, which is what we want

## Definitions

package-dir: ./vendor/{platform}-{user/vendorname}-{pkgname}/{version} (e.g. ./vendor/github-someuser-somepkg/0.0.1)

## vman install

- reads project config (valk.json)
- loops "dependencies"
-- if src is directory : skip
-- reads "current" & "current_hash"
--- if no "current" or no "current_hash", look at "version" mask, look up latest version (&hash) that matches the mask
-- now that we have our version & hash
--- validate version syntax
--- set/update "current" & "current_hash" in config
--- check if version is installed by checking if the 'pacakge-dir' exists
--- if not, clone repo to ~/.vman/repos, checkout the hash, copy files to the 'package-dir'
- save config
- success msg

## vman install {name} [{version}]

- if version specified : check if 'package-dir' exists, if so -> already installed success message
- fetch latest version/hash from repo if no version specified
- else find version in tags + hash
- clone repo to ~/.vman/repos if not exists, checkout the hash, copy files to the 'package-dir'
- store version in "current" & hash in "current_hash"
- save config
- success msg

## vman update

- reads project config (valk.json)
- loops "dependencies"
-- removes "current" & "current_hash"
- now run logic of: vman install
