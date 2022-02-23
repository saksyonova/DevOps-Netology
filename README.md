# ДЗ по теме "6.3 MySQL" :whale2:


## задача 1

используя докер, поднимаем инстанс MySQL версии 8, а данные БД попробуем сохранить в новый volume.  
затягиваем нужную версию MySql:
```
sania@sania-vb:~$ docker pull mysql:8.0
	8.0: Pulling from library/mysql
	6552179c3509: Pull complete 
	d69aa66e4482: Pull complete 
	3b19465b002b: Pull complete 
	7b0d0cfe99a1: Pull complete 
	9ccd5a5c8987: Pull complete 
	2dab00d7d232: Pull complete 
	5d726bac08ea: Pull complete 
	11bb049c7b94: Pull complete 
	7fcdd679c458: Pull complete 
	11585aaf4aad: Pull complete 
	5b5dc265cb1d: Pull complete 
	fd400d64ffec: Pull complete 
	Digest: sha256:e3358f55ea2b0cd432685d7e3c79a33a85c7a359b35fa87fc4993514b9573446
	Status: Downloaded newer image for mysql:8.0
	docker.io/library/mysql:8.0
```	
	
создаём volume:
```
sania@sania-vb:~$ docker volume create mysql_vol
	mysql_vol
```

запускаем контейнер с MySQL:
```
sania@sania-vb:~$ docker run --rm --name mysql-docker -e MYSQL_ROOT_PASSWORD=mysql -ti -p 3306:3306 -v mysql_vol:/etc/mysql mysql:8.0
```	

подключаемся к MySQL в самом контейнере:
```
sania@sania-vb:~$ docker exec -it mysql-docker mysql -uroot -p
	Enter password: mysql
	Welcome to the MySQL monitor.  Commands end with ; or \g.
	Your MySQL connection id is 8
	Server version: 8.0.28 MySQL Community Server - GPL
	
	Copyright (c) 2000, 2022, Oracle and/or its affiliates.
	
	Oracle is a registered trademark of Oracle Corporation and/or its
	affiliates. Other names may be trademarks of their respective
	owners.
	
	Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
	mysql> 
```

создаём новую БД, в которую будем восстанавливаться из бэкапа:
```
mysql>  create database test_db;
	Query OK, 1 row affected (0.02 sec)
mysql> exit
	Bye
```

восстанавливаем наш сохранённый дамп в БД внутри контейнера:
```
sania@sania-vb:~$ cat /home/sania/DBBackups/test_dump.sql | docker exec -i cbd602a6dc13 /usr/bin/mysql -u root --password=mysql test_db
```
		
заходим в нашу БД test_db:
```
mysql> use test_db
	Reading table information for completion of table and column names
	You can turn off this feature to get a quicker startup with -A
	
	Database changed
```	
	
проверяем её статус:
```
mysql> \s
	--------------
	mysql  Ver 8.0.28 for Linux on x86_64 (MySQL Community Server - GPL)
	
	Connection id:		24
	Current database:	test_db
	Current user:		root@localhost
	SSL:			Not in use
	Current pager:		stdout
	Using outfile:		''
	Using delimiter:	;
	Server version:		8.0.28 MySQL Community Server - GPL
	Protocol version:	10
	Connection:		Localhost via UNIX socket
	Server characterset:	utf8mb4
	Db     characterset:	utf8mb4
	Client characterset:	latin1
	Conn.  characterset:	latin1
	UNIX socket:		/var/run/mysqld/mysqld.sock
	Binary data as:		Hexadecimal
	Uptime:			16 min 54 sec
	
	Threads: 2  Questions: 222  Slow queries: 0  Opens: 265  Flush tables: 3  Open tables: 178  Queries per second avg: 0.218
	--------------
```	
	
и восстановилась ли табличка orders из дампа:
```
mysql> show tables
	+-------------------+
	| Tables_in_test_db |
	+-------------------+
	| orders            |
	+-------------------+
	1 row in set (0.00 sec)
```		
	
выясняем кол-во записей с price > 300:
```
mysql> select count(*) from orders where price > 300;
	+----------+
	| count(*) |
	+----------+
	|        1 |
	+----------+
	1 row in set (0.00 sec)
```	


## задача 2

