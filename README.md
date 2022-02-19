# ДЗ по теме "6.2 SQL" :whale2:

## задание 1
  
поднимаем PostgreSQL 12-ой версии с двумя вольюмами:  

```
sania@sania-vb:~$ docker pull postgres:12
sania@sania-vb:~$ docker volume create vol1
vol1
sania@sania-vb:~$ docker volume create vol2
vol2

sania@sania-vb:~$ docker run --rm --name pg-docker -e POSTGRES_PASSWORD=postgres -ti -p 5432:5432 -v vol1:/var/lib/postgresql/data -v vol2:/var/lib/postgresql postgres:12
```

подключаемся к postgres, смотрим, что внутри:  
```
sania@sania-vb:~$ psql -h 127.0.0.1 -U postgres -d postgres
postgres=# \l
```
![задание 1](https://i.ibb.co/1ftpDRK/Screenshot-1.png)

  
  
## задание 2
  
создаём БД test_db, пользователя test-admin-user и раздаём ему сразу права на все операции:
```
postgres=# CREATE DATABASE test_db;
	CREATE DATABASE
postgres=# CREATE ROLE "test-admin-user" SUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN;
	CREATE ROLE
```
  
создаём таблички orders и clients по спецификации:  
```
postgres=# CREATE TABLE orders 
(
id integer, 
name text, 
price integer, 
PRIMARY KEY (id) 
);
	CREATE TABLE
```
```
postgres=# CREATE TABLE clients 
(
id integer PRIMARY KEY,
lastname text,
country text,
booking integer,
FOREIGN KEY (booking) REFERENCES orders (Id)
);
	CREATE TABLE
```
  
проверяем созданные таблички:
```
test_db=# \dt
        List of relations
	Schema    |  Name    | Type   |  Owner   
	----------+----------+--------+----------
	public    | clients  | table  | postgres
	public    | orders   | table  | postgres
	(2 rows)
```
  
создаём второго пользователя test-simple-user и даём ему права только на SELECT/INSERT/UPDATE/DELETE на созданные таблички:
```
test_db=# CREATE ROLE "test-simple-user" NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN;
	CREATE ROLE
test_db=# GRANT SELECT ON TABLE public.clients TO "test-simple-user";
	GRANT
test_db=# GRANT INSERT ON TABLE public.clients TO "test-simple-user";
	GRANT
test_db=# GRANT UPDATE ON TABLE public.clients TO "test-simple-user";
	GRANT
test_db=# GRANT DELETE ON TABLE public.clients TO "test-simple-user";
	GRANT
test_db=# GRANT SELECT ON TABLE public.orders TO "test-simple-user";
	GRANT
test_db=# GRANT INSERT ON TABLE public.orders TO "test-simple-user";
	GRANT
test_db=# GRANT UPDATE ON TABLE public.orders TO "test-simple-user";
	GRANT
test_db=# GRANT DELETE ON TABLE public.orders TO "test-simple-user";
	GRANT
```
  
**итого имеем**  
список БД:  
```
test_db=# \l
```
![БД](https://i.ibb.co/dtF0xXb/test-db.png)

  
список табличек:  
```
test_db=# \dt
```
![таблички](https://i.ibb.co/9YdWZg8/tables.png)

  
список ролей:  
```
test_db=# \du
```
![роли](https://i.ibb.co/drYPNr2/image.png)

  
список пользователей с правами в созданных табличках:  
```
test_db=# SELECT * FROM information_schema.table_privileges where grantee in ('test-admin-user', 'test-simple-user');
```
![привилегии](https://i.ibb.co/GM0TMMV/privileges.png)

  
  
## задание 3
  
добавляем записи в таблички:
```
test_db=# insert into orders VALUES (1, 'Шоколад', 10), (2, 'Принтер', 3000), (3, 'Книга', 500), (4, 'Монитор', 7000), (5, 'Гитара', 4000);
	INSERT 0 5
test_db=# insert into clients VALUES (1, 'Иванов Иван Иванович', 'USA'), (2, 'Петров Петр Петрович', 'Canada'), (3, 'Иоганн Себастьян Бах', 'Japan'), (4, 'Ронни Джеймс Дио', 'Russia'), (5, 'Ritchie Blackmore', 'Russia');
	INSERT 0 5
```
  
считаем кол-во записей в табличках:
```
test_db=# select count (*) from orders;
	count 
	-------
	5
(1 row)

test_db=# select count (*) from clients;
	count 
	-------
	5
(1 row)
```
  
  
## задание 4
  
"оформляем" заказы для некоторых пользователей:
```
test_db=# UPDATE clients SET booking = 3 where id = 1;
	UPDATE 1
test_db=# UPDATE clients SET booking = 4 where id = 2;
	UPDATE 1
test_db=# UPDATE clients SET booking = 5 where id = 3;
	UPDATE 1
```
  
выводим только тех клиентов, которые сделали заказ:
```
test_db=# SELECT * FROM clients where booking IS NOT null;
```
![заказы](https://i.ibb.co/n7JTbzG/orders.png)

 
  
## задание 5
  
пробуем получить полную инфу по выполнению запроса выдачи всех пользователей, используя запрос EXPLAIN, который покажет инфу о нагрузке при исполнении запроса и отфильтрует инфу по заполненным полям booking:
```
test_db=# EXPLAIN SELECT * FROM clients where booking IS NOT null;
```
![инфа](https://i.ibb.co/YBH25bL/explain.png)

  
  
## задание 5
  
пробуем создать бэкап нашей test_db и поместить его в вольюм для бэкапов.
сначала проверяем имя текущего контейнера:
```
sania@sania-vb:~$ docker ps
```
![контейнер](https://i.ibb.co/hXvfLMf/pg-docker.png)

  
делаем бэкап:
```
sania@sania-vb:~$ docker exec -t pg-docker pg_dump -U postgres test_db -f /var/lib/postgresql/data/dump_test.sql
```
  
останавливаем текущий контейнер:
```
sania@sania-vb:~$ docker stop pg-docker
	pg-docker
```

поднимаем новый контейнер:
```
sania@sania-vb:~$ docker run --rm --name pg-docker-2 -e POSTGRES_PASSWORD=postgres -ti -p 5432:5432 -v vol1:/var/lib/postgresql/data -v vol2:/var/lib/postgresql postgres:12
```
![новый контейнер](https://i.ibb.co/WBmSSn2/pg-docker-2.png)


поднимаем в нём бэкап:
```
sania@sania-vb:~$ docker exec -i pg-docker-2 psql -U postgres -d test_db -f /var/lib/postgresql/data/dump_test.sql
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
	CREATE TABLE
	ALTER TABLE
	COPY 5
	COPY 5
	ALTER TABLE
	ALTER TABLE
	ALTER TABLE
	GRANT
	GRANT
```


```