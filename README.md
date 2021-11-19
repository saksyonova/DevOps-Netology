# DevOps-Netology
ДЗ "ОС 1":

1. 	vagrant@vagrant:~$ strace /bin/bash -c 'cd /tmp'

-с - подсчитывает кол-во ошибок, вызовов и времени выполнения для каждого системного вызова
	
	...
chdir("/tmp")

2. команда file позволяет узнать тип данных, которые на самом деле содержатся внутри документа.

vagrant@vagrant:~$ strace filestrace file
...
/usr/share/misc/magic.mgc - база типов.

3. пробуем отредактировать, а затем удалить существующий в /home/vagrant файлик tmp.txt:
vagrant@vagrant:~$ rm -fr tmp.txt
	
проверяем его в процессах через lsof:
vagrant@vagrant:~$ lsof | grep tmp.txt
	cat     2589      vagrant     1w     REG     253,0     47     131094     /home/vagrant/tmp.txt (deleted)

нам нужен PID (2589) и файловый дескриптор (1w) процесса cat
	
пробуем обнулить открытый удалённый файл:
vagrant@vagrant:~$ echo '' >/proc/2589/fd/1

4. 	зомби - это фантомный процесс, который просто имеет запись в таблице процессов, но при этом никакие ресурсы, кроме пространства таблицы процессов, не используются.

5. устанавливаем утилиту opensnoop (нужна для трассировки):
vagrant@vagrant:~$ sudo apt-get update
vagrant@vagrant:~$ sudo apt-get install bpfcc-tools
	
выполняем:
vagrant@vagrant:~$ dpkg -L bpfcc-tools | grep sbin/opensnoop
/usr/sbin/opensnoop-bpfcc

переключаемся на рута и выполняем:
root@vagrant:~# /usr/sbin/opensnoop-bpfcc
PID    COMM               FD ERR PATH
393    systemd-udevd      14   0 /sys/fs/cgroup/unified/system.slice/systemd-udevd.service/cgroup.procs
393    systemd-udevd      14   0 /sys/fs/cgroup/unified/system.slice/systemd-udevd.service/cgroup.threads
1      systemd            21   0 /proc/398/cgroup
802    vminfo              4   0 /var/run/utmp
584    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
584    dbus-daemon        18   0 /usr/share/dbus-1/system-services
584    dbus-daemon        -1   2 /lib/dbus-1/system-services
…

6. команда uname отображает системную инфу, включая архитектуру ядра Linux, версию имени и выпуск:
vagrant@vagrant:~$ uname -a
Linux vagrant 5.4.0-80-generic #90-Ubuntu SMP Fri Jul 9 22:49:44 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux

цитата из мана:
NOTES
…
Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}. 

7. ; - разделитель последовательных команд;
&& - используется для объединения команд таким образом, что следующая команда запускается только когда предыдущая команда завершилась без ошибок (с кодом возврата 0).
	test -d /tmp/some_dir; echo Hi - команда test не выполняется, поэтому следом выполняется команда echo;

	test -d /tmp/some_dir && echo Hi - команда test не выполняется, следовательно, не выполняется и команда echo.
		

set -e прерывает выполнение, если команда имеет ненулевой статус.

"&&" использовать вместе с "set -e", кажется, не имеет смысла.

8. vagrant@vagrant:~$ help set
	-e - прерывает выполнение, если команда имеет ненулевой статус;
	-u - не установленные/не заданные параметры и переменные считаются ошибками, будут записаны как стандартные ошибки, неинтерактивный вызов завершится;
	-x - вывод команд и аргументов по мере их выполнения;
	-o - опция - pipefail - устанавливает код выхода из конвейера равным таковому для самой верной команды для выхода с ненулевым статусом или равным нулю, если все команды конвейера завершаются успешно.
		
При использовании для сценариев повышается детализация вывода ошибок (логирование). При наличии ошибок завершит сценарий на любом этапе, кроме последней завершающей команды.

9. vagrant@vagrant:~$ ps -o stat
Ss
R+

Ss - ожидающие завершения, спящие с прерыванием "сна";
R+ - текущие активные процессы в фоновой группе.