пробуем создать пользователя test в нашей БД с паролем test-pass, используя:
	▪ плагин авторизации mysql_native_password
	▪ срок истечения пароля - 180 дней
	▪ количество попыток авторизации - 3
	▪ максимальное количество запросов в час - 100
	▪ атрибуты пользователя:
		- Фамилия "Pretty"
		- Имя "James"

```
mysql> CREATE USER 'test'@'localhost' IDENTIFIED BY 'test-pass';
	Query OK, 0 rows affected (0.03 sec)
```

сразу даём ему имя:
```
mysql> ALTER USER 'test'@'localhost' ATTRIBUTE '{"fname":"James", "lname":"Pretty"}';
	Query OK, 0 rows affected (0.02 sec)
```	

настраиваем атрибуты:
```	
mysql> ALTER USER 'test'@'localhost'
	-> IDENTIFIED BY 'test-pass'
	-> WITH
	-> MAX_QUERIES_PER_HOUR 100
	-> PASSWORD EXPIRE INTERVAL 180 DAY
	-> FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2;
		Query OK, 0 rows affected (0.01 sec)
```	

предоставляем привилегии пользователю test на SELECT в БД test_db:
```
	mysql> GRANT Select ON test_db.orders TO 'test'@'localhost';
		Query OK, 0 rows affected, 1 warning (0.02 sec)
```	

выполняем запрос из таблички:
```
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER='test';
	+-------+-----------+---------------------------------------+
	| USER 	| HOST      | ATTRIBUTE                             |
	+-------+-----------+---------------------------------------+
	| test  | localhost | {"fname": "James", "lname": "Pretty"} |
	+-------+-----------+---------------------------------------+
	1 row in set (0.00 sec)
```		


## задача 3

устанавливаем профилирование (позволяет узнать, какими запросами формируется страница и сколько времени на это уходит) SET profiling = 1:
```
mysql> SET profiling = 1;
	Query OK, 0 rows affected, 1 warning (0.00 sec)
```	

узнаём, какой engine используется в табличке нашей test_db:
```
mysql> SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES WHERE table_name = 'orders' and TABLE_SCHEMA = 'test_db';
	+------------+--------+
	| TABLE_NAME | ENGINE |
	+------------+--------+
	| orders     | InnoDB |
	+------------+--------+
	1 row in set (0.00 sec)
```

пробуем изменить engine и приводим время выполнения в ответе:
```
mysql> ALTER TABLE orders ENGINE = MyISAM;
	Query OK, 5 rows affected (0.10 sec)
	Records: 5  Duplicates: 0  Warnings: 0
```

```	
mysql> ALTER TABLE orders ENGINE = INNODB;
	Query OK, 5 rows affected (0.12 sec)
	Records: 5  Duplicates: 0  Warnings: 0
```

```		
mysql> SHOW PROFILES;
+----------+------------+--------------------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                              |
+----------+------------+--------------------------------------------------------------------------------------------------------------------+
|  1       | 0.00158375 | SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES WHERE table_name = 'orders' and TABLE_SCHEMA = 'test_db'  |
|  2       | 0.10500350 | ALTER TABLE orders ENGINE = MyISAM                                                                                 |
|  3       | 0.11157125 | ALTER TABLE orders ENGINE = INNODB                                                                                 |
+--------------+-----------------+-----------------------------------------------------------------------------------------------------------+
3 rows in set, 1 warning (0.00 sec)
```
на MyISAM переключились за 0.105 секунд;
на INNODB переключились за 0.111 секунд.


## задача 4

```
sania@sania-vb:/etc/mysql$ cat my.cnf
	!includedir /etc/mysql/conf.d/
	!includedir /etc/mysql/mysql.conf.d/
	
	[mysqld]
	pid-file        = /var/run/mysqld/mysqld.pid
	socket          = /var/run/mysqld/mysqld.sock
	datadir         = /var/lib/mysql
	secure-file-priv= NULL
	
	#Set IO Speed
	# 0 - скорость
	# 1 - сохранность
	# 2 - универсальный параметр
	innodb_flush_log_at_trx_commit = 0 
	
	#Set compression
	#Barracuda - формат файла с сжатием
	innodb_file_format=Barracuda
	
	#Set buffer
	innodb_log_buffer_size	= 1M
	
	#Set Cache size
	key_buffer_size = 640М
	
	#Set log size
	max_binlog_size	= 100M
```