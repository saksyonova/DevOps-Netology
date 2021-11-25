## DevOps-Netology
**ДЗ "Файловые системы"** :whale2:

1. разрежённые файлы используются для сжатия данных на уровне ФС (экономия дискового пространства). 

2. из лекции стало понятно, что hardlink - это, по сути, ссылка на один и тот же файл, имеет один и тот же inode, соответственно, одни и те же права доступа и владельца. НО, наверно, если, к примеру, 2 файла, имеющих hl, лежат в разных директориях, на одну из которых есть ограничение прав доступа, то файл, лежащий под ограничениями может быть недоступен, в то время как в доступном каталоге - всё ок.

3. подняли новый инстанс по указанному содержимому Vagrantfile:  
>vagrant@vagrant:~$ lsblk  
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT  
sda                    8:0    0   64G  0 disk  
├─sda1                 8:1    0  512M  0 part /boot/efi  
├─sda2                 8:2    0    1K  0 part  
└─sda5                 8:5    0 63.5G  0 part  
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /  
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]  
sdb                    8:16   0  2.5G  0 disk  
sdc                    8:32   0  2.5G  0 disk  
  
4. разбиваем под рутом первый диск на 2 раздела (2 гига и оставшееся пространство):  
>fdisk /dev/sdb  
...  
Device     Boot   Start     End Sectors  Size Id Type  
/dev/sdb1          2048 4196351 4194304    2G 83 Linux  
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux  
  
5. используя sfdisk, пробуем перенести данную таблицу разделов на второй диск:  
>root@vagrant:~# sfdisk -d /dev/sdb | sfdisk --force /dev/sdc  
Checking that no-one is using this disk right now ... OK  
...
Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors  
Disk model: VBOX HARDDISK  
Units: sectors of 1 * 512 = 512 bytes  
Sector size (logical/physical): 512 bytes / 512 bytes  
I/O size (minimum/optimal): 512 bytes / 512 bytes  
...
>>> Script header accepted.  
>>> Script header accepted.  
>>> Script header accepted.  
>>> Script header accepted.  
>>> Created a new DOS disklabel with disk identifier 0xdbec7206.  
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.  
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.  
/dev/sdc3: Done.  
...
New situation:  
Disklabel type: dos  
Disk identifier: 0xdbec7206  
...
Device     Boot   Start     End Sectors  Size Id Type  
/dev/sdc1          2048 4196351 4194304    2G 83 Linux  
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux  
...
The partition table has been altered.  
Calling ioctl() to re-read partition table.  
Syncing disks.  
    
проверяем результат:  
>root@vagrant:~# /sbin/fdisk -l /dev/sdb  
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors  
Disk model: VBOX HARDDISK  
Units: sectors of 1 * 512 = 512 bytes  
Sector size (logical/physical): 512 bytes / 512 bytes  
I/O size (minimum/optimal): 512 bytes / 512 bytes  
Disklabel type: dos  
Disk identifier: 0xdbec7206  
...
Device     Boot   Start     End Sectors  Size Id Type  
/dev/sdb1          2048 4196351 4194304    2G 83 Linux  
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux  
  
>root@vagrant:~# /sbin/fdisk -l /dev/sdc  
Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors  
Disk model: VBOX HARDDISK  
Units: sectors of 1 * 512 = 512 bytes  
Sector size (logical/physical): 512 bytes / 512 bytes  
I/O size (minimum/optimal): 512 bytes / 512 bytes  
Disklabel type: dos  
Disk identifier: 0xdbec7206  
...
Device     Boot   Start     End Sectors  Size Id Type  
/dev/sdc1          2048 4196351 4194304    2G 83 Linux  
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux  
  
6. собираем через mdadm RAID1 на паре разделов, которые по 2 гига:  
>root@vagrant:~# mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sd{b1,c1}  
mdadm: Note: this array has metadata at the start and  
    may not be suitable as a boot device.  If you plan to  
    store '/boot' on this device please ensure that  
    your boot-loader understands md/v1.x metadata, or use  
    --metadata=0.90  
mdadm: size set to 2094080K  
Continue creating array? y  
mdadm: Defaulting to version 1.2 metadata  
mdadm: array /dev/md1 started.  
  
7. собираем через mdadm RAID0 на второй паре маленьких разделов:  
>root@vagrant:~# mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{b2,c2}  
mdadm: Note: this array has metadata at the start and  
    may not be suitable as a boot device.  If you plan to  
    store '/boot' on this device please ensure that  
    your boot-loader understands md/v1.x metadata, or use  
    --metadata=0.90  
