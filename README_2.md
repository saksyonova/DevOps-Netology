## DevOps-Netology
**ДЗ "Компьютерные сети 3"** :whale2:  
  
1. подключаемся к публичному маршрутизатору:  
>route-views>show ip route 37.1.85.133  
Routing entry for 37.1.80.0/21  
Known via "bgp 6447", distance 20, metric 0  
Tag 3356, type external  
Last update from 4.68.4.46 1w3d ago  
Routing Descriptor Blocks:  
\* 4.68.4.46, from 4.68.4.46, 1w3d ago  
	Route metric is 0, traffic share count is 1  
	AS Hops 3  
	Route tag 3356  
	MPLS label: none  
  
show ip route выводит таблицу маршрутизатора роутера. состоит из списка всех сетей, которые доступны роутеру, их метрику (приоритет маршрутов) и шлюза.  

>route-views>show bgp 37.1.85.133/32  
  
очень большой вывод, нет смысла копировать.  
	
show bgp (border gateway protocol) выводит протокол динамической маршрутизации.  
  
2. dummy — это локальный интерфейс-затычка для некоторых специальных задач.  
  
чтобы модуль автоматически запускался при старте системы, добавим в файл /etc/modules строку dummy:  
>echo "dummy" >> /etc/modules  
  
а чтобы создался интерфейс, нужно добавить конфигу:  
>sudo -i  
>echo "options dummy numdummies=2" > /etc/modbrobe.d/dummy.conf  
  
устанавливаем статический IP-адрес в /etc/network/interfaces:  
>sudo vim /etc/network/interfaces  
auto dummy0  
iface dummy0 inet static  
address 10.2.2.2/32  
pre-up ip link add dummy0 type dummy  
post-down ip link del dummy0  

добавляем адрес в интерфейс:  
>sudo ip addr add 192.168.1.150/24 dev dummy0  
  
проверяем таблицу маршрутизации:  
>sania@Sania-VB:~$ netstat -r  
Kernel IP routing table  
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface  
default         _gateway        0.0.0.0         UG        0 0          0 enp0s3  
10.0.2.0        0.0.0.0         255.255.255.0   U         0 0          0 enp0s3  
link-local      0.0.0.0         255.255.0.0     U         0 0          0 enp0s3  
192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 dummy0  
  
3. открытые TCP-соединения:  
>sania@Sania-VB:~$ ss -tl
State   Recv-Q  Send-Q     Local Address:Port       Peer Address:Port  Process  
LISTEN  0       4096       127.0.0.53%lo:domain          0.0.0.0:*              
LISTEN  0       5              127.0.0.1:ipp             0.0.0.0:*              
LISTEN  0       5                  [::1]:ipp                [::]:* 
  
видимо, никакие процессы сейчас не используют эти порты.  
  
4. используемые UDP сокеты:  
>sania@Sania-VB:~$ ss -lu  
State   Recv-Q  Send-Q     Local Address:Port       Peer Address:Port  Process    
UNCONN  0       0          127.0.0.53%lo:domain          0.0.0.0:*                
UNCONN  0       0                0.0.0.0:33169           0.0.0.0:*                
UNCONN  0       0                0.0.0.0:631             0.0.0.0:*                
UNCONN  0       0                0.0.0.0:mdns            0.0.0.0:*                
UNCONN  0       0                   [::]:53180              [::]:*                
UNCONN  0       0                   [::]:mdns               [::]:*    
  
кажется, никакие процессы сейчас также не используют и эти порты.  
  
5. модель OSI:  
L1 – физический уровень (провода и коммутация);  
L2 – уровень физической адресации (mac-адреса);  
L3 – уровень логической адресации (IP-адреса).  

схемку набросала по статье на хабре https://habr.com/ru/post/134892/:
![L3 scheme](https://i.ibb.co/ggKf0WF/L3-scheme.png)
