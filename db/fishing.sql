-- kill other connections
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'fishing_stories' AND pid <> pg_backend_pid();
-- (re)create the database
DROP DATABASE IF EXISTS fishing_stories;
CREATE DATABASE fishing_stories;
-- connect via psql
\c fishing_stories

-- database configuration
SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET default_tablespace = '';
SET default_with_oids = false;


CREATE TABLE fishing_gear (
	id SERIAL PRIMARY KEY,
	rod TEXT NOT NULL,
	reel TEXT,
	line TEXT,
	hook TEXT,
	leader TEXT
);

CREATE TABLE baits (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	atrificial BOOLEAN NOT NULL,
	size TEXT,
	color TEXT,
	description TEXT,
	UNIQUE (name, size, color)
);

CREATE TABLE fishes (
	id SERIAL PRIMARY KEY,
	species TEXT NOT NULL,
	datetime_caught TIMESTAMP NOT NULL,
	weight NUMERIC,
	length NUMERIC,
	description TEXT,
	bait_id INT NOT NULL,
	fishing_gear_id INT,
	fishing_spot_id INT NOT NULL,
	CONSTRAINT fk_fishes_baits
	FOREIGN KEY(bait_id)
	REFERENCES baits(id)
	ON DELETE CASCADE,
	CONSTRAINT fk_fishes_fishing_gear
	FOREIGN KEY(fishing_gear_id)
	REFERENCES fishing_gear(id)
	ON DELETE SET NULL
);

CREATE TABLE priviledges (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE account_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    price DECIMAL NOT NULL
);

CREATE TABLE account_types_priviledges (
    priviledge_id INT NOT NULL,
    account_type_id INT NOT NULL,
    PRIMARY KEY(priviledge_id, account_type_id),
	CONSTRAINT fk_account_types_priviledges_priviledge
	FOREIGN KEY(priviledge_id)
	REFERENCES priviledges(id)
	ON DELETE CASCADE,
	CONSTRAINT fk_account_types_priviledges_account_type
	FOREIGN KEY(account_type_id)
	REFERENCES account_types(id)
	ON DELETE CASCADE
);

CREATE TABLE ranks (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL UNIQUE,
	rank_number INT NOT NULL UNIQUE,
	description TEXT NOT NULL
);

CREATE TABLE anglers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    rank_id INT NOT NULL,
	CONSTRAINT fk_anglers_ranks
	FOREIGN KEY(rank_id)
	REFERENCES ranks(id)
	ON DELETE CASCADE
);

CREATE TABLE user_accounts (
    id SERIAL PRIMARY KEY,
    username CHARACTER(30) NOT NULL UNIQUE,
    password CHARACTER(20) NOT NULL,
    account_type_id INT NOT NULL,
    angler_id INT NOT NULL,
	CONSTRAINT fk_account_type
	FOREIGN KEY(account_type_id)
	REFERENCES account_types(id)
	ON DELETE CASCADE,
	CONSTRAINT fk_angler
	FOREIGN KEY(angler_id)
	REFERENCES anglers(id)
	ON DELETE CASCADE
);

CREATE TABLE fishing_outings (
	id SERIAL PRIMARY KEY,
	date TIMESTAMP NOT NULL,
	trip_type TEXT NOT NULL,
	description TEXT,
	water TEXT
);

CREATE TABLE anglers_outings (
    angler_id INT NOT NULL,
    fishing_outing_id INT NOT NULL,
    PRIMARY KEY(angler_id, fishing_outing_id),
	CONSTRAINT fk_anglers_outings_angler
	FOREIGN KEY(angler_id)
	REFERENCES anglers(id)
	ON DELETE CASCADE,
	CONSTRAINT fk_anglers_outings_outing
	FOREIGN KEY(fishing_outing_id)
	REFERENCES fishing_outings(id)
	ON DELETE CASCADE
);

CREATE TABLE fishing_spots (
	id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	gps_coordinates DECIMAL NOT NULL UNIQUE,
	description TEXT
);

CREATE TABLE fishing_conditions (
	id SERIAL PRIMARY KEY,
	timestamp TIMESTAMP NOT NULL,
	weather TEXT NOT NULL,
	tide_phase TEXT NOT NULL,
	moon_phase TEXT,
	wind_speed INTEGER,
	wind_direction TEXT,
	current_flow TEXT,
	current_speed NUMERIC,
    pressure_today Numeric,
    pressure_yesterday Numeric,
    fishing_spot_id INT NOT NULL,
	CONSTRAINT fk__fishing_spot
	FOREIGN KEY(fishing_spot_id)
	REFERENCES fishing_spots(id)
	ON DELETE CASCADE
);

CREATE TABLE outing_spots (
	fishing_outing_id INT NOT NULL,
	fishing_spot_id INT NOT NULL,
	PRIMARY KEY(fishing_outing_id, fishing_spot_id),
	CONSTRAINT fk_outing_spots_finshing_outings
	FOREIGN KEY(fishing_outing_id)
	REFERENCES fishing_outings(id)
	ON DELETE CASCADE,
	CONSTRAINT fk_outing_spots_fishing_spots
	FOREIGN KEY(fishing_spot_id)
	REFERENCES fishing_spots(id)
	ON DELETE CASCADE
);

ALTER TABLE fishes
ADD CONSTRAINT fk_fishing_spot
FOREIGN KEY(fishing_spot_id)
REFERENCES fishing_spots(id)
ON DELETE CASCADE;