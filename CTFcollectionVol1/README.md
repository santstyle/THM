# CTF Collection Vol.1 - TryHackMe Writeup

## Report Metadata
- **Platform**: TryHackMe
- **Difficulty**: Easy
- **Category**: Cryptography, Steganography, Forensics, Web Exploitation, OSINT
- **Tools Used**: CyberChef, ExifTool, Steghide, Binwalk, Wireshark, Stegsolve, Qr Scanner, Wayback Machine, Dcode.fr, XOR.pw, RapidTables.com
- **Objective**: Document the step-by-step resolution of 21 CTF challenges to facilitate learning and replication by others.

## Executive Summary
This report details the comprehensive walkthrough of the "CTF Collection Vol.1" room on TryHackMe, encompassing 21 challenges across various cybersecurity domains. Each task is approached methodically, with clear prerequisites, tools, commands, outputs, and flags provided for reproducibility. The challenges cover fundamental techniques in decoding, steganography, forensics, and more, making this a valuable resource for beginners in offensive security.

## Methodology
The approach to each challenge follows a structured process:
1. **Understanding the Task**: Analyze the provided information, hints, or files.
2. **Tool Selection**: Choose appropriate tools based on the challenge type (e.g., CyberChef for encoding/decoding, ExifTool for metadata extraction).
3. **Execution**: Run commands or perform actions step-by-step.
4. **Analysis**: Interpret outputs to extract the flag.
5. **Documentation**: Record all steps, inputs, outputs, and results for clarity.

All tasks were performed in a controlled environment using Kali Linux or equivalent, ensuring tools are installed and up-to-date.

## Detailed Walkthrough

### Task 1: Read Author Note
**Objective**: Familiarize with the room's introduction.  
**Prerequisites**: Access to TryHackMe room.  
**Steps**:  
1. Read the author's note provided in the task.  
**Flag**: N/A (No flag required, introductory task).

### Task 2: Base64 Decoding
**Objective**: Decode a Base64 encoded string.  
**Prerequisites**: Access to CyberChef (online tool).  
**Steps**:  
1. Navigate to https://gchq.github.io/CyberChef/.  
2. Input the string: `VEhNe2p1NTdfZDNjMGQzXzdoM19iNDUzfQ==`.  
3. Apply the "From Base64" operation.  
**Output**:  
```
THM{**********************}
```
**Flag**: THM{**********************}

### Task 3: EXIF Metadata Extraction
**Objective**: Extract hidden flag from image metadata.  
**Prerequisites**: Download `Find_me_1577975566801.jpg`, ExifTool installed (`sudo apt install exiftool`).  
**Steps**:  
1. Run the command:  
   ```bash
   exiftool Find_me_1577975566801.jpg
   ```  
**Output** (truncated for brevity):  
```
ExifTool Version Number         : 13.25
File Name                       : Find_me_1577975566801.jpg
Directory                       : .
File Size                       : 35 kB
File Modification Date/Time     : 2025:11:04 14:22:33+07:00
File Access Date/Time           : 2025:11:04 14:22:33+07:00
File Inode Change Date/Time     : 2025:11:04 14:22:33+07:00
File Permissions                : -rw-rw-r--
File Type                       : JPEG
File Type Extension             : jpg
MIME Type                       : image/jpeg
JFIF Version                    : 1.01
X Resolution                    : 96
Y Resolution                    : 96
Exif Byte Order                 : Big-endian (Motorola, MM)
Resolution Unit                 : inches
Y Cb Cr Positioning             : Centered
Exif Version                    : 0231
Components Configuration        : Y, Cb, Cr, -
Flashpix Version                : 0100
Owner Name                      : THM{**********************}
Comment                         : CREATOR: gd-jpeg v1.0 (using IJG JPEG v62), quality = 60.
Image Width                     : 800
Image Height                    : 480
Encoding Process                : Progressive DCT, Huffman coding
Bits Per Sample                 : 8
Color Components                : 3
Y Cb Cr Sub Sampling            : YCbCr4:2:0 (2 2)
Image Size                      : 800x480
Megapixels                      : 0.384
```  
**Flag**: THM{**********************}

### Task 4: Steghide Extraction
**Objective**: Extract hidden data from an image using Steghide.  
**Prerequisites**: Download the task file, Steghide installed (`sudo apt install steghide`).  
**Steps**:  
1. Run Steghide to extract (assuming no passphrase or default):  
   ```bash
   steghide extract -sf [filename]
   ```  
**Output**:  
```
THM{**********************}
```
**Flag**: THM{**********************}

### Task 5: Sensor Selection
**Objective**: Identify the correct sensor to find the flag.  
**Prerequisites**: Access to the task interface.  
**Steps**:  
1. Select the appropriate sensor as per the question.  
**Output**:  
```
THM{**********************}
```
**Flag**: THM{**********************}

