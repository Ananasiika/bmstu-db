/*
-- Скалярная функция
-- количество посещений клиента в данной тренировке
CREATE OR REPLACE FUNCTION get_visits_count(client_id INT, workout_id INT)
  RETURNS INTEGER AS $$
    DECLARE
      visits_count INTEGER;
    BEGIN
      SELECT COUNT(*) INTO visits_count
      FROM sc1.visits
      WHERE id_client = client_id AND id_workout = workout_id;
  
      RETURN visits_count;
    END;
  $$ LANGUAGE plpgsql;

SELECT get_visits_count(314, 513);


-- Подставляемая табличная функция
-- Клиенты с определенным полом
CREATE OR REPLACE FUNCTION get_clients_by_gender(p_gender VARCHAR(2))
  RETURNS TABLE (id_client INT, name VARCHAR(100), surname VARCHAR(100)) AS $$
    SELECT id_client, name, surname
    FROM sc1.clients
    WHERE p_gender = gender;
  $$ LANGUAGE SQL;

SELECT get_clients_by_gender('f');


-- Многооператорная табличная функция
-- таблица или клиентов или тренеров
CREATE OR REPLACE FUNCTION get_different_tables(param INT)
  RETURNS TABLE (name VARCHAR(100), surname VARCHAR(100)) AS $$
    BEGIN
      IF param = 1 THEN
        RETURN QUERY SELECT c.name, c.surname FROM sc1.clients c;
      ELSE
        RETURN QUERY SELECT co.name, co.surname FROM sc1.coaches co;
      END IF;
    END;
  $$
  LANGUAGE plpgsql;
  
SELECT *
FROM get_different_tables(2);


-- Рекурсивная функция или функция с рекурсивным ОТВ
-- Факториал
CREATE OR REPLACE FUNCTION factorial(n INTEGER)
  RETURNS INTEGER AS $$
    BEGIN
      IF n = 0 THEN
        RETURN 1;
      ELSE
        RETURN n * factorial(n - 1);
      END IF;
    END;
  $$
  LANGUAGE plpgsql;
  
SELECT factorial(5);

--все тренера, которых посещает определенный клиент
CREATE OR REPLACE FUNCTION sc1.get_client_coaches_recursive(p_client_id INT)
  RETURNS TABLE (id_coach INT, name VARCHAR(100), surname VARCHAR(100), gender VARCHAR(2), date_of_birth DATE, email VARCHAR(100), experience INT, specialization VARCHAR(100))
AS $$
BEGIN
  RETURN QUERY
  WITH RECURSIVE client_coaches AS (
    SELECT c.id_coach, c.name, c.surname, c.gender, c.date_of_birth, c.email, c.experience, c.specialization
    FROM sc1.visits v
    JOIN sc1.coaches c ON v.id_coach = c.id_coach
    WHERE v.id_client = p_client_id
    UNION ALL
    SELECT c.id_coach, c.name, c.surname, c.gender, c.date_of_birth, c.email, c.experience, c.specialization
    FROM sc1.visits v
    JOIN sc1.coaches c ON v.id_coach = c.id_coach
    JOIN client_coaches cc ON v.id_client = cc.id_coach   
  )
  SELECT client_coaches.id_coach, client_coaches.name, client_coaches.surname, client_coaches.gender, client_coaches.date_of_birth, client_coaches.email, client_coaches.experience, client_coaches.specialization
  FROM client_coaches;
END;
$$ LANGUAGE plpgsql;
  
SELECT * FROM sc1.get_client_coaches_recursive(1);


-- Хранимая процедура без параметров
CREATE OR REPLACE PROCEDURE sc1.update_rating() AS $$
BEGIN
  UPDATE sc1.branches
  SET rating = rating - 1
  WHERE rating > 2;
  
  UPDATE sc1.coaches
  SET experience = experience + 1
  WHERE experience < 20;
END;
$$ LANGUAGE plpgsql;

-- CALL sc1.update_rating();

SELECT *
from sc1.branches;

-- Хранимая процедура с параметрами
CREATE OR REPLACE PROCEDURE sc1.create_client(
  p_name VARCHAR(100),
  p_surname VARCHAR(100),
  p_gender VARCHAR(2),
  p_date_of_birth DATE,
  p_email VARCHAR(100)
)
AS $$
BEGIN
  INSERT INTO sc1.clients (id_client, name, surname, gender, date_of_birth, email)
  VALUES (1022, p_name, p_surname, p_gender, p_date_of_birth, p_email);
END;
$$ LANGUAGE plpgsql;

-- CALL sc1.create_client('Alica', 'Petrova', 'f', '09-09-2021', 'alica@gmail.com');

SELECT * 
FROM sc1.clients
WHERE name = 'Alica';


-- Рекурсивная хранимая процедура или хранимая процедура с рекурсивным ОТВ
-- таблица со всеми филиалами, которые являются потомками филиалa
CREATE TABLE IF NOT EXISTS new_branches (
  id_branch SERIAL NOT NULL PRIMARY KEY,
  address VARCHAR(255) NOT NULL,
  email VARCHAR(100),
  foundation_date DATE,
  rating INT NOT NULL CHECK (rating >= 1 and rating <= 10),
  parent_branch INT
);

INSERT INTO new_branches (address, email, foundation_date, rating, parent_branch)
VALUES ('Адрес1', 'email1@example.com', '2022-01-01', 8, NULL),
       ('Адрес2', 'email2@example.com', '2022-02-01', 6, NULL),
       ('Адрес3', 'email3@example.com', '2022-03-01', 9, 1),
       ('Адрес4', 'email4@example.com', '2022-04-01', 7, 1),
       ('Адрес5', 'email5@example.com', '2022-05-01', 5, 2),
       ('Адрес6', 'email6@example.com', '2022-06-01', 9, 2),
       ('Адрес7', 'email7@example.com', '2022-07-01', 8, 3),
       ('Адрес8', 'email8@example.com', '2022-08-01', 7, 3);

CREATE OR REPLACE FUNCTION get_all_branches(parent_branch_id INTEGER)
  RETURNS TABLE (id_branch INTEGER, address VARCHAR(255), email VARCHAR(100), foundation_date DATE, rating INT, parent_branch INTEGER) AS
$$
BEGIN
  RETURN QUERY
  WITH RECURSIVE all_branches AS (
    SELECT nb.id_branch, nb.address, nb.email, nb.foundation_date, nb.rating, nb.parent_branch
    FROM new_branches nb
    WHERE nb.id_branch = parent_branch_id
    UNION ALL
    SELECT nb.id_branch, nb.address, nb.email, nb.foundation_date, nb.rating, nb.parent_branch
    FROM new_branches nb
    JOIN all_branches ab ON ab.id_branch = nb.parent_branch
  )
  SELECT ab.id_branch, ab.address, ab.email, ab.foundation_date, ab.rating, ab.parent_branch
  FROM all_branches ab;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_all_branches(1);


-- Хранимая процедура с курсором
-- имена и фамилия клиентов
CREATE OR REPLACE PROCEDURE get_clients()
AS $$
DECLARE
  client_cursor CURSOR FOR SELECT id_client, name, surname FROM sc1.clients;
  client_record RECORD;
BEGIN
  OPEN client_cursor;
  
  LOOP
    FETCH client_cursor INTO client_record;
    EXIT WHEN NOT FOUND;
    RAISE NOTICE 'Client ID: %, Name: %, Surname: %', client_record.id_client, client_record.name, client_record.surname;
  END LOOP;

  CLOSE client_cursor;
END;
$$ LANGUAGE plpgsql;

CALL get_clients();

select *
from sc1.clients;
*/


