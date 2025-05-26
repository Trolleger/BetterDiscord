FROM node:20-alpine as builder

WORKDIR /app

RUN apk add --no-cache yarn

# Copy package.json and yarn.lock first (to leverage cache)
COPY package.json yarn.lock ./

# Copy the rest of the source files
COPY . .

# Install dependencies
RUN yarn install

# Force right esbuild version
RUN yarn add -D esbuild@0.25.4

# Build the app
RUN yarn build

# Debug step: check contents of build folder
RUN ls -l /app/build

FROM nginx:latest

# Clear default nginx html folder before copy (optional)
RUN rm -rf /usr/share/nginx/html/*

# COPY the correct build folder (change from /app/dist to /app/build)
COPY --from=builder /app/build /usr/share/nginx/html


EXPOSE 80