### Task 6: QR Code Scanning
**Objective**: Scan a QR code to reveal the flag.  
**Prerequisites**: QR scanner app or online tool.  
**Steps**:  
1. Use a QR scanner on the provided image.  
**Output**:  
```
THM{**********************}
```
**Flag**: THM{**********************}

### Task 7: Binary Analysis
**Objective**: Analyze an ELF binary to find the flag.  
**Prerequisites**: Download `hello_1577977122465.hello`, `file` and `strings` tools available.  
**Steps**:  
1. Identify file type:  
   ```bash
   file hello_1577977122465.hello
   ```  
   Output: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=02900338a56c3c8296f8ef7a8cf5df8699b18696, for GNU/Linux 3.2.0, not stripped  
2. Extract strings and grep for flag:  
   ```bash
   strings hello_1577977122465.hello | grep "THM{"
   ```  
**Output**:  
```
THM{**********************}
```
**Flag**: THM{**********************}

### Task 8: Base58 Decoding
**Objective**: Decode a Base58 encoded string.  
**Prerequisites**: CyberChef access.  
**Steps**:  
1. Use CyberChef with "From Base58" operation.  
**Output**:  
```
THM{**********************}
```
**Flag**: THM{**********************}

### Task 9: Caesar Cipher (ROT13 with offset)
**Objective**: Decrypt a Caesar cipher.  
**Prerequisites**: CyberChef access.  
**Steps**:  
1. Apply ROT13 with amount 7.  
**Output**:  
```
THM{**********************}
```
**Flag**: THM{**********************}

### Task 10: Hidden HTML Element
**Objective**: Inspect webpage source for hidden content.  
**Prerequisites**: Browser with developer tools.  
**Steps**:  
1. Inspect the paragraph: "No downloadable file, no ciphered or encoded text. Huh .......".  
2. View page source to find hidden HTML:  
   ```html
   <p style="display:none;"> <span data-testid="glossary-term" class="glossary-term">THM</span>{**********************} </p>
   ```  
**Flag**: THM{**********************}

### Task 11: PNG Header Manipulation
**Objective**: Fix corrupted PNG header to reveal image and flag.  
**Prerequisites**: Download `spoil_1577979329740.png`, CyberChef access.  
**Steps**:  
1. Examine hex dump:  
   ```bash
   xxd --plain spoil_1577979329740.png | head
   ```  
   Output: 2333445f0d0a1a0a0000000d4948445200000320000003200806000000db700668000000017352474200aece1ce9000000097048597300000ec400000ec401952b0e1b0000200049444154789cecdd799c9c559deff1cf799e5abb7a5f927477f640480209201150c420bba288a8805c19067c5d64c079e9752e03ce38e30e8e2f75e63a23ea8c0ce8308e036470c191cd80880c4b200909184c42b64ed2e9f4bed7f23ce7fe51559dea4e27a4bbaaf7effbf5ea57d2d5554f9daa7abafa7ceb9cf33bc65a6b1111111111111907ce4437404444444444660e0510111111111119370a202222222222326e144044444444464dc288088888888888c8b8510011111111119171a300222222222222e34601444444444444c68d028888888888888c1b0510111111111119370a  
2. In CyberChef, use "Render Image" and "Hex", replace `2333445f` with `89 50 4E 47`.  
**Output**: Image renders with flag.  
**Flag**: THM{**********************}

### Task 12: OSINT Search
**Objective**: Use Google dorks to find flag on Reddit.  
**Prerequisites**: Web browser.  
**Steps**:  
1. Search: `site:reddit.com intext:"THM"`.  
**Output**: Found post with flag.  
**Flag**: THM{**********************}

### Task 13: Brainfuck Decoding
**Objective**: Decode Brainfuck code.  
**Prerequisites**: Access to https://www.dcode.fr/brainfuck-language.  
**Steps**:  
1. Input the Brainfuck code into the decoder.  
**Output**:  
```
THM{**********************}
```
**Flag**: THM{**********************}

### Task 14: XOR Decryption
**Objective**: Decrypt XOR encrypted data.  
**Prerequisites**: Access to https://xor.pw/.  
**Steps**:  
1. Input as hexadecimal (base 16), output as ASCII (base 256).  
**Output**:  
```
THM{**********************}
```
**Flag**: THM{**********************}

### Task 15: Embedded Zip Extraction
**Objective**: Extract hidden zip from JPEG using Binwalk.  
**Prerequisites**: Download `hell_1578018688127.jpg`, Binwalk installed (`sudo apt install binwalk`).  
**Steps**:  
1. Analyze with Binwalk:  
   ```bash
   binwalk -B hell_1578018688127.jpg
   ```  
   Output:  
   ```
   DECIMAL       HEXADECIMAL     DESCRIPTION
   --------------------------------------------------------------------------------
   0             0x0             JPEG image data, JFIF standard 1.02
   30            0x1E            TIFF image data, big-endian, offset of first image directory: 8
   265845        0x40E75         Zip archive data, at least v2.0 to extract, uncompressed size: 69, name: hello_there.txt
   266099        0x40F73         End of Zip archive, footer length: 22
   ```  
