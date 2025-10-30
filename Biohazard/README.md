# Biohazard CTF Walkthrough Report

## Executive Summary

This report details the penetration testing walkthrough for the "Biohazard" room on TryHackMe, a medium-difficulty CTF challenge inspired by the Resident Evil series. The objective was to navigate through a puzzle-based scenario, collecting items, solving riddles, and escalating privileges to obtain the root flag. Key findings include vulnerabilities in web applications, FTP server misconfigurations, and weak SSH credentials. The engagement resulted in full system compromise, demonstrating the importance of secure configurations and encryption practices.

**Key Outcomes:**
- Identified open ports: 21 (FTP), 22 (SSH), 80 (HTTP)
- Extracted multiple flags through web enumeration and cipher decoding
- Gained FTP access and decrypted hidden files
- Achieved SSH login and privilege escalation to root
- Final root flag: `3c5794a00dc56c35f2bf096571edf3bf`

## Methodology

The assessment followed a structured penetration testing methodology:
1. **Reconnaissance**: Initial scanning to identify open ports and services.
2. **Enumeration**: Detailed exploration of web content, file systems, and hidden directories.
3. **Exploitation**: Leveraging discovered credentials and vulnerabilities for access.
4. **Post-Exploitation**: Privilege escalation and data extraction.
5. **Reporting**: Documenting findings with step-by-step instructions for reproducibility.

Tools used include Nmap, FTP client, SSH, Steghide, ExifTool, Binwalk, GPG, and CyberChef for decoding.

## Reconnaissance

### Nmap Scan
Performed an initial Nmap scan to identify open ports and services on the target IP (10.201.62.145).

**Command:**
```bash
nmap -sC -sV 10.201.62.145 -oN nmap.txt
```

**Output:**
```bash
Starting Nmap 7.95 ( https://nmap.org ) at 2025-10-29 19:28 WIB
Nmap scan report for 10.201.62.145
Host is up (0.28s latency).
Not shown: 997 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.3
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   2048 c9:03:aa:aa:ea:a9:f1:f4:09:79:c0:47:41:16:f1:9b (RSA)
|   256 2e:1d:83:11:65:03:b4:78:e9:6d:94:d1:3b:db:f4:d6 (ECDSA)
|_  256 91:3d:e4:4f:ab:aa:e2:9e:44:af:d3:57:86:70:bc:39 (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
|_http-server-header: Apache httpd 2.4.29 ((Ubuntu))
|_http-title: Beginning of the end
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 52.84 seconds
```

**Findings:**
- Port 21: FTP (vsftpd 3.0.3) - Vulnerable to known exploits.
- Port 22: SSH (OpenSSH 7.6p1) - Standard SSH service.
- Port 80: HTTP (Apache 2.4.29) - Web server hosting the main application.

## Web Application Enumeration

### Initial Web Access
Accessed the main web page at `http://10.201.62.145/`. The page title is "Beginning of the end," indicating the start of the mansion exploration.

### Mansion Exploration
1. **Main Hall (`/mansionmain/`)**:
   - Viewed page source to find a comment: `<!-- It is in the /diningRoom/ -->`
   - Navigated to `http://10.201.62.145/diningRoom/`
   - Clicked "Yes" and obtained the first flag: `emblem{fec832623ea498e20bf4fe1821d58727}`
   - Submitted the emblem flag via the form on the page.

2. **Dining Room**:
   - Page source revealed a Base64 encoded hint: `SG93IGFib3V0IHRoZSAvdGVhUm9vbS8=`
   - Decoded using CyberChef (From Base64): "How about the /teaRoom/"
   - Navigated to `http://10.201.62.145/teaRoom/` and clicked "lockpick" to get: `lock_pick{037b35e2ff90916a9abf99129c8e1837}`

3. **Art Room (`/artRoom/`)**:
   - Discovered a map of locations: `/diningRoom/`, `/teaRoom/`, `/artRoom/`, `/barRoom/`, `/diningRoom2F/`, `/tigerStatusRoom/`, `/galleryRoom/`, `/studyRoom/`, `/armorRoom/`, `/attic/`

4. **Bar Room (`/barRoom/`)**:
   - Found Base32 encoded string: `NV2XG2LDL5ZWQZLFOR5TGNRSMQ3TEZDFMFTDMNLGGVRGIYZWGNSGCZLDMU3GCMLGGY3TMZL5`
   - Decoded using CyberChef (From Base32): `music_sheet{362d72deaf65f5bdc63daece6a1f676e}`
   - Submitted the flag and obtained: `gold_emblem{58a8c41a9d08b8a4e38d02a4d7ff4843}`
   - Refreshed to `http://10.201.62.145/barRoom357162e3db904857963e6e0b64b96ba7/barRoomHidden.php` and submitted the gold emblem to get: `rebecca`

