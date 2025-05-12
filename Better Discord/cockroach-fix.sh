#!/bin/bash
# Temporary fix for insecure mode
docker-compose down -v
docker-compose run --rm cockroachdb start-single-node \
  --accept-sql-without-tls \
  --insecure \
  --listen-addr=0.0.0.0:26257 \
  --http-addr=0.0.0.0:8080 \
  --advertise-addr=cockroachdb:26257 \
  --background
docker-compose up -d