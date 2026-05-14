#!/bin/bash

# ================================================
# NMAP Commands
# Usage: ./nmap_commands.sh
# Author: Dima Payne
# ================================================

get_target() {
  echo -e "Enter victim IP, r@nge, 0r CIDR (e.g. 10.10.30.10, 10.10.30.0/24, 10.10.10-20.1)"
  read -rp "	Target: " TARGET

  if [[ -z "$TARGET" ]]; then
    echo -e "No target privded. Exiting..."
    exit 1
  fi
}

get_ports() {
  echo ""
  echo -e "Enter ports to scan: "
  echo -e "1) Top 1000 (default)"
  echo -e "2) All ports (1-65535)"
  echo -e "3) Common ports (21,22,23,25,53,80,139,443,445,3389,8000,8080,8443)"
  echo -e "4) Custom ports"
  read -rp "	Choice [1-4]: " PORT_CHOICE

  case $PORT_CHOICE in
  1) PORTS="" ;;
  2) PORTS="-p" ;;
  3) PORTS="-p 21,22,23,25,53,80,139,443,445,3389,8000,8080,8443" ;;
  4)
    read -rp "	Enter ports (e.g. 22,80,443 or 1-1024): " CUSTOM_PORTS
    PORTS="-p $CUSTOM_PORTS"
    ;;
  *) PORTS="" ;;
  esac
}

get_output_file() {
  echo ""
  echo -e "Save output to file? (y/n): "
  read -rp " 	Choice: " SAVE_OUPUT
  if [[ "$SAVE_OUPUT" =~ ^[Yn]$ ]]; then
    read -rp " 	Filename (without extension): " OUTFILE
    OUTPUT_FLAG="-oA $(OUTFILE)"
  else
    OUTPUT_FILE=""
  fi
}

print_commands() {
  echo ""
  echo -e "================================================"
  echo -e " Generating Nmap Commands for: $TARGET"
  echo -e "================================================"
  echo -e ""

  # 1 - Quick ping sweep
  echo -e "Host Discover/Ping sweep"
  echo -e "	nmap -sn $TARGET $OUTPUT_FILE"
  echo -e ""

  # 2 - SYN stealth scan
  echo -e "SYN Scan - Note: Requires root"
  echo -e "	sudo nmap -sS $PORTS $TARGET $OUPUT_FLAG"
  echo -e ""

  # 3 - TCP connect scan
  echo -e "TCP Connect Scan"
  echo -e "	nmap -sT $PORTS $TARGET $OUTPUT_FLAG"
  echo -e ""

  # 4 - UDP scan
  echo -e "UDP scan"
  echo -e "	sudo nmap -sU $PORTS $TARGET $OUTPUT_FLAG"
  echo -e ""

  # 5 - Service/Version Scan
  echo -e "Service and Version Scan"
  echo -e "	nmap -sV $PORTS $TARGET $OUTPUT_FLAG"
  echo -e ""

  # 6 - OS scan
  echo -e "OS scan"
  echo -e "	nmap -O $PORTS $TARGET $OUTPUT_FLAG"
  echo -e ""

  # 7 - Aggressive scan
  echo -e "Aggressive Scan (-A) - OS, version, scripts, traceroute"
  echo -e "	sudo nmap -A $PORTS $TARGETS $OUTPUT_FLAG"
  echo -e ""

  # 8 - Full Active Recon Scan
  echo -e "Full Active Recon scan combining SYN scan, Version scan, and verbose"
  echo -e " 	sudo nmap -sS -sV -sC -v $PORTS $TARGET $OUTPUT_FLAG"
  echo -e ""

  # 9 - Specific NSE scripts
  echo -e "List of NSE scripts for smb, http, ftp, ssh, dns"
  echo -e "	SMB enum:	nmap --script smb-enum-shares,smb-enum-users $PORTS $TARGET"
  echo -e "	HTTP enum:	nmap --script http-enum $PORTS $TARGET"
  echo -e "	SSH auth:	nmap --script ssh-auth-methods $PORTS $TARGET"
  echo -e "	DNS enum: 	nmap --script dns-brute $TARGET"
  echo -e ""
}

get_target
get_ports
get_output_file
print_commands
