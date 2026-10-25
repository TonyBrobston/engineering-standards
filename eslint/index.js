import { brobstonPlugin } from "./no-comments.js";

const allowedShortNames = ["i", "j", "k", "x", "y", "id", "ok", "db", "fs", "os", "to", "at", "on"];

const namingRules = {
  "id-length": ["error", { min: 3, exceptions: allowedShortNames, properties: "never" }],
  camelcase: ["error", { properties: "never", ignoreDestructuring: true, allow: ["^UNSAFE_"] }],
};

const structureRules = {
  curly: ["error", "all"],
  "brace-style": ["error", "1tbs", { allowSingleLine: false }],
  "no-nested-ternary": "error",
  "no-unneeded-ternary": "error",
  "no-sequences": "error",
  "no-warning-comments": ["error", { terms: ["todo", "fixme", "hack", "xxx"], location: "anywhere" }],
  "no-unused-vars": ["error", { argsIgnorePattern: "^_", varsIgnorePattern: "^_" }],
  "no-param-reassign": "error",
  "prefer-const": "error",
  "no-var": "error",
  eqeqeq: ["error", "always"],
  "max-depth": ["error", 3],
  "max-params": ["error", 4],
  complexity: ["error", 10],
};

export const brobstonRules = {
  "brobston/no-comments": "error",
  ...namingRules,
  ...structureRules,
};

export const brobstonConfig = {
  name: "brobston/engineering-standards",
  plugins: { brobston: brobstonPlugin },
  rules: brobstonRules,
};

export const brobstonTestOverrides = {
  name: "brobston/engineering-standards/tests",
  files: ["**/*.test.*", "**/*.spec.*", "**/tests/**", "**/__tests__/**", "**/testing/**"],
  rules: {
    "max-params": "off",
    complexity: "off",
    "id-length": "off",
  },
};

export const brobstonIgnores = {
  name: "brobston/engineering-standards/ignores",
  ignores: [".engineering-standards/**", "dist/**", "build/**", "coverage/**", ".next/**", "out/**"],
};

export default [brobstonIgnores, brobstonConfig, brobstonTestOverrides];
