#!/bin/bash

set -euo pipefail

CPU_THRESHOLD=70
MEM_THRESHOLD=70
DISK_THRESHOLD=70

HOSTNAME=$(hostname)
UPTIME=$(uptime)

CPU_USAGE=$(top -bn2 -d 0.5 | grep "%Cpu(s)" | tail -n 1 | awk '{print 100 - $8}')
CPU_INT=$(printf "%.0f" "$CPU_USAGE")

MEM_USAGE=$(free | awk 'NR==2 {printf "%.1f", $3/$2*100}')
MEM_INT=$(printf "%.0f" "$MEM_USAGE")

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

EXIT_CODE=0

echo "================================="
echo "       SERVER HEALTH CHECK"
echo "================================="

echo
echo "Hostname : $HOSTNAME"
echo "Uptime   : $UPTIME"

echo
echo "CPU Usage    : $CPU_USAGE%"
echo "Memory Usage : $MEM_USAGE%"
echo "Disk Usage   : $DISK_USAGE%"

echo
echo "===== HEALTH STATUS ====="

if [ "$CPU_INT" -le "$CPU_THRESHOLD" ]; then
    echo "CPU    : OK"
else
    echo "CPU    : HIGH"
    EXIT_CODE=1
fi

if [ "$MEM_INT" -le "$MEM_THRESHOLD" ]; then
    echo "Memory : OK"
else
    echo "Memory : HIGH"
    EXIT_CODE=1
fi

if [ "$DISK_USAGE" -le "$DISK_THRESHOLD" ]; then
    echo "Disk   : OK"
else
    echo "Disk   : HIGH"
    EXIT_CODE=1
fi

echo

if [ "$EXIT_CODE" -eq 0 ]; then
    echo "Overall Status: HEALTHY"
else
    echo "Overall Status: UNHEALTHY"
fi

exit "$EXIT_CODE"