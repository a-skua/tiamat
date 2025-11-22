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

  await t.step("ST", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x1100,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          val: 1,
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1110,
          gr: [0, 1, 0, 0, 0, 0, 0, 0],
          val: 1,
          expect: {
            gr: [0, 1, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1120,
          gr: [0, 0, 1, 0, 0, 0, 0, 0],
          val: 1,
          expect: {
            gr: [0, 0, 1, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1130,
          gr: [0, 0, 0, 1, 0, 0, 0, 0],
          val: 1,
          expect: {
            gr: [0, 0, 0, 1, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1140,
          gr: [0, 0, 0, 0, 1, 0, 0, 0],
          val: 1,
          expect: {
            gr: [0, 0, 0, 0, 1, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1150,
          gr: [0, 0, 0, 0, 0, 1, 0, 0],
          val: 1,
          expect: {
            gr: [0, 0, 0, 0, 0, 1, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1160,
          gr: [0, 0, 0, 0, 0, 0, 1, 0],
          val: 1,
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 1, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1170,
          gr: [0, 0, 0, 0, 0, 0, 0, 1],
          val: 1,
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 1],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1101,
          gr: [1, 100, 0, 0, 0, 0, 0, 0],
          val: 1,
          expect: {
            gr: [1, 100, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1102,
          gr: [1, 0, 100, 0, 0, 0, 0, 0],
          val: 1,
          expect: {
            gr: [1, 0, 100, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1103,
          gr: [1, 0, 0, 100, 0, 0, 0, 0],
          val: 1,
          expect: {
            gr: [1, 0, 0, 100, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1104,
          gr: [1, 0, 0, 0, 100, 0, 0, 0],
          val: 1,
          expect: {
            gr: [1, 0, 0, 0, 100, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1105,
          gr: [1, 0, 0, 0, 0, 100, 0, 0],
          val: 1,
          expect: {
            gr: [1, 0, 0, 0, 0, 100, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1106,
          gr: [1, 0, 0, 0, 0, 0, 100, 0],
          val: 1,
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 100, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1107,
          gr: [1, 0, 0, 0, 0, 0, 0, 100],
          val: 1,
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 0, 100],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
      ] as const;

      for (const { op, gr, val, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}, val=${val}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }

            const adr = random(2 ** 15) + 2;

            const x = (op & 0x000f) > 0
              ? gr.slice(1).reduce((a, b) => a + b, 0 as number)
              : 0;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            step();
            test(expect);
            assertEquals(memory.getInt16((adr + x) * 2, true), val);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x1180,
        0x1190,
        0x11a0,
        0x11b0,
        0x11c0,
        0x11d0,
        0x11e0,
        0x11f0,
        0x1108,
        0x1109,
        0x110a,
        0x110b,
        0x110c,
        0x110d,
        0x110e,
        0x110f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;

            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("LAD", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x1200,
          adr: 100,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [100, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1210,
          adr: 100,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 100, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1220,
          adr: 100,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 100, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1230,
          adr: 100,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 100, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1240,
          adr: 100,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 100, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1250,
          adr: 100,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 100, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1260,
          adr: 100,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 100, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1270,
          adr: 100,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 100],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1201,
          adr: 100,
          gr: [0, 1, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [101, 1, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1202,
          adr: 100,
          gr: [0, 0, 1, 0, 0, 0, 0, 0],
          expect: {
            gr: [101, 0, 1, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1203,
          adr: 100,
          gr: [0, 0, 0, 1, 0, 0, 0, 0],
          expect: {
            gr: [101, 0, 0, 1, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1204,
          adr: 100,
          gr: [0, 0, 0, 0, 1, 0, 0, 0],
          expect: {
            gr: [101, 0, 0, 0, 1, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1205,
          adr: 100,
          gr: [0, 0, 0, 0, 0, 1, 0, 0],
          expect: {
            gr: [101, 0, 0, 0, 0, 1, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1206,
          adr: 100,
          gr: [0, 0, 0, 0, 0, 0, 1, 0],
          expect: {
            gr: [101, 0, 0, 0, 0, 0, 1, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1207,
          adr: 100,
          gr: [0, 0, 0, 0, 0, 0, 0, 1],
          expect: {
            gr: [101, 0, 0, 0, 0, 0, 0, 1],
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

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x1280,
        0x1290,
        0x12a0,
        0x12b0,
        0x12c0,
        0x12d0,
        0x12e0,
        0x12f0,
        0x1208,
        0x1209,
        0x120a,
        0x120b,
        0x120c,
        0x120d,
        0x120e,
        0x120f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;

            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("LD_GR", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x1400,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x1401,
          gr: [0, 1, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 1, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1402,
          gr: [0, 0, 1, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 1, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1403,
          gr: [0, 0, 0, 1, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 1, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1404,
          gr: [0, 0, 0, 0, 1, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 1, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1405,
          gr: [0, 0, 0, 0, 0, 1, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 1, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1406,
          gr: [0, 0, 0, 0, 0, 0, 1, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 1, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1407,
          gr: [0, 0, 0, 0, 0, 0, 0, 1],
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 0, 1],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1410,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 1, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1420,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 1, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1430,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 1, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1440,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 1, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1450,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 1, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1460,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 1, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1470,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 0, 1],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x1470,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0xffff],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
      ] as const;

      for (const { op, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            memory.setInt16(0, op, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x1480,
        0x1490,
        0x14a0,
        0x14b0,
        0x14c0,
        0x14d0,
        0x14e0,
        0x14f0,
        0x1408,
        0x1409,
        0x140a,
        0x140b,
        0x140c,
        0x140d,
        0x140e,
        0x140f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            memory.setInt16(0, op, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("ADDA", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x2000,
          val: 0,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x2000,
          val: 1,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [2, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2010,
          val: 1,
          gr: [0, 1, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 2, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2020,
          val: 1,
          gr: [0, 0, 1, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 2, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2030,
          val: 1,
          gr: [0, 0, 0, 1, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 2, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2040,
          val: 1,
          gr: [0, 0, 0, 0, 1, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 2, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2050,
          val: 1,
          gr: [0, 0, 0, 0, 0, 1, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 2, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2060,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 1, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 2, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2070,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 1],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 2],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2001,
          val: 1,
          gr: [1, 1, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [2, 1, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2002,
          val: 1,
          gr: [1, 0, 1, 0, 0, 0, 0, 0],
          expect: {
            gr: [2, 0, 1, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2003,
          val: 1,
          gr: [1, 0, 0, 1, 0, 0, 0, 0],
          expect: {
            gr: [2, 0, 0, 1, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2004,
          val: 1,
          gr: [1, 0, 0, 0, 1, 0, 0, 0],
          expect: {
            gr: [2, 0, 0, 0, 1, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2005,
          val: 1,
          gr: [1, 0, 0, 0, 0, 1, 0, 0],
          expect: {
            gr: [2, 0, 0, 0, 0, 1, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2006,
          val: 1,
          gr: [1, 0, 0, 0, 0, 0, 1, 0],
          expect: {
            gr: [2, 0, 0, 0, 0, 0, 1, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2007,
          val: 1,
          gr: [1, 0, 0, 0, 0, 0, 0, 1],
          expect: {
            gr: [2, 0, 0, 0, 0, 0, 0, 1],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2000,
          val: 1,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x2000,
          val: -1,
          gr: [-1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [-2, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2000,
          val: 0xffff,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [-2, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2000,
          val: 1,
          gr: [0x7fff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [-32768, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2000,
          val: 0xffff,
          gr: [0x8000, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x7fff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b100,
          },
        },
      ] as const;

      for (const { op, val, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}, val=${val}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            const adr = random(2 ** 15) + 2;
            const x = (op & 0xf) > 0
              ? gr.slice(1).reduce((a, b) => a + b, 0 as number)
              : 0;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);
            memory.setInt16((adr + x) * 2, val, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x2080,
        0x2090,
        0x20a0,
        0x20b0,
        0x20c0,
        0x20d0,
        0x20e0,
        0x20f0,
        0x2008,
        0x2009,
        0x200a,
        0x200b,
        0x200c,
        0x200d,
        0x200e,
        0x200f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("SUBA", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x2100,
          val: 0,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x2100,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [-1, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2110,
          val: 1,
          gr: [0, 2, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 1, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2120,
          val: 1,
          gr: [0, 0, 2, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 1, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2130,
          val: 1,
          gr: [0, 0, 0, 2, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 1, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2140,
          val: 1,
          gr: [0, 0, 0, 0, 2, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 1, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2150,
          val: 1,
          gr: [0, 0, 0, 0, 0, 2, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 1, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2160,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 2, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 1, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2170,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 2],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 1],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2101,
          val: 1,
          gr: [0, 1, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [-1, 1, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2102,
          val: 1,
          gr: [0, 0, 1, 0, 0, 0, 0, 0],
          expect: {
            gr: [-1, 0, 1, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2103,
          val: 1,
          gr: [0, 0, 0, 1, 0, 0, 0, 0],
          expect: {
            gr: [-1, 0, 0, 1, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2104,
          val: 1,
          gr: [0, 0, 0, 0, 1, 0, 0, 0],
          expect: {
            gr: [-1, 0, 0, 0, 1, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2105,
          val: 1,
          gr: [0, 0, 0, 0, 0, 1, 0, 0],
          expect: {
            gr: [-1, 0, 0, 0, 0, 1, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2106,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 1, 0],
          expect: {
            gr: [-1, 0, 0, 0, 0, 0, 1, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2107,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 1],
          expect: {
            gr: [-1, 0, 0, 0, 0, 0, 0, 1],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
      ] as const;

      for (const { op, val, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}, val=${val}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            const adr = random(2 ** 15) + 2;
            const x = (op & 0xf) > 0
              ? gr.slice(1).reduce((a, b) => a + b, 0 as number)
              : 0;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);
            memory.setInt16((adr + x) * 2, val, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x2180,
        0x2190,
        0x21a0,
        0x21b0,
        0x21c0,
        0x21d0,
        0x21e0,
        0x21f0,
        0x2108,
        0x2109,
        0x210a,
        0x210b,
        0x210c,
        0x210d,
        0x210e,
        0x210f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("ADDL", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x2200,
          val: 0,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x2200,
          val: 1,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [2, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2210,
          val: 1,
          gr: [0, 1, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 2, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2220,
          val: 1,
          gr: [0, 0, 1, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 2, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2230,
          val: 1,
          gr: [0, 0, 0, 1, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 2, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2240,
          val: 1,
          gr: [0, 0, 0, 0, 1, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 2, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2250,
          val: 1,
          gr: [0, 0, 0, 0, 0, 1, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 2, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2260,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 1, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 2, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2270,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 1],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 2],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2201,
          val: 1,
          gr: [1, 10, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [2, 10, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2202,
          val: 1,
          gr: [1, 0, 10, 0, 0, 0, 0, 0],
          expect: {
            gr: [2, 0, 10, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2203,
          val: 1,
          gr: [1, 0, 0, 10, 0, 0, 0, 0],
          expect: {
            gr: [2, 0, 0, 10, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2204,
          val: 1,
          gr: [1, 0, 0, 0, 10, 0, 0, 0],
          expect: {
            gr: [2, 0, 0, 0, 10, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2205,
          val: 1,
          gr: [1, 0, 0, 0, 0, 10, 0, 0],
          expect: {
            gr: [2, 0, 0, 0, 0, 10, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2206,
          val: 1,
          gr: [1, 0, 0, 0, 0, 0, 10, 0],
          expect: {
            gr: [2, 0, 0, 0, 0, 0, 10, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2207,
          val: 1,
          gr: [1, 0, 0, 0, 0, 0, 0, 10],
          expect: {
            gr: [2, 0, 0, 0, 0, 0, 0, 10],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2200,
          val: 1,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b101,
          },
        },
        {
          op: 0x2200,
          val: -1,
          gr: [-1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xfffe, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2200,
          val: 0xffff,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xfffe, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2200,
          val: 1,
          gr: [0x7fff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x8000, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2200,
          val: 0xffff,
          gr: [0x8000, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x7fff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b100,
          },
        },
      ] as const;

      for (const { op, val, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}, val=${val}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            const adr = random(2 ** 15) + 2;
            const x = (op & 0xf) > 0
              ? gr.slice(1).reduce((a, b) => a + b, 0 as number)
              : 0;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);
            memory.setInt16((adr + x) * 2, val, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x2280,
        0x2290,
        0x22a0,
        0x22b0,
        0x22c0,
        0x22d0,
        0x22e0,
        0x22f0,
        0x2208,
        0x2209,
        0x220a,
        0x220b,
        0x220c,
        0x220d,
        0x220e,
        0x220f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("SUBL", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x2300,
          val: 0,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x2300,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2310,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0xffff, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2320,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0xffff, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2330,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0xffff, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2340,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0xffff, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2350,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0xffff, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2360,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0xffff, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2370,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0xffff],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2301,
          val: 1,
          gr: [0, 10, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 10, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2302,
          val: 1,
          gr: [0, 0, 10, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 10, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2303,
          val: 1,
          gr: [0, 0, 0, 10, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 10, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2304,
          val: 1,
          gr: [0, 0, 0, 0, 10, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 10, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2305,
          val: 1,
          gr: [0, 0, 0, 0, 0, 10, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 10, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2306,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 10, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 10, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2307,
          val: 1,
          gr: [0, 0, 0, 0, 0, 0, 0, 10],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 10],
            pr: 2,
            sp: 0xffff,
            fr: 0b110,
          },
        },
      ] as const;

      for (const { op, val, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}, val=${val}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            const adr = random(2 ** 15) + 2;
            const x = (op & 0xf) > 0
              ? gr.slice(1).reduce((a, b) => a + b, 0 as number)
              : 0;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);
            memory.setInt16((adr + x) * 2, val, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x2380,
        0x2390,
        0x23a0,
        0x23b0,
        0x23c0,
        0x23d0,
        0x23e0,
        0x23f0,
        0x2308,
        0x2309,
        0x230a,
        0x230b,
        0x230c,
        0x230d,
        0x230e,
        0x230f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("ADDA_GR", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x2400,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x2400,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [2, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2410,
          gr: [1, 2, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 3, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2420,
          gr: [1, 0, 2, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 3, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2430,
          gr: [1, 0, 0, 2, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 3, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2440,
          gr: [1, 0, 0, 0, 2, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 3, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2450,
          gr: [1, 0, 0, 0, 0, 2, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 3, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2460,
          gr: [1, 0, 0, 0, 0, 0, 2, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 3, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2470,
          gr: [1, 0, 0, 0, 0, 0, 0, 2],
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 0, 3],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2401,
          gr: [1, 2, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [3, 2, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2402,
          gr: [1, 0, 2, 0, 0, 0, 0, 0],
          expect: {
            gr: [3, 0, 2, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2403,
          gr: [1, 0, 0, 2, 0, 0, 0, 0],
          expect: {
            gr: [3, 0, 0, 2, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2404,
          gr: [1, 0, 0, 0, 2, 0, 0, 0],
          expect: {
            gr: [3, 0, 0, 0, 2, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2405,
          gr: [1, 0, 0, 0, 0, 2, 0, 0],
          expect: {
            gr: [3, 0, 0, 0, 0, 2, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2406,
          gr: [1, 0, 0, 0, 0, 0, 2, 0],
          expect: {
            gr: [3, 0, 0, 0, 0, 0, 2, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2407,
          gr: [1, 0, 0, 0, 0, 0, 0, 2],
          expect: {
            gr: [3, 0, 0, 0, 0, 0, 0, 2],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2401,
          gr: [1, 0x7fff, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [-0x8000, 0x7fff, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2401,
          gr: [-1, -2, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [-3, -2, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
      ] as const;

      for (const { op, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            memory.setInt16(0, op, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x2480,
        0x2490,
        0x24a0,
        0x24b0,
        0x24c0,
        0x24d0,
        0x24e0,
        0x24f0,
        0x2408,
        0x2409,
        0x240a,
        0x240b,
        0x240c,
        0x240d,
        0x240e,
        0x240f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("SUBA_GR", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x2500,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x2500,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x2510,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, -1, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2520,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, -1, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2530,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, -1, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2540,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, -1, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2550,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, -1, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2560,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 0, -1, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2570,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 0, -1],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2501,
          gr: [1, 2, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [-1, 2, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2502,
          gr: [1, 0, 2, 0, 0, 0, 0, 0],
          expect: {
            gr: [-1, 0, 2, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2503,
          gr: [1, 0, 0, 2, 0, 0, 0, 0],
          expect: {
            gr: [-1, 0, 0, 2, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2504,
          gr: [1, 0, 0, 0, 2, 0, 0, 0],
          expect: {
            gr: [-1, 0, 0, 0, 2, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2505,
          gr: [1, 0, 0, 0, 0, 2, 0, 0],
          expect: {
            gr: [-1, 0, 0, 0, 0, 2, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2506,
          gr: [1, 0, 0, 0, 0, 0, 2, 0],
          expect: {
            gr: [-1, 0, 0, 0, 0, 0, 2, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2507,
          gr: [1, 0, 0, 0, 0, 0, 0, 2],
          expect: {
            gr: [-1, 0, 0, 0, 0, 0, 0, 2],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x2507,
          gr: [0xfffe, 0, 0, 0, 0, 0, 0, 0xffff],
          expect: {
            gr: [-1, 0, 0, 0, 0, 0, 0, 0xffff],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
      ] as const;

      for (const { op, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            memory.setInt16(0, op, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x2580,
        0x2590,
        0x25a0,
        0x25b0,
        0x25c0,
        0x25d0,
        0x25e0,
        0x25f0,
        0x2508,
        0x2509,
        0x250a,
        0x250b,
        0x250c,
        0x250d,
        0x250e,
        0x250f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("ADDL_GR", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x2600,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x2600,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [2, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2610,
          gr: [1, 2, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 3, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2620,
          gr: [1, 0, 2, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 3, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2630,
          gr: [1, 0, 0, 2, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 3, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2640,
          gr: [1, 0, 0, 0, 2, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 3, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2650,
          gr: [1, 0, 0, 0, 0, 2, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 3, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2660,
          gr: [1, 0, 0, 0, 0, 0, 2, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 3, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2670,
          gr: [1, 0, 0, 0, 0, 0, 0, 2],
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 0, 3],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2601,
          gr: [1, 2, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [3, 2, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2602,
          gr: [1, 0, 2, 0, 0, 0, 0, 0],
          expect: {
            gr: [3, 0, 2, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2603,
          gr: [1, 0, 0, 2, 0, 0, 0, 0],
          expect: {
            gr: [3, 0, 0, 2, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2604,
          gr: [1, 0, 0, 0, 2, 0, 0, 0],
          expect: {
            gr: [3, 0, 0, 0, 2, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2605,
          gr: [1, 0, 0, 0, 0, 2, 0, 0],
          expect: {
            gr: [3, 0, 0, 0, 0, 2, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2606,
          gr: [1, 0, 0, 0, 0, 0, 2, 0],
          expect: {
            gr: [3, 0, 0, 0, 0, 0, 2, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2607,
          gr: [1, 0, 0, 0, 0, 0, 0, 2],
          expect: {
            gr: [3, 0, 0, 0, 0, 0, 0, 2],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x2607,
          gr: [-1, 0, 0, 0, 0, 0, 0, 1],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 1],
            pr: 1,
            sp: 0xffff,
            fr: 0b101,
          },
        },
        {
          op: 0x2607,
          gr: [0x7fff, 0, 0, 0, 0, 0, 0, 1],
          expect: {
            gr: [0x8000, 0, 0, 0, 0, 0, 0, 1],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
      ] as const;

      for (const { op, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            memory.setInt16(0, op, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x2680,
        0x2690,
        0x26a0,
        0x26b0,
        0x26c0,
        0x26d0,
        0x26e0,
        0x26f0,
        0x2608,
        0x2609,
        0x260a,
        0x260b,
        0x260c,
        0x260d,
        0x260e,
        0x260f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("SUBL_GR", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x2700,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x2700,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x2710,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0xffff, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2720,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0xffff, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2730,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0xffff, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2740,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0xffff, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2750,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 0xffff, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2760,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 0xffff, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b110,
          },
        },
        {
          op: 0x2770,
          gr: [1, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [1, 0, 0, 0, 0, 0, 0, 0xffff],
            pr: 1,
            sp: 0xffff,
            fr: 0b110,
          },
        },
      ] as const;

      for (const { op, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            memory.setInt16(0, op, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x2780,
        0x2790,
        0x27a0,
        0x27b0,
        0x27c0,
        0x27d0,
        0x27e0,
        0x27f0,
        0x2708,
        0x2709,
        0x270a,
        0x270b,
        0x270c,
        0x270d,
        0x270e,
        0x270f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("AND", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x3000,
          val: 0x0f0f,
          gr: [0xf0f0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x3000,
          val: 0x00ff,
          gr: [0xff0f, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3010,
          val: 0x00ff,
          gr: [0, 0xff0f, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0x000f, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3020,
          val: 0x00ff,
          gr: [0, 0, 0xff0f, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0x000f, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3030,
          val: 0x00ff,
          gr: [0, 0, 0, 0xff0f, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0x000f, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3040,
          val: 0x00ff,
          gr: [0, 0, 0, 0, 0xff0f, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0x000f, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3050,
          val: 0x00ff,
          gr: [0, 0, 0, 0, 0, 0xff0f, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0x000f, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3060,
          val: 0x00ff,
          gr: [0, 0, 0, 0, 0, 0, 0xff0f, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0x000f, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3070,
          val: 0x00ff,
          gr: [0, 0, 0, 0, 0, 0, 0, 0xff0f],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0x000f],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3001,
          val: 0x00ff,
          gr: [0xff0f, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3002,
          val: 0x00ff,
          gr: [0xff0f, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3003,
          val: 0x00ff,
          gr: [0xff0f, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3004,
          val: 0x00ff,
          gr: [0xff0f, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3005,
          val: 0x00ff,
          gr: [0xff0f, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3006,
          val: 0x00ff,
          gr: [0xff0f, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3007,
          val: 0x00ff,
          gr: [0xff0f, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3000,
          val: 0x0f0f,
          gr: [0xf0f0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x3000,
          val: 0xffff,
          gr: [0x8000, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x8000, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
      ] as const;

      for (const { op, val, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}, val=${val}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            const adr = random(2 ** 15) + 2;
            const x = (op & 0xf) > 0
              ? gr.slice(1).reduce((a, b) => a + b, 0 as number)
              : 0;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);
            memory.setInt16((adr + x) * 2, val, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x3080,
        0x3090,
        0x30a0,
        0x30b0,
        0x30c0,
        0x30d0,
        0x30e0,
        0x30f0,
        0x3008,
        0x3009,
        0x300a,
        0x300b,
        0x300c,
        0x300d,
        0x300e,
        0x300f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("OR", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x3100,
          val: 0x0f0f,
          gr: [0xf0f0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3110,
          val: 0x0f0f,
          gr: [0, 0xf0f0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0xffff, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3120,
          val: 0x0f0f,
          gr: [0, 0, 0xf0f0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0xffff, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3130,
          val: 0x0f0f,
          gr: [0, 0, 0, 0xf0f0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0xffff, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3140,
          val: 0x0f0f,
          gr: [0, 0, 0, 0, 0xf0f0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0xffff, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3150,
          val: 0x0f0f,
          gr: [0, 0, 0, 0, 0, 0xf0f0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0xffff, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3160,
          val: 0x0f0f,
          gr: [0, 0, 0, 0, 0, 0, 0xf0f0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0xffff, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3170,
          val: 0x0f0f,
          gr: [0, 0, 0, 0, 0, 0, 0, 0xf0f0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0xffff],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3101,
          val: 0x0f0f,
          gr: [0xf0f0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3102,
          val: 0x0f0f,
          gr: [0xf0f0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3103,
          val: 0x0f0f,
          gr: [0xf0f0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3104,
          val: 0x0f0f,
          gr: [0xf0f0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3105,
          val: 0x0f0f,
          gr: [0xf0f0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3106,
          val: 0x0f0f,
          gr: [0xf0f0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3107,
          val: 0x0f0f,
          gr: [0xf0f0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3100,
          val: 0,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b001,
          },
        },
      ] as const;

      for (const { op, val, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}, val=${val}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            const adr = random(2 ** 15) + 2;
            const x = (op & 0xf) > 0
              ? gr.slice(1).reduce((a, b) => a + b, 0 as number)
              : 0;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);
            memory.setInt16((adr + x) * 2, val, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x3180,
        0x3190,
        0x31a0,
        0x31b0,
        0x31c0,
        0x31d0,
        0x31e0,
        0x31f0,
        0x3108,
        0x3109,
        0x310a,
        0x310b,
        0x310c,
        0x310d,
        0x310e,
        0x310f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("XOR", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x3200,
          val: 0xfff0,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3210,
          val: 0xfff0,
          gr: [0, 0xffff, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0x000f, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3220,
          val: 0xfff0,
          gr: [0, 0, 0xffff, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0x000f, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3230,
          val: 0xfff0,
          gr: [0, 0, 0, 0xffff, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0x000f, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3240,
          val: 0xfff0,
          gr: [0, 0, 0, 0, 0xffff, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0x000f, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3250,
          val: 0xfff0,
          gr: [0, 0, 0, 0, 0, 0xffff, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0x000f, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3260,
          val: 0xfff0,
          gr: [0, 0, 0, 0, 0, 0, 0xffff, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0x000f, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3270,
          val: 0xfff0,
          gr: [0, 0, 0, 0, 0, 0, 0, 0xffff],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0x000f],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3201,
          val: 0xfff0,
          gr: [0xffff, 1, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 1, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3202,
          val: 0xfff0,
          gr: [0xffff, 0, 1, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 1, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3203,
          val: 0xfff0,
          gr: [0xffff, 0, 0, 1, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 1, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3204,
          val: 0xfff0,
          gr: [0xffff, 0, 0, 0, 1, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 1, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3205,
          val: 0xfff0,
          gr: [0xffff, 0, 0, 0, 0, 1, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 1, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3206,
          val: 0xfff0,
          gr: [0xffff, 0, 0, 0, 0, 0, 1, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 1, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3207,
          val: 0xfff0,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 1],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 1],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3207,
          val: 0,
          gr: [0, 0, 0, 0, 0, 0, 0, 1],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 1],
            pr: 2,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x3200,
          val: 0x0f0f,
          gr: [0xf0f0, 0, 0, 0, 0, 0, 0, 1],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 1],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
      ] as const;

      for (const { op, val, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}, val=${val}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            const adr = random(2 ** 15) + 2;
            const x = (op & 0xf) > 0
              ? gr.slice(1).reduce((a, b) => a + b, 0 as number)
              : 0;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);
            memory.setInt16((adr + x) * 2, val, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x3280,
        0x3290,
        0x32a0,
        0x32b0,
        0x32c0,
        0x32d0,
        0x32e0,
        0x32f0,
        0x3208,
        0x3209,
        0x320a,
        0x320b,
        0x320c,
        0x320d,
        0x320e,
        0x320f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("AND_GR", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x3400,
          gr: [0x000f, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3401,
          gr: [0x000f, 0xffff, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0xffff, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3402,
          gr: [0x000f, 0, 0xffff, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0xffff, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3403,
          gr: [0x000f, 0, 0, 0xffff, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0xffff, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3404,
          gr: [0x000f, 0, 0, 0, 0xffff, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0xffff, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3405,
          gr: [0x000f, 0, 0, 0, 0, 0xffff, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0xffff, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3406,
          gr: [0x000f, 0, 0, 0, 0, 0, 0xffff, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0xffff, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3407,
          gr: [0x000f, 0, 0, 0, 0, 0, 0, 0xffff],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 0xffff],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3410,
          gr: [0x00ff, 0xff0f, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x00ff, 0x000f, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3420,
          gr: [0x00ff, 0, 0xff0f, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x00ff, 0, 0x000f, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3430,
          gr: [0x00ff, 0, 0, 0xff0f, 0, 0, 0, 0],
          expect: {
            gr: [0x00ff, 0, 0, 0x000f, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3440,
          gr: [0x00ff, 0, 0, 0, 0xff0f, 0, 0, 0],
          expect: {
            gr: [0x00ff, 0, 0, 0, 0x000f, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3450,
          gr: [0x00ff, 0, 0, 0, 0, 0xff0f, 0, 0],
          expect: {
            gr: [0x00ff, 0, 0, 0, 0, 0x000f, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3460,
          gr: [0x00ff, 0, 0, 0, 0, 0, 0xff0f, 0],
          expect: {
            gr: [0x00ff, 0, 0, 0, 0, 0, 0x000f, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3470,
          gr: [0x00ff, 0, 0, 0, 0, 0, 0, 0xff0f],
          expect: {
            gr: [0x00ff, 0, 0, 0, 0, 0, 0, 0x000f],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3400,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x3400,
          gr: [0x8000, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x8000, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
      ] as const;

      for (const { op, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            memory.setInt16(0, op, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x3480,
        0x3490,
        0x34a0,
        0x34b0,
        0x34c0,
        0x34d0,
        0x34e0,
        0x34f0,
        0x3408,
        0x3409,
        0x340a,
        0x340b,
        0x340c,
        0x340d,
        0x340e,
        0x340f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("OR_GR", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x3500,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x3510,
          gr: [0x0f0f, 0xf0f0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x0f0f, 0xffff, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3520,
          gr: [0x0f0f, 0, 0xf0f0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x0f0f, 0, 0xffff, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3530,
          gr: [0x0f0f, 0, 0, 0xf0f0, 0, 0, 0, 0],
          expect: {
            gr: [0x0f0f, 0, 0, 0xffff, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3540,
          gr: [0x0f0f, 0, 0, 0, 0xf0f0, 0, 0, 0],
          expect: {
            gr: [0x0f0f, 0, 0, 0, 0xffff, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3550,
          gr: [0x0f0f, 0, 0, 0, 0, 0xf0f0, 0, 0],
          expect: {
            gr: [0x0f0f, 0, 0, 0, 0, 0xffff, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3560,
          gr: [0x0f0f, 0, 0, 0, 0, 0, 0xf0f0, 0],
          expect: {
            gr: [0x0f0f, 0, 0, 0, 0, 0, 0xffff, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x3570,
          gr: [0x0f0f, 0, 0, 0, 0, 0, 0, 0xf0f0],
          expect: {
            gr: [0x0f0f, 0, 0, 0, 0, 0, 0, 0xffff],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
      ] as const;

      for (const { op, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            memory.setInt16(0, op, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x3580,
        0x3590,
        0x35a0,
        0x35b0,
        0x35c0,
        0x35d0,
        0x35e0,
        0x35f0,
        0x3508,
        0x3509,
        0x350a,
        0x350b,
        0x350c,
        0x350d,
        0x350e,
        0x350f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("XOR_GR", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x3600,
          gr: [0, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x3600,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0, 0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
        {
          op: 0x3610,
          gr: [0xffff, 0xfff0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0x000f, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3620,
          gr: [0xffff, 0, 0xfff0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0x000f, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3630,
          gr: [0xffff, 0, 0, 0xfff0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0x000f, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3640,
          gr: [0xffff, 0, 0, 0, 0xfff0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0x000f, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3650,
          gr: [0xffff, 0, 0, 0, 0, 0xfff0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0x000f, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3660,
          gr: [0xffff, 0, 0, 0, 0, 0, 0xfff0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0x000f, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3670,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0xfff0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0x000f],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3601,
          gr: [0xffff, 0xfff0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0xfff0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3602,
          gr: [0xffff, 0, 0xfff0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0xfff0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3603,
          gr: [0xffff, 0, 0, 0xfff0, 0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0xfff0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3604,
          gr: [0xffff, 0, 0, 0, 0xfff0, 0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0xfff0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3605,
          gr: [0xffff, 0, 0, 0, 0, 0xfff0, 0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0xfff0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3606,
          gr: [0xffff, 0, 0, 0, 0, 0, 0xfff0, 0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0xfff0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3607,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0xfff0],
          expect: {
            gr: [0x000f, 0, 0, 0, 0, 0, 0, 0xfff0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x3601,
          gr: [0x0f0f, 0xf0f0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0xf0f0, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
      ] as const;

      for (const { op, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            memory.setInt16(0, op, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x3680,
        0x3690,
        0x36a0,
        0x36b0,
        0x36c0,
        0x36d0,
        0x36e0,
        0x36f0,
        0x3608,
        0x3609,
        0x360a,
        0x360b,
        0x360c,
        0x360d,
        0x360e,
        0x360f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("CPA", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x4000,
          val: 0x7fff,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x4000,
          val: 0xffff,
          gr: [0x7fff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x7fff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x4000,
          val: 0xffff,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b001,
          },
        },
      ] as const;

      for (const { op, val, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}, val=${val}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            const adr = random(2 ** 15) + 2;
            const x = (op & 0xf) > 0
              ? gr.slice(1).reduce((a, b) => a + b, 0 as number)
              : 0;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);
            memory.setInt16((adr + x) * 2, val, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x4080,
        0x4090,
        0x40a0,
        0x40b0,
        0x40c0,
        0x40d0,
        0x40e0,
        0x40f0,
        0x4008,
        0x4009,
        0x400a,
        0x400b,
        0x400c,
        0x400d,
        0x400e,
        0x400f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("CPL", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x4100,
          val: 0x7fff,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x4100,
          val: 0xffff,
          gr: [0x7fff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x7fff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x4100,
          val: 0xffff,
          gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0, 0, 0, 0, 0, 0, 0],
            pr: 2,
            sp: 0xffff,
            fr: 0b001,
          },
        },
      ] as const;

      for (const { op, val, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}, val=${val}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            const adr = random(2 ** 15) + 2;
            const x = (op & 0xf) > 0
              ? gr.slice(1).reduce((a, b) => a + b, 0 as number)
              : 0;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);
            memory.setInt16((adr + x) * 2, val, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x4180,
        0x4190,
        0x41a0,
        0x41b0,
        0x41c0,
        0x41d0,
        0x41e0,
        0x41f0,
        0x4108,
        0x4109,
        0x410a,
        0x410b,
        0x410c,
        0x410d,
        0x410e,
        0x410f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("CPA_GR", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x4401,
          gr: [0xffff, 0x7fff, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0x7fff, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x4401,
          gr: [0x7fff, 0xffff, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x7fff, 0xffff, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x4401,
          gr: [0xffff, 0xffff, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0xffff, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
      ] as const;

      for (const { op, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            memory.setInt16(0, op, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x4480,
        0x4490,
        0x44a0,
        0x44b0,
        0x44c0,
        0x44d0,
        0x44e0,
        0x44f0,
        0x4408,
        0x4409,
        0x440a,
        0x440b,
        0x440c,
        0x440d,
        0x440e,
        0x440f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            const adr = random(2 ** 15) + 2;
            memory.setInt16(0, op, true);
            memory.setInt16(2, adr, true);

            assertThrows(() => step());
          },
        );
      }
    });
  });

  await t.step("CPL_GR", async (t) => {
    await t.step("normal", async (t) => {
      const tests = [
        {
          op: 0x4501,
          gr: [0xffff, 0x7fff, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0x7fff, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b000,
          },
        },
        {
          op: 0x4501,
          gr: [0x7fff, 0xffff, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0x7fff, 0xffff, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b010,
          },
        },
        {
          op: 0x4501,
          gr: [0xffff, 0xffff, 0, 0, 0, 0, 0, 0],
          expect: {
            gr: [0xffff, 0xffff, 0, 0, 0, 0, 0, 0],
            pr: 1,
            sp: 0xffff,
            fr: 0b001,
          },
        },
      ] as const;

      for (const { op, gr, expect } of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            for (const i in gr) {
              GR[i].value = gr[i];
            }
            memory.setInt16(0, op, true);

            step();
            test(expect);
          },
        );
      }
    });

    await t.step("unreachable", async (t) => {
      const tests = [
        0x4580,
        0x4590,
        0x45a0,
        0x45b0,
        0x45c0,
        0x45d0,
        0x45e0,
        0x45f0,
        0x4508,
        0x4509,
        0x450a,
        0x450b,
        0x450c,
        0x450d,
        0x450e,
        0x450f,
      ] as const;

      for (const op of tests) {
        await t.step(
          `op=0x${op.toString(16).padStart(4, "0")}`,
          () => {
            reset();

            memory.setInt16(0, op, true);

            assertThrows(() => step());
          },
        );
      }
    });
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
