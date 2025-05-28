const mediasoup = require('mediasoup');

(async () => {
  const worker = await mediasoup.createWorker({
    logLevel: 'warn',
    rtcMinPort: 40000,
    rtcMaxPort: 40100,
  });
  console.log(`MediaSoup Worker started with PID ${worker.pid}`);
  // Prevent exit
  process.stdin.resume();
})();
