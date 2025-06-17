-- Database initialization script
-- This script will be executed by the db-init container

-- Test connection first
SELECT 1 AS connection_test;

-- Create database and users
CREATE DATABASE IF NOT EXISTS chat_app;
CREATE USER IF NOT EXISTS root WITH PASSWORD 'G7ADSg4SG&ADSKIEBIDITOILETTTAIDSSSSADS';
GRANT ALL ON DATABASE chat_app TO root;
GRANT ADMIN TO root;


