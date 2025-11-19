import { Router } from 'express';

const healthRouter = Router();

healthRouter.get('/', (_, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

export default healthRouter;
