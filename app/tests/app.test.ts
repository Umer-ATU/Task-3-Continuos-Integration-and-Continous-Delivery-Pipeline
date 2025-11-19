import request from 'supertest';
import { createServer } from '../src/app';

const app = createServer();

describe('API routes', () => {
  it('responds with ok for /health', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('ok');
  });

  it('greets from /hello', async () => {
    const response = await request(app).get('/hello');
    expect(response.status).toBe(200);
    expect(response.text).toContain('Hello from EKS');
  });

  it('returns dummy users for /users', async () => {
    const response = await request(app).get('/users');
    expect(response.status).toBe(200);
    expect(response.body.count).toBeGreaterThanOrEqual(3);
    expect(response.body.users[0]).toHaveProperty('favoriteTool');
  });
});
