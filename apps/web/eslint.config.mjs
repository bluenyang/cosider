import { nuxtConfig } from '@cosider/eslint-config/nuxt';

import withNuxt from './.nuxt/eslint.config.mjs';

// withNuxt already registers `import`. Re-passing eslint-plugin-import-x
// from nuxtConfig makes ESLintFlatConfigUtils throw on plugin instance mismatch.
const withoutDuplicateImport = nuxtConfig.map((config) => {
  if (!config.plugins?.import) return config;
  const plugins = Object.fromEntries(
    Object.entries(config.plugins).filter(([name]) => name !== 'import'),
  );
  return { ...config, plugins };
});

export default withNuxt(...withoutDuplicateImport);
