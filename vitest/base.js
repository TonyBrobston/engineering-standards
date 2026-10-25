export const coverageThresholds = {
  statements: 95,
  branches: 85,
  functions: 95,
  lines: 95,
};

export function brobstonVitestConfig(overrides = {}) {
  const { test: testOverrides = {}, ...rest } = overrides;
  const { coverage: coverageOverrides = {}, ...otherTestOverrides } = testOverrides;
  return {
    ...rest,
    test: {
      include: ["tests/**/*.spec.{ts,tsx,mjs,js}", "src/**/*.test.{ts,tsx,mjs,js}"],
      environment: "node",
      ...otherTestOverrides,
      coverage: {
        provider: "v8",
        include: ["src/**"],
        exclude: ["src/**/*.test.*", "src/testing/**", "src/**/*.d.ts"],
        thresholds: coverageThresholds,
        ...coverageOverrides,
      },
    },
  };
}
