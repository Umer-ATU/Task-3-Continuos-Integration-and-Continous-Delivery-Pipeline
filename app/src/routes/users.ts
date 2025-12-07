import { Router } from 'express';

interface UserProfile {
  id: number;
  name: string;
  role: string;
  favoriteTool: string;
}

const users: UserProfile[] = [
  { id: 1, name: 'Amina Ortega', role: 'Platform Engineer', favoriteTool: 'Terraform' },
  { id: 2, name: 'Charlie Singh', role: 'Site Reliability Engineer', favoriteTool: 'Prometheus' },
  { id: 3, name: 'Lena Martins', role: 'Cloud Developer', favoriteTool: 'AWS CDK' }
];

const usersRouter = Router();
console.log(users);

usersRouter.get('/', (_, res) => {
  res.json({ count: users.length, users });
});

export default usersRouter;
