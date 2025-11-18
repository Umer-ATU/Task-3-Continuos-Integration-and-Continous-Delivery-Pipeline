# TypeScript Sample Project

This is a minimal TypeScript starter that now includes an Express server with a `/health` endpoint plus a simple greeting helper. Use it as a clean baseline for experiments or coding exercises.

## Quick start

1. Install dependencies
   ```bash
   npm install
   ```
2. Run the Express server in dev mode (ts-node executes the TypeScript directly)
   ```bash
   npm run dev
   ```
   - Visit `http://localhost:3000/health` to confirm the JSON `{ "status": "ok" }`.
3. Build the project (outputs to `dist/`)
   ```bash
   npm run build
   ```
4. Run the compiled Express server
   ```bash
   npm start
   ```

### Customize the greeting helper
- Execute the helper directly: `npm run greet -- Alice`
- Or set an environment variable: `NAME=Bob npm run greet`

`src/index.ts` contains the reusable `greet` function, while `src/server.ts` wires it into the Express server for the `/` route.
