import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

export default defineConfig({
  plugins: [react()],
  root: './',  // The root is your project directory
  publicDir: 'public',  // Static files like index.html are in the "public" folder
  build: {
    outDir: 'build',  // The final build output will go to the "build" folder
    emptyOutDir: true,  // Clear the build folder before generating new files
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'public/index.html'),  // Ensure Vite uses the index.html in the "public" folder
      },
    },
    commonjsOptions: {
      transformMixedEsModules: true,
    },
  },
});
