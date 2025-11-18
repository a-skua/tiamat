import { assertEquals } from "jsr:@std/assert";
import * as comet2 from "./comet2.wasm";

function random(max = 2 ** 16): number {
  return Math.floor(Math.random() * max);
}

function test(
  expect: {
    gr: readonly [
      number,
      number,
      number,
      number,
      number,
      number,
      number,
      number,
    ];
    pr: number;
    sp: number;
    fr: number;
  },
) {
  assertEquals({
    gr: [
      GR[0].value,
      GR[1].value,
      GR[2].value,
      GR[3].value,
      GR[4].value,
      GR[5].value,
      GR[6].value,
      GR[7].value,
    ],
    pr: PR.value,
    sp: SP.value,
    fr: FR.value,
  }, expect);
}

const { reset, step } = comet2;
const memory = new DataView(comet2.memory.buffer);

const GR = [
  comet2.GR0 as unknown as WebAssembly.Global,
  comet2.GR1 as unknown as WebAssembly.Global,
  comet2.GR2 as unknown as WebAssembly.Global,
  comet2.GR3 as unknown as WebAssembly.Global,
  comet2.GR4 as unknown as WebAssembly.Global,
  comet2.GR5 as unknown as WebAssembly.Global,
  comet2.GR6 as unknown as WebAssembly.Global,
  comet2.GR7 as unknown as WebAssembly.Global,
] as const;
const PR = comet2.PR as unknown as WebAssembly.Global;
const SP = comet2.SP as unknown as WebAssembly.Global;
const FR = comet2.FR as unknown as WebAssembly.Global;

// Deno.test("foo", () => {
//   assertEquals(comet2.foo(), -1);
// });

Deno.test("reset", () => {
  for (const gr of GR) {
    gr.value = random();
  }
  PR.value = random();
  SP.value = random();
  FR.value = random();

  reset();
  test({ gr: [0, 0, 0, 0, 0, 0, 0, 0], pr: 0, sp: 0xffff, fr: 0b000 });
});

Deno.test("step", async (t) => {
  await t.step("NOP", () => {
    reset();

    const pr = random(2 ** 15);
    PR.value = pr;

    step();
    test({ gr: [0, 0, 0, 0, 0, 0, 0, 0], pr: pr + 1, sp: 0xffff, fr: 0b000 });
  });

  const tests = [
    {
      op: 0x1000,
      adr: random(2 ** 15),
      val: 1,
      gr: [0, 0, 0, 0, 0, 0, 0, 0],
      expect: { gr: [1, 0, 0, 0, 0, 0, 0, 0], pr: 2, sp: 0xffff, fr: 0b000 },
    },
    {
      op: 0x1010,
      adr: random(2 ** 15),
      val: 1,
      gr: [0, 0, 0, 0, 0, 0, 0, 0],
      expect: { gr: [0, 1, 0, 0, 0, 0, 0, 0], pr: 2, sp: 0xffff, fr: 0b000 },
    },
    {
      op: 0x1020,
      adr: random(2 ** 15),
      val: 1,
      gr: [0, 0, 0, 0, 0, 0, 0, 0],
      expect: { gr: [0, 0, 1, 0, 0, 0, 0, 0], pr: 2, sp: 0xffff, fr: 0b000 },
    },
    {
      op: 0x1030,
      adr: random(2 ** 15),
      val: 1,
      gr: [0, 0, 0, 0, 0, 0, 0, 0],
      expect: { gr: [0, 0, 0, 1, 0, 0, 0, 0], pr: 2, sp: 0xffff, fr: 0b000 },
    },
    {
      op: 0x1040,
      adr: random(2 ** 15),
      val: 1,
      gr: [0, 0, 0, 0, 0, 0, 0, 0],
      expect: { gr: [0, 0, 0, 0, 1, 0, 0, 0], pr: 2, sp: 0xffff, fr: 0b000 },
    },
    {
      op: 0x1050,
      adr: random(2 ** 15),
      val: 1,
      gr: [0, 0, 0, 0, 0, 0, 0, 0],
      expect: { gr: [0, 0, 0, 0, 0, 1, 0, 0], pr: 2, sp: 0xffff, fr: 0b000 },
    },
    {
      op: 0x1060,
      adr: random(2 ** 15),
      val: 1,
      gr: [0, 0, 0, 0, 0, 0, 0, 0],
      expect: { gr: [0, 0, 0, 0, 0, 0, 1, 0], pr: 2, sp: 0xffff, fr: 0b000 },
    },
    {
      op: 0x1070,
      adr: random(2 ** 15),
      val: 1,
      gr: [0, 0, 0, 0, 0, 0, 0, 0],
      expect: { gr: [0, 0, 0, 0, 0, 0, 0, 1], pr: 2, sp: 0xffff, fr: 0b000 },
    },
    {
      op: 0x1000,
      adr: random(2 ** 15),
      val: 0,
      gr: [0, 0, 0, 0, 0, 0, 0, 0],
      expect: { gr: [0, 0, 0, 0, 0, 0, 0, 0], pr: 2, sp: 0xffff, fr: 0b001 },
    },
    {
      op: 0x1000,
      adr: random(2 ** 15),
      val: 0xffff,
      gr: [0, 0, 0, 0, 0, 0, 0, 0],
      expect: { gr: [0xffff, 0, 0, 0, 0, 0, 0, 0], pr: 2, sp: 0xffff, fr: 0b010 },
    },
    {
      op: 0x1007,
      adr: random(2 ** 15),
      val: 1,
      gr: [0, 0, 0, 0, 0, 0, 0, 100],
      expect: { gr: [1, 0, 0, 0, 0, 0, 0, 100], pr: 2, sp: 0xffff, fr: 0b000 },
    },
  ] as const;

  for (const { op, adr, val, gr, expect } of tests) {
    await t.step(
      `LD (op=0x${op.toString(16).padStart(4, "0")}, adr=0x${
        adr.toString(16).padStart(4, "0")
      }, val=${val})`,
      () => {
        reset();

        for (const i in gr) {
          GR[i].value = gr[i];
        }
        const x = gr.reduce((a, b) => a + b, 0 as number);
        memory.setInt16(0, op, true);
        memory.setInt16(2, adr, true);
        memory.setInt16((adr + x) * 2, val, true);

        step();
        test(expect);
      },
    );
  }
});
