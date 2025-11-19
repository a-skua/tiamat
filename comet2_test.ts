import { assertEquals, assertThrows } from "@std/assert";
import * as comet2 from "./comet2.wasm";

console.log("comet2:", comet2);

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

const { reset, step, supervisor } = comet2;
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
  await t.step("LD", async (t) => {
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
        expect: {
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
          pr: 2,
          sp: 0xffff,
          fr: 0b010,
        },
      },
      {
        op: 0x1007,
        adr: random(2 ** 15),
        val: 1,
        gr: [0, 0, 0, 0, 0, 0, 0, 100],
        expect: {
          gr: [1, 0, 0, 0, 0, 0, 0, 100],
          pr: 2,
          sp: 0xffff,
          fr: 0b000,
        },
      },
      {
        op: 0x1010,
        adr: random(2 ** 15),
        val: 1,
        gr: [100, 0, 0, 0, 0, 0, 0, 0],
        expect: {
          gr: [100, 1, 0, 0, 0, 0, 0, 0],
          pr: 2,
          sp: 0xffff,
          fr: 0b000,
        },
      },
    ] as const;

    for (const { op, adr, val, gr, expect } of tests) {
      await t.step(
        `op=0x${op.toString(16).padStart(4, "0")}, adr=0x${
          adr.toString(16).padStart(4, "0")
        }, val=${val}`,
        () => {
          reset();

          for (const i in gr) {
            GR[i].value = gr[i];
          }
          const x = gr.slice(1).reduce((a, b) => a + b, 0 as number);
          memory.setInt16(0, op, true);
          memory.setInt16(2, adr, true);
          memory.setInt16((adr + x) * 2, val, true);

          step();
          test(expect);
        },
      );
    }
  });

  await t.step("PUSH", async (t) => {
    const tests = [
      {
        op: 0x7000,
        adr: random(2 ** 15),
        gr: [100, 0, 0, 0, 0, 0, 0, 0],
        sp: 255,
        expect: { gr: [100, 0, 0, 0, 0, 0, 0, 0], pr: 2, sp: 254, fr: 0b000 },
      },
      {
        op: 0x7001,
        adr: random(2 ** 15),
        gr: [100, 1, 0, 0, 0, 0, 0, 0],
        sp: 255,
        expect: { gr: [100, 1, 0, 0, 0, 0, 0, 0], pr: 2, sp: 254, fr: 0b000 },
      },
      {
        op: 0x7002,
        adr: random(2 ** 15),
        gr: [100, 0, 1, 0, 0, 0, 0, 0],
        sp: 255,
        expect: { gr: [100, 0, 1, 0, 0, 0, 0, 0], pr: 2, sp: 254, fr: 0b000 },
      },
      {
        op: 0x7003,
        adr: random(2 ** 15),
        gr: [100, 0, 0, 1, 0, 0, 0, 0],
        sp: 255,
        expect: { gr: [100, 0, 0, 1, 0, 0, 0, 0], pr: 2, sp: 254, fr: 0b000 },
      },
      {
        op: 0x7004,
        adr: random(2 ** 15),
        gr: [100, 0, 0, 0, 1, 0, 0, 0],
        sp: 255,
        expect: { gr: [100, 0, 0, 0, 1, 0, 0, 0], pr: 2, sp: 254, fr: 0b000 },
      },
      {
        op: 0x7005,
        adr: random(2 ** 15),
        gr: [100, 0, 0, 0, 0, 1, 0, 0],
        sp: 255,
        expect: { gr: [100, 0, 0, 0, 0, 1, 0, 0], pr: 2, sp: 254, fr: 0b000 },
      },
      {
        op: 0x7006,
        adr: random(2 ** 15),
        gr: [100, 0, 0, 0, 0, 0, 1, 0],
        sp: 255,
        expect: { gr: [100, 0, 0, 0, 0, 0, 1, 0], pr: 2, sp: 254, fr: 0b000 },
      },
      {
        op: 0x7007,
        adr: random(2 ** 15),
        gr: [100, 0, 0, 0, 0, 0, 0, 1],
        sp: 255,
        expect: { gr: [100, 0, 0, 0, 0, 0, 0, 1], pr: 2, sp: 254, fr: 0b000 },
      },
    ] as const;

    for (const { op, adr, sp, gr, expect } of tests) {
      await t.step(
        `op=0x${op.toString(16).padStart(4, "0")}, adr=0x${
          adr.toString(16).padStart(4, "0")
        }`,
        () => {
          reset();

          SP.value = sp;
          for (const i in gr) {
            GR[i].value = gr[i];
          }
          memory.setInt16(0, op, true);
          memory.setInt16(2, adr, true);

          const x = gr.slice(1).reduce((a, b) => a + b, 0 as number);

          step();
          test(expect);
          assertEquals(memory.getInt16(sp * 2, true), adr + x);
        },
      );
    }
  });

  await t.step("POP", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x7100,
          val: 1,
          sp: 255,
          expect: { gr: [1, 0, 0, 0, 0, 0, 0, 0], pr: 1, sp: 256, fr: 0b000 },
        },
        {
          op: 0x7110,
          val: 1,
          sp: 255,
          expect: { gr: [0, 1, 0, 0, 0, 0, 0, 0], pr: 1, sp: 256, fr: 0b000 },
        },
        {
          op: 0x7120,
          val: 1,
          sp: 255,
          expect: { gr: [0, 0, 1, 0, 0, 0, 0, 0], pr: 1, sp: 256, fr: 0b000 },
        },
        {
          op: 0x7130,
          val: 1,
          sp: 255,
          expect: { gr: [0, 0, 0, 1, 0, 0, 0, 0], pr: 1, sp: 256, fr: 0b000 },
        },
        {
          op: 0x7140,
          val: 1,
          sp: 255,
          expect: { gr: [0, 0, 0, 0, 1, 0, 0, 0], pr: 1, sp: 256, fr: 0b000 },
        },
        {
          op: 0x7150,
          val: 1,
          sp: 255,
          expect: { gr: [0, 0, 0, 0, 0, 1, 0, 0], pr: 1, sp: 256, fr: 0b000 },
        },
        {
          op: 0x7160,
          val: 1,
          sp: 255,
          expect: { gr: [0, 0, 0, 0, 0, 0, 1, 0], pr: 1, sp: 256, fr: 0b000 },
        },
        {
          op: 0x7170,
          val: 1,
          sp: 255,
          expect: { gr: [0, 0, 0, 0, 0, 0, 0, 1], pr: 1, sp: 256, fr: 0b000 },
        },
        {
          op: 0x7100,
          val: 0,
          sp: 255,
          expect: { gr: [0, 0, 0, 0, 0, 0, 0, 0], pr: 1, sp: 256, fr: 0b000 },
        },
        {
          op: 0x7100,
          val: 0xffff,
          sp: 255,
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 256,
            fr: 0b000,
          },
        },
      ] as const;

      for (const { op, val, sp, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}, val=${val}`,
          () => {
            reset();

            SP.value = sp;

            memory.setInt16(0, op, true);
            memory.setInt16(sp * 2, val, true);
            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x7180,
        0x7190,
        0x71a0,
        0x71b0,
        0x71c0,
        0x71d0,
        0x71e0,
        0x71f0,
      ];

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const val = 1;
            const sp = 255;
            SP.value = sp;

            memory.setInt16(0, op, true);
            memory.setInt16(sp * 2, val, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("CALL", async (t) => {
    const tests = [
      {
        op: 0x8000,
        adr: 128,
        gr: [100, 0, 0, 0, 0, 0, 0, 0],
        sp: 255,
        expect: { gr: [100, 0, 0, 0, 0, 0, 0, 0], pr: 128, sp: 254, fr: 0b000 },
      },
      {
        op: 0x8001,
        adr: 128,
        gr: [100, 1, 0, 0, 0, 0, 0, 0],
        sp: 255,
        expect: { gr: [100, 1, 0, 0, 0, 0, 0, 0], pr: 129, sp: 254, fr: 0b000 },
      },
      {
        op: 0x8002,
        adr: 128,
        gr: [100, 0, 1, 0, 0, 0, 0, 0],
        sp: 255,
        expect: { gr: [100, 0, 1, 0, 0, 0, 0, 0], pr: 129, sp: 254, fr: 0b000 },
      },
      {
        op: 0x8003,
        adr: 128,
        gr: [100, 0, 0, 1, 0, 0, 0, 0],
        sp: 255,
        expect: { gr: [100, 0, 0, 1, 0, 0, 0, 0], pr: 129, sp: 254, fr: 0b000 },
      },
      {
        op: 0x8004,
        adr: 128,
        gr: [100, 0, 0, 0, 1, 0, 0, 0],
        sp: 255,
        expect: { gr: [100, 0, 0, 0, 1, 0, 0, 0], pr: 129, sp: 254, fr: 0b000 },
      },
      {
        op: 0x8005,
        adr: 128,
        gr: [100, 0, 0, 0, 0, 1, 0, 0],
        sp: 255,
        expect: { gr: [100, 0, 0, 0, 0, 1, 0, 0], pr: 129, sp: 254, fr: 0b000 },
      },
      {
        op: 0x8006,
        adr: 128,
        gr: [100, 0, 0, 0, 0, 0, 1, 0],
        sp: 255,
        expect: { gr: [100, 0, 0, 0, 0, 0, 1, 0], pr: 129, sp: 254, fr: 0b000 },
      },
      {
        op: 0x8007,
        adr: 128,
        gr: [100, 0, 0, 0, 0, 0, 0, 1],
        sp: 255,
        expect: { gr: [100, 0, 0, 0, 0, 0, 0, 1], pr: 129, sp: 254, fr: 0b000 },
      },
      {
        op: 0x8000,
        adr: 0,
        gr: [100, 0, 0, 0, 0, 0, 0, 0],
        sp: 255,
        expect: { gr: [100, 0, 0, 0, 0, 0, 0, 0], pr: 0, sp: 254, fr: 0b000 },
      },
      {
        op: 0x8000,
        adr: 0xffff,
        gr: [100, 0, 0, 0, 0, 0, 0, 0],
        sp: 255,
        expect: {
          gr: [100, 0, 0, 0, 0, 0, 0, 0],
          pr: 0xffff,
          sp: 254,
          fr: 0b000,
        },
      },
    ] as const;

    for (const { op, adr, gr, sp, expect } of tests) {
      await t.step(
        `op=0x${op.toString(16).padStart(4, "0")}, adr=${
          adr.toString(16).padStart(4, "0")
        }`,
        () => {
          reset();

          for (const i in gr) {
            GR[i].value = gr[i];
          }
          SP.value = sp;
          memory.setInt16(0, op, true);
          memory.setInt16(2, adr, true);

          step();
          test(expect);
          assertEquals(memory.getInt16(sp * 2, true), 2);
        },
      );
    }
  });

  await t.step("RET", async (t) => {
    const tests = [
      {
        op: 0x8100,
        val: 128,
        sp: 255,
        expect: { gr: [0, 0, 0, 0, 0, 0, 0, 0], pr: 128, sp: 256, fr: 0b000 },
      },
      {
        op: 0x8100,
        val: 0,
        sp: 255,
        expect: { gr: [0, 0, 0, 0, 0, 0, 0, 0], pr: 0, sp: 256, fr: 0b000 },
      },
      {
        op: 0x8100,
        val: 0xffff,
        sp: 255,
        expect: {
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          pr: 0xffff,
          sp: 256,
          fr: 0b000,
        },
      },
    ] as const;

    for (const { op, val, sp, expect } of tests) {
      await t.step(
        `op=0x${op.toString(16).padStart(4, "0")}, val=${val}`,
        () => {
          reset();

          SP.value = sp;
          memory.setInt16(0, op, true);
          memory.setInt16(sp * 2, val, true);

          step();
          test(expect);
        },
      );
    }
  });

  await t.step("SVC", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0xf000,
          adr: 0,
          gr: [100, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [100, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0xf001,
          adr: 0,
          gr: [100, 1, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [100, 1, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0xf002,
          adr: 0,
          gr: [100, 0, 1, 0, 0, 0, 0, 0],
          expect: {
            gr: [100, 0, 1, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0xf003,
          adr: 0,
          gr: [100, 0, 0, 1, 0, 0, 0, 0],
          expect: {
            gr: [100, 0, 0, 1, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0xf004,
          adr: 0,
          gr: [100, 0, 0, 0, 1, 0, 0, 0],
          expect: {
            gr: [100, 0, 0, 0, 1, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0xf005,
          adr: 0,
          gr: [100, 0, 0, 0, 0, 1, 0, 0],
          expect: {
            gr: [100, 0, 0, 0, 0, 1, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0xf006,
          adr: 0,
          gr: [100, 0, 0, 0, 0, 0, 1, 0],
          expect: {
            gr: [100, 0, 0, 0, 0, 0, 1, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0xf007,
          adr: 0,
          gr: [100, 0, 0, 0, 0, 0, 0, 1],
          expect: {
            gr: [100, 0, 0, 0, 0, 0, 0, 1],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
      ] as const;

      for (const { op, adr, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}, adr=${
            adr.toString(16).padStart(4, "0")
          }`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            const x = gr.slice(1).reduce((a, b) => a + b, 0 as number);
            let call = 0;
            supervisor.set(adr + x, () => call++);

            step();
            test(expect);
            assertEquals(call, 1);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0xf008,
        0xf009,
        0xf00a,
        0xf00b,
        0xf00c,
        0xf00d,
        0xf00e,
        0xf00f,
      ];
      for (const op of tests) {
        await t.step(`op=0x${op.toString(16).padStart(4, "0")}`, () => {
          reset();

          const op = 0xf008;
          const adr = 0;
          const gr = [100, 0, 0, 0, 0, 0, 0, 1];
          for (const i in gr) {
            GR[i].value = gr[i];
          }
          memory.setInt16(0, op, true);
          memory.setInt16(2, adr, true);

          const x = gr.slice(1).reduce((a, b) => a + b, 0 as number);
          let call = 0;
          supervisor.set(adr + x, () => call++);

          assertThrows(() => step());
        });
      }
    });
  });

  await t.step("NOP", () => {
    reset();

    const pr = random(2 ** 15);
    PR.value = pr;

    step();
    test({ gr: [0, 0, 0, 0, 0, 0, 0, 0], pr: pr + 1, sp: 0xffff, fr: 0b000 });
  });
});
