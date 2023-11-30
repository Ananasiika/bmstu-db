import psycopg2 
from interface import *

def main():
    try:
        cnnct = psycopg2.connect(
            database = "Larisa",
            user = "Larisa",
            password = "password",
            host = "localhost",
            port = "5432"
        )
        print('Подключение прошло успешно!')
    except:
        print('Ошибка подключения((')
        return

    cur = cnnct.cursor()
    code = mainMenu()
    while code != 0:
        if code >= 1 and code <= 11:
            action(cur, code, cnnct)
        code = mainMenu()

    cur.close()
    cnnct.close()
    print('Закрыто!')

if __name__ == "__main__":
    main()