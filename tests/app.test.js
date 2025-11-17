const request = require('supertest');
const app = require('../src/app');

describe('API endpoints', () => {
  describe('GET /health', () => {
    it('returns status ok', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
      expect(response.body).toEqual({ status: 'ok' });
    });
  });

  describe('POST /echo', () => {
    it('echoes back provided JSON body', async () => {
      const payload = { message: 'Hello AWS' };
      const response = await request(app).post('/echo').send(payload);
      expect(response.status).toBe(200);
      expect(response.body).toEqual(payload);
    });
  });
});
