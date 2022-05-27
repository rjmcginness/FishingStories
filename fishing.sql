CREATE TABLE fishing_gear (
	id SERIAL,
	rod TEXT NOT NULL,
	reel TEXT,
	line TEXT,
	hook TEXT,
	leader TEXT,
	PRIMARY KEY(id)
);

CREATE TABLE baits (
	id SERIAL,
	name TEXT NOT NULL,
	atrificial BOOLEAN NOT NULL,
	size TEXT,
	color TEXT,
	description TEXT,
	PRIMARY KEY(id)
);

CREATE TABLE fishes (
	id SERIAL,
	species TEXT NOT NULL,
	weight NUMERIC,
	length NUMERIC,
	description TEXT,
	PRIMARY KEY(id),
	bait_id INT NOT NULL,
	fishing_gear_id INT NOT NULL
);

ALTER TABLE fishes
ADD CONSTRAINT fk_fishes_baits
FOREIGN KEY(bait_id)
REFERENCES baits(id);

ALTER TABLE fishes
ADD CONSTRAINT fk_fishes_fishing_gear
FOREIGN KEY(fishing_gear_id)
REFERENCES fishing_gear(id);

CREATE TABLE priviledges (
    id SERIAL,
    name TEXT NOT NULL UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE account_types (
    id SERIAL,
    name TEXT NOT NULL UNIQUE,
    price DECIMAL NOT NULL,
    PRIMARY KEY(id)
);

CREATE TABLE account_types_priviledges (
    priviledge_id INT NOT NULL,
    account_type_id INT NOT NULL,
    PRIMARY KEY(priviledge_id, account_type_id)
);

ALTER TABLE account_types_priviledges
ADD CONSTRAINT fk_account_types_priviledges_priviledge
FOREIGN KEY(priviledge_id)
REFERENCES priviledges(id);

ALTER TABLE account_types_priviledges
ADD CONSTRAINT fk_account_types_priviledges_account_type
FOREIGN KEY(account_type_id)
REFERENCES account_types(id);

CREATE TABLE user_accounts (
    id SERIAL,
    username CHARACTER(30) NOT NULL UNIQUE,
    password CHARACTER(20) NOT NULL,
    PRIMARY KEY(id),
    account_type_id INT NOT NULL,
    angler_id INT NOT NULL
);

CREATE TABLE anglers (
    id SERIAL,
    name TEXT NOT NULL UNIQUE,
    rank TEXT,
    PRIMARY KEY(id)
);

ALTER TABLE user_accounts
ADD CONSTRAINT fk_account_type
FOREIGN KEY(account_type_id)
REFERENCES account_types(id);

ALTER TABLE user_accounts
ADD CONSTRAINT fk_angler
FOREIGN KEY(angler_id)
REFERENCES anglers(id);

CREATE TABLE fishing_outings (
	id SERIAL,
	date TIMESTAMP NOT NULL,
	trip_type TEXT NOT NULL,
	description TEXT,
	water TEXT,
	PRIMARY KEY(id)
);

CREATE TABLE anglers_outings (
    angler_id INT NOT NULL,
    fishing_outing_id INT NOT NULL,
    PRIMARY KEY(angler_id, fishing_outing_id)
);

ALTER TABLE anglers_outings
ADD CONSTRAINT fk_anglers_outings_angler
FOREIGN KEY(angler_id)
REFERENCES anglers(id);

ALTER TABLE anglers_outings
ADD CONSTRAINT fk_anglers_outings_outing
FOREIGN KEY(fishing_outing_id)
REFERENCES fishing_outings(id);

CREATE TABLE fishing_conditions (
	id SERIAL,
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
    fishing_spot_id INT NOT NULL
	PRIMARY KEY(id)
);

CREATE TABLE fishing_spots (
	id SERIAL,
	name TEXT NOT NULL,
	gps_coordinates DECIMAL NOT NULL UNIQUE,
	description TEXT,
	PRIMARY KEY(id),
);

ALTER TABLE fishing_conditions
ADD CONSTRAINT fk__fishing_spot
FOREIGN KEY(fishing_spot_id)
REFERENCES fishing_spots(id);

CREATE TABLE outing_spots (
	fishing_outing_id INT NOT NULL,
	fishing_spot_id INT NOT NULL,
	PRIMARY KEY(fishing_outing_id, fishing_spot_id)
);

ALTER TABLE outing_spots
ADD CONSTRAINT fk_outing_spots_finshing_outings
FOREIGN KEY(fishing_outing_id)
REFERENCES fishing_outings(id);

ALTER TABLE outing_spots
ADD CONSTRAINT fk_outing_spots_fishing_spots
FOREIGN KEY(fishing_spot_id)
REFERENCES fishing_spots(id);

CREATE TABLE fish_caught (
    angler_id INT NOT NULL
    fish_id INT NOT NULL
    PRIMARY KEY(angler_id, fish_id)
);

ALTER TABLE fish_caught
ADD CONSTRAINT fk_fish_caught_fish
FOREIGN KEY(fk_fish_id)
REFERENCES fish(id)

ALTER TABLE fish_caught
ADD CONSTRAINT fk_fish_caught_anglers
FOREIGN KEY(fk_angler_id)
REFERENCES anglers(id)