#!/bin/bash
# Remote Server Monitoring Script
# Runs on Windows workstation, connects to Ubuntu server via SSH

SERVER_USER="upendra"
SERVER_IP="192.168.56.101"
SSH_KEY="C:/Users/Admin/OneDrive/Desktop/Upendra-Ubuntu/id_ed25519"

echo "=========================================="
echo "Remote Server Monitoring Report"
echo "=========================================="
echo "Connecting to: $SERVER_USER@$SERVER_IP"
echo "Timestamp: $(date)"
echo ""

# System Uptime and Load
echo "--- System Uptime and Load ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "uptime"
echo ""

# CPU Usage
echo "--- CPU Usage (Top 5 Processes) ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "ps aux --sort=-%cpu | head -n 6"
echo ""

# Memory Usage
echo "--- Memory Usage ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "free -h"
echo ""

# Disk Usage
echo "--- Disk Usage ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "df -h | grep -E '^/dev/'"
echo ""

# Network Statistics
echo "--- Network Interfaces ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "ip -br addr"
echo ""

# Active Network Connections
echo "--- Active Connections ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "ss -tuln | head -n 10"
echo ""

# Running Services
echo "--- Critical Services Status ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "systemctl is-active ssh nginx fail2ban apparmor unattended-upgrades"
echo ""

# System Load Average
echo "--- Load Average ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "cat /proc/loadavg"
echo ""

echo "=========================================="
echo "Remote Monitoring Complete"
echo "=========================================="