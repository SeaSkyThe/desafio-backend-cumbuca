default: build run

build:
	mix escript.build

run:
	./desafio_cli

testing:
	mix test

clean:
	rm -rf _build
	rm -rf deps
	rm -rf mix.lock
	rm -rf escript.lock
