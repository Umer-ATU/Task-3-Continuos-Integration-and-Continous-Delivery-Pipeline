const http = require('http');
const app = require('./app');

const PORT = process.env.PORT || 3000;

/**
 * The server is intentionally kept minimal. It wraps the Express app so that
 * Lambda, Docker, or any process manager can reuse the same app instance.
 */
const server = http.createServer(app);

server.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});

module.exports = server;
