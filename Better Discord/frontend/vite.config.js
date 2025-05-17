import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

export default defineConfig({
  plugins: [react()],
  root: './',                // root is frontend folder (where index.html lives)
  publicDir: 'public',       // static assets
  server: {
    port: 3000,
  },
  build: {
    outDir: 'build',         // output folder for build
    emptyOutDir: true,
    rollupOptions: {
      input: resolve(__dirname, 'index.html'),  // point directly to root index.html
    },
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),           // optional alias for src
    },
  },
});
