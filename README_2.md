# ДЗ по теме "6.4. PostgreSQL" :tropical_fish:


## задача 1

используя докер, поднимаем инстанс PostgreSQL версии 13, данные также будем сохранять в новом volume.  
затягиваем нужную версию PostgreSQL:  
```
sania@sania-vb:~$ docker pull postgres:13
	13: Pulling from library/postgres
	5eb5b503b376: Already exists 
	daa0467a6c48: Already exists 
	7cf625de49ef: Already exists 
	bb8afcc973b2: Already exists 
	c74bf40d29ee: Already exists 
	2ceaf201bb22: Already exists 
	1255f255c0eb: Already exists 
	12a9879c7aa1: Already exists 
	0052b4855bef: Pull complete 
	e1392be26b85: Pull complete 
	9154b308134e: Pull complete 
	7e0447003684: Pull complete 
	3d7ffb6e96a5: Pull complete 
	Digest: sha256:8b8ff4fcdc9442d8a1d38bd1a77acbdfbc8a04afda9c19df47383cb2d08fc04b
	Status: Downloaded newer image for postgres:13
	docker.io/library/postgres:13
```
  
создаём volume для хранения:
```
sania@sania-vb:~$ docker volume create postgresql_vol
	postgresql_vol
```
  
запускаем контейнер с PostgreSQL:
```
sania@sania-vb:~$ docker run --rm --name pg-docker -e POSTGRES_PASSWORD=postgres -ti -p 5432:5432 -v postgresql_vol:/var/lib/postgresql/data postgres:13
```
  
подключаемся к самому PostgreSQL в контейнере:
```
sania@sania-vb:~$ docker exec -it pg-docker bash
root@0bc7fb4f0a92:/# psql -h localhost -p 5432 -U postgres -W
	Password: 
	psql (13.6 (Debian 13.6-1.pgdg110+1))
	Type "help" for help.
	
	postgres=# 
```
  
**выводим результаты управляющих команд**  
  
вывод списка БД:
```
postgres=# \l
							List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres         +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres         +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)  
```
  
подключение к БД:
```
postgres=# \c [DB_NAME]
```
  
вывод списка таблиц:
```
postgres=# \dt
```	
  
вывод описания содержимого таблиц:
```
postgres=# \dS+ [TABLE_NAME]
```	
  
выход из psql:
```
postgres=# \q
```
  
  
## задача 2

подключаемся обратно к psql, создаём БД test_database:
```	
postgres=# CREATE DATABASE test_database;
	CREATE DATABASE
```
  
восстанавливаем наш сохранённый дамп в БД test_database внутри контейнера:
```
sania@sania-vb:~$ docker exec -i pg-docker psql --username postgres test_database < /home/sania/DBBackups/test_dump_postgresql.sql
	SET
	SET
	SET
	SET
	SET
	 set_config 
	------------
	 
	(1 row)
	
	SET
	SET
	SET
	SET
	SET
	SET
	CREATE TABLE
	ALTER TABLE
	CREATE SEQUENCE
	ALTER TABLE
	ALTER SEQUENCE
	ALTER TABLE
	COPY 8
	 setval 
	--------
		8
	(1 row)
	
	ALTER TABLE
```
  
подключаемся к нашей восстановленной БД test_database:
```
postgres=# \c test_database
	Password: 
		You are now connected to database "test_database" as user "postgres".
	test_database=# 
```
  
проверим таблички восстановленной БД:
```
test_database=# \dt
			List of relations
	 Schema  |  Name  |  Type  |  Owner   
	---------+--------+--------+----------
	 public  | orders | table  | postgres
	(1 row)
```
  
проводим сбор статистики по табличке orders:
```
test_database=# ANALYZE VERBOSE public.orders;
	INFO:  analyzing "public.orders"
	INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
	ANALYZE
```

используя pg_stats, ищем столбец таблички orders с наибольшим средним значением размера элементов в байтах.  
сначала просто узнаём, что выведет pg_stats по табличке orders:
```
test_database=# select * from pg_stats where tablename = 'orders';
```
  
по доке cреднее значение размера элементов в байтах выводится в столбце avg_width, поэтому делаем конкретный селект по этому столбцу:
```
test_database=# select avg_width from pg_stats where tablename = 'orders';
	avg_width 
	-----------
	       4
	       16
	       4
	(3 rows)
```


## задача 3  

попробуем переименовать основную таблицу, создать две новые и разнести данные из основной в две созданные по ценовому диапазону.  
сначала посмотрим, что внутри этой таблички orders:
```
test_database=# select * from orders;
	 id |        title         | price 
	----+----------------------+-------
	  1 | War and peace        |   100
	  2 | My little database   |   500
	  3 | Adventure psql time  |   300
	  4 | Server gravity falls |   300
	  5 | Log gossips          |   123
	  6 | WAL never lies       |   900
	  7 | Me and my bash-pet   |   499
	  8 | Dbiezdmin            |   501
	(8 rows)
```

переименовываем табличку:
```
test_database=# alter table orders rename to orders_base;
	ALTER TABLE
```
  	
создаём 2 новые таблички, предварительно создав ещё одну "базовую" с необходимыми параметрами данных:
```
test_database=# create table orders (id integer, title varchar(80), price integer) partition by range(price);
	CREATE TABLE
```
```
test_database=# create table orders_1 partition of orders for values from (499) to (999999999);
	CREATE TABLE
```
```	
test_database=# create table orders_2 partition of orders for values from (0) to (499);
	CREATE TABLE
```
  
заносим данные в табличку orders:
```
test_database=# insert into orders (id, title, price) select * from orders_base;
	INSERT 0 8
```
делаем селект по каждой, проверяем, всё ли ок:
```
test_database=# select * from orders_1;
	 id |       title        | price 
	----+--------------------+-------
	  2 | My little database |   500
	  6 | WAL never lies     |   900
	  7 | Me and my bash-pet |   499
	  8 | Dbiezdmin          |   501
	(4 rows)
```
```		
test_database=# select * from orders_2;
	 id |        title         | price 
	----+----------------------+-------
	  1 | War and peace        |   100
	  3 | Adventure psql time  |   300
	  4 | Server gravity falls |   300
	  5 | Log gossips          |   123
	(4 rows)
```
  
данные успешно разнеслись, согласно ценовому диапазону.  
кстати, в самом начале при создании этой таблички orders можно было изначально сделать её секционированной.  


## задача 4

делаем бэкап нашей БД test_database:
```
sania@sania-vb:~$ docker exec -i pg-docker pg_dump --username postgres test_database > /home/sania/DBBackups/test_database_backup.sql
```

уникальности столбца title можно было бы добиться через добавление индекса:
```
CREATE INDEX ON orders (title);
```