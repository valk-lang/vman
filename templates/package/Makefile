vc ?= valk

test:
	$(vc) build ./tests --test --run
lint:
	$(vc) build ./src --lint
docs:
	@mkdir -p docs
	$(vc) doc . -o docs/api.md --markdown --no-private
	$(vc) doc . -o docs/api-full.md --markdown --no-private --full

.PHONY: test lint docs
