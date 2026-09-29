# Frontend Dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install --production=false


# Copy source code
COPY . .

# Build the app
RUN npm run build

# Intall serve globally
RUN run npm -g serve

CMD ["serve", "-s", "build", "l", "3000", "single"]