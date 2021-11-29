## DevOps-Netology
**ДЗ "Компьютерные сети 1"** :whale2:

1. вывод по запросу telnet stackoverflow.com 80:  
>HTTP/1.1 301 Moved Permanently  
cache-control: no-cache, no-store, must-revalidate  
location: https://stackoverflow.com/questions  
x-request-guid: 3768e80c-d856-455b-932b-f446460a861b  
feature-policy: microphone 'none'; speaker 'none'  
content-security-policy: upgrade-insecure-requests; frame-ancestors 'self' https://stackexchange.com  
Accept-Ranges: bytes  
Transfer-Encoding: chunked  
Date: Sat, 27 Nov 2021 13:20:19 GMT  
Via: 1.1 varnish  
Connection: keep-alive  
X-Served-By: cache-ams21080-AMS  
X-Cache: MISS  
X-Cache-Hits: 0  
X-Timer: S1638019219.955237,VS0,VE76  
Vary: Fastly-SSL  
X-DNS-Prefetch-Control: off  
Set-Cookie: prov=c6c8237c-3091-b4a6-5b81-f586d36db048; domain=.stackoverflow.com; expires=Fri, 01-Jan-2055 00:00:00 GMT; path=/; HttpOnly  
0  
  
вывод сообщает нам, что страница, к которой клиент обращается, была окончательно перенесена на новый URI, указанный в поле location заголовка - https. а порт 80 по умолчанию - это порт протокола http.
  
  
2. полученный HTTP код от первого ответа сервера (именно он и выполнялся дольше всего - 399 мс):  
>**General:**  
	Request URL: https://stackoverflow.com/  
	Request Method: GET  
	Status Code: 200   
	Remote Address: 151.101.129.69:443  
	Referrer Policy: strict-origin-when-cross-origin  
**Response Headers**  
	accept-ranges: bytes  
	cache-control: private  
	content-security-policy: upgrade-insecure-requests; frame-ancestors 'self' https://stackexchange.com  
	content-type: text/html; charset=utf-8  
	date: Sat, 27 Nov 2021 14:41:42 GMT  
	feature-policy: microphone 'none'; speaker 'none'  
	strict-transport-security: max-age=15552000  
	vary: Accept-Encoding,Fastly-SSL  
	via: 1.1 varnish  
	x-cache: MISS  
	x-cache-hits: 0  
	x-dns-prefetch-control: off  
	x-frame-options: SAMEORIGIN  
	x-request-guid: 100a4f6f-a593-4ffd-80e1-aa17c385855d  
	x-served-by: cache-ams21036-AMS  
	x-timer: S1638024103.612700,VS0,VE80  
**Request Headers**  
	:authority: stackoverflow.com  
	:method: GET  
	:path: /  
	:scheme: https
	accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9  
	accept-encoding: gzip, deflate, br  
	accept-language: en-US,en;q=0.9,ru-RU;q=0.8,ru;q=0.7,de;q=0.6  
	cache-control: no-cache  
	cookie: prov=4e3477cb-d5a2-f96a-5fe4-b1e01ba497f0; _ga=GA1.2.1224917880.1637702231; OptanonAlertBoxClosed=2021-11-23T21:17:13.297Z; OptanonConsent=isIABGlobal=false&datestamp=Wed+Nov+24+2021+00%3A17%3A13+GMT%2B0300+(%D0%9C%D0%BE%D1%81%D0%BA%D0%B2%D0%B0%2C+%D1%81%D1%82%D0%B0%D0%BD%D0%B4%D0%B0%D1%80%D1%82%D0%BD%D0%BE%D0%B5+%D0%B2%D1%80%D0%B5%D0%BC%D1%8F)&version=6.10.0&hosts=&landingPath=NotLandingPage&groups=C0003%3A1%2CC0004%3A1%2CC0002%3A1%2CC0001%3A1; _ym_d=1637836925; _ym_uid=1637836925367902936; _gid=GA1.2.723807105.1638015627; _ym_isad=1; mfnes=3aecCAYQAxoLCOLhlt3X7Zg6EAUgASgBMgg0NTgxYzc5YQ==  
	pragma: no-cache  
	sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="96", "Google Chrome";v="96"  
	sec-ch-ua-mobile: ?1  
	sec-ch-ua-platform: "Android"  
	sec-fetch-dest: document  
	sec-fetch-mode: navigate  
	sec-fetch-site: none  
	sec-fetch-user: ?1  
	upgrade-insecure-requests: 1  
	user-agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Mobile Safari/537.36  
  
