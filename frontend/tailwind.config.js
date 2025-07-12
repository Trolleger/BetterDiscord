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
      jsx: 'react',
      loader: {
        '.ts': 'tsx',
        '.tsx': 'tsx',
      },
    },
  },
  build: {
    outDir: './dist',  // Set build output to the root dist folder
    commonjsOptions: {
      transformMixedEsModules: true,
    },
  },
});
