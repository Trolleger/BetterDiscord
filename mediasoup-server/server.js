const mediasoup = require('mediasoup');
const WebSocket = require('ws');

const PORT = 3000;

// Store active transports and producers
const transports = new Map();
const producers = new Map();

async function run() {
  // 1. Create Worker
  const worker = await mediasoup.createWorker({
    logLevel: 'debug',
    rtcMinPort: 40000,
    rtcMaxPort: 40100
  });

  // 2. Create Router
  const router = await worker.createRouter({
    mediaCodecs: [
      {
        kind: 'audio',
        mimeType: 'audio/opus',
        clockRate: 48000,
        channels: 2
      },
      {
        kind: 'video',
        mimeType: 'video/VP8',
        clockRate: 90000
      }
    ]
  });

  // 3. WebSocket Server
  const wss = new WebSocket.Server({ port: PORT });
  console.log(`✅ Mediasoup signaling server running on ws://localhost:${PORT}`);

  wss.on('connection', (ws) => {
    console.log('🔌 New client connected');

    ws.on('message', async (raw) => {
      try {
        const msg = JSON.parse(raw);
        console.log(`📨 Received: ${msg.type}`);

        switch (msg.type) {
          // Basic ping/pong
          case 'ping':
            ws.send(JSON.stringify({ type: 'pong' }));
            break;

          // Get router capabilities
          case 'getRouterCapabilities':
            ws.send(JSON.stringify({
              type: 'routerCapabilities',
              data: router.rtpCapabilities
            }));
            break;

          // Create WebRTC transport
          case 'createTransport':
            const transport = await router.createWebRtcTransport({
              listenIps: [{ ip: '0.0.0.0', announcedIp: null }], // Use Docker IP in production
              enableUdp: true,
              enableTcp: true,
            });
            
            transports.set(transport.id, transport);
            
            transport.on('dtlsstatechange', (state) => {
              if (state === 'closed') {
                transports.delete(transport.id);
              }
            });

            ws.send(JSON.stringify({
              type: 'transportCreated',
              data: {
                id: transport.id,
                iceParameters: transport.iceParameters,
                iceCandidates: transport.iceCandidates,
                dtlsParameters: transport.dtlsParameters
              }
            }));
            break;

          // Connect transport
          case 'connectTransport': {
            const { transportId, dtlsParameters } = msg.data;
            await transports.get(transportId).connect({ dtlsParameters });
            ws.send(JSON.stringify({ type: 'transportConnected' }));
            break;
          }

          // Create producer (sender)
          case 'produce':
            const { transportId, kind, rtpParameters } = msg.data;
            const producer = await transports
              .get(transportId)
              .produce({ kind, rtpParameters });
            
            producers.set(producer.id, producer);
            ws.send(JSON.stringify({
              type: 'producerReady',
              data: { id: producer.id }
            }));
            break;

          // Create consumer (receiver)
          case 'consume':
            const { producerId, rtpCapabilities } = msg.data;
            const consumer = await transports
              .get(msg.data.transportId)
              .consume({
                producerId,
                rtpCapabilities,
                paused: false
              });
            
            ws.send(JSON.stringify({
              type: 'consumerReady',
              data: {
                id: consumer.id,
                producerId: producerId,
                kind: consumer.kind,
                rtpParameters: consumer.rtpParameters
              }
            }));
            break;

          default:
            throw new Error(`Unknown message type: ${msg.type}`);
        }
      } catch (err) {
        console.error('⚠️ Error:', err.message);
        ws.send(JSON.stringify({
          type: 'error',
          data: err.message
        }));
      }
    });

    ws.on('close', () => {
      console.log('❌ Client disconnected');
      transports.clear();
      producers.clear();
    });
  });
}

run().catch(console.error);