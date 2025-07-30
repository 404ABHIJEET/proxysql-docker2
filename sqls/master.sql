-- monitor user
CREATE USER 'monitor'@'%' IDENTIFIED BY 'monitor';
GRANT ALL PRIVILEGES ON *.* TO 'monitor'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- appuser
CREATE USER 'appuser'@'%' IDENTIFIED BY 'appuser';
GRANT ALL PRIVILEGES ON *.* TO 'appuser'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

CREATE USER 'appuser_reader'@'%' IDENTIFIED BY 'appuser';
GRANT SELECT, SHOW VIEW, SHOW DATABASES ON *.* TO 'appuser_reader'@'%';
FLUSH PRIVILEGES;

-- creating databases
CREATE DATABASE parakh_hpc_admin;
CREATE DATABASE parakh_hpc_admin_r1;
CREATE DATABASE parakh_hpc_admin_r2;

CREATE DATABASE parakh_hpc_state_ch;
CREATE DATABASE parakh_hpc_state_ch_r1;
CREATE DATABASE parakh_hpc_state_ch_r2;