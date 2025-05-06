// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      'expo': resolve(__dirname, 'node_modules/expo'),
      'expo-modules-core': resolve(__dirname, 'node_modules/expo-modules-core'),
    },
  },
  optimizeDeps: {
    include: ['expo', 'expo-modules-core'],
    esbuildOptions: {
      tsconfig: 'tsconfig.json',
      // This helps with TypeScript's "export type" syntax
      jsx: 'react',
      loader: {
        '.ts': 'tsx',
        '.tsx': 'tsx',
      },
    },
  },
  build: {
    commonjsOptions: {
      transformMixedEsModules: true,
    },
  },
});