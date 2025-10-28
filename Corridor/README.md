# TryHackMe Corridor Challenge

## Executive Summary

This report details the exploitation of the "Corridor" challenge on TryHackMe, classified as an easy-difficulty Capture The Flag (CTF) room. The objective was to escape a virtual corridor by identifying and exploiting an Insecure Direct Object Reference (IDOR) vulnerability. The vulnerability involved URL endpoints using MD5 hashes as identifiers for sequential room numbers, allowing unauthorized access to hidden pages.

Key findings include the discovery of hashed room identifiers, pattern recognition of MD5 hashing for integers, and successful fuzzing to locate a valid endpoint containing the flag. The challenge was completed without advanced techniques, relying on enumeration and basic web application testing tools.

## Scope

- **Target System**: TryHackMe Corridor challenge web application (IP: 10.201.111.203).
- **Objective**: Identify and exploit IDOR vulnerability to access restricted content and retrieve the flag.
- **Assumptions**: The target is a simulated environment with no real-world impact. All actions were performed ethically within the CTF context.
- **Out of Scope**: Physical access, network infrastructure beyond the web application, or exploitation of unrelated vulnerabilities.

## Methodology

The assessment followed a structured penetration testing methodology adapted for CTF challenges:

1. **Reconnaissance**: Initial exploration of the web application to understand its structure and identify potential entry points.
2. **Enumeration**: Detailed mapping of accessible resources, including URL patterns and hidden elements.
3. **Vulnerability Identification**: Analysis of observed patterns to hypothesize underlying weaknesses (e.g., IDOR via hashed identifiers).
4. **Exploitation**: Development and execution of proof-of-concept exploits to access restricted areas.
5. **Post-Exploitation**: Retrieval of the flag and documentation of findings.

Tools used included web browsers for manual navigation, online hash cracking services, command-line utilities for hash generation, and fuzzing tools for automated discovery.

## Enumeration

### Step 1: Initial Access and Site Exploration
- Accessed the target web application at `http://10.201.111.203`.
- Observed a corridor-themed interface with clickable areas representing doors or rooms.
- Upon clicking a room, the URL changed to include a hexadecimal string, e.g., `http://10.201.111.203/c81e728d9d4c2f636f067f89cc14862c`.
- Suspected these strings were hashes due to their length (32 characters) and format, indicative of MD5.

### Step 2: Hash Analysis
- Submitted the observed hash (`c81e728d9d4c2f636f067f89cc14862c`) to an online hash cracking service (e.g., crackstation.net).
- Result: The hash corresponded to the integer `2`.
- Repeated the process for other rooms, confirming a pattern where each room's hash represented a sequential integer (e.g., room 1, 2, 3, etc.).

### Step 3: Source Code Inspection
- Inspected the page source code to identify additional clues.
- Located an HTML `<map>` element defining clickable areas (rooms) with `href` attributes containing the same hashes.
- Extracted all hashes from the source for further analysis:
  ```
  c4ca4238a0b923820dcc509a6f75849b (likely room 1)
  c81e728d9d4c2f636f067f89cc14862c (room 2)
  eccbc87e4b5ce2fe28308fd9f2a7baf3 (room 3)
  a87ff679a2f3e71d9181a67b7542122c (room 4)
  e4da3b7fbbce2345d7772b0674a318d5 (room 5)
  1679091c5a880faf6fb5e6087eb1b2dc (room 6)
  8f14e45fceea167a5a36dedd4bea2543 (room 7)
  c9f0f895fb98ab9159f51fd0297e236d (room 8)
  45c48cce2e2d7fbdea1afc51c7c6ad26 (room 9)
  d3d9446802a44259755d38e6d163e820 (room 10)
  6512bd43d9caa6e02c990b0a82652dca (room 11)
  c20ad4d76fe97759aa27a0c99bff6710 (room 12)
  c51ce410c124a10e0db5e4b97fc2af39 (room 13)
  ```
- Hypothesized that the application used MD5 hashes of integers to identify rooms, potentially allowing IDOR by guessing or generating additional hashes.

## Exploitation

### Step 1: Hash Generation
- Generated MD5 hashes for a range of integers (0 to 20) to cover potential rooms beyond those visible in the source.
- Used the following Bash command to create a wordlist of hashes:
  ```bash
  (for i in 0 $(seq 14 20); do echo -n $i | md5sum | awk '{print $1}'; done) > hashes.txt
  ```
- This produced a file `hashes.txt` containing MD5 hashes for integers 0, 14 through 20.

### Step 2: Directory Fuzzing
- Employed ffuf (Fast web fuzzer) to test the generated hashes as URL paths.
- Command executed:
  ```bash
  ffuf -w hashes.txt -u http://10.201.111.203/FUZZ -ac -c
  ```
- Parameters:
  - `-w hashes.txt`: Wordlist of potential hashes.
  - `-u http://10.201.111.203/FUZZ`: Target URL with FUZZ placeholder.
  - `-ac`: Auto-calibration to reduce false positives.
  - `-c`: Colorized output.
- Output indicated one valid endpoint:
  ```
  cfcd208495d565ef66e7dff9f98764da [Status: 200, Size: 797, Words: 121, Lines: 34, Duration: 1023ms]
  ```
- Verified that `cfcd208495d565ef66e7dff9f98764da` is the MD5 hash of `0`.

### Step 3: Flag Retrieval
- Navigated to the discovered URL: `http://10.201.111.203/cfcd208495d565ef66e7dff9f98764da`.
- The page contained the flag: `flag{2477ef02448ad9156661ac40a6b8862e}`.

## Conclusion

The Corridor challenge was successfully completed by exploiting an IDOR vulnerability through predictable MD5 hashing of room identifiers. The key to success was recognizing the hash pattern and using fuzzing to enumerate hidden endpoints.

### Lessons Learned
- IDOR vulnerabilities can arise from insecure object references, such as using hashes without proper access controls.
- Systematic enumeration and pattern recognition are crucial in CTF challenges.
- Tools like ffuf streamline the discovery process for web application vulnerabilities.

### Recommendations
- Implement proper authorization checks for object access.
- Avoid using predictable identifiers; consider random or encrypted values with server-side validation.
- Regularly audit web applications for IDOR and similar flaws.

### Tools Used
- Web Browser (for manual navigation and source inspection).
- crackstation.net (online hash cracking).
- md5sum (command-line hash generation).
- ffuf (web fuzzing tool).

Flag: `flag{2477ef02448ad9156661ac40a6b8862e}`
