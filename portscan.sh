#!/data/data/com.termux/files/usr/bin/bash
# Author: Argh94 (Adapted from Prince Kumar's script)
# Date: 6 Jun 2025
# Version: V1.1
# Simple Port Scanner with Auto-Setup for Termux

# Step 1: Auto-update Termux and install required packages
echo -e "\033[32m[*] Updating Termux and installing required packages...\033[0m"
pkg update -y && pkg upgrade -y
pkg install bash coreutils netcat -y

# Step 2: Clear screen and display new banner
clear
echo -e "\e[32m          ▄▀▄     ▄▀▄"
echo -e "\e[32m         ▄█░░▀▀▀▀▀░░█▄"
echo -e "\e[32m     ▄▄  █░░░░░░░░░░░█  ▄▄"
echo -e "\e[32m    █▄▄█ █░░█░░┬░░█░░█ █▄▄█"
echo -e "\e[36m ╔════════════════════════════════════╗"
echo -e "\e[32m ║ ♚ Project: Port Scanner Tool       ║"
echo -e "\e[32m ║ ♚ Author: Argh94                   ║"
echo -e "\e[32m ║ ♚ GitHub: https://GitHub.com/Argh94║"
echo -e "\e[36m ╚════════════════════════════════════╝"
echo -e "\e[0m"

# Animation for starting scan
banner="S T A R T I N G _ S C A N"
for char in $banner; do
    echo -n "$char "
    sleep 0.2
done
echo ""
sleep 1

# Step 3: Get user input
read -p $'\033[33;1m(\033[31m+\033[33m)\033[36m Enter an IP or Domain: ' host
echo ""
read -p $'\033[31;1m(\033[32m+\033[31m)\033[35m Enter start port: ' s_point
echo ""
read -p $'\033[31;1m(\033[32m+\033[31m)\033[35m Enter end port: ' e_point
echo ""

# Input validation
if ! [[ "$s_point" =~ ^[0-9]+$ && "$e_point" =~ ^[0-9]+$ ]]; then
    echo -e "\033[31m[!] Start port and end port must be numbers!\033[0m"
    exit 1
fi
if [ -z "$host" ]; then
    echo -e "\033[31m[!] Host/IP cannot be empty!\033[0m"
    exit 1
fi
if [ "$e_point" -lt "$s_point" ]; then
    echo -e "\033[31m[!] End port must be greater than or equal to start port!\033[0m"
    exit 1
fi

# Function to scan a single port
scan_port() {
    local host=$1
    local port=$2
    nc -w 1 -z $host $port 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "$port"
    fi
}

# Progress bar simulation (simple counter)
total_ports=$((e_point - s_point + 1))
current=0
open_ports=()

echo -e "\033[32m[*] Starting port scan on $host...\033[0m"

# Single-threaded scan (for termux compatibility)
for ((port=s_point; port<=e_point; port++)); do
    result=$(scan_port "$host" "$port")
    if [ ! -z "$result" ]; then
        open_ports+=("$result")
        echo -ne "\r\033[32m[+] Open port: $port\033[0m                    "
    fi
    ((current++))
    percentage=$((current * 100 / total_ports))
    echo -ne "\rScanning: $percentage% ($port/$e_point)"
done

echo -e "\n\033[32m[*] Scan completed!\033[0m"
if [ ${#open_ports[@]} -gt 0 ]; then
    echo -e "\033[36m[+] Open ports on $host:\033[0m"
    printf "%s\n" "${open_ports[@]}"
else
    echo -e "\033[31m[-] No open ports found in range.\033[0m"
fi
