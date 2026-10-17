#!/usr/bin/env bash
set -euo pipefail

# Server Health Monitor
# Purpose: Monitor CPU, memory, disk, load average, and uptime.
# Usage: ./health_check.sh [--help]
# Logs:  logs/health.log

set -u

# Print usage information and exit successfully.
show_help() {
    cat <<'EOF'
Server Health Monitor

Usage:
  ./health_check.sh [OPTION]

Options:
  -h, --help    Show this help message and exit

Description:
  Checks CPU utilization, memory usage, root disk usage,
  load average, and server uptime. Appends a timestamped
  report to logs/health.log.

Examples:
  ./health_check.sh
  ./health_check.sh --help
EOF
}

# Display help if requested. Reject unsupported arguments.
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    "")
        ;;
    *)
        echo "Error: Unknown option: $1" >&2
        echo "Run './health_check.sh --help' for usage." >&2
        exit 2
        ;;
esac


# Project paths
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/health.log"

# Warning thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

mkdir -p "$LOG_DIR"

# Get CPU utilization over a one-second interval
read_cpu() {
    local cpu user nice system idle iowait irq softirq steal rest

    read -r cpu user nice system idle iowait irq softirq steal rest < /proc/stat

    CPU_TOTAL=$((user + nice + system + idle + iowait + irq + softirq + steal))
    CPU_IDLE=$((idle + iowait))
}

read_cpu
total1=$CPU_TOTAL
idle1=$CPU_IDLE

sleep 1

read_cpu
total2=$CPU_TOTAL
idle2=$CPU_IDLE

total_diff=$((total2 - total1))
idle_diff=$((idle2 - idle1))

if (( total_diff > 0 )); then
    CPU_USAGE=$((100 * (total_diff - idle_diff) / total_diff))
else
    CPU_USAGE=0
fi

# Memory usage percentage
MEMORY_USAGE=$(free | awk '/^Mem:/ {
    if ($2 > 0) printf "%.0f", (($2 - $7) / $2) * 100
}')

# Root filesystem disk usage percentage
DISK_USAGE=$(df -P / | awk 'NR == 2 {
    gsub(/%/, "", $5)
    print $5
}')

# Load average and uptime
LOAD_AVERAGE=$(awk '{print $1}' /proc/loadavg)
UPTIME=$(uptime -p)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Write the report to the log
{
    echo "======================================"
    echo "Timestamp: $TIMESTAMP"
    echo "CPU Usage: ${CPU_USAGE}%"
    echo "Memory Usage: ${MEMORY_USAGE}%"
    echo "Disk Usage: ${DISK_USAGE}%"
    echo "Load Average (1 min): $LOAD_AVERAGE"
    echo "Uptime: $UPTIME"

    if (( CPU_USAGE >= CPU_THRESHOLD )); then
        echo "WARNING: High CPU usage"
    fi

    if (( MEMORY_USAGE >= MEMORY_THRESHOLD )); then
        echo "WARNING: High memory usage"
    fi

    if (( DISK_USAGE >= DISK_THRESHOLD )); then
        echo "WARNING: High disk usage"
    fi

    echo "Status: Health check completed"
} >> "$LOG_FILE"

echo "Health check completed at $TIMESTAMP"
echo "CPU: ${CPU_USAGE}% | Memory: ${MEMORY_USAGE}% | Disk: ${DISK_USAGE}%"
echo "Report saved to: $LOG_FILE"
