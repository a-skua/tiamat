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
