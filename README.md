## DevOps-Netology
**ДЗ "ОС 2"** *(наконец-то изучила синтаксис md-файлов! :whale2:)*

1. сервис стартует и перезапускается без проблем:

>vagrant@vagrant:/tmp$ ps -e | grep node_exporter
>   4859 ?        00:00:00 node_exporter


vagrant@vagrant:/tmp$ systemctl stop node_exporter
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to stop 'node_exporter.service'.
Authenticating as: vagrant,,, (vagrant)
Password:
==== AUTHENTICATION COMPLETE ===
'''
'''
vagrant@vagrant:/tmp$ ps -e | grep node_exporter
'''
'''
vagrant@vagrant:/tmp$ systemctl start node_exporter
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to start 'node_exporter.service'.
Authenticating as: vagrant,,, (vagrant)
Password:
==== AUTHENTICATION COMPLETE ===
'''
'''
vagrant@vagrant:/tmp$ ps -e | grep node_exporter
   4923 ?        00:00:00 node_exporter
'''
'''
vagrant@vagrant:/tmp$ systemctl restart node_exporter
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ===
Authentication is required to restart 'node_exporter.service'.
Authenticating as: vagrant,,, (vagrant)
Password:
==== AUTHENTICATION COMPLETE ===
'''
'''
vagrant@vagrant:/tmp$ ps -e | grep node_exporter
   4955 ?        00:00:00 node_exporter
'''

создан конфигурационный файл node_exporter.service:
'''
vagrant@vagrant:/etc/systemd/system$ cat /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
vagrant@vagrant:/etc/systemd/system$
'''

2. знакомимся с опциями node_exporter и выводом /metrics:

CPU: curl http://localhost:9100/metrics | grep cpu 
	node_cpu_seconds_total{cpu="0",mode="idle"} 24627.48
	node_cpu_seconds_total{cpu="0",mode="iowait"} 7.59
	node_cpu_seconds_total{cpu="0",mode="system"} 24.14
	node_cpu_seconds_total{cpu="0",mode="user"} 47.87
		
	node_cpu_seconds_total{cpu="1",mode="idle"} 24609.03
	node_cpu_seconds_total{cpu="1",mode="iowait"} 5.51
	node_cpu_seconds_total{cpu="1",mode="system"} 22.7
	node_cpu_seconds_total{cpu="1",mode="user"} 53

		
	process_cpu_seconds_total 0.21

memory: curl http://localhost:9100/metrics | grep memory
	node_memory_MemAvailable_bytes 7.06052096e+08
	node_memory_MemFree_bytes 1.8579456e+08
	node_memory_MemTotal_bytes 1.028694016e+09
		
disk (их несколько, выбрали sda): curl http://localhost:9100/metrics | grep disk
	node_disk_io_time_seconds_total{device="sda"} 27.056
	node_disk_read_time_seconds_total{device="sda"} 6.684
	node_disk_write_time_seconds_total{device="sda"} 56.715
		
network: curl http://localhost:9100/metrics | grep network
	node_network_receive_errs_total{device="eth0"} 0
	node_network_receive_errs_total{device="lo"} 0
	
	node_network_receive_packets_total{device="eth0"} 53189
	node_network_receive_packets_total{device="lo"} 313
	
	node_network_transmit_bytes_total{device="eth0"} 1.83348e+06
	node_network_transmit_bytes_total{device="lo"} 383553
	
	node_network_transmit_errs_total{device="eth0"} 0
	node_network_transmit_errs_total{device="lo"} 0

3. после всей настройки проверяем статус, метрики изучены:
	vagrant@vagrant:~$ netstat -ap | grep 19999
	(Not all processes could be identified, non-owned process info
	 will not be shown, you would have to be root to see it all.)
	tcp        0      0 0.0.0.0:19999           0.0.0.0:*               LISTEN      -
	tcp6       0      0 [::]:19999              [::]:*                  LISTEN      -

4. да, можно:
vagrant@vagrant:~$ dmesg | grep virtual
[    0.003610] CPU MTRRs all blank - virtualized system.
[    0.103912] Booting paravirtualized kernel on KVM
[    3.173605] systemd[1]: Detected virtualization oracle.

5. 
vagrant@vagrant:~$ /sbin/sysctl -n fs.nr_open
1048576
это максимальное число открытых дескрипторов для системы.

общесистемное ограничение на количество открытых файлов для всех процессов можно узнать так:
vagrant@vagrant:~$ cat /proc/sys/fs/file-max
9223372036854775807

vagrant@vagrant:~$ ulimit -Hn
1048576
это жёсткий лимит на пользователя, не может быть увеличен, только уменьшен.

6. запускаем sleep:
root@vagrant:~$ sleep 10m

в другой сессии выполняем:
root@vagrant:~# ps -e | grep sleep
   3062 pts/2    00:00:00 sleep
root@vagrant:~# nsenter --target 3062 --pid --mount
root@vagrant:/# ps
    PID TTY          TIME CMD
   3046 pts/1    00:00:00 sudo
   3048 pts/1    00:00:00 bash
   3066 pts/1    00:00:00 nsenter
   3067 pts/1    00:00:00 bash
   3076 pts/1    00:00:00 ps

7. команда :(){ :|:& };: породит процессы kernel до смерти: 
определяется функция с именем : , которая вызывает себя дважды (код: : | : ).
и всё это происходит в фоновом режиме ( & ). 
после ; определение функции выполнено, и функция : запускается.
таким образом, каждый экземпляр : начинает два новых : и так далее.

система в пользовательской зоне ресурсов имеет определённое ограничение на создаваемые ресурсы,
поэтому при превышении начинает блокировать процессы. 

но если установить ulimit -u 50, то число процессов будет ограниченно до 50 для пользователя. 