CREATE KEYSPACE IF NOT EXISTS employee_db
WITH replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 1};

USE employee_db;

CREATE TABLE IF NOT EXISTS employee_salary (
    id UUID PRIMARY KEY,
    name text,
    role text,
    salary int
);
