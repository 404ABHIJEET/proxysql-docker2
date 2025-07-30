-- updating monitor username and password
UPDATE global_variables SET variable_value='monitor' WHERE variable_name='mysql-monitor_username';
UPDATE global_variables SET variable_value='monitor' WHERE variable_name='mysql-monitor_password';
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;

-- entries of mysql servers in server table
INSERT INTO mysql_servers (hostgroup_id, hostname, port, comment) 
VALUES (10, 'mariadb-master', 3306, 'admin_master'); 
INSERT INTO mysql_servers (hostgroup_id, hostname, port, comment) 
VALUES (11, 'mariadb-slave-1', 3306, 'admin_replica1'); 
INSERT INTO mysql_servers (hostgroup_id, hostname, port, comment) 
VALUES (11, 'mariadb-slave-2', 3306, 'admin_replica2'); 

INSERT INTO mysql_servers (hostgroup_id, hostname, port, comment) 
VALUES (20, 'mariadb-state-ch-master', 3306, 'ch_master'); 
INSERT INTO mysql_servers (hostgroup_id, hostname, port, comment) 
VALUES (21, 'mariadb-state-ch-slave-1', 3306, 'ch_replica1'); 
INSERT INTO mysql_servers (hostgroup_id, hostname, port, comment) 
VALUES (21, 'mariadb-state-ch-slave-2', 3306, 'ch_replica2'); 

LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

-- entry of user in user table
INSERT INTO mysql_users (username, password, default_hostgroup) 
VALUES ('appuser', 'appuser', 10);
INSERT INTO mysql_users (username, password, default_hostgroup) 
VALUES ('appuser_reader', 'appuser', 10);

LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;

-- entries of replication hostgroup
INSERT INTO mysql_replication_hostgroups (writer_hostgroup, reader_hostgroup, check_type, comment)
VALUES (10, 11, 'read_only', 'parakh_hpc_admin');
INSERT INTO mysql_replication_hostgroups (writer_hostgroup, reader_hostgroup, check_type, comment)
VALUES (20, 21, 'read_only', 'parakh_hpc_state_ch');

LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

INSERT INTO mysql_query_rules (rule_id, active, schemaname, match_pattern, destination_hostgroup, apply, comment, re_modifiers)
VALUES 
(1, 1, 'parakh_hpc_admin', '^\s*(SELECT|SHOW|DESCRIBE|EXPLAIN|COUNT|DISTINCT|ANALYZE)', 11, 1, 'admin-read-host', 'CASELESS'), 
(2, 1, 'parakh_hpc_admin', '^\s*(INSERT|UPDATE|DELETE|REPLACE|CREATE|TRUNCATE|ALTER|DROP|GRANT|REVOKE|FLUSH)', 10, 1, 'admin-write-host', 'CASELESS'),
(3, 1, 'parakh_hpc_admin', '.*', 10, 1, 'admin-fallback-host', 'CASELESS'),

(4, 1, 'parakh_hpc_state_ch', '^\s*(SELECT|SHOW|DESCRIBE|EXPLAIN|COUNT|DISTINCT|ANALYZE)', 21, 1, 'state-ch-read-host', 'CASELESS'),
(5, 1, 'parakh_hpc_state_ch', '^\s*(INSERT|UPDATE|DELETE|REPLACE|CREATE|TRUNCATE|ALTER|DROP|GRANT|REVOKE|FLUSH)', 20, 1, 'state-ch-write-host', 'CASELESS'),
(6, 1, 'parakh_hpc_state_ch', '.*', 20, 1, 'state-ch-fallback-host', 'CASELESS');

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;

