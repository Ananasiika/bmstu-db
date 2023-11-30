-- drop table clients;
/*
CREATE TABLE IF NOT EXISTS clients (
	id_client SERIAL NOT NULL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	surname VARCHAR(100) NOT NULL,
	gender VARCHAR(2) NOT NULL CHECK (gender IN ('m', 'f')),
	date_of_birth DATE NOT NULL,
	email VARCHAR(100)
);*/
-- SELECT * FROM clients;


-- INSERT INTO clients VALUES(1001, 'Alice', 'Popova', 'f', '01.10.2012', 'alice@gmail.com');
-- SELECT * FROM clients WHERE gender='f' and date >= '2004-05-06';
-- copy clients from '/home/larisa/bmstu-db/lab_01/data/clients.csv' delimiter ',';


-- drop table coaches;
/*
CREATE TABLE IF NOT EXISTS coaches (
  id_coach SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  surname VARCHAR(100) NOT NULL,
  gender VARCHAR(2) NOT NULL CHECK (gender IN ('m', 'f')),
  date_of_birth DATE NOT NULL,
  email VARCHAR(100),
  experience INT CHECK (experience >= 0 and experience <= 30),
  specialization VARCHAR(100)
);*/
-- SELECT * FROM coaches;



-- drop table branches;
/*
CREATE TABLE IF NOT EXISTS branches (
  id_branch SERIAL NOT NULL PRIMARY KEY,
  address VARCHAR(255) NOT NULL,
  email VARCHAR(100),
  foundation_date DATE,
  rating INT NOT NULL CHECK (rating >= 1 and rating <= 10)
);*/
-- SELECT * FROM branches;



-- drop table workouts;
/*
CREATE TABLE IF NOT EXISTS workouts (
  id_workout SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  id_coach INT REFERENCES coaches (id_coach),
  duration INTERVAL,
  id_branch INT REFERENCES branches (id_branch),
  rating INT NOT NULL CHECK (rating >= 1 and rating <= 10)
);*/
-- SELECT * FROM workouts;



-- drop table visits;
/*
CREATE TABLE IF NOT EXISTS visits (
  id_visit SERIAL NOT NULL PRIMARY KEY,
  id_client INT REFERENCES clients (id_client),
  id_workout INT REFERENCES workouts (id_workout),
  date_of_visit DATE,
  id_coach INT REFERENCES coaches (id_coach),
  id_branch INT REFERENCES branches (id_branch)
);*/
-- SELECT * FROM visits;