#!/usr/bin/env bash

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

file="$DIR/../dists/cacert.pem"

if [[ ! -e $file || $(find "$file" -mtime +14 -print) ]]; then
	rm $file
	echo "cacert.pem is older than 14 days -> Downloading new certificate"
	curl -o "$file" https://curl.se/ca/cacert.pem
fi
