import assert from "node:assert/strict";
import { test } from "node:test";
import { Linter } from "eslint";
import brobston from "./index.js";

const linter = new Linter({ configType: "flat" });

function lint(code) {
  return linter.verify(code, [
    ...brobston,
    { languageOptions: { ecmaVersion: 2022, sourceType: "module" } },
  ]);
}

function ruleIdsOf(code) {
  return lint(code).map((message) => message.ruleId);
}

test("a line comment is reported", () => {
  assert.deepEqual(ruleIdsOf("// explains the next line\nexport const total = 1;\n"), [
    "brobston/no-comments",
  ]);
});

test("a block comment is reported", () => {
  assert.deepEqual(ruleIdsOf("/* why */\nexport const total = 1;\n"), ["brobston/no-comments"]);
});

test("eslint directives are allowed", () => {
  assert.deepEqual(ruleIdsOf("// eslint-disable-next-line id-length\nexport const ct = 5;\n"), []);
});

test("ts-expect-error is allowed", () => {
  assert.deepEqual(ruleIdsOf("// @ts-expect-error legacy global\nexport const total = 1;\n"), []);
});

test("a license identifier is allowed", () => {
  assert.deepEqual(ruleIdsOf("// SPDX-License-Identifier: MIT\nexport const total = 1;\n"), []);
});

test("a todo is reported by both rules", () => {
  const ruleIds = ruleIdsOf("// TODO: later\nexport const total = 1;\n");
  assert.ok(ruleIds.includes("brobston/no-comments"));
  assert.ok(ruleIds.includes("no-warning-comments"));
});

test("one and two character identifiers are reported", () => {
  assert.deepEqual(ruleIdsOf("export const ct = 5;\n"), ["id-length"]);
});

test("braceless control flow is reported", () => {
  const ruleIds = ruleIdsOf("export function clamp(percent) {\n  if (percent > 100) return 100;\n  return percent;\n}\n");
  assert.deepEqual(ruleIds, ["curly"]);
});

test("clean code passes", () => {
  const code = [
    "export function clampPercent(percent) {",
    "  if (percent > 100) {",
    "    return 100;",
    "  }",
    "  return percent;",
    "}",
    "",
  ].join("\n");
  assert.deepEqual(ruleIdsOf(code), []);
});
