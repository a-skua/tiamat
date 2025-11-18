import { assert } from "@std/assert";

export function call_supervisor(fn: (() => void) | null): void {
  assert(fn);
  fn();
}
