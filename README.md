# курсовая работа по итогам модуля "DevOps и системное администрирование"

## создаём свеженькую ВМ, устанавливаем и настраиваем ufw

ufw был в составе основных пакетов при разворачивании Ubuntu 20.04, поэтому просто проверяем его статус:
```
sanny@Sania-VB:~$ sudo ufw status
Status: inactive 
```

включаем его:
```
sanny@Sania-VB:~$ sudo ufw enable
Firewall is active and enabled on system startup
```

разрешаем входящие и исходящие подключения:
```
sanny@Sania-VB:~$ sudo ufw default allow incoming
Default incoming policy changed to 'allow'
(be sure to update your rules accordingly)

sanny@Sania-VB:~$ sudo ufw default allow outgoing
Default outgoing policy changed to 'allow'
(be sure to update your rules accordingly)
```

разрешаем подключения по SSH (на всякий случай), HTTP и HTTPS:
```
sanny@Sania-VB:~$ sudo ufw allow ssh
#ИЛИ можно использовать sudo ufw allow 22
Rule added
Rule added (v6)

sanny@Sania-VB:~$ sudo ufw allow http
#ИЛИ можно использовать sudo ufw allow 80
Rule added
Rule added (v6)

sanny@Sania-VB:~$ sudo ufw allow https
#ИЛИ можно использовать sudo ufw allow 443
Rule added
Rule added (v6)
```

проверяем созданные правила:
```
sanny@Sania-VB:~$ sudo ufw status verbose

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
22                         ALLOW IN    Anywhere
443                        ALLOW IN    Anywhere
443/tcp (Nginx HTTPS)      ALLOW IN    Anywhere
80/tcp (Nginx HTTP)        ALLOW IN    Anywhere
22/tcp (v6)                ALLOW IN    Anywhere (v6)
22 (v6)                    ALLOW IN    Anywhere (v6)
443 (v6)                   ALLOW IN    Anywhere (v6)
443/tcp (Nginx HTTPS (v6)) ALLOW IN    Anywhere (v6)
80/tcp (Nginx HTTP (v6))   ALLOW IN    Anywhere (v6)
```


## устанавливаем HashiCorp Vault и выпускаем сертификат, который будем использовать далее при настройке веб-сервера nginx

перед установкой HashiCorp добавляем сначала ключ GPG:

```
sanny@Sania-VB:~$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
OK
```

добавляем официальный репозиторий ХашиКорпа:
```
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) mai
```

обновляемся и устанавливаем само хранилище:
```
sanny@Sania-VB:~$ sudo apt-get update && sudo apt-get install vault
…
Unpacking vault (1.9.2) ...
Setting up vault (1.9.2) ...
Generating Vault TLS key and self-signed certificate...
Generating a RSA private key
........++++
.................++++
writing new private key to 'tls.key'
-----
Vault TLS key and self-signed certificate have been generated in '/opt/vault/tls'.
```

проверяем на запуск командой vault - всё ок.

выпускаем сертификат.

запускаем хранилище в одном терминальном окне:
```
sanny@Sania-VB:~$ vault server -dev -dev-root-token-id root
…
==> Vault server started! Log data will stream in below:

Unseal Key: broutcMiN0tyzpUwiagDAQmunTjp8uhEXeBNJjOIiEI=
Root Token: root
```

в другом терминальном окошке экспортируем переменные для корректной работы хранилища:
```
sanny@Sania-VB:~$ export VAULT_ADDR=http://127.0.0.1:8200
sanny@Sania-VB:~$ export VAULT_TOKEN=root
```

всё готово к использованию хранилища в dev-режиме.

активируем PKI тип секрета для корневого центра сертификации:
```
sanny@Sania-VB:~$ vault secrets enable pki
Success! Enabled the pki secrets engine at: pki/
```

настраиваем время действия выпускаемых сертификаторв на 1 месяц (744 часа):
```
sanny@Sania-VB:~$ vault secrets tune -max-lease-ttl=744h pki
Success! Tuned the secrets engine at: pki/
```

генерим самоподписанный сертификат (называем его CA_cert.crt). хранилище, по идее, автоматом должно отозвать его как только истечёт время действия:
```
sanny@Sania-VB:~$ vault write -field=certificate pki/root/generate/internal \
common_name="example.com" \
ttl=744h > CA_cert.crt
```

