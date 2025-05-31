import { useEffect, useRef, useState } from "react";
import { Device } from "mediasoup-client";

export function useMediasoup(routerRtpCapabilities: any) {
  const [device, setDevice] = useState<Device | null>(null);
  const [sendTransport, setSendTransport] = useState<any>(null);
  const socket = useRef<WebSocket>(null);

  useEffect(() => {
    socket.current = new WebSocket("ws://localhost:4000/socket/websocket");

    socket.current.onopen = () => {
      // Join mediasoup channel
      socket.current?.send(
        JSON.stringify({
          event: "phx_join",
          topic: "mediasoup:lobby",
          payload: {},
          ref: "1",
        })
      );

      // Request to create send transport
      socket.current?.send(
        JSON.stringify({
          event: "createWebRtcTransport",
          topic: "mediasoup:lobby",
          payload: { direction: "send" },
          ref: "2",
        })
      );
    };

    socket.current.onmessage = async (event) => {
      const msg = JSON.parse(event.data);

      if (msg.event === "transportCreated") {
        const params = msg.payload;

        const newDevice = new Device();
        await newDevice.load({ routerRtpCapabilities });

        const transport = newDevice.createSendTransport(params);

        transport.on("connect", ({ dtlsParameters }, callback, errback) => {
          socket.current?.send(
            JSON.stringify({
              event: "connectTransport",
              topic: "mediasoup:lobby",
              payload: {
                transportId: params.id,
                dtlsParameters,
              },
              ref: "3",
            })
          );
          // Assume success for now
          callback();
        });

        setDevice(newDevice);
        setSendTransport(transport);
      }

      if (msg.event === "connectTransportSuccess") {
        console.log("Transport connected:", msg.payload.transportId);
      }

      if (msg.event === "error") {
        console.error("Mediasoup error:", msg.payload.reason);
      }
    };

    return () => {
      socket.current?.close();
    };
  }, [routerRtpCapabilities]);

  return { device, sendTransport };
}