mdadm: size set to 522240K  
Continue creating array? y  
mdadm: Defaulting to version 1.2 metadata  
mdadm: array /dev/md0 started.  
  
проверяем, что получилось:  
>root@vagrant:~# lsblk  
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT  
sda                    8:0    0   64G  0 disk  
├─sda1                 8:1    0  512M  0 part  /boot/efi  
├─sda2                 8:2    0    1K  0 part  
└─sda5                 8:5    0 63.5G  0 part  
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /  
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]  
sdb                    8:16   0  2.5G  0 disk  
├─sdb1                 8:17   0    2G  0 part  
│ └─md1                9:1    0    2G  0 raid1  
└─sdb2                 8:18   0  511M  0 part  
  └─md0                9:0    0  510M  0 raid1  
sdc                    8:32   0  2.5G  0 disk  
├─sdc1                 8:33   0    2G  0 part  
│ └─md1                9:1    0    2G  0 raid1  
└─sdc2                 8:34   0  511M  0 part  
  └─md0                9:0    0  510M  0 raid1  
  
8. создаём 2 независимых PV на получившихся md-устройствах:  
>root@vagrant:~# pvcreate /dev/md1 /dev/md0  
  Physical volume "/dev/md1" successfully created.  
  Physical volume "/dev/md0" successfully created.  
  
9. создаём общую volume-группу на этих двух PV:  
>root@vagrant:~# vgcreate vg1 /dev/md1 /dev/md0  
  Volume group "vg1" successfully created  
    
проверяем:  
> root@vagrant:~# vgdisplay  
  --- Volume group ---  
  VG Name               vgvagrant  
  System ID  
  Format                lvm2  
  Metadata Areas        1  
  Metadata Sequence No  3  
  VG Access             read/write  
  VG Status             resizable  
  MAX LV                0  
  Cur LV                2  
  Open LV               2  
  Max PV                0  
  Cur PV                1  
  Act PV                1  
  VG Size               <63.50 GiB  
  PE Size               4.00 MiB  
  Total PE              16255  
  Alloc PE / Size       16255 / <63.50 GiB  
  Free  PE / Size       0 / 0  
  VG UUID               PaBfZ0-3I0c-iIdl-uXKt-JL4K-f4tT-kzfcyE  
...
  --- Volume group ---  
  VG Name               vg1  
  System ID  
  Format                lvm2  
  Metadata Areas        2  
  Metadata Sequence No  1  
  VG Access             read/write  
  VG Status             resizable  
  MAX LV                0  
  Cur LV                0  
  Open LV               0  
  Max PV                0  
  Cur PV                2  
  Act PV                2  
  VG Size               2.49 GiB  
  PE Size               4.00 MiB  
  Total PE              638  
  Alloc PE / Size       0 / 0  
  Free  PE / Size       638 / 2.49 GiB  
  VG UUID               6Y89n3-ACvQ-fOoW-Wbs1-CelW-6BS5-Xzery7  
  
10. создаём LV, размером 100 мб, указав его расположение на PV с RAID0:  
>root@vagrant:~# lvcreate -L 100M vg1 /dev/md0  
  Logical volume "lvol0" created.  
  
проверяем:  
>root@vagrant:~# vgs  
  VG        #PV #LV #SN Attr   VSize   VFree  
  vg1         2   1   0 wz--n-   2.49g 2.39g  
  vgvagrant   1   2   0 wz--n- <63.50g    0  
  
>root@vagrant:~# lvs  
  LV     VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert  
  lvol0  vg1       -wi-a----- 100.00m  
  root   vgvagrant -wi-ao---- <62.54g  
  swap_1 vgvagrant -wi-ao---- 980.00m  
  
11. создаём mkfs.ext4 ФС на получившемся LV:  
>root@vagrant:~# mkfs.ext4 /dev/vg1/lvol0  
mke2fs 1.45.5 (07-Jan-2020)  
Creating filesystem with 25600 4k blocks and 25600 inodes  
...
Allocating group tables: done  
Writing inode tables: done  
Creating journal (1024 blocks): done  
Writing superblocks and filesystem accounting information: done  
  
12. монтируем этот раздел в директорию /tmp/new. сначала создаём эту директорию:  
>root@vagrant:~# mkdir /tmp/new  
  
затем монтируем:  
>root@vagrant:~# mount /dev/vg1/lvol0 /tmp/new  
  
