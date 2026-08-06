
# Design

DO NOT MODIFY THIS FILE

## Guidelines

- Version syntax is `{0-9}.{0-9}{0-9}`, it can have a `v` in front of it.
- Version strings should always be converted to Version objects, this removes the `v` character for us, which is what we want
- Http requests should be cached for 5 minutes in ~/.vman/cache.json in order not to overload 3rd party web servers

## Definitions

package-dir: ./vendor/{platform}-{user/vendorname}-{pkgname}/{version} (e.g. ./vendor/github-someuser-somepkg/0.0.1)

## vman install

- reads project config (valk.json)
- loops "dependencies"
-- if src is directory : skip
-- reads "current" & "current_hash"
--- if no "current" or no "current_hash", look at "version" mask (error if invalid mask), look up latest version (&hash) that matches the mask (error if no versions match)
-- now that we have our version & hash
--- validate version syntax
--- set/update "current" & "current_hash" in config (also set "version" if missing)
--- check if version is installed by checking if the 'pacakge-dir' exists
--- if not, clone repo to ~/.vman/repos, checkout the hash (error if doesnt exist), copy files to the 'package-dir'
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

## vman remove {name}

- Removes the `dependencies.{name}` object from the config

## vman clean packages

- if inside a project with a config
-- delete every ./vendor/{pkg}/{version} that's not found in the config dependencies
-- delete every folder in ./vendor that's empty

## vman clean cache

- Clears ~/.vman/cache.json
- Remove files from ~/.vman/downloads

## vman clean repos

- delete every folder in ~/.vman/repos

## vman unuse {version}

note: Do not document this command in the -h/--help output

- check if version is the current used version
- Removes directory if exists: ~/.vman/versions/{version}
- if it was the current or current was null : delete symlink
