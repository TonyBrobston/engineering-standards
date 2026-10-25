import { defineConfig } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import brobston from "@tonybrobston/engineering-standards/eslint";

export default defineConfig([...nextVitals, ...brobston]);
