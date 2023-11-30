from faker import Faker
import random
import datetime

MAX = 1001

def GenerateClients(): # id имя фамилия пол дата рождения почта
    result = open("data/clients.csv", "w")
    fake = Faker()
    
    min_date = datetime.date.today() - datetime.timedelta(days=60*365)
    max_date = datetime.date.today() - datetime.timedelta(days=16*365)

    for i in range(MAX):
        line = "{0},\"{1}\",\"{2}\",\"{3}\",{4},{5}\n".format(
            i, fake.first_name(), fake.last_name(), fake.random_element(elements=('f', 'm')), fake.date_between_dates(min_date, max_date), fake.email())
        result.write(line)

    result.close()

def GenerateCoaches(): # id имя фамилия пол дата рождения почта стаж специализация
    result = open("data/coaches.csv", "w")
    fake = Faker()

    min_date = datetime.date.today() - datetime.timedelta(days=60*365)
    max_date = datetime.date.today() - datetime.timedelta(days=16*365)

    specializations = ['Персональный тренинг', 'Функциональный тренинг', 'Кроссфит', 'Aэробика', 'Пилатес', 'Спортивный массаж']

    for i in range(MAX):
        line = "{0},\"{1}\",\"{2}\",\"{3}\",{4},{5},{6},\"{7}\"\n".format(
            i, fake.first_name(), fake.last_name(), fake.random_element(elements=('f', 'm')), fake.date_between_dates(min_date, max_date), fake.email(), random.randint(0, 30), random.choice(specializations))
        result.write(line)

    result.close()

def GenerateWorkouts(): # id название idтренера длительность idцентра рейтинг
    result = open("data/workouts.csv", "w")
    str = []

    word1 = ["Быстрый", "Функциональный", "Взрывной", "Динамичный", "Горячий", "Интенсивный", "Активный", "Жиросжигающий", "Энергичный", "Гибкий"]
    word2 = [" бой", " старт", " подъем", " вызов", " бросок", " взрыв", " огонь", " бокс"]

    i = 0
    while (i != 1001):
        line = "{0},\"{1}\",\"{2}\",\"{3}\",{4},{5}\n".format(
            i, random.choice(word1) + random.choice(word2), random.randint(1, 1000), random.randint(20, 120), random.randint(1, 1000), random.randint(1, 10))
        if line not in str:
            str.append(line)
            result.write(line)
            i += 1

    result.close()

def GenerateBranches(): # id адрес почта дата основания рейтинг
    result = open("data/branches.csv", "w")
    fake = Faker()
    
    min_date = datetime.date.today() - datetime.timedelta(days=60*365)
    max_date = datetime.date.today() - datetime.timedelta(days=2*365)

    for i in range(MAX):
        line = "{0},\"{1}\",\"{2}\",\"{3}\",{4}\n".format(
            i, fake.address(), fake.email(), fake.date_between_dates(min_date, max_date), random.randint(1, 10))
        result.write(line)

    result.close()

def GenerateVisits(): # id idклиента idтренировки дата посещения idтренера idфиллиала
    str = []
    result = open("data/visits.csv", "w")
    fake = Faker() 
    
    min_date = datetime.date.today() - datetime.timedelta(days=10*365)
    max_date = datetime.date.today() - datetime.timedelta(days=0)

    i = 0
    while (i != 1001):
        line = "{0},\"{1}\",\"{2}\",\"{3}\",{4},{5}\n".format(
            i, random.randint(1, 1000), random.randint(1, 1000), fake.date_between_dates(min_date, max_date), random.randint(1, 1000), random.randint(1, 1000))
        if line not in str:
            str.append(line)
            result.write(line)
            i += 1

    result.close()


if __name__ == "__main__":
    #GenerateClients()
    #GenerateBranches()
    GenerateVisits()
    GenerateWorkouts()
    #GenerateCoaches()
