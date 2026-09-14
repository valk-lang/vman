
# Design

DO NOT MODIFY THIS FILE

## Guidelines

- Version syntax is `{0-9}.{0-9}{0-9}`, it can have a `v` in front of it.
- Version strings should always be converted to Version objects, this removes the `v` character for us, which is what we want
- Http requests should be cached for 5 minutes in ~/.vman/cache.json in order not to overload 3rd party web servers

## Definitions

package-dir: ./vendor/{platform}-{user/vendorname}-{pkgname}/{version} (e.g. ./vendor/github-someuser-somepkg/0.0.1)

repo-dir: ~/.vman/repos/{platform}.{user/vendorname}.{pkgname}, the cloned package repository

project-valk-version: the "use" version in the project valk.json (null if missing)

valk-requirement: the lowest valk version a package declares in its own valk.json, no block means any version
```
{ "require": { "valk": { "min": "0.7.0" } } }
```

## Valk requirements

- the requirement of a package version is read from the valk.json at that version's commit: `git show {hash}:valk.json` in the repo-dir (no valk.json or invalid json -> any version)
- before reading requirements, clone the repo-dir if missing, otherwise `git fetch --tags` (once per run)
- an invalid "min" version prints a warning and is ignored
- "check requirements": for every dependency with a "current" version (or a local directory src), read the valk.json in its package-dir (or directory) and print a warning when its requirement does not include the project-valk-version (skip if no project-valk-version)

## vman install

- reads project config (valk.json)
- loops "dependencies"
-- if src is directory : skip
-- reads "current" & "current_hash"
--- if no "current" or no "current_hash", look at "version" mask (error if invalid mask, if no mask use x.x.x mask), look up latest version (&hash) that matches the mask (error if no versions match)
-- now that we have our version & hash
--- validate version syntax
--- set/update "current" & "current_hash" in config (also set "version" if missing)
--- check if version is installed by checking if the 'pacakge-dir' exists
--- if not, clone repo to ~/.vman/repos, checkout the hash (error if doesnt exist), copy files to the 'package-dir'
- save config
- check requirements
- success msg

## vman install {name} [{version-mask}]

- if no version-mask, use x.x.x
- fetch the versions/hashes from the repo tags (error if none)
- select the highest version that matches the version-mask (error if none match)
-- if there is a project-valk-version: select the highest matching version whose valk-requirement includes it (if none, print the matching versions with their requirements and error)
- clone repo to ~/.vman/repos if not exists, checkout the hash, copy files to the 'package-dir'
- store version-mask in "version"
- store version in "current" & hash in "current_hash"
- save config
- success msg, followed by the valk-requirement of the installed version if it's not "any"

## vman versions {name}

- fetch the versions/hashes from the repo tags (error if none)
- clone/fetch the repo-dir
- print every version, highest first, with its valk-requirement
- if inside a project with a project-valk-version: mark every version as compatible or incompatible with it

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

## vman use [{version}]

- resolve the requested version:
-- if no version specified, read "use" from ./valk.json (error if no config or no "use")
-- if it's a named-version -> vman fetch (ignore_cache: false) -> resolve named-version from ~/.vman/versions.json (error if not found)
-- otherwise, if it's a valid version string, use it as-is (error if it's neither a known channel nor valid version syntax)
- validate version syntax
- check for a new vman version and print a notice (~/.vman/vman.json update check)
- if not installed: print installing msg, download the valk archive from https://files.valk-cdn.dev/releases/valk/{version}/... (skip download if the archive already exists in ~/.vman/downloads), then unzip into ~/.vman/versions/{version}
- create the symbolic link ~/.vman/bin/valk -> ~/.vman/versions/{version}/valk (remove any existing link, including dangling ones)
- success msg
- if ./valk.json exists: check requirements against the switched-to version

## vman unuse {version}

note: Do not document this command in the -h/--help output

- check if version is the current used version
- Removes directory if exists: ~/.vman/versions/{version}
- if it was the current or current was null : delete symlink

## vman self-update

- fetch/reuse the cached vman versions (~/.vman/versions.json)
- if already up-to-date (current >= latest) : print up-to-date msg and stop
- print downloading msg
- download http://cdn/.../vman-{os}-{arch}.tar.gz to a temp file in ~/.vman/downloads (error on non-200)
- move temp file to ~/.vman/downloads/vman.tar.gz
- unpack the tarball into ~/.vman/ (overwrites the current vman install)
- print up-to-date msg

## vman fetch [true (ignore_cache)]

- fetch function (argument: ignore_cache: bool (default false))
-- fetch versions.json from CDN (skip request cache if ignore_cache)
-- store versions in ~/.vman/versions.json
