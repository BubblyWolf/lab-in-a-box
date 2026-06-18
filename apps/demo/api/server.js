const express = require('express');
const redis = require('redis');
const client = require('prom-client');

const app = express();
app.use(express.json());

// Config
const PORT = process.env.PORT || 3001;
const REDIS_URL = process.env.REDIS_URL || 'redis://localhost:6379';

// Prometheus metrics
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const jobsSubmitted = new client.Counter({
  name: 'pulse_jobs_submitted_total',
  help: 'Total jobs submitted to queue',
  registers: [register]
});

// Redis client
const redisClient = redis.createClient({ url: REDIS_URL });
redisClient.on('error', (err) => console.error('Redis error:', err));

let redisConnected = false;

async function start() {
  await redisClient.connect();
  redisConnected = true;
  console.log(`API connected to Redis at ${REDIS_URL}`);

  app.listen(PORT, () => {
    console.log(`API listening on port ${PORT}`);
  });
}

// Graceful shutdown
async function shutdown() {
  console.log('API shutting down...');
  if (redisConnected) {
    await redisClient.quit();
  }
  process.exit(0);
}

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

// Routes
app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.post('/jobs', async (req, res) => {
  const { type } = req.body;
  const jobType = type || 'default';

  const job = {
    id: `job-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
    type: jobType,
    ts: Date.now()
  };

  await redisClient.lPush('jobs:queue', JSON.stringify(job));
  await redisClient.incr('jobs:submitted');
  jobsSubmitted.inc();

  res.status(202).json({ id: job.id, status: 'accepted' });
});

app.get('/stats', async (req, res) => {
  const submitted = parseInt(await redisClient.get('jobs:submitted') || '0', 10);
  const processed = parseInt(await redisClient.get('jobs:processed') || '0', 10);

  res.json({
    submitted,
    processed,
    pending: Math.max(0, submitted - processed)
  });
});

start().catch(err => {
  console.error('Failed to start:', err);
  process.exit(1);
});