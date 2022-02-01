# ДЗ по теме "Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

## задача 1

[ссылка на созданный репозиторий в DockerHub](
https://hub.docker.com/repository/docker/saksyonova/saksyonova_repo).

команды, которые использовались при выполнении задания:  

скачиваем себе на локал образ nginx:  
```
sania@sania-vb:/$ sudo docker pull nginx
Using default tag: latest
latest: Pulling from library/nginx
Digest: sha256:2834dc507516af02784808c5f48b7cbe38b8ed5d0f4837f16e78d00deb7e7767
Status: Image is up to date for nginx:latest
docker.io/library/nginx:latest
```

проверяем свои запущенные контейнеры (пока ничего не запускали):
```
sania@sania-vb:/$ sudo docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
и доступные образы:
```
sania@sania-vb:/$ sudo docker images
REPOSITORY    TAG       IMAGE ID       CREATED        SIZE
nginx         latest    c316d5a335a5   6 days ago     142MB
```

создаём каталог docker_images, где создадим Dockerfile и свой index.html. c помощью Dockerfile мы далее создадим свой образ nginx, который будет использовать наш отредактированный вывод index.html:  
```
cat Dockerfile
FROM nginx
COPY index.html /usr/share/nginx/html/index.html
```

```
cat index.html
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I'm DevOps Engineer!</h1>
</body>
</html>
```

создаём свой образ, используя Dockerfile:  
```
sudo docker build -t saksyonova/saksyonova_repo:1.0 .
Sending build context to Docker daemon  15.87kB
Step 1/2 : FROM nginx
 ---> c316d5a335a5
Step 2/2 : COPY index.html /usr/share/nginx/html/index.html
 ---> 91d686dd787d
Successfully built 91d686dd787d
Successfully tagged saksyonova/saksyonova_repo:1.0
```

пушим наш созданный образ в репозиторий Docker Hub:  
```
sania@sania-vb:/$ sudo docker push saksyonova/saksyonova_repo:1.0
The push refers to repository [docker.io/saksyonova/saksyonova_repo]
55bd5f235b68: Pushed 
762b147902c0: Pushed 
235e04e3592a: Pushed 
6173b6fa63db: Pushed 
9a94c4a55fe4: Pushed 
9a3a6af98e18: Mounted from library/nginx 
7d0ebbe3f5d2: Mounted from library/nginx 
1.0: digest: sha256:431029c5f7bcee18087fabbcabf9e87b38f21f5621ce3f9faf2c8d623fadb939 size: 1777
```

запускаем наш образ:  
```
sania@sania-vb:/$ sudo docker run -d saksyonova/saksyonova_repo:1.0
f53d98c950a2e2985a1de7c2d55f8286cc9303e153a306784fd2265557e524ed
sania@sania-vb:/$ sudo docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS          PORTS     NAMES
f53d98c950a2   saksyonova/saksyonova_repo:1.0   "/docker-entrypoint.…"   26 seconds ago   Up 25 seconds   80/tcp    lucid_morse
```

заходим в запущенный контейнер и проверяем, подменился ли index.html на нужный нам:  
```
sania@sania-vb:~/Documents/docker_images$ sudo docker exec -it f53d98c950a2 bash
root@f53d98c950a2:/usr/share/nginx/html# cat index.html
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I'm DevOps Engineer!</h1>
</body>
</html>
```


## задача 2

- высоконагруженное монолитное java веб-приложение:  
	физический сервер, скорее всего. раз оно монолитное, значит, в микросервисах не реализовать его без "опасных" изменений кода, а раз высоконагруженное - то точно понадобится физический доступ к ресурсам, без использования гипервизора;  

- Nodejs веб-приложение:  
	достаточно докера, обычно там и делают веб-приложения, удобный, быстрый и легкодоступный вариант;  

- мобильное приложение c версиями для Android и iOS:  
	наверно, виртуальная машина, проще развернуть разные версии с доступом к их интерфейсу (что невозможно в докере);  

- шина данных на базе Apache Kafka:  
	кажется, можно использовать два варианта: виртуальную машину или докер. зависит от передаваемых данных или самого использования шины..  
	
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana:  
	мы на работе Elasticsearch развернули в докере, так как используем его для тестирования микросервисов, развёрнутых там же.. logstash и kibana можно использовать также в докер-контейнерах (удобно и функционально);  

- мониторинг-стек на базе Prometheus и Grafana:  
	почитала, что эти системы сами по себе не хранят данных, как таковых, поэтому их, наверно, можно развернуть в докере (быстро и легкомасштабируемо);  

- MongoDB, как основное хранилище данных для java-приложения:  
	скорее всего, виртуальная машина (раз хранилище), маловероятно, что в докере можно успешно хранить БД с данными;  

- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.  
	идеальные кейсы для разворачивания в докере, так как данных, как таковых, нет..  


## задача 3

запускаем первый контейнер **centos**:latest:
```
root@sania-vb:/usr/share/data# docker run -it -v /usr/share/data:/usr/share/data centos:latest /bin/bash
```

запускаем второй контейнер **debian**:latest:
```
root@sania-vb:/usr/share/data# docker run -it -v /usr/share/data:/usr/share/data debian:latest /bin/bash
```

проверяем, что всё ок:
```
root@sania-vb:/usr/share/data# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED          STATUS          PORTS     NAMES
4b8bc091cec1   debian    "bash"    31 minutes ago   Up 31 minutes             nostalgic_bouman
ebada2fed4f0   centos    "bash"    2 hours ago      Up 2 hours                confident_robinson
```

подключаемся к первому контейнеру и создаём текстовый файл:
```
root@sania-vb:/usr/share/data# docker run -it -v /usr/share/data:/usr/share/data centos:latest /bin/bash
root@f128e87ab29b /# touch /usr/share/data/testfile.txt
root@f128e87ab29b /# exit
exit
```

добавляем ещё один текстовый файл, но уже на хосте:
```
root@sania-vb:/usr/share/data# touch testfile_2.txt
```

подключаемся во второй контейнер и проверяем, что смонтировалось в обе стороны и удачно:
```
root@sania-vb:/usr/share/data# docker run -it -v /usr/share/data:/usr/share/data debian:latest /bin/bash
root@1225f27ecc39:/# ls /usr/share/data
testfile.txt  testfile_2.txt
```

