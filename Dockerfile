# Use a lightweight Node.js image
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy package.json + package-lock.json (if exists)
COPY package*.json ./

# Install only production dependencies
RUN npm install --production

# Copy rest of the source code
COPY . ./

# Build TypeScript
RUN npm run build

# Expose port (matches your .env default)
EXPOSE 8000

# Default environment variables (can be overridden in ECS)
ENV PORT=8000

# Start server
CMD ["npm", "start"]
