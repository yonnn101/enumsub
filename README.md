# Subdomain Enumeration Mega Script

A comprehensive and automated subdomain enumeration tool written in Bash. It combines 15+ industry-standard tools and methods to discover subdomains through passive sources, active brute-forcing, permutations, and live probing.

## 🚀 Features

*   **Multi-Source Enumeration**: aggregated results from `crt.sh`, `CertSpotter`, `Hackertarget`, `Chaos`, `VirusTotal`, `subfinder`, `assetfinder`, `sublist3r`, and `amass`.
*   **Smart Modes**: choose between `light` (fast), `balance` (thorough), and `deep` (extensive) scans.
*   **Permutations**: generates and resolves subdomain variations using `alterx`.
*   **Brute-Force**: robust DNS brute-forcing using `shuffledns` or `puredns`.
*   **Live Resolution**: verifies active subdomains using `puredns` or `dnsx`.
*   **Port Scanning**: integrated `naabu` fast port scanning (top 100/1000 ports).
*   **Web Probing**: automatically probes for HTTP/HTTPS servers using `httpx`, prioritizing open ports found by naabu.
*   **Safety Checks**: prevents crashes by checking wordlist sizes before running memory-intensive tools like `altdns`.

## 🛠️ Prerequisites

Ensure the following tools are installed and available in your `$PATH`:

*   `curl`, `jq`, `sed`, `grep`, `sort` (Standard Linux tools)
*   [subfinder](https://github.com/projectdiscovery/subfinder)
*   [assetfinder](https://github.com/tomnomnom/assetfinder)
*   [sublist3r](https://github.com/aboul3la/Sublist3r)
*   [amass](https://github.com/owasp-amass/amass)
*   [alterx](https://github.com/projectdiscovery/alterx)
*   [puredns](https://github.com/d3mondev/puredns)
*   [shuffledns](https://github.com/projectdiscovery/shuffledns)
*   [dnsx](https://github.com/projectdiscovery/dnsx)
*   [naabu](https://github.com/projectdiscovery/naabu)
*   [httpx](https://github.com/projectdiscovery/httpx)
*   *(Optional)* `altdns` (for deep mode)

## 📥 Usage

```bash
./subenum.sh -d example.com [OPTIONS]
