## DevOps-Netology
**Доработка по ДЗ "ОС 2"** 

дополнительные опции в службу можно передать через $OPTIONS, которые в свою очередь будут начитываться из файла параметров окружения, который мы также создадим:  
...  
[Service]  
User=node_exporter  
**EnvironmentFile=/etc/sysconfig/node_exporter**  
ExecStart=/usr/local/bin/node_exporter **$OPTIONS**  
...  

создаём этот файл для опций:  
>vagrant@vagrant: sudo mkdir -p /etc/sysconfig  
>vagrant@vagrant: sudo touch /etc/sysconfig/node_exporter  
  
и используем его для указания опций, например:  
>OPTIONS="_option_=_definition_"  
  
