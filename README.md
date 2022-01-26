# ДЗ по теме "применение принципов IaaC в работе с ВМ"

## задача 1

- с помощью применения IaaC-паттернов мы значительно можем ускорить производство и вывод продукта на рынок, также уменьшить затраты на это;
- также IaaC предоставляет стабильную среду, не требуется постоянной ручной настройки, развёртывание инфраструктуры с помощью IaaC повторяемо и предотвращает проблемы во время выполнения, снижает вероятность ошибок или отклонений (**идемпотентность, главное преимущество и основополагающий принцип применения IaaC**);
- ещё IaaC позволяет документировать, регистрировать и отслеживать каждое изменение конфигурации сервера, а в случае непредвиденных аварийных ситуаций позволяет восстановиться через повторное развёртывание последнего работоспособного состояния.


## задача 2

преимущество Ansible в том, что это - довольно простой инструмент для написания сценариев автоматизации. 
	
Ansible позволяет:
- устанавливать, удалять и настраивать необходимое ПО;
- управлять пользовательскими ключами и паролями;
- создавать и удалять пользователей;
- запускать скрипты и тесты;
- создавать и удалять контейнеры и ВМ.
	
а модули Playbooks, которые используются для выполнения сценариев, можно применить на разных платформах.
	
	
в лекции говорилось, что существует 3 подхода к IaaC, но основные - 2: декларативный (который описывает конечную цель и определяет требуемое состояние наших ресурсов, отвечает на вопрос: "**что** нужно создать?" (например, 2 ВМ); и императивный (который отвечает на вопрос: "**как** нужно изменить инфраструктуру для достижения той или иной цели, выдавая последовательность различных команд (Ansible Playbook).
	
разница между методами IaaC push и pull:
в pull-режиме каждый сервер будет пуллить свою конфигу из мастер-сервера, а в push-режиме мастер-сервер сам распушивает конфигу по целевой системе.

"из коробки" все сценарии и команды в Ansible выполняются методом push, наверно, он надёжнее.


## задача 3
основная ОС: Windows10
	
установлен Oracle VB:
Version 6.1.32 r149290
	
развёрнута ВМ Ubuntu 20.04
внутри развёрнут vagrant:
```
sania@sania-vb:~$ vagrant --version
Vagrant 2.2.6
```	

и ansible:
```
sania@sania-vb:~$ ansible --version
ansible 2.9.6
```


## задача 4
установили на ВМ докер:
```
sudo apt install docker.io
```

проверяем, что всё ок:
```
sania@sania-vb:/$ sudo docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

пробуем запустить первый докер-контейнер:
```
sania@sania-vb:/$ sudo docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
2db29710123e: Pull complete 
Digest: sha256:507ecde44b8eb741278274653120c2bf793b174c06ff4eaa672b713b3263477b
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```
