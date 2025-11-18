import express from "express";
import { greet } from "./index";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const PORT = process.env.PORT ? Number(process.env.PORT) : 3000;
const DEFAULT_NAME = process.env.NAME;

app.get("/", (_req, res) => {
  res.json({ message: greet(DEFAULT_NAME) });
});

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.listen(PORT, () => {
  console.log(`Express server listening on port ${PORT}`);
});
