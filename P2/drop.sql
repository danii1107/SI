SELECT * FROM pg_stat_activity WHERE datname = 'si1';

SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'si1' AND pid <> pg_backend_pid();

