const express = require('express');
const client = require('prom-client');
const http = require('http');

const app = express();

// Config
const PORT = process.env.PORT || 3000;
const API_URL = process.env.API_URL || 'http://localhost:3001';

// Prometheus metrics
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const proxyRequests = new client.Counter({
  name: 'pulse_frontend_proxy_requests_total',
  help: 'Total proxied requests to API',
  registers: [register]
});

// Proxy helper
function proxyToAPI(reqPath, req, res) {
  proxyRequests.inc();

  const options = {
    hostname: new URL(API_URL).hostname,
    port: new URL(API_URL).port,
    path: reqPath,
    method: req.method,
    headers: {
      'Content-Type': req.headers['content-type'] || 'application/json'
    }
  };

  const proxyReq = http.request(options, (proxyRes) => {
    res.status(proxyRes.statusCode);
    Object.entries(proxyRes.headers).forEach(([k, v]) => res.set(k, v));
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (err) => {
    console.error('Proxy error:', err);
    res.status(502).json({ error: 'API unavailable' });
  });

  if (req.method === 'POST') {
    req.pipe(proxyReq);
  } else {
    proxyReq.end();
  }
}

// Routes
app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Proxy API calls
app.use('/api', (req, res) => {
  proxyToAPI(req.url, req, res);
});

// Main page
app.get('/', (req, res) => {
  res.send(`<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Pulse</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 600px; margin: 40px auto; padding: 0 20px; }
    h1 { color: #333; }
    .stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin: 24px 0; }
    .stat { background: #f5f5f5; padding: 16px; border-radius: 8px; text-align: center; }
    .stat-value { font-size: 32px; font-weight: bold; color: #2563eb; }
    .stat-label { font-size: 12px; color: #666; text-transform: uppercase; margin-top: 4px; }
    button { background: #2563eb; color: white; border: none; padding: 12px 24px; border-radius: 6px; font-size: 16px; cursor: pointer; }
    button:hover { background: #1d4ed8; }
    button:disabled { opacity: 0.6; cursor: not-allowed; }
    .status { margin-top: 12px; font-size: 14px; color: #666; }
    .error { color: #dc2626; }
  </style>
</head>
<body>
  <h1>⚡ Pulse</h1>
  <p>Submit jobs and watch them get processed.</p>
  <button id="submitBtn" onclick="submitJob()">Submit Job</button>
  <div class="status" id="status"></div>
  <div class="stats">
    <div class="stat">
      <div class="stat-value" id="submitted">-</div>
      <div class="stat-label">Submitted</div>
    </div>
    <div class="stat">
      <div class="stat-value" id="processed">-</div>
      <div class="stat-label">Processed</div>
    </div>
    <div class="stat">
      <div class="stat-value" id="pending">-</div>
      <div class="stat-label">Pending</div>
    </div>
  </div>
  <script>
    async function loadStats() {
      try {
        const res = await fetch('/api/stats');
        const data = await res.json();
        document.getElementById('submitted').textContent = data.submitted;
        document.getElementById('processed').textContent = data.processed;
        document.getElementById('pending').textContent = data.pending;
      } catch (err) {
        console.error('Stats error:', err);
      }
    }

    async function submitJob() {
      const btn = document.getElementById('submitBtn');
      const status = document.getElementById('status');
      btn.disabled = true;
      status.textContent = 'Submitting...';
      status.className = 'status';

      try {
        const res = await fetch('/api/jobs', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ type: 'demo' })
        });
        const data = await res.json();
        status.textContent = 'Job ' + data.id + ' accepted';
        loadStats();
      } catch (err) {
        status.textContent = 'Error: ' + err.message;
        status.className = 'status error';
      } finally {
        btn.disabled = false;
      }
    }

    loadStats();
    setInterval(loadStats, 2000);
  </script>
</body>
</html>`);
});

const server = app.listen(PORT, () => {
  console.log(`Frontend listening on port ${PORT}`);
});

// Graceful shutdown
function shutdown() {
  console.log('Frontend shutting down...');
  server.close(() => {
    process.exit(0);
  });
}

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);