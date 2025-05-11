# Stage 1: Build frontend
FROM node:20-alpine as build

WORKDIR /app

# Install dependencies
COPY package.json yarn.lock ./
RUN yarn install

# Build the app
COPY . . 
RUN yarn build

# Stage 2: Serve frontend with Nginx
FROM nginx:latest

# Copy built frontend from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Expose Nginx port
EXPOSE 80
