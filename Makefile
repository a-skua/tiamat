fmt:
	dartfmt -w ./

tests:
	pub run test

webserve:
	webdev serve
