import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  optimizeDeps: {
    include: ["mediasoup-client"],
    esbuildOptions: {
      target: "esnext",
    },
  },
  server: {
    host: "0.0.0.0",
    port: 3000,
    strictPort: true,
    fs: {
      strict: false,
    },
  },
  build: {
    target: "esnext",
  },
});
