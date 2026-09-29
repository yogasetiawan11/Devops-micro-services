# Frontend Dockerfile
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm run 

# Copy source code
COPY . .

# Build the app
RUN npm run build

# Production stage
FROM node:20-alpine

COPY --from=builder /app/build ./app
RUN addgroup -S Frontend \
    adduser -S yogaw 

EXPOSE 80

CMD ["serve", "-s", "build"]