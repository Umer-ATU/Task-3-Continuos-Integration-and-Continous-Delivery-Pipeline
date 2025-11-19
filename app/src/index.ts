import { createServer } from './app';

const PORT = Number(process.env.PORT) || 8080;
const app = createServer();

app.listen(PORT, () => {
  console.log(`API running on port ${PORT}`);
});
