-- 1 - предикат сравнения
-- тренера, у которых тренировки с рейтингом > 6

SELECT DISTINCT c.name, c.surname, c.gender, w.rating
FROM sc1.coaches c JOIN sc1.workouts w ON w.id_coach = c.id_coach
WHERE w.rating > 6
ORDER BY c.gender;

-- 2 - предикат between
-- клиенты с днем рождения между 1999-01-01 и 1997-03-31
SELECT DISTINCT name, date_of_birth
FROM sc1.clients
WHERE date_of_birth BETWEEN '1997-01-01' AND '1997-03-31';

-- 3 - предикат like
-- тренировки со словом Энергичный в названии

SELECT DISTINCT name
FROM sc1.workouts
WHERE name LIKE '%Энергичный%';

-- 4 - предикат in с вложенным подзапросом
-- клиенты, которые посетили фитнес зал между '2015-01-01' и '2015-03-31'

SELECT name, surname
FROM sc1.clients
WHERE id_client IN (SELECT id_client
 FROM sc1.visits
 WHERE date_of_visit BETWEEN '2015-01-01' AND '2015-03-31');

-- 5 - предикат exists с вложенным подзапросом
-- клиенты, которые посетили фитнес зал между '2015-01-01' и '2015-03-31'

SELECT *
FROM sc1.clients as c
WHERE EXISTS (
   SELECT 1
   FROM sc1.visits
   WHERE id_client = c.id_client
	AND date_of_visit BETWEEN '2015-01-01' AND '2015-03-31'
);

-- 6 - предикат сравнения с квантором
-- тренера с наибольшим стажем в специализации Пилатес

SELECT *
FROM sc1.coaches
WHERE specialization = 'Пилатес'
AND experience >= ALL (
   SELECT experience
   FROM sc1.coaches
   WHERE specialization = 'Пилатес'
);

-- 7 - аггрегатные функции в выражениях столбцов
-- средняя продолжительность тренировок с одинаковым названием

SELECT name, AVG(duration) as avg_duration
FROM sc1.workouts
GROUP BY name;

-- 8 - скалярные подзапросы в выражениях столбцов
-- клиенты, количество их визитов и максимальный рейтинг тренера, у которого они были

SELECT c.name, c.surname, 
(SELECT COUNT(*) FROM sc1.visits WHERE visits.id_client = c.id_client) AS visit_count,
(SELECT MAX(rating) FROM sc1.workouts WHERE workouts.id_coach = coaches.id_coach) AS max_rating
FROM sc1.clients as c
LEFT JOIN sc1.visits ON visits.id_client = c.id_client
LEFT JOIN sc1.workouts ON workouts.id_workout = visits.id_workout
LEFT JOIN sc1.coaches ON coaches.id_coach = visits.id_coach
WHERE visits.id_visit IS NOT NULL 
AND (SELECT MAX(rating) FROM sc1.workouts WHERE workouts.id_coach = coaches.id_coach) > 0
GROUP BY c.id_client, coaches.id_coach;

-- 9 - простое выражени case 
-- клиенты и их пол

SELECT name, surname, gender,
CASE
  WHEN gender = 'm' THEN 'Male'
  WHEN gender = 'f' THEN 'Female'
  ELSE 'Unknown'
END AS gender_text
FROM sc1.clients;

-- 10 - поисковое выражение case
-- название тренировок, имя тренера и рейтинг

SELECT workouts.name AS workout_name, coaches.name AS coach_name, rating,
CASE
  WHEN rating > 8 THEN 'High'
  WHEN rating > 6 THEN 'Medium'
  WHEN rating > 4 THEN 'Low'
  ELSE 'Very Low'
END AS rating_category
FROM sc1.workouts
JOIN sc1.coaches ON workouts.id_coach = coaches.id_coach;

-- 11 - создание новой временной локальной таблицы из результирующего набора данных
-- таблица из названия и рейтинга тренировок

/*CREATE TEMPORARY TABLE temp_table AS
SELECT name as new_name, rating as new_rating
FROM sc1.workouts
WHERE rating > 6;*/

/*SELECT name as new_name, rating as new_rating
INTO temp_table
FROM sc1.workouts
WHERE rating < 6;

SELECT *
from temp_table;

DROP TABLE temp_table;*/

-- 12 - вложенные коррелированные подзапросы в качестве производных таблиц в предложении from
-- адрес филиала и имя тренера, который там работает

SELECT T1.address AS branch_address, T2.name AS coach_name
FROM (SELECT id_branch, address FROM sc1.branches) AS T1
JOIN (SELECT id_coach, name FROM sc1.coaches) AS T2 ON T1.id_branch = T2.id_coach;

-- 13 - вложенные подзапросы с уровнем вложенности 3
-- клиенты, которые посещали тренировки, проводимые тренерами со специализацией "Кроссфит"

SELECT *
FROM sc1.clients
WHERE id_client IN (
    SELECT id_client
    FROM sc1.visits
    WHERE id_visit IN (
        SELECT id_visit
        FROM sc1.workouts
        WHERE id_coach IN (
            SELECT id_coach
            FROM sc1.coaches
            WHERE specialization = 'Кроссфит'
        )
    )
);

-- 14 - консолидирующая данные с помощью предложения group by, но без having
-- id тренера и количество его тренировок

SELECT id_coach, COUNT(*) AS total_workouts
FROM sc1.workouts
GROUP BY id_coach;

-- 15 - консолидирующая данные с помощью предложения group by с having
-- id тренера и количество его тренировок, только те тренера, у которых не менее 3 тренировок

