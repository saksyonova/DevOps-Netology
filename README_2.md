# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | получим ошибку, потому что типы не подходят для операции сложения: int и str  |
| Как получить для переменной `c` значение 12?  | приводим значение a к строке: c = str(a) + b  |
| Как получить для переменной `c` значение 3?  | приводим значение b к целому числу: c = a + int(b)  |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

кажется, в скрипте лишняя переменная is_change, а конечный break сразу же может прервать обработку при первом же найденном вхождении.

### Ваш скрипт:
```python
import os

bash_command = ["cd C:\\Users\\skuznetsova\\Git\\Projects\\DevOps-Netology", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
```

### Вывод скрипта при запуске при тестировании:
```
PS C:\Users\skuznetsova\PyProjects> & C:/Users/skuznetsova/AppData/Local/Programs/Python/Python310/python.exe c:/Users/skuznetsova/PyProjects/script_1.py
**README_2.md**
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
import os
import sys

cmd = os.getcwd()

if len(sys.argv) >= 2:
    cmd = sys.argv[1]
bash_command = ["cd " + cmd, "git status"]

result_os = os.popen(' && '.join(bash_command)).read()

for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '\\')
        print(cmd + prepare_result)
```

### Вывод скрипта при запуске при тестировании:
```
PS C:\Users\skuznetsova\Git\Projects\DevOps-Netology> & C:/Users/skuznetsova/AppData/Local/Programs/Python/Python310/python.exe c:/Users/skuznetsova/PyProjects/script_2.py
**C:\Users\skuznetsova\Git\Projects\DevOps-Netology\README_2.md**
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
import socket as s
import time as t
import datetime as dt

#устанавливаем значения переменных
i = 1 
wait = 3 #интервал проверок в секундах
srv = {'drive.google.com':'0.0.0.0', 'mail.google.com':'0.0.0.0', 'google.com':'0.0.0.0'} #якобы предыдущие актуальные IP сервисов
init = 0

print('__________')
print(srv)
print('__________')

while 1==1 : #отладочное число проверок 
    for host in srv:
        ip = s.gethostbyname(host)
        if ip != srv[host]:
            if i==1 and init !=1:
                print(str(dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + ' [ERROR] ' + str(host) + ' IP mismatch: '+srv[host]+' '+ip)
            srv[host]=ip
    #отладочное число итераций для проверки
    i+=1
    if i >= 20: 
        break
    t.sleep(wait)
```

### Вывод скрипта при запуске при тестировании:
```
PS C:\Users\skuznetsova\PyProjects> & C:/Users/skuznetsova/AppData/Local/Programs/Python/Python310/python.exe c:/Users/skuznetsova/PyProjects/script_3.py
__________
{'drive.google.com': '0.0.0.0', 'mail.google.com': '0.0.0.0', 'google.com': '0.0.0.0'}
__________
2021-12-15 01:07:19 [ERROR] drive.google.com IP mismatch: 0.0.0.0 74.125.131.194
2021-12-15 01:07:19 [ERROR] mail.google.com IP mismatch: 0.0.0.0 108.177.14.18
2021-12-15 01:07:19 [ERROR] google.com IP mismatch: 0.0.0.0 64.233.162.113
```