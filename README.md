# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис.

ответ: не хватает закрывающих кавычек в ключе "ip" и обеих кавычек в его значении:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```


## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
import socket as s
import time as t
import datetime as dt
import json
import yaml

#устанавливаем значения переменных
i = 1
wait = 3 #интервал проверок в секундах
srv = {'drive.google.com':'0.0.0.0', 'mail.google.com':'0.0.0.0', 'google.com':'0.0.0.0'} #якобы предыдущие актуальные IP сервисов
init = 0
fpath = "C:\\Users\\skuznetsova\\AppData\\Local\\Programs\\Python\\Python310" #путь к конфигам
flog = "C:\\Users\\skuznetsova\\AppData\\Local\\Programs\\Python\\Python310\\error.log" #путь к логам

print('__________')
print(srv)
print('__________')

while 1==1 : #отладочное число проверок 
    for host in srv:
        ip = s.gethostbyname(host)
        if ip != srv[host]:
            if i==1 and init !=1:
                print(str(dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + ' [ERROR] ' + str(host) + ' IP mismatch: '+srv[host]+' '+ip)
            #json
            with open(fpath + host + ".json", 'w') as jsf:
                json_data = json.dumps({host: ip})
                jsf.write(json_data)
            #yaml
            with open(fpath + host + ".yaml", 'w') as ymf:
                yaml_data = yaml.dump([{host: ip}])
                ymf.write(yaml_data)
            
            srv[host]=ip
    #отладочное число итераций для проверки
    i+=1
    if i >= 20: 
        break
    t.sleep(wait)
```

### Вывод скрипта при запуске при тестировании:
```
PS C:\Users\skuznetsova\PyProjects> & C:/Users/skuznetsova/AppData/Local/Programs/Python/Python310/python.exe c:/Users/skuznetsova/PyProjects/HW4_1.py
__________
{'drive.google.com': '0.0.0.0', 'mail.google.com': '0.0.0.0', 'google.com': '0.0.0.0'}
__________
2021-12-17 13:44:04 [ERROR] drive.google.com IP mismatch: 0.0.0.0 74.125.131.194   
2021-12-17 13:44:04 [ERROR] mail.google.com IP mismatch: 0.0.0.0 108.177.14.83     
2021-12-17 13:44:04 [ERROR] google.com IP mismatch: 0.0.0.0 64.233.162.100
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{"drive.google.com": "74.125.131.194"}
```

```json
{"google.com": "64.233.162.100"}
```

```json
{"mail.google.com": "108.177.14.83"}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
- drive.google.com: 74.125.131.194
```
```yaml
- google.com: 64.233.162.100
```
```yaml
- mail.google.com: 108.177.14.83
```