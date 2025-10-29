# Capture! CTF Challenge Penetration Testing Report

## Executive Summary

This report documents the penetration testing activities conducted on the "Capture!" challenge from TryHackMe. The challenge involves bypassing a login form protected by a custom rate limiter and CAPTCHA mechanism. The objective was to gain unauthorized access to the application and retrieve the flag. The assessment identified vulnerabilities in the authentication system, allowing brute-force attacks to succeed despite rate limiting measures. Successful exploitation led to credential discovery and flag retrieval.

**Key Findings:**
- Weak rate limiting allowed brute-force enumeration of credentials.
- CAPTCHA could be bypassed manually after credential discovery.
- Flag obtained: [REDACTED FOR SECURITY]

**Difficulty Level:** Easy  
**Target IP:** 10.201.79.144  

## Scope

The scope of this assessment was limited to the web application hosted at `http://10.201.79.144/login`. The goal was to bypass the login form and capture the flag without disrupting the underlying infrastructure. No external tools or services beyond the provided challenge files were used.

## Methodology

The assessment followed a structured penetration testing methodology, including:

1. **Reconnaissance:** Initial enumeration of the target application.
2. **Enumeration:** Identification of usernames and passwords using provided wordlists.
3. **Exploitation:** Brute-force attack against the login form.
4. **Post-Exploitation:** Manual login and CAPTCHA bypass to retrieve the flag.

Tools Used:
- Python 3 (for brute-force script)
- Web browser (for manual interaction)
- Provided wordlists: `usernames.txt` and `passwords.txt`

## Detailed Exploitation Steps

### Step 1: Environment Setup
1. Download the required task files from TryHackMe and (usernames.txt, passwords.txt, and bruteforce_captcha.py).
2. Ensure Python 3 is installed on your system.
3. Place the downloaded files in a working directory (e.g., `~/Desktop/THM/Capture!`).

### Step 2: Reconnaissance
1. Access the target URL: `http://10.201.79.144/login` in a web browser.
2. Observe the login form, which includes fields for username, password, and CAPTCHA.
3. Note the presence of rate limiting and CAPTCHA to prevent automated attacks.

### Step 3: Credential Enumeration Preparation
1. Review the provided wordlists:
   - `usernames.txt`: Contains potential usernames.
   - `passwords.txt`: Contains potential passwords.
2. Ensure the wordlists are populated with relevant entries (e.g., common usernames like "natalie").

### Step 4: Brute-Force Attack
1. Execute the brute-force script using the following command:
   ```
   python3 bruteforce_captcha.py
   ```
2. The script will attempt to brute-force the login form using the provided wordlists.
3. Monitor the output for successful attempts. Example output:
   - Failed attempts: "Failed, natalie, sk8board, 2247"
   - Successful attempt: "Success, natalie, sk8board, 60"
4. Identify the valid credentials: Username: `natalie`, Password: `sk8board`.
5. Note: The script automatically handles CAPTCHA by parsing and solving simple math operations (e.g., "1 + 2 = 3") in the response and resubmitting the form.

### Step 5: Manual Login and CAPTCHA Bypass
1. Navigate to `http://10.201.79.144/login` in a web browser.
2. Enter the discovered credentials:
   - Username: `natalie`
   - Password: `sk8board`
3. Solve the CAPTCHA manually (e.g., enter the displayed text or solve the puzzle).
4. Submit the login form.

### Step 6: Flag Retrieval
1. Upon successful login, access the protected area of the application.
2. Locate and retrieve the flag from the `flag.txt` file or equivalent resource.
3. Flag Content: [REDACTED FOR SECURITY] (In a real scenario, this would be the full flag: `**********************`)

## Findings and Vulnerabilities

### Vulnerability 1: Inadequate Rate Limiting
- **Description:** The custom rate limiter was insufficient to prevent brute-force attacks, allowing the script to succeed after multiple attempts.
- **Impact:** Low to Medium. Enables credential enumeration.
- **Remediation:** Implement stronger rate limiting (e.g., exponential backoff) or integrate a WAF.

### Vulnerability 2: CAPTCHA Bypass
- **Description:** CAPTCHA could be solved manually post-credential discovery. The script also automates solving simple math-based CAPTCHAs.
- **Impact:** Low. Requires human intervention but feasible; automation possible for basic math.
- **Remediation:** Use more robust CAPTCHA solutions (e.g., reCAPTCHA) or multi-factor authentication.

## Conclusion

The "Capture!" challenge was successfully completed by exploiting weaknesses in the authentication mechanism. The rate limiter and CAPTCHA provided minimal protection against determined attackers. This highlights the importance of layered security defenses in web applications.

## Recommendations

- Enhance rate limiting with server-side controls.
- Implement advanced CAPTCHA or alternative anti-automation measures.
- Conduct regular security audits on authentication systems.

**Disclaimer:** This report is for educational purposes only, as part of the TryHackMe CTF challenge. Unauthorized testing on real systems is illegal.
