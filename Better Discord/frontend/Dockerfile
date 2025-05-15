# Stage 1: Build frontend
FROM node:20-alpine as builder

WORKDIR /app

# Install Yarn
RUN apk add --no-cache yarn

# Copy package.json first (caching optimization)
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install 

# Copy the rest of the files (including public/)
COPY . .

# Build the app (outputs to /app/build or /app/dist)
RUN yarn build

# Stage 2: Serve with Nginx
FROM nginx:latest

# Copy build output to Nginx
COPY --from=builder /app/build /usr/share/nginx/html  
# OR (if using Vite)
# COPY --from=builder /app/dist /usr/share/nginx/html

# nginx.conf is bind-mounted (no COPY needed)
EXPOSE 80