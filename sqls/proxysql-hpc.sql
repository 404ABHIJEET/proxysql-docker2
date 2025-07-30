-- ========================
-- MONITOR USER CONFIG
-- ========================
UPDATE global_variables SET variable_value='monitor' WHERE variable_name='mysql-monitor_username';
UPDATE global_variables SET variable_value='monitor' WHERE variable_name='mysql-monitor_password';

-- Enable Query Caching (Optional)----------------

-- Useful if you have high-read traffic and want ProxySQL to cache frequent SELECTs.

UPDATE global_variables SET variable_value='true' WHERE variable_name='mysql-query_cache_enabled';
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;

-- Enable Automatic Failover ---------------------
-- Ensure mysql-monitor_username user has these on all backend MySQL servers:

GRANT USAGE, REPLICATION CLIENT, PROCESS ON *.* TO 'monitor'@'%';

-- You can enable automatic reconfiguration of replication roles:
UPDATE global_variables SET variable_value='true' WHERE variable_name='mysql-monitor_enable_failover';
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;

-- ========================
-- BACKEND SERVERS
-- ========================

-- AdminDB: Hostgroups 10 (write), 11 (read)
INSERT INTO mysql_servers (hostgroup_id, hostname, port, comment) VALUES
(10, 'admin-master-host', 3306, 'admin-master-host'),
(11, 'admin-replica-host-1', 3306, 'admin-replica-host-1'),
(11, 'admin-replica-host-2', 3306, 'admin-replica-host-2');

-- -- StateDB ch-Chandigarh, cg-Chattisgarh, go-Goa, hp-Himanchal Pradesh, mh-Maharastra, tr-Tripura: Hostgroups 20 (write), 21 (read)
INSERT INTO mysql_servers (hostgroup_id, hostname, port, comment) VALUES
(20, 'state-ch-master-host', 3306, 'Chandigarh Master Server IP'),         
(21, 'state-ch-replica-host-1', 3306, 'Chandigarh Readonly Host 1'),
(21, 'state-ch-replica-host-2', 3306, 'Chandigarh Readonly Host 2');

(30, 'state-cg-master-host', 3306, 'state-cg-master-host'),         
(31, 'state-cg-replica-host-1', 3306, 'state-cg-replica-host-1'),
(31, 'state-cg-replica-host-2', 3306, 'state-cg-replica-host-2'),

(40, 'state-go-master-host', 3306, 'state-go-master-host'),
(41, 'state-go-replica-host-1', 3306, 'state-go-replica-host-1'),
(41, 'state-go-replica-host-2', 3306, 'state-go-replica-host-2'),

(50, 'state-hp-master-host', 3306, 'state-hp-master-host'),
(51, 'state-hp-replica-host-1', 3306, 'state-hp-replica-host-1'),
(51, 'state-hp-replica-host-2', 3306, 'state-hp-replica-host-2'),

(60, 'state-mh-master-host', 3306, 'state-mh-master-host'),
(61, 'state-mh-replica-host-1', 3306, 'state-mh-replica-host-1'),
(61, 'state-mh-replica-host-2', 3306, 'state-mh-replica-host-2'),

(70, 'state-tr-master-host', 3306, 'state-tr-master-host'),
(71, 'state-tr-replica-host-1', 3306, 'state-tr-replica-host-1'),
(71, 'state-tr-replica-host-2', 3306, 'state-tr-replica-host-2');

-- Load into runtime
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;


-- ========================
-- REPLICATION HOSTGROUPS
-- ========================
INSERT INTO mysql_replication_hostgroups (writer_hostgroup, reader_hostgroup, check_type, comment) VALUES
(10, 11, 'read_only', 'admin-db-replica-hosts'),
(20, 21, 'read_only', 'state-ch-replica-hosts'),
(30, 31, 'read_only', 'state-cg-replica-hosts'),
(40, 41, 'read_only', 'state-go-replica-hosts'),
(50, 51, 'read_only', 'state-hp-replica-hosts'),
(60, 61, 'read_only', 'state-mh-replica-hosts'),
(70, 71, 'read_only', 'state-tr-replica-hosts');

-- ========================
-- MYSQL USERS
-- ========================

-- Multi DB user: if db user are different for each hostgroup
INSERT INTO mysql_users (username, password, default_hostgroup) VALUES 
('admindb-appuser', 'admindb-appuser', 10),
('state-ch-appuser', 'state-ch-appuser', 20);
('state-cg-appuser', 'state-cg-appuser', 30),
('state-go-appuser', 'state-go-appuser', 40),
('state-hp-appuser', 'state-hp-appuser', 50),
('state-mh-appuser', 'state-mh-appuser', 60),
('state-tr-appuser', 'state-tr-appuser', 70);

-- Load into runtime
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;


-- ========================
-- QUERY RULES
-- ========================

