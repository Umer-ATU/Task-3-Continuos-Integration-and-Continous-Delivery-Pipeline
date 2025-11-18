/**
 * Simple entry point to demonstrate TypeScript compilation.
 * Pass a name via CLI arg or NAME env var to customize greeting.
 */
function greet(name: string = "Developer"): string {
  return `Hello, ${name}! Welcome to your TypeScript starter project.`;
}

const cliName = process.argv[2];
const envName = process.env.NAME;
const message = greet(cliName || envName || undefined);

console.log(message);

export { greet };
