.PHONY: all
all: comet2.wasm comet2_slim.wasm build_dart.wasm

.PHONY: run
run: main.ts comet2_slim.wasm build_dart.wasm
	@deno run --allow-read $<

%.wasm: %.wat
	wasm-tools parse $< -o $@

%_slim.wasm: %.wasm
	wasm-tools strip $< -a -o $@

%_dart.wasm: %.dart
	dart compile wasm $< -o $@ -D ART_WASM=1


.PHONY: clean
clean:
	rm -f *.wasm
