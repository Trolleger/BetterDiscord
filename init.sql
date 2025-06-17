-- Database initialization script
-- This script will be executed by the db-init container

-- Test connection first
SELECT 1 AS connection_test;

-- Create database and users
CREATE DATABASE IF NOT EXISTS chat_app_dev;
CREATE USER IF NOT EXISTS craig WITH PASSWORD 'cockroach12938';
GRANT ALL ON DATABASE chat_app_dev TO craig;
GRANT ADMIN TO craig;