-- Хранимая процедура доступа к метаданным
-- название и тип всех столбцов таблицы name
CREATE OR REPLACE PROCEDURE metadata2(name VARCHAR)
AS $$
DECLARE
    elem RECORD;
BEGIN
  FOR elem IN
    SELECT column_name,data_type
    FROM information_schema.columns
    WHERE table_name = name
  LOOP
    RAISE NOTICE 'elem = % ', elem;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CALL metadata2('visits');

/*
-- Триггер AFTER
-- срабатывает при добавлении записи в clients
CREATE OR REPLACE FUNCTION my_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  RAISE NOTICE 'Inserted record: %', NEW;
  RETURN NEW; -- RETURN NULL, если требуется отменить операцию
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER my_trigger
AFTER INSERT ON sc1.clients
FOR EACH ROW
EXECUTE FUNCTION my_trigger_function();


INSERT INTO sc1.clients(id_client, name, surname, gender, date_of_birth, email)
VALUES(1051, 'Sasha', 'Lumina', 'f', '2001-02-12', 'sasha@gmail.com');

SELECT *
FROM sc1.clients;
*/


-- Триггер INSTEAD OF 
-- UPDATE -> INSERT
-- представление по sc1.clients
/*
CREATE OR REPLACE VIEW sc1.newClients1 AS
SELECT *
FROM sc1.clients
WHERE id_client IS NOT NULL;
/*
CREATE OR REPLACE FUNCTION my_trigger_function_instead_of_update()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE sc1.clients
  SET name = 'Misa', surname = 'Lupin', gender = 'm', date_of_birth = NEW.date_of_birth, email = 'misa@mail.ru'
  WHERE id_client = OLD.id_client;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER my_trigger_instead_of_update
INSTEAD OF UPDATE ON sc1.newClients1
FOR EACH ROW
EXECUTE FUNCTION my_trigger_function_instead_of_update();
*/

UPDATE sc1.newClients1
SET name = 'New Name', surname = 'New Surname', email = 'newemail@example.com'
WHERE id_client = 1;

SELECT *
FROM sc1.newClients1;

SELECT *
from sc1.clients;
*/