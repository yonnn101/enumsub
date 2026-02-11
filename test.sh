#!/usr/bin/env bash

# ----------------------------------------------------------------------
# Subdomain Enumeration Mega Script (with puredns)
# Combines 15+ tools and methods – passive, active, permutations, brute.
# ----------------------------------------------------------------------

set -u
set -o pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

usage() {
    echo -e "${YELLOW}Usage: $0 -d example.com [-w /path/to/wordlist] [-r /path/to/resolvers.txt]${NC}"
    exit 1
}

DEFAULT_WORDLIST="wordlist/n0kovo_subdomains_small.txt"
DEFAULT_RESOLVERS="wordlist/resolvers.txt"
FALLBACK_RESOLVERS="/etc/resolv.conf"

WORDLIST=""; RESOLVERS=""; DOMAIN=""
while getopts "d:w:r:h" opt; do
    case "$opt" in
        d) DOMAIN="$OPTARG" ;;
        w) WORDLIST="$OPTARG" ;;
        r) RESOLVERS="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

[[ -z "$DOMAIN" ]] && { echo -e "${RED}[-] Domain is required${NC}"; usage; }

[[ -z "$WORDLIST" ]] && WORDLIST="$DEFAULT_WORDLIST" && echo -e "${YELLOW}[!] Using default wordlist: $WORDLIST${NC}"
[[ -z "$RESOLVERS" ]] && RESOLVERS="$DEFAULT_RESOLVERS" && echo -e "${YELLOW}[!] Using default resolvers: $RESOLVERS${NC}"

if [[ ! -f "$RESOLVERS" ]]; then
    echo -e "${YELLOW}[!] Resolvers not found, falling back to $FALLBACK_RESOLVERS${NC}"
    RESOLVERS="$FALLBACK_RESOLVERS"
    [[ ! -f "$RESOLVERS" ]] && RESOLVERS="" && echo -e "${RED}[-] No resolvers available${NC}"
fi

WORDLIST_EXISTS=false
[[ -f "$WORDLIST" ]] && WORDLIST_EXISTS=true || echo -e "${YELLOW}[!] Wordlist missing, brute-force skipped${NC}"

OUTDIR="subenum_${DOMAIN}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"
echo -e "${GREEN}[+] Output directory: $OUTDIR${NC}"

RAW_FILES=()

check_tool() { command -v "$1" &>/dev/null; }

echo -e "${GREEN}[+] Starting passive enumeration...${NC}"

# ----------------------------------------------------------------------
# 1. crt.sh
# ----------------------------------------------------------------------
fetch_crtsh() {
    local out="$OUTDIR/crtsh.txt"
    echo -e "${GREEN}[*] Fetching crt.sh${NC}"
    curl -s --fail --max-time 30 \
        -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
        "https://crt.sh/?q=%25.${DOMAIN}&output=json" 2>/dev/null | \
        jq -r '.[]?.name_value // .[]?.common_name // empty' 2>/dev/null | \
        sed 's/\\*\.//g' | sort -u > "$out" || true
    if [[ -s "$out" ]]; then
        RAW_FILES+=("$out"); echo -e "${GREEN}  └─ Found $(wc -l < "$out") subdomains${NC}"
    else
        echo -e "${YELLOW}  └─ No results${NC}"; rm -f "$out"
    fi
}
check_tool curl && check_tool jq && fetch_crtsh

# ----------------------------------------------------------------------
# 2. CertSpotter
# ----------------------------------------------------------------------
fetch_certspotter() {
    local out="$OUTDIR/certspotter.txt"
    echo -e "${GREEN}[*] Fetching CertSpotter${NC}"
    curl -s --max-time 30 \
        -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
        "https://api.certspotter.com/v1/issuances?domain=${DOMAIN}&include_subdomains=true&expand=dns_names" 2>/dev/null | \
        jq -r '.[].dns_names[]? // empty' 2>/dev/null | \
        sed 's/\"//g; s/\*\.//g' | sort -u > "$out" || true
    if [[ -s "$out" ]]; then
        RAW_FILES+=("$out"); echo -e "${GREEN}  └─ Found $(wc -l < "$out") subdomains${NC}"
    else
        echo -e "${YELLOW}  └─ No results${NC}"; rm -f "$out"
    fi
}
check_tool curl && check_tool jq && fetch_certspotter

# ----------------------------------------------------------------------
# 3. Hackertarget
# ----------------------------------------------------------------------
fetch_hackertarget() {
    local out="$OUTDIR/hackertarget.txt"
    echo -e "${GREEN}[*] Fetching Hackertarget${NC}"
    curl -s --max-time 30 \
        -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
        "https://api.hackertarget.com/hostsearch/?q=${DOMAIN}" 2>/dev/null | \
        cut -d, -f1 | sort -u > "$out" || true
    if [[ -s "$out" ]]; then
        RAW_FILES+=("$out"); echo -e "${GREEN}  └─ Found $(wc -l < "$out") subdomains${NC}"
    else
        echo -e "${YELLOW}  └─ No results${NC}"; rm -f "$out"
    fi
}
check_tool curl && fetch_hackertarget

