import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

export default ({ mode }) => {
  const env = loadEnv(mode, process.cwd(), "");
  
  return defineConfig({
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
      port: Number(env.VITE_DEV_SERVER_PORT) || 3000,
      strictPort: true,
      watch: {
        usePolling: true,
        interval: 300,
      },
      fs: {
        strict: false,
      },
    },
    build: {
      target: "esnext",
    },
  });
};