# Домашнее задание к занятию "4.1. Командная оболочка Bash: Практические навыки"

## Обязательная задача 1

Есть скрипт:
```bash
a=1
b=2
c=a+b
d=$a+$b
e=$(($a+$b))
```

Какие значения переменным c,d,e будут присвоены? Почему?

| Переменная  | Значение | Обоснование |
| ------------- | ------------- | ------------- |
| `c`  | a+b  | указали текст, а не переменные |
| `d`  | 1+2  | bash преобразовал и вывел значения переменных, но не выполнил сложение, так как по умолчанию введённые значения - текстовые строки |
| `e`  | 3  | за счёт скобок выполнилась арифметическая операция сложения с преобразованными значениями переменных |


## Обязательная задача 2
На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным (после чего скрипт должен завершиться). В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на Жёстком Диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:
```bash
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	fi
done
```
1. не хватает закрывающей скобки в while;
2. нет проверки успешности выполнения, чтобы выйти из цикла!
3. возможно, нужно задать какой-то интервал для проверки, чтобы не забивался файл слишком быстро..

скрипт может выглядеть так:
```bash
while ((1==1)) #1
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	else exit #2
	fi
done
```

Необходимо написать скрипт, который проверяет доступность трёх IP: `192.168.0.1`, `173.194.222.113`, `87.250.250.242` по `80` порту и записывает результат в файл `log`. Проверять доступность необходимо пять раз для каждого узла.

### Ваш скрипт:
```bash
hosts=(192.168.0.1 173.194.222.113 87.250.250.24)
timeout=5
for i in {1..5}
do
date >>hosts.log
    for h in ${hosts[@]}
    do
	curl -s --connect-timeout $timeout $host:$port
        echo "    check" $h status=$? >>hosts.log
    done
done
```

sania@Sania-VB:~$ cat hosts.log  
Вт 14 дек 2021 22:01:16 MSK  
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=127  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=127  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=127  
Вт 14 дек 2021 22:01:16 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=127  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=127  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=127  
Вт 14 дек 2021 22:01:16 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=127  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=127  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=127  
Вт 14 дек 2021 22:01:16 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=127  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=127  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=127  
Вт 14 дек 2021 22:01:16 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=127  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=127  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=127  
Вт 14 дек 2021 22:06:06 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=127  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=127  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=127  
Вт 14 дек 2021 22:06:06 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=127  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=127  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=127  
Вт 14 дек 2021 22:06:06 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=127  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=127  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=127  
Вт 14 дек 2021 22:06:06 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=127  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=127  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=127  
Вт 14 дек 2021 22:06:06 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=127  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=127  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=127  
Вт 14 дек 2021 22:08:44 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=3  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=3  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=3  
Вт 14 дек 2021 22:08:44 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=3  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=3  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=3  
Вт 14 дек 2021 22:08:44 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=3  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=3  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=3  
Вт 14 дек 2021 22:08:44 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=3  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=3  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=3  
Вт 14 дек 2021 22:08:44 MSK  
&ensp;&ensp;&ensp;&ensp;check 192.168.0.1 status=3  
&ensp;&ensp;&ensp;&ensp;check 173.194.222.113 status=3  
&ensp;&ensp;&ensp;&ensp;check 87.250.250.24 status=3  

## Обязательная задача 3
Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается.

### Ваш скрипт:
```bash
hosts=(192.168.0.1 173.194.222.113 87.250.250.24)
timeout=5
res=0

while (($res == 0))
do
    for h in ${hosts[@]}
    do
	curl -s --connect-timeout $timeout $host:$port
	res=$?
	if (($res != 0))
	then
	    echo "    ERROR on " $h status=$res >>hosts_2.log
	fi
    done
done
```

sania@Sania-VB:~$ cat hosts_2.log  
&ensp;&ensp;&ensp;&ensp;ERROR on  192.168.0.1 status=3  
&ensp;&ensp;&ensp;&ensp;ERROR on  173.194.222.113 status=3  
&ensp;&ensp;&ensp;&ensp;ERROR on  87.250.250.24 status=3  