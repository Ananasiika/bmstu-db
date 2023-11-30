-- Создать расширение plpython3u
CREATE EXTENSION IF NOT EXISTS plpython3u;

-- Определяемую пользователем скалярную функцию CLR
-- Получить имя тренера по id
CREATE OR REPLACE FUNCTION get_coach_name(coach_id INT)
  RETURNS VARCHAR 
AS $$
result = plpy.execute(f" \
    SELECT name \
    FROM sc1.coaches  \
    WHERE id_coach = {coach_id};")

if result:
  return result[0]['name']
$$
LANGUAGE plpython3u;

SELECT * FROM get_coach_name(5) as "Coach name";


-- Пользовательскую агрегатную функцию CLR
-- Количество тренировок по id филлиала
CREATE OR REPLACE FUNCTION sc1.get_count_workout_by_branch(a INT, _id_branch INT)
  RETURNS INT 
AS $$
  count = 0
  res = plpy.execute("SELECT * FROM sc1.workouts")

  for elem in res:
    if elem['id_branch'] == _id_branch:
      count += 1

  return count;
$$ LANGUAGE plpython3u;

-- Агрегат, чтобы вывести количество у каждого филлиала
CREATE OR REPLACE AGGREGATE sc1.count_workouts_by_branch (INT) (
  SFUNC = sc1.get_count_workout_by_branch,
  STYPE = INT
);

SELECT id_branch, sc1.count_workouts_by_branch(id_branch) AS total_workouts
FROM sc1.branches
GROUP BY id_branch;


-- Определяемую пользователем табличную функцию CLR
-- Таблица с клиентами определенного тренера
CREATE OR REPLACE FUNCTION sc1.get_clients_by_coach(_id_coach INT)
  RETURNS TABLE (id_client INT, name VARCHAR(100), surname VARCHAR(100), gender VARCHAR(2), date_of_birth DATE, email VARCHAR(100)) 
AS $$
  res = plpy.execute("SELECT * FROM sc1.clients WHERE id_client IN (SELECT id_client FROM sc1.visits WHERE id_coach = %s)" % _id_coach)

  result = []
  for row in res:
    result.append((row['id_client'], row['name'], row['surname'], row['gender'], row['date_of_birth'], row['email']))

  return result;
$$ LANGUAGE plpython3u;

SELECT *
FROM sc1.get_clients_by_coach(1);


-- Хранимую процедуру CLR
-- изменение опыта у тренера по id
CREATE OR REPLACE PROCEDURE sc1.update_coach_experience(_id_coach INT, _years INT)
AS $$
  res = plpy.execute("SELECT * FROM sc1.coaches WHERE id_coach = %s" % _id_coach)

  if len(res) > 0:
    current_experience = res[0]['experience']
    new_experience = current_experience + _years

    plpy.execute("UPDATE sc1.coaches SET experience = %s WHERE id_coach = %s" % (new_experience, _id_coach))
  else:
    raise Exception('Coach does not exist.')
$$ LANGUAGE plpython3u;

-- CALL sc1.update_coach_experience(2, -2);

SELECT id_coach, name, experience
from sc1.coaches
ORDER BY id_coach;


-- Триггер CLR
CREATE OR REPLACE VIEW sc1.workouts_new AS
SELECT * 
FROM sc1.workouts
WHERE id_workout < 15;

SELECT * FROM sc1.workouts_new;

-- Заменяем удаление на мягкое удаление.
CREATE OR REPLACE FUNCTION del_workouts_func()
RETURNS TRIGGER
AS $$
old_id = TD["old"]["id_workout"]
rv = plpy.execute(f" \
UPDATE sc1.workouts_new SET name = \'none\'  \
WHERE sc1.workouts_new.id_workout = {old_id}")

return TD["new"]
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER del_workout_trigger
INSTEAD OF DELETE ON sc1.workouts_new
FOR EACH ROW
EXECUTE PROCEDURE del_workouts_func();

DELETE FROM sc1.workouts_new
WHERE name = 'Быстрый подъем';

SELECT *
from sc1.workouts_new;


-- Определяемый пользователем тип данных CLR
-- Тип данных содержит название тренировки и кол-во таковых

-- CREATE TYPE sc1.workout_count AS (
--   workout_name VARCHAR(255),
--   count INT
-- );

CREATE OR REPLACE FUNCTION get_workout_count(work VARCHAR)
RETURNS sc1.workout_count
AS
$$
plan = plpy.prepare(" \
SELECT name, COUNT(id_workout) \
FROM sc1.workouts \
WHERE name = $1 \
GROUP BY name;", ["VARCHAR"])

# return value
rv = plpy.execute(plan, [work])

if (rv.nrows()):
    return (rv[0]["name"], rv[0]["count"])
$$ LANGUAGE plpython3u;

SELECT * FROM get_workout_count('Интенсивный бой');