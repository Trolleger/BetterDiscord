// Authorization header is an HTTP request header used to send credentials (like tokens) from the client to the server. 
import { Socket } from "phoenix";
import { fetchSocketToken } from "./socket_auth";
// Gets the imports, fetSocketToken is from auth.ts

const BACKEND_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:4000";
const wsUrl = BACKEND_URL.replace(/^http/, "ws") + "/socket";
// If it's prod link its https


export async function connectSocket(jwtAccessToken) {
  // Takes an async function with jwtAccessToken as an argument, it awaits the fetching of the phoenix token from backend
  try {
    const phoenixToken = await fetchSocketToken(jwtAccessToken);
    if (!phoenixToken) {
      console.error("No Phoenix token, cannot connect socket");
      return null;
      // If no phoenix token it just stops it and gives null
    }
    
    const socket = new Socket(wsUrl, {
      params: { token: phoenixToken },
    });
    // Creates a socke instance

    

    socket.connect();
    // Connects

    socket.onOpen(() => console.log("Socket connected"));
    socket.onError(() => console.error("Socket error"));
    socket.onClose(() => console.log("Socket closed"));
    // Some console logs to check if shit works

    return socket;
    // This returns the connected socket instance so the caller can use it to join channels or send/receive messages. When we return the socket we return the live connected websocket so the user can actually do shit with it
  } catch (error) {
    console.error("Failed to connect socket:", error);
    return null;
  }
}
