import express, { Application } from 'express';
import helmet from 'helmet';
import morgan from 'morgan';
import healthRouter from './routes/health';
import helloRouter from './routes/hello';
import usersRouter from './routes/users';

export const createServer = (): Application => {
  const app = express();

  // Basic security and logging middleware
  app.use(helmet());
  app.use(express.json());
  app.use(morgan('combined'));

  app.get('/', (_, res) => {
    res.json({
      service: 'DevOps Pipeline Demo API',
      documentation: 'Refer to README for endpoint details.'
    });
  });

  app.use('/health', healthRouter);
  app.use('/hello', helloRouter);
  app.use('/users', usersRouter);

  // Global fallback for unknown routes
  app.use((_, res) => {
    res.status(404).json({ message: 'Route not found' });
  });

  return app;
};

export default createServer;