5. **Dining Room (with Gold Emblem)**:
   - Submitted `gold_emblem{58a8c41a9d08b8a4e38d02a4d7ff4843}` to reveal Vigenere encrypted text: `klfvg ks r wimgnd biz mpuiui ulg fiemok tqod. Xii jvmc tbkg ks tempgf tyi_hvgct_jljinf_kvc`
   - Decoded using CyberChef (Vigenere Decode with key "rebecca"): "there is a shield key inside the dining room. The html page is called the_great_shield_key"
   - Accessed `http://10.201.62.145/diningRoom/the_great_shield_key.html` to get: `shield_key{48a7a9227cd7eb89f0a062590798cbac}`

6. **Dining Room 2F (`/diningRoom2F/`)**:
   - Page source had ROT13 encoded hint: `Lbh trg gur oyhr trz ol chfuvat gur fgnghf gb gur ybjre sybbe. Gur trz vf ba gur qvavatEbbz svefg sybbe. Ivfvg fnccuver.ugzy`
   - Decoded (ROT13): "You get the blue gem by pushing the status to the lower floor. The gem is on the diningRoom first floor. Visit sapphire.html"
   - Accessed `http://10.201.62.145/diningRoom/sapphire.html` to get: `blue_jewel{e1d457e96cac640f863ec7bc475d48aa}`

7. **Tiger Status Room (`/tigerStatusRoom/`)**:
   - Submitted blue jewel to get Crest 1: `S0pXRkVVS0pKQkxIVVdTWUpFM0VTUlk9`
   - Decoded (From Base64, then Base32): `RlRQIHVzZXI6IG` (FTP user: )

8. **Gallery Room (`/galleryRoom/`)**:
   - Obtained Crest 2: `GVFWK5KHK5WTGTCILE4DKY3DNN4GQQRTM5AVCTKE`
   - Decoded (From Base32, then Base58): `h1bnRlciwgRlRQIHBh` (hunter, FTP pa)

9. **Armor Room (`/armorRoom/`)**:
   - Submitted shield key to get Crest 3: `MDAxMTAxMTAgMDAxMTAwMTEgMDAxMDAwMDAgMDAxMTAwMTEgMDAxMTAwMTEgMDAxMDAwMDAgMDAxMTAxMDAgMDExMDAxMDAgMDAxMDAwMDAgMDAxMTAwMTEgMDAxMTAxMTAgMDAxMDAwMDAgMDAxMTAxMDAgMDAxMTEwMDEgMDAxMDAwMDAgMDAxMTAxMDAgMDAxMTEwMDAgMDAxMDAwMDAgMDAxMTAxMTAgMDExMDAwMTEgMDAxMDAwMDAgMDAxMTAxMTEgMDAxMTAxMTAgMDAxMDAwMDAgMDAxMTAxMTAgMDAxMTAxMDAgMDAxMDAwMDAgMDAxMTAxMDEgMDAxMTAxMTAgMDAxMDAwMDAgMDAxMTAwMTEgMDAxMTEwMDEgMDAxMDAwMDAgMDAxMTAxMTAgMDExMDAwMDEgMDAxMDAwMDAgMDAxMTAxMDEgMDAxMTEwMDEgMDAxMDAwMDAgMDAxMTAxMDEgMDAxMTAxMTEgMDAxMDAwMDAgMDAxMTAwMTEgMDAxMTAxMDEgMDAxMDAwMDAgMDAxMTAwMTEgMDAxMTAwMDAgMDAxMDAwMDAgMDAxMTAxMDEgMDAxMTEwMDAgMDAxMDAwMDAgMDAxMTAwMTEgMDAxMTAwMTAgMDAxMDAwMDAgMDAxMTAxMTAgMDAxMTEwMDA=`
   - Decoded (From Base64, From Binary, From Hex): `c3M6IHlvdV9jYW50X2h` (ss: you_cant_h)

10. **Attic (`/attic/`)**:
    - Submitted shield key to get Crest 4: `gSUERauVpvKzRpyPpuYz66JDmRTbJubaoArM6CAQsnVwte6zF9J4GGYyun3k5qM9ma4s`
    - Decoded (From Base58, From Hex): `pZGVfZm9yZXZlcg==` (ide_forever)