# ----------------------------------------------------------------------
# 4. ThreatCrowd
# ----------------------------------------------------------------------
fetch_threatcrowd() {
    local out="$OUTDIR/threatcrowd.txt"
    echo -e "${GREEN}[*] Fetching ThreatCrowd${NC}"
    curl -s --max-time 30 \
        -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
        "https://www.threatcrowd.org/searchApi/v2/domain/report/?domain=${DOMAIN}" 2>/dev/null | \
        jq -r '.subdomains[]? // empty' 2>/dev/null | sort -u > "$out" || true
    if [[ -s "$out" ]]; then
        RAW_FILES+=("$out"); echo -e "${GREEN}  └─ Found $(wc -l < "$out") subdomains${NC}"
    else
        echo -e "${YELLOW}  └─ No results${NC}"; rm -f "$out"
    fi
}
check_tool curl && check_tool jq && fetch_threatcrowd

# ----------------------------------------------------------------------
# 5. Anubis
# ----------------------------------------------------------------------
fetch_anubis() {
    local out="$OUTDIR/anubis.txt"
    echo -e "${GREEN}[*] Fetching Anubis${NC}"
    curl -s --max-time 30 \
        -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
        "https://jldc.me/anubis/subdomains/${DOMAIN}" 2>/dev/null | \
        jq -r '.[]? // empty' 2>/dev/null | sort -u > "$out" || true
    if [[ -s "$out" ]]; then
        RAW_FILES+=("$out"); echo -e "${GREEN}  └─ Found $(wc -l < "$out") subdomains${NC}"
    else
        echo -e "${YELLOW}  └─ No results${NC}"; rm -f "$out"
    fi
}
check_tool curl && check_tool jq && fetch_anubis

# ----------------------------------------------------------------------
# 6. VirusTotal (requires API key)
# ----------------------------------------------------------------------
fetch_virustotal() {
    if [[ -n "${VT_API_KEY:-}" ]]; then
        local out="$OUTDIR/virustotal.txt"
        echo -e "${GREEN}[*] Fetching VirusTotal${NC}"
        curl -s --max-time 30 \
            -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
            --request GET \
            --url "https://www.virustotal.com/api/v3/domains/${DOMAIN}/subdomains?limit=40" \
            --header "x-apikey: ${VT_API_KEY}" 2>/dev/null | \
            jq -r '.data[].id? // empty' 2>/dev/null | sort -u > "$out" || true
        if [[ -s "$out" ]]; then
            RAW_FILES+=("$out"); echo -e "${GREEN}  └─ Found $(wc -l < "$out") subdomains${NC}"
        else
            echo -e "${YELLOW}  └─ No results${NC}"; rm -f "$out"
        fi
    else
        echo -e "${YELLOW}[!] VT_API_KEY not set – skipping VirusTotal${NC}"
    fi
}
check_tool curl && check_tool jq && fetch_virustotal

# ----------------------------------------------------------------------
# 7. Passive Tools (subfinder, assetfinder, sublist3r, amass passive)
# ----------------------------------------------------------------------
if check_tool "subfinder"; then
    out="$OUTDIR/subfinder.txt"
    echo -e "${GREEN}[*] Running subfinder${NC}"
    subfinder -d "$DOMAIN" -silent > "$out" 2>/dev/null || true
    [[ -s "$out" ]] && RAW_FILES+=("$out") && echo -e "${GREEN}  └─ Found $(wc -l < "$out") subdomains${NC}"
fi

if check_tool "assetfinder"; then
    out="$OUTDIR/assetfinder.txt"
    echo -e "${GREEN}[*] Running assetfinder${NC}"
    assetfinder --subs-only "$DOMAIN" > "$out" 2>/dev/null || true
    [[ -s "$out" ]] && RAW_FILES+=("$out") && echo -e "${GREEN}  └─ Found $(wc -l < "$out") subdomains${NC}"
fi

if check_tool "sublist3r"; then
    out="$OUTDIR/sublist3r.txt"
    echo -e "${GREEN}[*] Running sublist3r${NC}"
    sublist3r -d "$DOMAIN" -o "$out" &> /dev/null || true
    [[ -s "$out" ]] && RAW_FILES+=("$out") && echo -e "${GREEN}  └─ Found $(wc -l < "$out") subdomains${NC}"
fi

if check_tool "amass"; then
    out="$OUTDIR/amass_passive.txt"
    echo -e "${GREEN}[*] Running amass (passive)${NC}"
    amass enum -passive -d "$DOMAIN" -o "$out" &> /dev/null || true
    [[ -s "$out" ]] && RAW_FILES+=("$out") && echo -e "${GREEN}  └─ Found $(wc -l < "$out") subdomains${NC}"
fi

# ----------------------------------------------------------------------
# Merge passive results
# ----------------------------------------------------------------------
ALL_SUBS="$OUTDIR/all_passive_subs.txt"
if [[ ${#RAW_FILES[@]} -gt 0 ]]; then
    cat "${RAW_FILES[@]}" 2>/dev/null | grep -E "\.${DOMAIN}$" | sort -u > "$ALL_SUBS" 2>/dev/null || true
fi
PASSIVE_COUNT=$(wc -l < "$ALL_SUBS" 2>/dev/null || echo 0)
echo -e "${GREEN}[+] Passive subdomains collected: $PASSIVE_COUNT${NC}"

# ----------------------------------------------------------------------
# Permutation & Brute‑force (unchanged, but works with fixed passive list)
# ----------------------------------------------------------------------
# ... (rest of the script remains identical to the previous version) ...

echo -e "${GREEN}[+] Enumeration complete. Results in: $OUTDIR${NC}"
