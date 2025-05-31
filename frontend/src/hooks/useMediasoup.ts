import { useEffect, useState } from "react";
import { Device } from "mediasoup-client";

export function useMediasoup(routerRtpCapabilities: any) {
  const [device, setDevice] = useState<Device | null>(null);
  const [sendTransport, setSendTransport] = useState<any>(null);

  useEffect(() => {
    const socket = new WebSocket("ws://localhost:3001");

    socket.onopen = () => {
      console.log("Connected to mediasoup server");
      // Example: send a message to create send transport (you need to implement on server)
      socket.send(JSON.stringify({ action: "createWebRtcTransport", direction: "send" }));
    };

    socket.onmessage = async (event) => {
      const msg = JSON.parse(event.data);
      console.log("Message from server:", msg);

      if (msg.action === "transportCreated") {
        const params = msg.data;

        const newDevice = new Device();
        await newDevice.load({ routerRtpCapabilities });

        const transport = newDevice.createSendTransport(params);

        transport.on("connect", ({ dtlsParameters }, callback, errback) => {
          socket.send(
            JSON.stringify({
              action: "connectTransport",
              transportId: params.id,
              dtlsParameters,
            })
          );
          callback();
        });

        setDevice(newDevice);
        setSendTransport(transport);
      }

      if (msg.action === "error") {
        console.error("Mediasoup error:", msg.reason);
      }
    };

    socket.onerror = (err) => {
      console.error("WebSocket error:", err);
    };

    return () => {
      socket.close();
    };
  }, [routerRtpCapabilities]);

  return { device, sendTransport };
}
