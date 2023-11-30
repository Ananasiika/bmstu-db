--DROP SCHEMA IF EXISTS sc1 CASCADE;
--CREATE SCHEMA sc1;

CREATE TABLE IF NOT EXISTS sc1.clients (
	id_client INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	surname VARCHAR(100) NOT NULL,
	gender VARCHAR(2) NOT NULL CHECK (gender IN ('m', 'f')),
	date_of_birth DATE NOT NULL,
	email VARCHAR(100)
);


CREATE TABLE IF NOT EXISTS sc1.coaches (
  id_coach SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  surname VARCHAR(100) NOT NULL,
  gender VARCHAR(2) NOT NULL CHECK (gender IN ('m', 'f')),
  date_of_birth DATE NOT NULL,
  email VARCHAR(100),
  experience INT CHECK (experience >= 0 and experience <= 30),
  specialization VARCHAR(100)
);


CREATE TABLE IF NOT EXISTS sc1.branches (
  id_branch SERIAL NOT NULL PRIMARY KEY,
  address VARCHAR(255) NOT NULL,
  email VARCHAR(100),
  foundation_date DATE,
  rating INT NOT NULL CHECK (rating >= 1 and rating <= 10)
);


CREATE TABLE IF NOT EXISTS sc1.workouts (
  id_workout SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  id_coach INT REFERENCES sc1.coaches (id_coach),
  duration INTERVAL,
  id_branch INT REFERENCES sc1.branches (id_branch),
  rating INT NOT NULL CHECK (rating >= 1 and rating <= 10)
);


CREATE TABLE IF NOT EXISTS sc1.visits (
  id_visit SERIAL NOT NULL PRIMARY KEY,
  id_client INT REFERENCES sc1.clients (id_client),
  id_workout INT REFERENCES sc1.workouts (id_workout),
  date_of_visit DATE,
  id_coach INT REFERENCES sc1.coaches (id_coach),
  id_branch INT REFERENCES sc1.branches (id_branch)
);
SELECT * from sc1.clients;
SELECT * from sc1.coaches;
SELECT * from sc1.branches;
SELECT * from sc1.workouts;
SELECT * from sc1.visits;