-- AdminDB: Read queries to HG 11, Write queries to HG 10, Fallback for any unmatched to write HG
INSERT INTO mysql_query_rules (rule_id, active, schemaname, match_pattern, destination_hostgroup, apply, comment, re_modifiers)
VALUES 
(1, 1, 'parakh_hpc_admin', '^\s*(SELECT|SHOW|DESCRIBE|EXPLAIN|COUNT|DISTINCT|ANALYZE)', 11, 1, 'admin-read-host', 'CASELESS'), 
(2, 1, 'parakh_hpc_admin', '^\s*(INSERT|UPDATE|DELETE|REPLACE|CREATE|TRUNCATE|ALTER|DROP|GRANT|REVOKE|FLUSH)', 10, 1, 'admin-write-host', 'CASELESS'),
(3, 1, 'parakh_hpc_admin', '.*', 10, 1, 'admin-fallback-host', 'CASELESS'),

(4, 1, 'parakh_hpc_state_ch', '^\s*(SELECT|SHOW|DESCRIBE|EXPLAIN|COUNT|DISTINCT|ANALYZE)', 21, 1, 'state-ch-read-host', 'CASELESS'),
(5, 1, 'parakh_hpc_state_ch', '^\s*(INSERT|UPDATE|DELETE|REPLACE|CREATE|TRUNCATE|ALTER|DROP|GRANT|REVOKE|FLUSH)', 20, 1, 'state-ch-write-host', 'CASELESS'),
(6, 1, 'parakh_hpc_state_ch', '.*', 20, 1, 'state-ch-fallback-host', 'CASELESS'),

(7, 1, 'parakh_hpc_state_cg', '^\s*(SELECT|SHOW|DESCRIBE|EXPLAIN|COUNT|DISTINCT|ANALYZE)', 31, 1, 'state-cg-read-host', 'CASELESS'),
(8, 1, 'parakh_hpc_state_cg', '^\s*(INSERT|UPDATE|DELETE|REPLACE|CREATE|TRUNCATE|ALTER|DROP|GRANT|REVOKE|FLUSH)', 30, 1, 'state-cg-write-host', 'CASELESS'),
(9, 1, 'parakh_hpc_state_cg', '.*', 30, 1, 'state-cg-fallback-host', 'CASELESS'),

(10, 1, 'parakh_hpc_state_go', '^\s*(SELECT|SHOW|DESCRIBE|EXPLAIN|COUNT|DISTINCT|ANALYZE)', 41, 1, 'state-go-read-host', 'CASELESS'),
(11, 1, 'parakh_hpc_state_go', '^\s*(INSERT|UPDATE|DELETE|REPLACE|CREATE|TRUNCATE|ALTER|DROP|GRANT|REVOKE|FLUSH)', 40, 1, 'state-go-write-host', 'CASELESS'),
(12, 1, 'parakh_hpc_state_go', '.*', 40, 1, 'state-go-fallback-host', 'CASELESS'),

(13, 1, 'parakh_hpc_state_hp', '^\s*(SELECT|SHOW|DESCRIBE|EXPLAIN|COUNT|DISTINCT|ANALYZE)', 51, 1, 'state-hp-read-host', 'CASELESS'),
(14, 1, 'parakh_hpc_state_hp', '^\s*(INSERT|UPDATE|DELETE|REPLACE|CREATE|TRUNCATE|ALTER|DROP|GRANT|REVOKE|FLUSH)', 50, 1, 'state-hp-write-host', 'CASELESS'),
(15, 1, 'parakh_hpc_state_hp', '.*', 50, 1, 'state-hp-fallback-host', 'CASELESS'),

(16, 1, 'parakh_hpc_state_mh', '^\s*(SELECT|SHOW|DESCRIBE|EXPLAIN|COUNT|DISTINCT|ANALYZE)', 61, 1, 'state-mh-read-host', 'CASELESS'),
(17, 1, 'parakh_hpc_state_mh', '^\s*(INSERT|UPDATE|DELETE|REPLACE|CREATE|TRUNCATE|ALTER|DROP|GRANT|REVOKE|FLUSH)', 60, 1, 'state-mh-write-host', 'CASELESS'),
(18, 1, 'parakh_hpc_state_mh', '.*', 60, 1, 'state-mh-fallback-host', 'CASELESS'),

(19, 1, 'parakh_hpc_state_tr', '^\s*(SELECT|SHOW|DESCRIBE|EXPLAIN|COUNT|DISTINCT|ANALYZE)', 71, 1, 'state-tr-read-host', 'CASELESS'),
(20, 1, 'parakh_hpc_state_tr', '^\s*(INSERT|UPDATE|DELETE|REPLACE|CREATE|TRUNCATE|ALTER|DROP|GRANT|REVOKE|FLUSH)', 70, 1, 'state-tr-write-host', 'CASELESS'),
(21, 1, 'parakh_hpc_state_tr', '.*', 70, 1, 'state-tr-fallback-host', 'CASELESS');


-- Load into runtime
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;


-- Additional Settings ----------------------------------------------------------------

-- Health Check (Validation) -----------------------
-- Check if:
--     Writers have status ONLINE
--     Readers are ONLINE and not lagging

SELECT * FROM runtime_mysql_servers;
SELECT * FROM stats_mysql_connection_pool;