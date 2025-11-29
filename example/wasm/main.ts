import { assert } from "@std/assert";
import { compileStreaming, instantiate, invoke } from "./build_dart.mjs";

const asm = `
; サンプルコード
DO      START
; GR1     AND     GR1,GR1       ; ラベルエラー
LOOP    IN      IBUF,31       ; マクロ
        OUT     OUT,38        ; マクロ
        LAD     GR1,0
        LD      GR0,IBUF,GR1  コメント
        CPL     GR0,EXIT,GR1  ; コメント
        ; LAD     GR0,0
        JNZ     LOOP
        LAD     GR1,1,GR1
        LD      GR0,IBUF,GR1
        CPL     GR0,EXIT,GR1
        JNZ     LOOP
        LAD     GR1,1,GR1
        LD      GR0,IBUF,GR1
        CPL     GR0,EXIT,GR1
        JNZ     LOOP
        LAD     GR1,1,GR1
        LD      GR0,IBUF,GR1
        CPL     GR0,EXIT,GR1
        JNZ     LOOP
        LAD     GR1,1,GR1
        LD      GR0,IBUF,GR1
        CPL     GR0,EXIT,GR1
        JNZ     LOOP
END     OUT     MSG,32        ; マクロ
        RET
EXIT    DC      'exit',-1
OUT     DC      'input:'
IBUF    DS      31
EOF     DC      #FFFF
MSG     DC      'goodbye!',-1
        END

MAIN    START
        CALL DO
        RET
        END
`;
const wasm = await instantiate(
  compileStreaming(fetch(new URL("./build_dart.wasm", import.meta.url))),
);

declare const __dart_bin: Uint16Array;
declare const __dart_start: number;
invoke(wasm, asm);

const { instance: comet2 } = await WebAssembly.instantiateStreaming(
  fetch(new URL("./comet2_slim.wasm", import.meta.url)),
  {
    env: {
      call_supervisor: (fn: (() => void) | null): void => {
        assert(fn);
        fn();
      },
    },
  },
);
const memory = new Int16Array(
  (comet2.exports.memory as WebAssembly.Memory).buffer,
);
memory.set(__dart_bin, 0);

const gr1 = comet2.exports.GR1 as WebAssembly.Global;
const gr2 = comet2.exports.GR2 as WebAssembly.Global;
const pr = comet2.exports.PR as WebAssembly.Global;
const sp = comet2.exports.SP as WebAssembly.Global;

const step = comet2.exports.step as () => void;

const su = comet2.exports.supervisor as WebAssembly.Table;
su.set(1, () => {
  const input = prompt(">");
  if (input === null) {
    memory.set([-1], gr1.value);
    return;
  }
  const bytes = new TextEncoder().encode(input).slice(0, gr2.value);
  memory.set(bytes, gr1.value);
  memory.set([-1], gr1.value + bytes.length);
});
su.set(2, () => {
  const output = memory.slice(gr1.value, gr1.value + gr2.value);

  console.log(
    String.fromCharCode(...output.slice(0, output.findIndex((v) => v === -1))),
  );
});

pr.value = __dart_start;
do {
  step();
} while (sp.value);
