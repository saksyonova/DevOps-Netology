# ДЗ по теме "6.5. Elasticsearch" :whale2:


## задача 1
  
докерфайл-манифест для разворачивания Elasticsearch на основе образа Centos:7:
```
FROM centos:7

EXPOSE 9200 9300
USER 0
RUN export ES_HOME="/var/lib/elasticsearch" && \
yum -y install wget && \
wget artifacts.elastic.co..._64.tar.gz && \
wget artifacts.elastic.co....gz.sha512 && \
sha512sum -c elasticsearch-8.0.1-linux-x86_64.tar.gz.sha512 && \
tar -xzf elasticsearch-8.0.1-linux-x86_64.tar.gz && \
rm -f elasticsearch-8.0.1-linux-x86_64.tar.gz* && \
mv elasticsearch-8.0.1 ${ES_HOME} && \
useradd -m -u 1000 elasticsearch && \
chown elasticsearch:elasticsearch -R ${ES_HOME} && \
yum -y remove wget && \
yum clean all

COPY --chown=elasticsearch:elasticsearch elasticsearch.yml /var/lib/elasticsearch/config/
USER 1000
ENV ES_HOME="/var/lib/elasticsearch" \
ES_PATH_CONF="/var/lib/elasticsearch/config"
WORKDIR ${ES_HOME}

CMD [“sh”, “-c”, “${ES_HOME}/bin/elasticsearch”]
```
  
создаём образ:
```
root@sania-vb:/var/lib/docker/dockerfiles# docker build . -t saksyonova/saksyonova_repo:2.0
	...
	Successfully build 0667beeb27a5
	Successfully tagged saksyonova/saksyonova/saksyonova_repo:2.0
```
  
пушим этот образ к себе в репозиторий dockerhub:
```
root@sania-vb:/var/lib/docker/dockerfiles# docker push saksyonova/saksyonova_repo:2.0 
```
  
образ можно забрать тут:
```
docker pull saksyonova/saksyonova_repo:2.0 
```
  
запускаем:
```
sania@sania-vb:~$ docker run --rm -d --name elastic -p 9200:9200 -p 9300:9300 saksyonova/saksyonova_repo:2.0 
```
  
проверяем ответ elasticsearch:
```
sania@sania-vb:~$ curl -X GET 'localhost:9200/' 
{ 
  "name" : "netology_test", 
  "cluster_name" : "elasticsearch", 
  "cluster_uuid" : "erh1f3xnThKbfPaCcbH5Jw", 
  "version" : { 
    "number" : "8.0.1", 
    "build_flavor" : "default", 
    "build_type" : "tar", 
    "build_hash" : "801d9ccc7c2ee0f2cb121bbe22ab5af77a902372", 
    "build_date" : "2022-02-24T13:55:40.601285296Z", 
    "build_snapshot" : false, 
    "lucene_version" : "9.0.0", 
    "minimum_wire_compatibility_version" : "7.17.0", 
    "minimum_index_compatibility_version" : "7.0.0" 
  }, 
  "tagline" : "You Know, for Search" 
}
```
  
  
## задача 2
  
добавляем в Elasticsearch 3 индекса:
```
sania@sania-vb:~$ curl -X PUT localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}' 
	{"acknowledged":true,"shards_acknowledged":true,"index":"ind-1"} 
 
sania@sania-vb:~$ curl -X PUT localhost:9200/ind-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 2,  "number_of_replicas": 1 }}' 
	{"acknowledged":true,"shards_acknowledged":true,"index":"ind-2"} 
 
sania@sania-vb:~$ curl -X PUT localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 4,  "number_of_replicas": 2 }}' 
	{"acknowledged":true,"shards_acknowledged":true,"index":"ind-3"} 
```
  
выводим список получившихся индексов:
```
sania@sania-vb:~$ curl -X GET 'localhost:9200/_cat/indices?v' 
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size 
green  open   ind-1 EdE_IEKCStGTft2ekiGWcA   1   0          0            0       225b           225b 
yellow open   ind-3 BmKVbRsERQ6mGIjcLIFKig   4   2          0            0       900b           900b 
yellow open   ind-2 Km_nvfwpTgmjR4M2CcmVNw   2   1          0            0       450b           450b 
```
  
получаем состояние всего кластера через API:
```
sania@sania-vb:~$ curl -X GET "localhost:9200/_cluster/health?pretty" 
{ 
  "cluster_name" : "elasticsearch", 
  "status" : "yellow", 
  "timed_out" : false, 
  "number_of_nodes" : 1, 
  "number_of_data_nodes" : 1, 
  "active_primary_shards" : 8, 
  "active_shards" : 8, 
  "relocating_shards" : 0, 
  "initializing_shards" : 0, 
  "unassigned_shards" : 10, 
  "delayed_unassigned_shards" : 0, 
  "number_of_pending_tasks" : 0, 
  "number_of_in_flight_fetch" : 0, 
  "task_max_waiting_in_queue_millis" : 0, 
  "active_shards_percent_as_number" : 44.44444444444444 
} 
```

в подавляющем большинстве случаев причина статуса yellow - возможная нехватка места/ресурсов. а ещё у наших индексов указано число реплик, а по факту нет других серверов, соответствено, реплицировать некуда.  
  