настраиваем URL-ы для корневого центра сертификации:
```
sanny@Sania-VB:~$ vault write pki/config/urls \
issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
Success! Data written to: pki/config/urls
```

теперь генерим и настраиваем промежуточный центр сертификации. также сначала активируем PKI тип секрета для него:
```
sanny@Sania-VB:~$ vault secrets enable -path=pki_int pki
Success! Enabled the pki secrets engine at: pki_int/
```

также настраиваем срок его действия (1 месяц):
```
sanny@Sania-VB:~$ vault secrets tune -max-lease-ttl=744h pki_int
Success! Tuned the secrets engine at: pki_int/
```

генерим и сохраняем промежуточный сертификат как pki_intermediate.csr:
```
sanny@Sania-VB:~$ vault write -format=json pki_int/intermediate/generate/internal \
common_name="example.com Intermediate Authority" \
| jq -r '.data.csr' > pki_intermediate.csr
```

подписываем этот промежуточный сертификат нашим рутовым ЦС ключом и сохраняем его как intermediate.cert.pem:
```
sanny@Sania-VB:~$ vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
format=pem_bundle ttl="43800h" \
| jq -r '.data.certificate' > intermediate.cert.pem
```

как только CRS подписан и рутовый ЦС возвращает нам сертификат, мы можем испортировать его обратно в хранилище:
```
sanny@Sania-VB:~$ vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
Success! Data written to: pki_int/intermediate/set-signed
```

