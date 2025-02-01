.PHONY: test
test:
	dart test

.PHONY: init
init:
	dart pub global activate webdev

.PHONY: fmt
fmt:
	dart format .

.PHONY: docs
docs:
	dart doc
	python3 -m http.server -d doc/api

.PHONY: fix
fix:
	dart fix --dry-run

.PHONY: pub
pub:
	dart pub publish --dry-run

.PHONY: analyze
analyze:
	dart analyze
