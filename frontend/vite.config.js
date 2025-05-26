import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true,
  },
  build: {
    outDir: 'build',    // Build files here
    emptyOutDir: true,
  },
  base: './',            // crucial for Electron relative paths
  publicDir: false,      // disables the /public folder copying
  resolve: {
    extensions: ['.js', '.jsx', '.ts', '.tsx'],
  },
});
