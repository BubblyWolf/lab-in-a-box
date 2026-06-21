const express = require('express');
const redis = require('redis');
const client = require('prom-client');
const crypto = require('crypto');

// Config
const PORT = process.env.PORT || 3002;
const REDIS_URL = process.env.REDIS_URL || 'redis://localhost:6379';
// How much real CPU work each job costs (ms). This is what drives autoscaling:
// under a flood of jobs, worker CPU rises and the HPA adds more worker pods.
const WORK_CPU_MS = parseInt(process.env.WORK_CPU_MS || '120', 10);

// Burn CPU for ~ms by hashing in a tight loop (real work, not a sleep).
function burnCpu(ms) {
  const end = Date.now() + ms;
  let h = '0';
  while (Date.now() < end) {
    h = crypto.createHash('sha256').update(h).digest('hex');
  }
}

// Prometheus metrics
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const jobsProcessed = new client.Counter({
  name: 'pulse_jobs_processed_total',
  help: 'Total jobs processed from queue',
  registers: [register]
});

// Redis client
const redisClient = redis.createClient({ url: REDIS_URL });
redisClient.on('error', (err) => console.error('Redis error:', err));

let redisConnected = false;
let running = true;

// HTTP server for metrics and health
const app = express();

app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

const server = app.listen(PORT, () => {
  console.log(`Worker metrics on port ${PORT}`);
});

async function start() {
  await redisClient.connect();
  redisConnected = true;
  console.log(`Worker connected to Redis at ${REDIS_URL}`);

  while (running) {
    try {
      const result = await redisClient.blPop('jobs:queue', 5);

      if (result) {
        const job = JSON.parse(result.element);
        console.log(`Processing job: ${job.id} (type: ${job.type})`);

        // Do real CPU work for this job (drives autoscaling under load)...
        burnCpu(WORK_CPU_MS);
        // ...then yield briefly so the /healthz + /metrics endpoints stay responsive.
        await new Promise(r => setTimeout(r, 20));

        await redisClient.incr('jobs:processed');
        jobsProcessed.inc();

        console.log(`Completed job: ${job.id}`);
      }
    } catch (err) {
      if (running) {
        console.error('Job processing error:', err);
        await new Promise(r => setTimeout(r, 1000));
      }
    }
  }
}

// Graceful shutdown
async function shutdown() {
  console.log('Worker shutting down...');
  running = false;

  server.close();

  if (redisConnected) {
    await redisClient.quit();
  }

  // Give active job a moment to finish
  setTimeout(() => process.exit(0), 500);
}

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

start().catch(err => {
  console.error('Failed to start:', err);
  process.exit(1);
});