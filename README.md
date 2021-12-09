## DevOps-Netology
**ДЗ "Элементы безопасности информационных систем"** :whale2:
  
1. выполнено:  
![pic 1](https://i.ibb.co/fnz0tHJ/1.png)  
  
2. настроено:
![pic 2](https://i.ibb.co/ZxSvcX7/2.jpg)  
  
3. готово, получили ошибку о самоподписанном сертификате при переходе в localhost по протоколу HTTPS:  
![pic 3](https://i.ibb.co/YdhJYzB/3.png)  
  
4. проверили сайт Нетологии на https://www.ssllabs.com/:  
![pic 4](https://i.ibb.co/QkZtK66/4.png)  
  
видим, что сервер поддерживает версии TLS 1.0, 1.1, 1.2 и 1.3.
жёлтый цвет указывает, что версии 1.0 и 1.1 уже устарели.
домену присвоен рейтинг B, ибо для рейтинга А домен должен поддерживать только самые последние версии.
протокол SSL не имеет никакой поддержки, и это ок, поскольку считается устаревшим.  
  
5. сгенерировали ключи в PuTTY, публичный ключ отправили на другой сервер. попытались в PuTTY подключиться по SSH к этому серверу:  
![pic 5_1](https://i.ibb.co/QjXtfN9/5-1.png)  
  
![pic 5_2](https://i.ibb.co/DrCVfZ5/5-2.png)  
  
6. переименовали ключи, в файле C:\Windows\System32\drivers\etc\hosts прописали наш удалённый порт и имя хоста, по которому попробуем подключиться:  
![pic 6_1](https://i.ibb.co/7QbRgPv/6-1.png)  
  
в PuTTY подключаемся уже по имени хоста:  
![pic 6_2](https://i.ibb.co/F3f2PYP/6-2.png)  
  
успешно подцепились:  
![pic 6_2](https://i.ibb.co/fNVr6Cc/6-3.png)  
  
7. собираем дамп трафика интерфейса any (предварительно список доступных интерфейсов выловили по sudo tcpdump -D), кол-во пакетов = 100, вывод результатов в файл формата .pcap:  
>sania@Sania-VB:~$ sudo tcpdump -i any -c 100 -w packets_logs.pcap  
  
открываем полученный файл в Wireshark:  
![pic 7](https://i.ibb.co/DM6Q9WZ/7.png)  