![скриншот задания 2](https://i.ibb.co/FKPGKcK/Screenshot-1.png)  
  
  
3. мой IP через whoer.net/:  
>37.1.85.133  
  
  
4. мой провайдер:  
>Yarnet Ltd  
  
37.1.85.133.yarnet.ru принадлежит AS Yarnet Ltd (AS197078).  
  
  
5. у меня Win10, по команде tracert не выводится инфа по АС:  
>	PS C:\Windows\System32> tracert -An 8.8.8.8  
	
	Tracing route to dns.google [8.8.8.8]  
	over a maximum of 30 hops:  
	
	  1   170 ms   158 ms    32 ms  192.168.0.1  
	  2     5 ms    12 ms     2 ms  asr-1002-b4.yarnet.ru [212.232.63.66]  
	  3     *        *        *     Request timed out.  
	  4     *        *        *     Request timed out.  
	  5     *        *        *     Request timed out.  
	  6     *        *        *     Request timed out.  
	  7     *        *        *     Request timed out.  
	  8     *        *        *     Request timed out.  
	  9     *        *        *     Request timed out.  
	 10     *        *        *     Request timed out.  
	 11     *        *        *     Request timed out.  
	 12     *        *        *     Request timed out.  
	 13     *        *        *     Request timed out.  
	 14     *        *        *     Request timed out.  
	 15     *        *        *     Request timed out.  
	 16     *        *        *     Request timed out.  
	 17     *        *        *     Request timed out.  
	 18     *        *        *     Request timed out.  
	 19     *        *        *     Request timed out.  
	 20     *        *        *     Request timed out.  
	 21     *        *        *     Request timed out.  
	 22    21 ms     *        *     dns.google [8.8.8.8]  
	 23    23 ms    22 ms    23 ms  dns.google [8.8.8.8]  
	
	Trace complete.  
  
  
6. установили себе утилиту MTR для винды, делаем запрос по 8.8.8.8:  
>
|------------------------------------------------------------------------------------------|  
|                                      WinMTR statistics                                   |  
|                       Host              -   %  | Sent | Recv | Best | Avrg | Wrst | Last |  
|------------------------------------------------|------|------|------|------|------|------|  
|                             192.168.0.1 -    0 |    9 |    9 |    2 |    7 |   13 |   11 |  
|                   asr-1002-b2.yarnet.ru -    0 |    9 |    9 |    3 |    9 |   14 |   13 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                   No response from host -  100 |    1 |    0 |    0 |    0 |    0 |    0 |  
|                              dns.google -   20 |    5 |    4 |    0 |   25 |   27 |   24 |  
|________________________________________________|______|______|______|______|______|______|  
   WinMTR v0.92 GPL V2 by Appnor MSP - Fully Managed Hosting & Cloud Provider  
  
наибольшая задержка на хосте asr-1002-b2.yarnet.ru.  
  
  
7. вывод dig dns.google:  
>	C:\WINDOWS\system32>dig dns.google  
	  
	; <<>> DiG 9.16.23 <<>> dns.google  
	;; global options: +cmd  
	;; Got answer:  
	;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 38942  
	;; flags: qr rd ra ad; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1  
	  
	;; OPT PSEUDOSECTION:  
	; EDNS: version: 0, flags:; udp: 4096  
	;; QUESTION SECTION:  
	;dns.google.                    IN      A  
	  
	;; ANSWER SECTION:  
	**dns.google.             405     IN      A       8.8.8.8** 
	**dns.google.             405     IN      A       8.8.4.4** 
	  
	;; Query time: 0 msec  
	;; SERVER: 212.232.62.10#53(212.232.62.10)  
	;; WHEN: Sat Nov 27 19:10:31 Russia TZ 2 Standard Time 2021  
	;; MSG SIZE  rcvd: 71  
  
  
8. проверяем PTR записи для IP адресов:  
>C:\WINDOWS\system32>dig -x **8.8.8.8**  
  
	; <<>> DiG 9.16.23 <<>> -x 8.8.8.8  
	;; global options: +cmd  
	;; Got answer:  
	;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 23148  
	;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 1  
	
	;; OPT PSEUDOSECTION:  
	; EDNS: version: 0, flags:; udp: 4096  
	;; QUESTION SECTION:  
	;8.8.8.8.in-addr.arpa.          IN      PTR  
	
	;; ANSWER SECTION:  
	8.8.8.8.in-addr.arpa.   7918    IN      PTR     **dns.google**.  
	
	;; AUTHORITY SECTION:  
	8.8.in-addr.arpa.       6881    IN      NS      ns2.level3.net.  
	8.8.in-addr.arpa.       6881    IN      NS      ns1.level3.net.  
	
	;; Query time: 8 msec  
	;; SERVER: 212.232.62.10#53(212.232.62.10)  
	;; WHEN: Sat Nov 27 19:16:02 Russia TZ 2 Standard Time 2021  
	;; MSG SIZE  rcvd: 119  
	
>C:\WINDOWS\system32>dig -x **8.8.4.4**   
	
	; <<>> DiG 9.16.23 <<>> -x 8.8.4.4  
	;; global options: +cmd  
	;; Got answer:  
	;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6862  
	;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 1  
	
	;; OPT PSEUDOSECTION:  
	; EDNS: version: 0, flags:; udp: 4096  
	;; QUESTION SECTION:  
	;4.4.8.8.in-addr.arpa.          IN      PTR  
	
	;; ANSWER SECTION:  
	4.4.8.8.in-addr.arpa.   6834    IN      PTR     **dns.google**.  
	
	;; AUTHORITY SECTION:  
	8.8.in-addr.arpa.       6834    IN      NS      ns1.level3.net.  
	8.8.in-addr.arpa.       6834    IN      NS      ns2.level3.net.  
	
	;; Query time: 6 msec  
	;; SERVER: 212.232.62.10#53(212.232.62.10)  
	;; WHEN: Sat Nov 27 19:16:49 Russia TZ 2 Standard Time 2021  
	;; MSG SIZE  rcvd: 119  
  
к данным IP привязано доменное имя dns.google.  