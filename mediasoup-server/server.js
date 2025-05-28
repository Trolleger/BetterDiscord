const mediasoup = require('mediasoup');
const WebSocket = require('ws');

const PORT = 3000;

async function run() {
  // 1. Create a mediasoup worker
  const worker = await mediasoup.createWorker();

  // 2. Create a router with media codecs (audio/video formats)
  const router = await worker.createRouter({
    mediaCodecs: [
      {
        kind: 'audio',
        mimeType: 'audio/opus',
        clockRate: 48000,
        channels: 2,
      },
      {
        kind: 'video',
        mimeType: 'video/VP8',
        clockRate: 90000,
      },
    ],
  });

  // 3. Start WebSocket server for signaling
  const wss = new WebSocket.Server({ port: PORT });

  wss.on('connection', (ws) => {
    console.log('Client connected');

    ws.on('message', (message) => {
      console.log('Received message:', message.toString());
      // For now, just echo back
      ws.send(`Echo: ${message}`);
    });

    ws.on('close', () => {
      console.log('Client disconnected');
    });
  });

  console.log(`Mediasoup signaling server running on ws://localhost:${PORT}`);
}

run().catch(console.error);
