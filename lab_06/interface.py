def mainMenu():
    print('\nВыбери нужный пункт меню:\n' +\
        '1 - Скалярный запрос\n' +\
        '2 - Запрос с несколькими соединениями (join)\n' +\
        '3 - Запрос с ОТВ и оконными функциями\n' +\
        '4 - Запрос к метаданным\n' +\
        '5 - Скалярная функция (из 3 ЛР)\n' +\
        '6 - Многооператорная или табличная функция (из 3 ЛР)\n' +\
        '7 - Хранимая процедура (из 3 ЛР)\n' +\
        '8 - Системаня функция или процедура\n' +\
        '9 - Создание таблицы в БД, соответствующей тематике\n' +\
        '10 - Вставка данных в новую таблицу (через insert или copy)\n' +\
        '0 - Выход\n')

    try:
        task = int(input('Выбери пункт меню: '))
        if task >= 0 and task <= 10:
            if task == 0:
                print('Закрываемся...')
        else:
            task = -1
            print('Не нашлось такого пункта. Подумай еще и выбери правильно)')
    except ValueError:
        print('Нужно число ввести... Подумай еще и выбери правильно)')
        task = -1

    return task

def action(cur, task, cnnct):
    if task == 1:
        print('-- Количество посещений клиента')
        try:
            m = int(input('Введи id клиента (от 1 до 1000): '))
            if m >= 1 and m <= 1000:
                cur.execute(" \
                    select count(*) \
                    from sc1.visits \
                    where id_client = " + str(m))
                row = cur.fetchone()
                print('Количество посещений клиента с id {} равно {}'.format(m, row[0]))
            else:
                print('Нужно было число от 1 до 1000')
        except ValueError:
            print('Нужно было число ввести, а ты что ввел...?')
    elif task == 2:
        print('-- Тренера с тренировками, рейтинг которых больше определенного')
        try:
            m = int(input('Введи минимальный рейтинг тренировки (от 1 до 10): '))
            if m >= 1 and m <= 10:
                cur.execute(" \
                    select distinct c.name, c.surname, c.gender, w.rating \
                    from sc1.coaches c join sc1.workouts w on w.id_coach = c.id_coach \
                    where w.rating >="  + str(m) + ";")
                rows = cur.fetchall()
                print('  № |' + ' ' * 7 + 'Name' + ' ' * 7 + '|' +\
                    ' ' * 8 + 'Surname' + ' ' * 7 + '|' + ' ' * 1 + 'Gender' + ' ' * 1 +\
                    '| Rating')
                print('-' * 65)
                i = 1
                for elem in rows:
                    print('{:3d} | {:16s} | {:20s} | {:6s} | {} '.format(i, elem[0], elem[1], elem[2], elem[3]))
                    i += 1
            else:
                print('Нужно было число от 1 до 10')
        except ValueError:
            print('Нужно было число ввести, а ты что ввел...?')
    elif task == 3:
        print('-- Специализация тренеров и средний стаж по специализации ')
        cur.execute(" \
            with new(specialization, avg_experience) as ( \
                select distinct specialization, avg(experience) over (partition by specialization) as avg_experience \
                from sc1.coaches \
            ) \
            select *\
            from new \
            order by specialization")
        rows = cur.fetchall()
        print('      specialization      | avg_experience ')
        print('-' * 44)
        for elem in rows:
            print(' {:24s} | {:12.6f} '.format(elem[0], elem[1]))
    elif task == 4:
        print('-- Вывод имеющихся на базу данных триггеров')
        cur.execute(" \
            select trigger_catalog, trigger_name, event_manipulation \
            from information_schema.triggers")
        rows = cur.fetchall()
        if not rows:
            print('Триггеров нет...')
        else:
            print('    trigger_catalog   |     trigger_name     | event_manipulation')
            print('-' * 70)
            for elem in rows:
                print(" {:20s} | {:20s} | {:20s}".format(elem[0], elem[1], elem[2]))
    elif task == 5:
        print('-- Количество посещений клиента данной тренировки')
        try:
            id1 = int(input('Введи id клиента (целое число от 1 до 1000): '))
            id2 = int(input('Введи id тренировки (целое число от 1 до 1000): '))
            if id1 > 0 and id1 <= 1000 and id2 > 0 and id2 <= 1000:
                cur.execute("select get_visits_count(%s, %s)", (id1, id2))
                row = cur.fetchone()
                print('Количество посещений {} клиента {} тренировки равно {}'.format(id1, id2, row[0]))
            else:
                print('Нужно было число от 1 до 1000')
        except ValueError:
            print('Нужно было число ввести, а ты что ввел...?')
    elif task == 6:
        print('-- Клиенты с определенным полом')
        try:
            s = str(input('Введи пол (\'f\' или \'m\'): '))
            if s == "f" or s == "m":
                pass
                cur.execute("select get_clients_by_gender(%s)", (s))
                rows = cur.fetchall()
                if not rows:
                    print('Нет клиентов этого пола...')
                else:
                    print('  № |' + ' ' * 7 + 'Name' + ' ' * 7 + '|' +\
                    ' ' * 8 + 'Surname' + ' ' * 7)
                    print('-' * 45)
                    i = 1
                    for elem in rows:
                        new_s = elem[0].split(',')
                        print('{:3d} | {:16s} | {:20s} '.format(i, new_s[1], new_s[2][:-1]))
                        i += 1
            else:
                print('Нужно было ввести 1 из 2 символов без ковычек')
        except ValueError:
            print('Нужно было ввести символ...')
    elif task == 7:
        print('-- Понижение рейтинга всем филиалам и повышение опыта всем тренерам')
        cur.execute("call sc1.update_rating()")
        print('Обновлено!')
        cur.execute("select * \
            from sc1.coaches")
        rows = cur.fetchall()
        print(' ' * 7 + 'Name' + ' ' * 7 + '| Experience ')
        print('-' * 35)
        for i in range(100):
            elem = rows[i]
            print(' {:16s} | {} '.format(elem[1], elem[6]))
    elif task == 8:
        print('-- Текущий запрос, порт и текущая версия psql')
        cur.execute("select current_query(), inet_server_port(), version()")
        row = cur.fetchone()
        print('Current query: {} \nPort: {} \nPSQL version: {}'.format(row[0], row[1], row[2]))
    elif task == 9:
        print('-- Создание таблицы городов филиалов')
        #cur.execute("drop table sc1.city_branch")
        cur.execute(" \
            select * \
            from information_schema.tables \
            where table_name = 'city_branch'")
        if cur.fetchone():
            print('Такая таблица уже существует!')
            return
        cur.execute(" \
            create table sc1.city_branch \
            ( \
                id int generated by default as identity \
	            (start with 1 increment by 1) primary key,\
                city text not null,\
                id_branch int references sc1.branches (id_branch)\
            )") 
        print('Таблица успешно создана!')  
        cnnct.commit()     
    elif task == 10:
        print('-- Вставка значений в таблицу городов филиалов')
        cur.execute(" \
            select * \
            from information_schema.tables \
            where table_name = 'city_branch'")
        if not cur.fetchone():
            print('Такой таблицы еще не существует. Создай ее в пункте 9')
            return

        try:
            city = input('Введи город филиала: ')
            id = int(input('Введи id филиала (от 1 до 1000): '))
            if (id >= 1 and id <= 1000):
                try:
                    cur.execute(" \
                        insert into sc1.city_branch (city, id_branch) \
                        values(%s, %s)", (city, id))
                    print('Добавлено!')
                    cnnct.commit()
                    cur.execute("select * \
                                    from sc1.city_branch")
                    rows = cur.fetchall()
                    print(' ' * 7 + 'City' + ' ' * 7 + '| Id_branch ')
                    print('-' * 35)
                    for i in range(len(rows)):
                        elem = rows[i]
                        print(' {:16s} | {} '.format(elem[1], elem[2]))
                except:
                    print('Не добавилось... Попробуй снова')
                    cnnct.rollback()
            else:
                print('Нужно было число от 1 до 1000')
        except ValueError:
            print('Нужно было число ввести, а ты что ввел...?')