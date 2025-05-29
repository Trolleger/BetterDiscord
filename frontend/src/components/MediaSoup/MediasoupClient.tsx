import React, { useEffect } from 'react';
import * as mediasoupClient from 'mediasoup-client';

const MediasoupClient = () => {
  useEffect(() => {
    async function init() {
      const ws = new WebSocket('ws://localhost:3000'); // Change if your backend ws URL differs

      ws.onopen = () => {
        console.log('Connected to signaling server');
        ws.send(JSON.stringify({ action: 'getRouterRtpCapabilities' }));
      };

      ws.onmessage = async (event) => {
        const msg = JSON.parse(event.data);

        if (msg.action === 'routerRtpCapabilities') {
          try {
            const device = new mediasoupClient.Device();
            await device.load({ routerRtpCapabilities: msg.data });
            console.log('Device loaded with RTP capabilities');
            // From here you can create transports, produce/consume media, etc.
          } catch (error) {
            console.error('Error loading device:', error);
          }
        }
      };

      ws.onerror = (error) => {
        console.error('WebSocket error:', error);
      };
    }
    init();
  }, []);

  return <div>Mediasoup client loaded</div>;
};

export default MediasoupClient;
