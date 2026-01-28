
SRC=$(wildcard src/*.valk)
VERSION=0.0.1
DEFS=--def "VERSION=$(VERSION)"
# vc=/opt/valk/0.0.7/valk
vc=valk
DIST_FLAG=--static -c
PACK_FILES=bin env
PACK_FILES_WIN=bin

vman: $(SRC)
	$(vc) build src/*.valk -o vman $(DEFS)

dev: $(SRC)
	$(vc) build src/*.valk -o vman $(DEFS) --def "DEV=1"

win: $(SRC)
	$(vc) build src/*.valk -o /mnt/c/www/vman.exe $(DEFS) --target win-x64

test: vman
	$(vc) build debug/example.valk -o debug/example .
	./debug/example

clean:
	rm -f ./vman

.PHONY: clean

# Build dists

dist-linux-x64:
	rm -rf ./dists/linux-x64/
	mkdir -p ./dists/linux-x64/bin
	$(vc) build src/*.valk -o ./dists/linux-x64/bin/vman $(DEFS) --target linux-x64 $(DIST_FLAG)
	cp ./env ./dists/linux-x64/env
	cd ./dists/linux-x64/ && tar -czf  ../vman-linux-x64.tar.gz $(PACK_FILES)

dist-macos-x64:
	rm -rf ./dists/macos-x64/
	mkdir -p ./dists/macos-x64/bin
	$(vc) build src/*.valk -o ./dists/macos-x64/bin/vman $(DEFS) --target macos-x64 $(DIST_FLAG)
	cp ./env ./dists/macos-x64/env
	cd ./dists/macos-x64/ && tar -czf  ../vman-macos-x64.tar.gz $(PACK_FILES)

dist-macos-arm64:
	rm -rf ./dists/macos-arm64/
	mkdir -p ./dists/macos-arm64/bin
	$(vc) build src/*.valk -o ./dists/macos-arm64/bin/vman $(DEFS) --target macos-arm64 $(DIST_FLAG)
	cp ./env ./dists/macos-arm64/env
	cd ./dists/macos-arm64/ && tar -czf  ../vman-macos-arm64.tar.gz $(PACK_FILES)

dist-win:
	rm -rf ./dists/win-x64/
	mkdir -p ./dists/win-x64/bin
	$(vc) build src/*.valk -o ./dists/win-x64/bin/vman $(DEFS) --target win-x64 $(DIST_FLAG)
	bash ./cert-update.sh
	cp ./dists/cacert.pem ./dists/win-x64/bin/cacert.pem
	cd ./dists/win-x64/ && tar -czf  ../vman-win-x64.tar.gz $(PACK_FILES_WIN)

dist-all: dist-linux-x64 dist-macos-x64 dist-macos-arm64 dist-win

