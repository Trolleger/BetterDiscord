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

FROM nginx:latest

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