удаляем все индексы:  
```
sania@sania-vb:~$ curl -X DELETE 'http://localhost:9200/ind-1?pretty'  
{ 
  "acknowledged" : true 
} 
sania@sania-vb:~$ curl -X DELETE 'http://localhost:9200/ind-2?pretty'  
{ 
  "acknowledged" : true 
} 
sania@sania-vb:~$ curl -X DELETE 'http://localhost:9200/ind-3?pretty'  
{ 
  "acknowledged" : true 
} 
```
  
  
## задача 3
  
директорию для бэкапов мы создали в /var/lib/elasticsearch/snapshots. регистрируем данную директорию как snapshot repository c именем netology_backup:
```
[root@a248d4e474f3 /]# echo path.repo: [ "/var/lib/elasticsearch/snapshots" ] >> "$ES_HOME/config/elasticsearch.yml" 
[root@a248d4e474f3 /]# chown elasticsearch:elasticsearch /var/lib/elasticsearch/snapshots 
[root@a248d4e474f3 /]# exit 
sania@sania-vb:~$ docker restart elastic 
elastic 
  
sania@sania-vb:~$ curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d' {"type": "fs", "settings": {"location": "/var/lib/elasticsearch/snapshots", "compress": true}}' 
{ 
  "acknowledged" : true 
} 
```
  
проверяем, что всё ок:
```
sania@sania-vb:/$ curl -X GET 'localhost:9200/_snapshot/netology_backup?pretty' 
{ 
  "netology_backup" : { 
    "type" : "fs", 
    "settings" : { 
      "compress" : "true", 
      "location" : "/var/lib/elasticsearch/snapshots" 
    } 
  } 
} 
```
  
создаём индекс test без реплик и 1 шардой:
```
sania@sania-vb:/$ curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d' {"settings": {"number_of_shards": 1, "number_of_replicas": 0}}' 
{ 
  "acknowledged" : true, 
  "shards_acknowledged" : true, 
  "index" : "test" 
} 
```
  
приводим список индексов:
```
sania@sania-vb:/$ curl 'localhost:9200/_cat/indices?v' 
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size 
green  open   test  NIoKi2RZQNejf3Dixc3d0w   1   0          0            0       225b           225b 
```
  
создаём snapshot состояния нашего кластера Elasticsearch:
```
sania@sania-vb:/$ curl -X PUT "localhost:9200/_snapshot/netology_backup/snapshot_1?wait_for_completion=true&pretty" 
{ 
  "snapshot" : { 
    "snapshot" : "snapshot_1", 
    "uuid" : "rVkwuXEAR-CF5xl0J99qsw", 
    "repository" : "netology_backup", 
    "version_id" : 8000199, 
    "version" : "8.0.1", 
    "indices" : [ 
      ".geoip_databases", 
      "test" 
    ], 
    "data_streams" : [ ], 
    "include_global_state" : true, 
    "state" : "SUCCESS", 
    "start_time" : "2022-03-19T18:46:21.912Z", 
    "start_time_in_millis" : 1647715581912, 
    "end_time" : "2022-03-19T18:46:23.112Z", 
    "end_time_in_millis" : 1647715583112, 
    "duration_in_millis" : 1200, 
    "failures" : [ ], 
    "shards" : { 
      "total" : 2, 
      "failed" : 0, 
      "successful" : 2 
    }, 
    "feature_states" : [ 
      { 
        "feature_name" : "geoip", 
        "indices" : [ 
          ".geoip_databases" 
        ] 
      } 
    ] 
  } 
} 
```
  
приводим список файлов в директории со снэпшотами:
```
sania@sania-vb:/$ docker exec -it elastic ls -l /var/lib/elasticsearch/snapshots/ 
total 36 
-rw-r--r-- 1 elasticsearch elasticsearch   843 Mar 19 18:46 index-0 
-rw-r--r-- 1 elasticsearch elasticsearch     8 Mar 19 18:46 index.latest 
drwxr-xr-x 4 elasticsearch elasticsearch  4096 Mar 19 18:46 indices 
-rw-r--r-- 1 elasticsearch elasticsearch 17522 Mar 19 18:46 meta-rVkwuXEAR-CF5xl0J99qsw.dat 
-rw-r--r-- 1 elasticsearch elasticsearch   354 Mar 19 18:46 snap-rVkwuXEAR-CF5xl0J99qsw.dat 
```
  
удаляем наш индекс test и создаём индекс test-2:
```
sania@sania-vb:/$ curl -X DELETE 'localhost:9200/test?pretty' 
{ 
  "acknowledged" : true 
} 
  
sania@sania-vb:/$ curl -X PUT localhost:9200/test-2?pretty -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}' 
{ 
  "acknowledged" : true, 
  "shards_acknowledged" : true, 
  "index" : "test-2" 
} 
```

проверяем, что выводится теперь по индексам:
```
sania@sania-vb:/$ curl 'localhost:9200/_cat/indices?pretty' 
green open test-2 94fSOMTVRKeWWvw4tpQH7g 1 0 0 0 225b 225b 
```

восстанавливаем состояние кластера elasticsearch из снэпшота, созданного ранее:
```
sania@sania-vb:/$ curl -X POST "localhost:9200/_snapshot/netology_backup/snapshot_1/_restore?pretty" -H 'Content-Type: application/json' -d' {"indices": "*", "include_global_state": true}' 
{ 
  "accepted" : true 
} 
```

проверяем индексы после восстановления:
```
sania@sania-vb:/$ curl 'localhost:9200/_cat/indices?pretty' 
green open test-2 94fSOMTVRKeWWvw4tpQH7g 1 0 0 0 225b 225b 
green open test   _jgQnGAXRhiyT8aChXvxqA 1 0 0 0 225b 225b 
```