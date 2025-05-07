# Stage 1: Build the app
FROM node:20 AS builder

WORKDIR /app

# Copy package and yarn lock files
COPY package.json yarn.lock ./

# Install dependencies with Yarn
RUN yarn install --frozen-lockfile

# Copy the rest of the code
COPY . .

# Build the production web app
RUN yarn build

# Stage 2: Serve the app with Nginx
FROM nginx:alpine

# Clean default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built app from previous stage
COPY --from=builder /app/build /usr/share/nginx/html

# Expose default HTTP port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