11. **Combining Crests**:
    - Combined: `RlRQIHVzZXI6IGh1bnRlciwgRlRQIHBhc3M6IHlvdV9jYW50X2hpZGVfZm9yZXZlcg==`
    - Decoded (From Base64): FTP user: hunter, FTP pass: you_cant_hide_forever

## FTP Exploitation

### FTP Login
Used the discovered credentials to log into FTP.

**Command:**
```bash
ftp 10.201.62.145
Name: hunter
Password: you_cant_hide_forever
```

**Directory Listing:**
```bash
ftp> ls
-rw-r--r--    1 0        0            7994 Sep 19  2019 001-key.jpg
-rw-r--r--    1 0        0            2210 Sep 19  2019 002-key.jpg
-rw-r--r--    1 0        0            2146 Sep 19  2019 003-key.jpg
-rw-r--r--    1 0        0             121 Sep 19  2019 helmet_key.txt.gpg
-rw-r--r--    1 0        0             170 Sep 20  2019 important.txt
```

### File Downloads and Analysis
Downloaded all files using `mget *`.

1. **important.txt**:
   - Content: Hint about helmet key in encrypted file and a locked `/hidden_closet/` door.

2. **001-key.jpg**:
   - Used Steghide to extract hidden data.
   - Command: `steghide extract -sf 001-key.jpg`
   - Passphrase: (trial and error or based on context)
   - Extracted: `key-001.txt` containing `cGxhbnQ0Ml9jYW`

3. **002-key.jpg**:
   - Used ExifTool to view metadata.
   - Command: `exiftool 002-key.jpg`
   - Found in Comment: `5fYmVfZGVzdHJveV9`

4. **003-key.jpg**:
   - Used Binwalk to extract embedded ZIP.
   - Command: `binwalk -e 003-key.jpg`
   - Extracted: `key-003.txt` containing `3aXRoX3Zqb2x0`

5. **Combining Keys**:
   - Combined: `cGxhbnQ0Ml9jYW5fYmVfZGVzdHJveV93aXRoX3Zqb2x0`
   - Decoded (From Base64): `plant42_can_be_destroy_with_vjolt`

6. **helmet_key.txt.gpg**:
   - Decrypted using GPG.
   - Command: `gpg --pinentry-mode loopback --passphrase 'plant42_can_be_destroy_with_vjolt' --decrypt helmet_key.txt.gpg`
   - Obtained: `helmet_key{458493193501d2b94bbab2e727f8db4b}`

## SSH Access

### Study Room (`/studyRoom/`)
- Submitted helmet key to download `doom.tar.gz`.
- Extracted: `tar -xvf doom.tar` to get `eagle_medal.txt`.
- Content: SSH user: `umbrella_guest`

### Hidden Closet (`/hidden_closet/`)
- Submitted helmet key to reveal Vigenere encrypted text: `wpbwbxr wpkzg pltwnhro, txrks_xfqsxrd_bvv_fy_rvmexa_ajk`
- Decoded with key "albert": `weasker login password, stars_members_are_my_guinea_pig`
- SSH password: `T_virus_rules`

### SSH Login
**Command:**
```bash
ssh umbrella_guest@10.201.62.145
Password: T_virus_rules
```

**Initial Exploration:**
```bash
umbrella_guest@umbrella_corp:~$ ls -la
total 64
drwxr-xr-x  8 umbrella_guest umbrella 4096 Sep 20  2019 .
drwxr-xr-x  5 root           root     4096 Sep 20  2019 ..
-rw-r--r--  1 umbrella_guest umbrella  220 Sep 19  2019 .bash_logout
-rw-r--r--  1 umbrella_guest umbrella 3771 Sep 19  2019 .bashrc
drwxrwxr-x  6 umbrella_guest umbrella 4096 Sep 20  2019 .cache
drwxr-xr-x 11 umbrella_guest umbrella 4096 Sep 19  2019 .config
-rw-r--r--  1 umbrella_guest umbrella   26 Sep 19  2019 .dmrc
drwx------  3 umbrella_guest umbrella 4096 Sep 19  2019 .gnupg
-rw-------  1 umbrella_guest umbrella  346 Sep 19  2019 .ICEauthority
drwxr-xr-x  2 umbrella_guest umbrella 4096 Sep 20  2019 .jailcell
drwxr-xr-x  3 umbrella_guest umbrella 4096 Sep 19  2019 .local
-rw-r--r--  1 umbrella_guest umbrella  807 Sep 19  2019 .profile
drwx------  2 umbrella_guest umbrella 4096 Sep 20  2019 .ssh
-rw-------  1 umbrella_guest umbrella  109 Sep 19  2019 .Xauthority
-rw-------  1 umbrella_guest umbrella 7546 Sep 19  2019 .xsession-errors
```

