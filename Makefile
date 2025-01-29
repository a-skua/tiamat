.PHONY: test

init:
	dart pub global activate webdev

fmt:
	dart format .

test:
	dart test

serve:
	webdev serve

docs:
	dart doc
	python3 -m http.server -d doc/api

fix:
	dart fix --dry-run

pub:
	dart pub publish --dry-run

analyze:
	dart analyze