2. Copy and extract:  
   ```bash
   cp hell_1578018688127.jpg hell_1578018688127.zip
   unzip hell_1578018688127.zip
   ```  
   Output:  
   ```
   Archive:  hell_1578018688127.zip
   warning [hell_1578018688127.zip]:  265845 extra bytes at beginning or within zipfile
     (attempting to process anyway)
     inflating: hello_there.txt
   Thank you for extracting me, you are the best!
   THM{**********************}
   ```  
**Flag**: THM{**********************}

### Task 16: Steganography with Stegsolve
**Objective**: Use Stegsolve to reveal hidden data in image.  
**Prerequisites**: Download Stegsolve.jar, Java installed.  
**Steps**:  
1. Download:  
   ```bash
   wget http://www.caesum.com/handbook/Stegsolve.jar -O stegsolve.jar
   chmod +x stegsolve.jar
   java -jar stegsolve.jar
   ```  
2. Open the image and cycle through planes until flag appears.  
**Flag**: THM{**********************}

### Task 17: QR Code with Audio
**Objective**: Scan QR code leading to audio flag.  
**Prerequisites**: QR scanner.  
**Steps**:  
1. Scan the QR code, follow link to listen.  
**Output**: Audio reveals THM{**********************}.  
**Flag**: THM{**********************}

### Task 18: Wayback Machine OSINT
**Objective**: Use Wayback Machine to find historical flag.  
**Prerequisites**: Web browser, Wayback Machine access.  
**Steps**:  
1. Search the site in Wayback Machine.  
**Output**: Found flag in archived page.  
**Flag**: THM{**********************}

### Task 19: Vigenère Cipher
**Objective**: Decrypt Vigenère encrypted text.  
**Prerequisites**: CyberChef access.  
**Steps**:  
1. Use "Vigenère Decode" with key "THM".  
**Output**:  
```
TRYHACKME{****************}
```
**Flag**: TRYHACKME{****************}

### Task 20: Number Conversion
**Objective**: Convert decimal to hex, then to text.  
**Prerequisites**: Access to https://www.rapidtables.com.  
**Steps**:  
1. Convert decimal to hex.  
2. Convert hex to ASCII text.  
**Output**:  
```
THM{**********************}
```
**Flag**: THM{**********************}

### Task 21: Packet Analysis
**Objective**: Analyze PCAP file for HTTP traffic.  
**Prerequisites**: Download `flag_1578026731881.pcapng`, Wireshark installed.  
**Steps**:  
1. Open in Wireshark.  
2. Filter: `http.request.method == GET`.  
3. Follow HTTP Stream.  
**Output**:  
```
GET /flag.txt HTTP/1.1
Host: 192.168.247.140
User-Agent: Mozilla/5.0 (X11; Linux x86-64; rv:60.0) Gecko/20100101 Firefox/60.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Connection: keep-alive
Upgrade-Insecure-Requests: 1
If-Modified-Since: Fri, 03 Jan 2020 04:36:45 GMT
If-None-Match: "e1bb7-15-59b34db67925a"
Cache-Control: max-age=0

HTTP/1.1 200 OK
Date: Fri, 03 Jan 2020 04:43:14 GMT
Server: Apache/2.2.22 (Ubuntu)
Last-Modified: Fri, 03 Jan 2020 04:42:12 GMT
ETag: "e1bb7-20-59b34eee33e0c"
Accept-Ranges: bytes
Vary: Accept-Encoding
Content-Encoding: gzip
Content-Length: 52
Keep-Alive: timeout=5, max=100
Connection: Keep-Alive
Content-Type: text/plain

THM{**********************}

Found me!
```  
**Flag**: THM{**********************}

## Tools Used
- **CyberChef**: For encoding/decoding operations.
- **ExifTool**: Metadata extraction from images.
- **Steghide**: Steganography tool for hiding/extracting data.
- **Binwalk**: Firmware analysis and embedded file detection.
- **Wireshark**: Network packet analysis.
- **Stegsolve**: Steganography analysis tool.
- **QR Scanner**: For scanning QR codes.
- **Wayback Machine**: Historical web page retrieval.
- **Dcode.fr**: Brainfuck decoder.
- **XOR.pw**: XOR decryption.
- **RapidTables.com**: Number conversion.
- **Browser Developer Tools**: For inspecting web elements.

## Conclusion
This collection of challenges provides a solid foundation in various offensive security techniques, from basic decoding to advanced steganography and forensics. By following the detailed steps outlined, learners can replicate the solutions and gain hands-on experience. All flags have been verified, and the report ensures clarity for educational purposes. For further challenges, explore additional TryHackMe rooms.
