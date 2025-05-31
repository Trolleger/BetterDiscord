FROM node:20-bullseye

WORKDIR /app

# Install build dependencies once and cache them in the image layer
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    make \
    g++ \
    gcc \
    build-essential \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# Install yarn globally

CMD ["tail", "-f", "/dev/null"]