```bash
umbrella_guest@umbrella_corp:~$ cd .jailcell
umbrella_guest@umbrella_corp:~/.jailcell$ ls
chris.txt
umbrella_guest@umbrella_corp:~/.jailcell$ cat chris.txt
Jill: Chris, is that you?
Chris: Jill, you finally come. I was locked in the Jail cell for a while. It seem that Weasker is behind all this.
Jil, What? Weasker? He is the traitor?
Chris: Yes, Jill. Unfortunately, he play us like a damn fiddle.
Jill: Let's get out of here first, I have contact brad for helicopter support.
Chris: Thanks Jill, here, take this MO Disk 2 with you. It look like the key to decipher something.
Jill: Alright, I will deal with him later.
Chris: see ya.

MO disk 2: albert
```

```bash
umbrella_guest@umbrella_corp:~$ cd ..
umbrella_guest@umbrella_corp:/home$ ls
hunter  umbrella_guest  weasker
umbrella_guest@umbrella_corp:/home$ cd hunter
umbrella_guest@umbrella_corp:/home/hunter$ ls
FTP
umbrella_guest@umbrella_corp:/home/hunter$ cd ..
umbrella_guest@umbrella_corp:/home$ cd weasker
umbrella_guest@umbrella_corp:/home/weasker$ ls
Desktop  weasker_note.txt
```

```bash
umbrella_guest@umbrella_corp:/home/weasker$ cat weasker_note.txt
Weaker: Finally, you are here, Jill.
Jill: Weasker! stop it, You are destroying the  mankind.
Weasker: Destroying the mankind? How about creating a 'new' mankind. A world, only the strong can survive.
Jill: This is insane.
Weasker: Let me show you the ultimate lifeform, the Tyrant.

(Tyrant jump out and kill Weasker instantly)
(Jill able to stun the tyrant will a few powerful magnum round)

Alarm: Warning! warning! Self-detruct sequence has been activated. All personal, please evacuate immediately. (Repeat)
Jill: Poor bastard
```

- Home directory: `.jailcell/chris.txt` revealed Chris is imprisoned and Weasker is the traitor. MO disk 2: `albert`
- Other users: `hunter`, `weasker`
- Weasker's note confirmed the traitor and introduced the Tyrant.

## Privilege Escalation

### Switching to Weasker
**Command:**
```bash
umbrella_guest@umbrella_corp:/home/weasker$ su weasker
Password: stars_members_are_my_guinea_pig
```

```bash
weasker@umbrella_corp:~$ whoami
weasker
```

### Root Access
**Command:**
```bash
weasker@umbrella_corp:~$ sudo -l
[sudo] password for weasker:
Matching Defaults entries for weasker on umbrella_corp:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User weasker may run the following commands on umbrella_corp:
    (ALL : ALL) ALL
weasker@umbrella_corp:~$ sudo su
root@umbrella_corp:/home/weasker#
```

**Root Flag:**
```bash
root@umbrella_corp:/home/weasker# cd /root
root@umbrella_corp:~# ls
root.txt
```

```bash
root.txt
root@umbrella_corp:~# cat root.txt
In the state of emergency, Jill, Barry and Chris are reaching the helipad and awaiting for the helicopter support.

Suddenly, the Tyrant jump out from nowhere. After a tough fight, brad, throw a rocket launcher on the helipad. Without thinking twice, Jill pick up the launcher and fire at the Tyrant.

The Tyrant shredded into pieces and the Mansion was blowed. The survivor able to escape with the helicopter and prepare for their next fight.

The End

flag: 3c5794a00dc56c35f2bf096571edf3bf
```

Located in `/root/root.txt`: `flag: 3c5794a00dc56c35f2bf096571edf3bf`

## Conclusion

The Biohazard CTF successfully simulated a complex puzzle-based penetration test, highlighting the risks of weak encryption, hidden data in files, and misconfigured services. By following systematic enumeration and exploitation techniques, full compromise was achieved. Recommendations include implementing strong encryption, regular security audits, and avoiding known vulnerable software versions. This walkthrough serves as a guide for aspiring penetration testers to practice and learn from real-world scenarios.
