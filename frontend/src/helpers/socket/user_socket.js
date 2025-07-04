import { Socket } from "phoenix";

const BACKEND_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:4000";
const wsUrl = BACKEND_URL.replace(/^http/, "ws") + "/socket";

const socket = new Socket(wsUrl, {
  params: () => ({ token: localStorage.getItem("token") }),
});

socket.connect();

socket.onOpen(() => console.log("Socket connected"));
socket.onError(() => console.error("Socket error"));
socket.onClose(() => console.log("Socket closed"));

export { socket };
