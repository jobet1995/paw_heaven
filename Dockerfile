# Base stage for development
FROM node:20.19.0-alpine AS development

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Expose development server port
EXPOSE 5173

# Default command for development (overridden in docker-compose)
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# Build stage for production
FROM node:20.19.0-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies including devDependencies for building
RUN npm install --include=dev

# Copy application code
COPY . .

# Build the app
RUN npm run build

# Remove devDependencies after build to keep image size small
RUN npm prune --production

# Production stage
FROM nginx:stable-alpine AS production

# Set labels
LABEL maintainer="Paws_Heaven Team <dev@pawsheaven.com>"
LABEL description="Paws_Heaven - A pet care and adoption platform"
LABEL version="1.0.0"

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy built files from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]