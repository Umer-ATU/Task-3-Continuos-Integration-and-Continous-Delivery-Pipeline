import { Router } from 'express';

const helloRouter = Router();

helloRouter.get('/', (_, res) => {
  res.type('text/plain').send('Hello from EKS!');
});

export default helloRouter;
