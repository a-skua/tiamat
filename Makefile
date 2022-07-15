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

fix:
	dart fix --dry-run
