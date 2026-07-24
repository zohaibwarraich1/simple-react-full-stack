# Stage 1: Build stage (Installs devDependencies & compiles bundle with Webpack)
FROM node:26 AS builder

WORKDIR /app

COPY package.json ./

RUN npm install 

COPY ./ ./

RUN npm run build

# Stage 2: Production runtime stage
FROM dhi.io/node:26-alpine3.23

# Set production environment variables
ENV NODE_ENV=production

WORKDIR /app

# Copy production node_modules from builder stage with proper file ownership
COPY --chown=node:node --from=builder /app/node_modules ./node_modules

# Copy compiled frontend static assets from builder stage
COPY --chown=node:node --from=builder /app/dist ./dist

# Copy backend server code from builder stage
COPY --chown=node:node --from=builder /app/src/server ./src/server

# Copy package.json for application metadata
COPY --chown=node:node package.json ./

USER node

EXPOSE 8080

# Execute server using exec form for proper OS signal handling (SIGTERM/SIGINT)
CMD ["node", "src/server/index.js"]