13. помещаем туда тестовый файл:  
>root@vagrant:~# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz  
--2021-11-25 19:25:10--  https://mirror.yandex.ru/ubuntu/ls-lR.gz  
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183  
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.  
HTTP request sent, awaiting response... 200 OK  
Length: 22581153 (22M) [application/octet-stream]  
Saving to: ‘/tmp/new/test.gz’  
...
/tmp/new/test.gz         100%[==================================>]  21.53M  3.05MB/s    in 6.6s  
...
2021-11-25 19:25:17 (3.25 MB/s) - ‘/tmp/new/test.gz’ saved [22581153/22581153]  
  
14. итоговый вывод lsblk:  
>root@vagrant:~# lsblk  
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT  
sda                    8:0    0   64G  0 disk  
├─sda1                 8:1    0  512M  0 part  /boot/efi  
├─sda2                 8:2    0    1K  0 part  
└─sda5                 8:5    0 63.5G  0 part  
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /  
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]  
sdb                    8:16   0  2.5G  0 disk  
├─sdb1                 8:17   0    2G  0 part  
│ └─md1                9:1    0    2G  0 raid1  
└─sdb2                 8:18   0  511M  0 part  
  └─md0                9:0    0  510M  0 raid1  
    └─vg1-lvol0      253:2    0  100M  0 lvm   /tmp/new  
sdc                    8:32   0  2.5G  0 disk  
├─sdc1                 8:33   0    2G  0 part  
│ └─md1                9:1    0    2G  0 raid1  
└─sdc2                 8:34   0  511M  0 part  
  └─md0                9:0    0  510M  0 raid1  
    └─vg1-lvol0      253:2    0  100M  0 lvm   /tmp/new  
  
15. тестируем целостность файла:  
>root@vagrant: # gzip -t /tmp/new/test.gz  
root@vagrant: # echo $?  
0  
  
16. используя pvmove, перемещаем содержимое PV с RAID0 на RAID1:  
>root@vagrant:~# pvmove /dev/md0  
  /dev/md0: Moved: 28.00%  
  /dev/md0: Moved: 100.00%  
  
17. делаем --fail на устройство в нашем RAID1 md:  
>root@vagrant:~# mdadm /dev/md1 --fail /dev/sdb1  
mdadm: set /dev/sdb1 faulty in /dev/md1  
  
>root@vagrant:~# mdadm -D /dev/md1  
/dev/md1:  
           Version : 1.2  
     Creation Time : Thu Nov 25 18:53:57 2021  
        Raid Level : raid1  
        Array Size : 2094080 (2045.00 MiB 2144.34 MB)  
     Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)  
      Raid Devices : 2  
     Total Devices : 2  
       Persistence : Superblock is persistent  
... 
       Update Time : Thu Nov 25 19:34:13 2021  
             State : clean, degraded  
    Active Devices : 1  
   Working Devices : 1  
    Failed Devices : 1  
     Spare Devices : 0  
... 
Consistency Policy : resync  
  
              Name : vagrant:1  (local to host vagrant)  
              UUID : 5f778c03:03c9fa1f:76ba81a9:930cfa2a  
            Events : 19  
...
    Number   Major   Minor   RaidDevice State  
       -       0        0        0      removed  
       1       8       33        1      active sync   /dev/sdc1  
       0       8       17        -      faulty   /dev/sdb1  

18. убеждаемся через вывод dmesg, что RAID1 работает в деградированном состоянии:
>root@vagrant:~# dmesg | grep md1  
[ 1384.970804] md/raid1:md1: not clean -- starting background reconstruction  
[ 1384.970806] md/raid1:md1: active with 2 out of 2 mirrors  
[ 1384.970831] md1: detected capacity change from 0 to 2144337920  
[ 1384.975472] md: resync of RAID array md1  
[ 1395.447905] md: md1: resync done.  
[ 3800.592011] md/raid1:md1: Disk failure on sdb1, disabling device.  
               md/raid1:md1: Operation continuing on 1 devices.  
  
19. тестируем целостность файла, несмотря на "сбойный" диск он должен быть доступен:  
>root@vagrant: # gzip -t /tmp/new/test.gz  
root@vagrant: # echo $?  
0  
  
20. гасим тестовый хост:  
>PS C:\Users\skuznetsova> vagrant destroy  
    default: Are you sure you want to destroy the 'default' VM? [y/N] y  
==> default: Forcing shutdown of VM...  
==> default: Destroying VM and associated drives...  
