# ДЗ по теме "9.2 CI/CD" :whale2:
  
  
## Знакомство с SonarQube
  
### подготовка:
  
1. выполняем docker pull sonarqube:8.7-community;
  
2. запускаем контейнер с SonarQube: 
```
sania@sania-vb:~$ docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:8.7-community
```
    
3. проверяем логи контейнера через docker logs -f sonarqube;
  
4. всё ок, заходим через браузер под admin/admin, меняем пароль на свой.
  
### основная часть:
  
1. добавляем новый проект saksyonova и генерим к нему токен;
  
2. качаем пакет SonarScanner;
  
3. прописываем переменную в PATH для корректного запуска:  
```
sania@sania-vb:~$ env | grep PATH
```
![Path](https://i.ibb.co/1X6mrhG/Untitled-picture.png)

4. проверяем версию: 
``` 
sania@sania-vb:/opt/sonar-scanner$ sonar-scanner -v  
	INFO: Scanner configuration file: /opt/sonar-scanner/conf/sonar-scanner.properties  
	INFO: Project root configuration file: NONE  
	INFO: SonarScanner 4.7.0.2747  
	INFO: Java 11.0.14.1 Eclipse Adoptium (64-bit)  
	INFO: Linux 5.13.0-40-generic amd64  
```

5. прогоняем файлик с кодом через сканнер с дополнительным ключом -Dsonar.coverage.exclusions=fail.py:
```
sania@sania-vb:~$ sonar-scanner \  
-Dsonar.projectKey=saksyonova \  
-Dsonar.sources=. \  
-Dsonar.host.url=http://localhost:9000 \  
-Dsonar.login=28e128236568ba4f9d3f25fd9c533abedad7066c \  
-Dsonar.coverage.exclusions=fail.py 
```
  
6. переходим в интерфейс:
![Failed check](https://i.ibb.co/XjrKqW6/sonar-failed.png)
  
после исправлений:
![Successful check](https://i.ibb.co/JBZ9TG5/sonar-successful.png)
  
  
## Знакомство с Nexus
  
### подготовка:
  
1. выполняем docker pull sonatype/nexus3;
  
2. запускаем: 
```
sania@sania-vb:~$ docker run -d -p 8081:8081 --name nexus sonatype/nexus3;
```
    
3. проверяем логи через docker logs -f nexus;
  
4. проверяем, всё ли ок через браузер, узнаём пароль админа и меняем его на свой.
  
### основная часть:
  
1. загружаем необходимые артефакты в репозиторий maven-release необходимые артефакты с GAV-параметрами (maven-public недоступен для загрузки);

2. файлы загрузились успешно:
![maven-release](https://i.ibb.co/gggxq8h/Untitled-picture2.png)
  
скрин метаданных:
![maven-metadata](https://i.ibb.co/zxQr7fk/maven-metadata.png)

[ссылка на maven-metadata.xml](https://github.com/saksyonova/DevOps-Netology/blob/main/maven-metadata.xml)
  
  
## Знакомство с Maven
    
### подготовка:
  
1. качаем дистрибутив Maven, разархивируем его, прописываем переменную в PATH для корректного запуска, проверяем версию:  
```
sania@sania-vb:~$ mvn --version
	Apache Maven 3.8.5 (3599d3414f046de2324203b78ddcf9b5e4388aa0)
	Maven home: /opt/maven
	Java version: 11.0.15, vendor: Private Build, runtime: /usr/lib/jvm/java-11-openjdk-amd64
	Default locale: en_US, platform encoding: UTF-8
	OS name: "linux", version: "5.13.0-40-generic", arch: "amd64", family: "unix"
```
  
2. забираем pom-xml по ссылке из задания.
  
### основная часть:
  
1. меняем в этом pom.xml блок с зависимостями под наш артефакт версии 8_282;

2. запускаем mvn package в каталоге, где находится pom.xml, дожидаемся окончания;

3. в директории ~/.m2/repository/netology/java/8_282 появляется нужный артефакт:
![mvn](https://i.ibb.co/kmtmqN0/Untitled-picture3.png)

[ссылка на исправленный pom.xml](https://github.com/saksyonova/DevOps-Netology/blob/main/pom.xml)