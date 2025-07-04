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

const channel = socket.channel("room:lobby", {});

const chatInput = document.querySelector("#chat-input");
const messagesContainer = document.querySelector("#messages");

if (chatInput && messagesContainer) {
  chatInput.addEventListener("keypress", event => {
    if(event.key === 'Enter' && chatInput.value.trim() !== '') {
      channel.push("new_msg", { body: chatInput.value.trim() });
      chatInput.value = "";
    }
  });

  channel.on("new_msg", payload => {
    let messageItem = document.createElement("p");
    messageItem.innerText = `[${new Date().toLocaleTimeString()}] ${payload.body}`;
    messagesContainer.appendChild(messageItem);
  });
}

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp); })
  .receive("error", resp => { console.log("Unable to join", resp); });

export default socket;
