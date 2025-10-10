-- init.cql
CREATE USER IF NOT EXISTS scylladb WITH PASSWORD 'password' SUPERUSER;
CREATE KEYSPACE IF NOT EXISTS employee_salary WITH replication = {'class':'SimpleStrategy','replication_factor': 1};
CREATE KEYSPACE IF NOT EXISTS employee_DB WITH replication = {'class':'SimpleStrategy','replication_factor': 1};
USE employee_DB;
CREATE TABLE IF NOT EXISTS employee_salary (
  id text,
  process_date text,
  name text,
  salary float,
  status text,
  PRIMARY KEY (id, process_date)
) WITH CLUSTERING ORDER BY (process_date DESC);
