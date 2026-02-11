# 🔎 Subdomain Enumeration Mega Script

A comprehensive and automated **subdomain enumeration tool written in Bash**. It combines **15+ industry-standard tools and techniques** to discover subdomains through passive sources, active brute-forcing, permutations, and live probing.

---

## 🚀 Features

* **Multi-Source Enumeration**

  * crt.sh
  * CertSpotter
  * Hackertarget
  * Chaos
  * VirusTotal
  * subfinder
  * assetfinder
  * sublist3r
  * amass

* **Smart Scan Modes**

  * `light` – Fast reconnaissance
  * `balance` – Thorough scan (default)
  * `deep` – Extensive scan

* **Permutations**

  * Generates variations using `alterx`

* **Brute-Force**

  * DNS brute-forcing via `shuffledns` or `puredns`

* **Live Resolution**

  * Verifies active subdomains using `puredns` or `dnsx`

* **Port Scanning**

  * Integrated `naabu` scanning (Top 100 / 1000 ports)

* **Web Probing**

  * HTTP/HTTPS probing using `httpx`
  * Prioritizes open ports found by `naabu`

* **Safety Checks**

  * Prevents crashes by validating wordlist sizes before running `altdns`

---

## 🛠️ Prerequisites

Ensure the following tools are installed and available in your `$PATH`:

### Standard Linux Utilities

* curl
* jq
* sed
* grep
* sort

### Enumeration Tools

* [https://github.com/projectdiscovery/subfinder](https://github.com/projectdiscovery/subfinder)
* [https://github.com/tomnomnom/assetfinder](https://github.com/tomnomnom/assetfinder)
* [https://github.com/aboul3la/Sublist3r](https://github.com/aboul3la/Sublist3r)
* [https://github.com/owasp-amass/amass](https://github.com/owasp-amass/amass)
* [https://github.com/projectdiscovery/alterx](https://github.com/projectdiscovery/alterx)
* [https://github.com/d3mondev/puredns](https://github.com/d3mondev/puredns)
* [https://github.com/projectdiscovery/shuffledns](https://github.com/projectdiscovery/shuffledns)
* [https://github.com/projectdiscovery/dnsx](https://github.com/projectdiscovery/dnsx)
* [https://github.com/projectdiscovery/naabu](https://github.com/projectdiscovery/naabu)
* [https://github.com/projectdiscovery/httpx](https://github.com/projectdiscovery/httpx)

### Optional (Deep Mode)

* altdns

---

## 📥 Usage

```bash
./enumsub.sh -d example.com [OPTIONS]
```

---

## 🕹️ Scan Modes

### 1️⃣ Light Mode (`-m light`)

**Speed:** Very Fast (~30s – 2m)
**Description:** Quick reconnaissance using fast passive tools.

**Tools:**

* crt.sh
* subfinder
* assetfinder
* sublist3r

**Post-Processing:**

* naabu (Top 100 ports)
* httpx

---

### 2️⃣ Balance Mode (`-m balance`) — Default

**Speed:** Medium (~5m – 15m)
**Description:** Standard mode with brute-force and permutations.

**Adds:**

* amass (passive)
* alterx (permutations)
* shuffledns / puredns (brute-force)

**Post-Processing:**

* naabu (Top 1000 ports)
* httpx

---

### 3️⃣ Deep Mode (`-m deep`)

**Speed:** Slow (30m+)
**Description:** Exhaustive enumeration for deep engagements.

**Adds:**

* amass (active / recursive)
* altdns (permutation brute-force)

**Post-Processing:**

* naabu (Top 1000 ports)
* httpx

---

## 📂 Output Structure

Results are saved in a timestamped directory:

```
subenum_domain.com_YYYYMMDD_HHMMSS/
```

### Output Files

* `final_subdomains.txt` – Complete unique subdomain list
* `live_subdomains.txt` – Resolved subdomains
* `naabu_ports.txt` – Open ports (host:port format)
* `httpx_webservers.txt` – Active web servers with URLs
* `crtsh.txt`, `subfinder.txt`, etc. – Raw tool outputs

---

## ⚙️ Configuration

### API Keys

Create an `api_keys.conf` file:

```bash
CHAOS_API_KEY=your_key_here
VT_API_KEY=your_key_here
```

---

### Wordlists

Place your preferred wordlists inside:

```
wordlist/
```

---

## ⚠️ Disclaimer

Use this tool only on domains you own or have explicit permission to test. Unauthorized scanning is illegal.

---