сам получившийся сертификат (дата в формате США: ММ/ДД/ГГГГ):
![рутовый сертификат](https://i.ibb.co/0XgDtd1/1.png)

копируем его в /usr/local/share/ca-certificates:
```
sanny@Sania-VB:~$ sudo cp CA_cert.crt /usr/local/share/ca-certificates/
```

запускаем команду для обновления общесистемного списка сертификатов:
```
sanny@Sania-VB:~$ sudo update-ca-certificates
Updating certificates in /etc/ssl/certs...
1 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
```

создаём роль, которая позволит нам управлять сертификатами:
```
sanny@Sania-VB:~$ vault write pki_int/roles/example-dot-com \
allowed_domains="example.com" \
allow_subdomains=true \
max_ttl="744h"
Success! Data written to: pki_int/roles/example-dot-com
```

делаем запрос распечатки сертификата:
```
sanny@Sania-VB:~$ vault write pki_int/issue/example-dot-com common_name="test.example.com" ttl="24h"
```

получаем целое полотно, из которого берём значения ca_chain + issuing_ca + certificate, сохраняем их, например, в my_certificate.crt в /etc/ssl/. а значение private key сохраняем в отдельный файл private.key.

испортируем сертификат в список доверенных в самом браузере.


## ставим и настраиваем nginx, а потом в браузере хоста убеждаемся, что нет никаких предупреждений о какой-либо опасности

устанавливаем nginx:
```
sanny@Sania-VB:~$ sudo apt update && sudo apt install nginx
```

проверяем список конфигураций приложений, которые известны ufw:
```
sanny@Sania-VB:~$ sudo ufw app list
Available applications:
	CUPS
	Nginx Full
	Nginx HTTP
	Nginx HTTPS
```
*Nginx Full - этот профиль открывает порт 80 (обычный веб-трафик без шифрования) и порт 443 (трафик с шифрованием TLS/SSL);*  
*Nginx HTTP - этот профиль открывает только порт 80;*  
*Nginx HTPPS - этот открывает только порт 443;*  

проверяем работу службы nginx:
```
sanny@Sania-VB:~$ systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
	Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
	Active: **active (running)** since Thu 2022-01-06 23:22:40 MSK; 5min ago
		Docs: man:nginx(8)
	Main PID: 13660 (nginx)
		Tasks: 2 (limit: 5840)
		Memory: 2.9M
		CGroup: /system.slice/nginx.service
		             ├─13660 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
		             └─13661 nginx: worker process
		
		Jan 06 23:22:40 Sania-VB systemd[1]: Starting A high performance web server and a reverse proxy serv>
		Jan 06 23:22:40 Sania-VB systemd[1]: Started A high performance web server and a reverse proxy serve>
lines 1-13/13 (END)
```

находим файлик конфигурации nginx.conf в /etc/nginx, добавляем туда следующие строки в секцию http:
```
sanny@Sania-VB:~$ sudo vim nginx.conf
	server {
		
    listen 443 ssl;
	
    server_name test.example.com;
    ssl_certificate /etc/ssl/my_certificate.crt;
    ssl_certificate_key /etc/ssl/private.key;
	}
```

в /etc/hosts также добавляем запись:
```
...
10.0.2.15	test.example.com
```

перезапускаем nginx (system reload nginx), открываем браузер, переходим на https-адрес страницы, которую обслуживает сервер nginx:
https://test.example.com/

браузер не выдаёт никаких сообщений о "неподходящем" сертификате, всё ок:
![скрин браузера без предупреждений](https://i.ibb.co/XWNpZS5/3.png)


## создаём скрипт для генерации нового сертификата в хранилище и помещаем его в crontab для автоматического запуска этой задачи

запускаем cron:
```
sanny@Sania-VB:~$ sudo systemctl enable cron
Synchronizing state of cron.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable cron
```

задачи в cron записываются и управляются в /var/spool/cron/crontabs/, пока там пусто. 

сначала создаём bash-скрипт в /usr/local/bin/ по автоматическому обновлению сертификата (под рутом):
```
sanny@Sania-VB:/usr/local/bin$ cat script.sh
#!/bin/bash
echo $(date) >> /usr/local/bin/testcron.log

SHELL=/bin/bash
export_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root

vault write -format=json pki_int/issue/example-dot-com common_name="test.example.com" ttl="500h" > /etc/ssl/website.crt

cat /etc/ssl/website.crt | jq -r .data.certificate > /etc/ssl/website.crt.pem

cat /etc/ssl/website.crt | jq -r .data.ca_chain[] >> /etc/ssl/website.crt.pem

cat /etc/ssl/website.crt | jq -r .data.private_key > /etc/ssl/website.key
```

добавляем задание в cron, которое будет каждую минуту выполнять скрипт выше:
```
sanny@Sania-VB:~$ crontab -e                   
#each minute cert renewal
* * * * * /usr/local/bin/script.sh
```

проверяем, что cron отрабатывает:
```
sanny@Sania-VB:~$ cat /var/log/syslog | grep CRON

...
Jan  7 20:23:01 Sania-VB CRON[6290]: (root) CMD (/usr/local/bin/script.sh)
Jan  7 20:23:01 Sania-VB CRON[6289]: (CRON) info (No MTA installed, discarding output)
Jan  7 20:24:01 Sania-VB CRON[6314]: (root) CMD (/usr/local/bin/script.sh)
Jan  7 20:24:01 Sania-VB CRON[6313]: (CRON) info (No MTA installed, discarding output)
Jan  7 20:25:01 Sania-VB CRON[6326]: (root) CMD (/usr/local/bin/script.sh)
Jan  7 20:25:01 Sania-VB CRON[6325]: (CRON) info (No MTA installed, discarding output)
Jan  7 20:26:01 Sania-VB CRON[6341]: (root) CMD (/usr/local/bin/script.sh)
Jan  7 20:26:02 Sania-VB CRON[6340]: (CRON) info (No MTA installed, discarding output)
Jan  7 20:27:01 Sania-VB CRON[6364]: (root) CMD (/usr/local/bin/script.sh)
Jan  7 20:27:01 Sania-VB CRON[6363]: (CRON) info (No MTA installed, discarding output)
Jan  7 20:28:01 Sania-VB CRON[6377]: (root) CMD (/usr/local/bin/script.sh)
Jan  7 20:28:01 Sania-VB CRON[6376]: (CRON) info (No MTA installed, discarding output)
Jan  7 20:29:01 Sania-VB CRON[6391]: (root) CMD (/usr/local/bin/script.sh)
Jan  7 20:29:01 Sania-VB CRON[6390]: (CRON) info (No MTA installed, discarding output)
```
P. S. сообщение Not MTA installed оказалось не ошибочным, просто не установлен почтовый агент (ни на что не влияет).



