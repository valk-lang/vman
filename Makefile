
TEST_BIN=debug/vman-tests
DEFS=
vc=valk
DIST_FLAG=--static --no-system-libs
PACK_FILES=bin env
PACK_FILES_WIN=bin

vman:
	$(vc) build -o vman $(DEFS)

win: 
	$(vc) -o /mnt/c/www/vman.exe $(DEFS) --target win-x64

test: 
	mkdir -p debug
	$(vc) build ./src/tests -o $(TEST_BIN) $(DEFS) --test
	./$(TEST_BIN)

clean:
	rm -f ./vman $(TEST_BIN)

# Build dists

dist-linux-x64:
	rm -rf ./dists/linux-x64/
	mkdir -p ./dists/linux-x64/bin
	$(vc) build -o ./dists/linux-x64/bin/vman $(DEFS) --target linux-x64 $(DIST_FLAG)
	cp ./env ./dists/linux-x64/env
	cd ./dists/linux-x64/ && tar -czf  ../vman-linux-x64.tar.gz $(PACK_FILES)

dist-macos-x64:
	rm -rf ./dists/macos-x64/
	mkdir -p ./dists/macos-x64/bin
	$(vc) build -o ./dists/macos-x64/bin/vman $(DEFS) --target macos-x64 $(DIST_FLAG)
	cp ./env ./dists/macos-x64/env
	cd ./dists/macos-x64/ && tar -czf  ../vman-macos-x64.tar.gz $(PACK_FILES)

dist-macos-arm64:
	rm -rf ./dists/macos-arm64/
	mkdir -p ./dists/macos-arm64/bin
	$(vc) build -o ./dists/macos-arm64/bin/vman $(DEFS) --target macos-arm64 $(DIST_FLAG)
	cp ./env ./dists/macos-arm64/env
	cd ./dists/macos-arm64/ && tar -czf  ../vman-macos-arm64.tar.gz $(PACK_FILES)

dist-win:
	rm -rf ./dists/win-x64/
	mkdir -p ./dists/win-x64/bin
	$(vc) build -o ./dists/win-x64/bin/vman $(DEFS) --target win-x64 $(DIST_FLAG)
	bash ./cert-update.sh
	cp ./dists/cacert.pem ./dists/win-x64/bin/cacert.pem
	cd ./dists/win-x64/ && tar -czf  ../vman-win-x64.tar.gz $(PACK_FILES_WIN)

dist-all: dist-linux-x64 dist-macos-x64 dist-macos-arm64 dist-win

#

.PHONY: vman win test clean test dist-all dist-linux-x64 dist-macos-x64 dist-macos-arm64 dist-win

