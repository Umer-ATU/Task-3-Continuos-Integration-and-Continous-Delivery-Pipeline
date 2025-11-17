const express = require('express');

/**
 * AWS DevOps pipeline sample API.
 * Run locally with `npm install` followed by `npm start`.
 * The health and echo endpoints are intentionally simple so they can be
 * exercised easily from CodeBuild tests or manual curl requests.
 */
const app = express();

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.post('/echo', (req, res) => {
  res.json(req.body || {});
});

module.exports = app;