SELECT id_coach, COUNT(*) AS total_workouts
FROM sc1.workouts
GROUP BY id_coach
HAVING COUNT(*) >= 3;

-- 16 - insert вставка в таблицу одного значения
-- вставка John в clients

--INSERT INTO sc1.clients (id_client, name, surname, gender, date_of_birth, email)
--VALUES (1001, 'John', 'Doe', 'm', '1990-01-01', 'johndoe@example.com');

select *
from sc1.clients
where name = 'John';

-- 17 - многострочная insert, вып. вставку в таблицу результирующего набора данных вложенного подзапроса
-- добавление в посещения клиентов

/*INSERT INTO sc1.visits (id_visit, id_client, id_workout, date_of_visit, id_coach, id_branch)
SELECT id_client + 967, id_client as id_client, 34, 
(SELECT MAX(date_of_visit) FROM sc1.visits), 
32, 12
FROM sc1.clients
WHERE id_client > 100 AND id_client < 150 AND gender = 'f';*/

SELECT *
FROM sc1.visits;

-- 18 - инструкция update 
-- изменение почты

UPDATE sc1.clients
SET email = 'newemail@example.com'
WHERE id_client = 12;

SELECT *
FROM sc1.clients
WHERE id_client = 12;

-- 19 - update со скалярным подзапросом в предложении set
-- изменение почты

UPDATE sc1.clients
SET email = (SELECT CONCAT(name, '_', surname, '@example.com')
             FROM sc1.clients
             WHERE id_client = 123)
WHERE id_client = 123;

SELECT *
FROM sc1.clients
WHERE id_client = 123;

-- 20 - delete
-- удаление посещения id_client = 5

DELETE FROM sc1.visits
WHERE id_client = 5;

SELECT *
FROM sc1.visits;

-- 21 - delete с вложенным коррелированным подзапросом в предложении where
-- удаление посещений людей, которые были не ранее 2022 года

DELETE FROM sc1.visits
WHERE id_client IN (
    SELECT id_client
    FROM sc1.clients
    WHERE date_of_visit >= '2022-01-01' AND id_client = sc1.visits.id_client
);

SELECT *
FROM sc1.visits
WHERE date_of_visit >= '2021-01-01';

-- 22 - простое обобщенное табличное выражение
WITH my_cte AS (
    SELECT id_client, name, surname, gender
    FROM sc1.clients
    WHERE gender = 'f'
)
SELECT id_client, CONCAT(name, ' ', surname) AS full_name, gender
FROM my_cte;

-- 23 - рекурсивное обобщенное табличное выражение

-- Создание таблицы branches
CREATE TABLE IF NOT EXISTS branches (
  id_branch SERIAL NOT NULL PRIMARY KEY,
  address VARCHAR(255) NOT NULL,
  email VARCHAR(100),
  foundation_date DATE,
  rating INT NOT NULL CHECK (rating >= 1 and rating <= 10),
  parent_branch INT
);

-- Заполнение таблицы branches значениями

INSERT INTO branches (address, email, foundation_date, rating, parent_branch)
VALUES ('Адрес1', 'email1@example.com', '2022-01-01', 8, NULL),
       ('Адрес2', 'email2@example.com', '2022-02-01', 6, NULL),
       ('Адрес3', 'email3@example.com', '2022-03-01', 9, 1),
       ('Адрес4', 'email4@example.com', '2022-04-01', 7, 1),
       ('Адрес5', 'email5@example.com', '2022-05-01', 5, 2),
       ('Адрес6', 'email6@example.com', '2022-06-01', 9, 2),
       ('Адрес7', 'email7@example.com', '2022-07-01', 8, 3),
       ('Адрес8', 'email8@example.com', '2022-08-01', 7, 3);

-- Запрос для получения иерархической структуры фитнес центров
WITH RECURSIVE branch_tree(id_branch, address, parent_branch, level) AS (
  SELECT id_branch, address, parent_branch, 0
  FROM branches
  WHERE parent_branch IS NULL
  UNION ALL
  SELECT b.id_branch, b.address, b.parent_branch, bt.level + 1
  FROM branches b
  INNER JOIN branch_tree bt ON b.parent_branch = bt.id_branch
)
SELECT id_branch, address, level
FROM branch_tree
ORDER BY level, id_branch;


-- 24 - оконные функции. использование min max avg over 

--Вычисление минимального и максимального возраста клиентов по полу:
SELECT gender, MIN(date_of_birth) OVER (PARTITION BY gender) as min_age,
       MAX(date_of_birth) OVER (PARTITION BY gender) as max_age
FROM sc1.clients;

--Вычисление среднего стажа работы тренеров по их специализации:
SELECT DISTINCT specialization, AVG(experience) OVER (PARTITION BY specialization) as avg_experience
FROM sc1.coaches;

--Вычисление минимальной и максимальной продолжительности тренировок по филиалам:
SELECT id_branch, MIN(duration) OVER (PARTITION BY id_branch) as min_duration,
       MAX(duration) OVER (PARTITION BY id_branch) as max_duration
FROM sc1.workouts;

-- 25 - оконные функции для устранения дублей

SELECT id_client, name, surname, gender
FROM sc1.clients
UNION ALL
SELECT id_client, name, surname, gender
FROM sc1.clients;

WITH cte AS (
  SELECT id_client, name, surname, gender,
         ROW_NUMBER() OVER (PARTITION BY id_client, name, surname, gender ORDER BY id_client) AS row_num
  FROM sc1.clients
)
SELECT id_client, name, surname, gender
FROM cte
WHERE row_num = 1;
