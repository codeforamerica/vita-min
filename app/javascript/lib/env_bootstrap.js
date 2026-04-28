// Loaded by the dev tooling pack to surface env vars in dev/test.
import crossenv from "crossenv";

export function bootstrapEnv(extra = {}) {
  const env = crossenv({ NODE_ENV: process.env.NODE_ENV || "development", ...extra });
  return env;
}
