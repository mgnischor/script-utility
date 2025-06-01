#!/bin/bash

# Utility: Linux System Cleanup and Optimization
# Filename: linux-optimization.sh
# Developer: Miguel Nischor <miguel@nischor.com.br>
# Version 1.0

# Color codes
COLOR_INFO='\033[0;32m'     # Green
COLOR_WARNING='\033[0;33m'  # Yellow
COLOR_ERROR='\033[0;31m'    # Red
COLOR_DEFAULT='\033[0m'     # Default

# Log file configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/linux-optimization.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Function to log messages
log_message() {
    echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
}

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${COLOR_DEFAULT}"
    log_message "$message"
}

# Function to check command success
check_command() {
    if [ $? -eq 0 ]; then
        print_message "$COLOR_INFO" "[SUCCESS] $1"
        return 0
    else
        print_message "$COLOR_ERROR" "[ERROR] $1 (Exit code: $?)"
        return 1
    fi
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_message "$COLOR_ERROR" "ERROR: This script must be run as root (use sudo)"
        echo "Please run: sudo $0"
        exit 1
    fi
}

# Initialize log file
echo "========================================" > "$LOG_FILE"
echo "Linux System Cleanup and Optimization" >> "$LOG_FILE"
echo "Started: $TIMESTAMP" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

print_message "$COLOR_INFO" "========================================"
print_message "$COLOR_INFO" "   LINUX SYSTEM CLEANUP AND"
print_message "$COLOR_INFO" "     OPTIMIZATION UTILITY"
print_message "$COLOR_INFO" "========================================"
echo
print_message "$COLOR_INFO" "[INFO] Log file: $LOG_FILE"
log_message "[INFO] Log file initialized"

print_message "$COLOR_WARNING" "WARNING: This script requires root privileges"
echo "Press any key to continue..."
read -n 1 -s

# Check if running as root
check_root

print_message "$COLOR_INFO" "[INFO] Root privileges confirmed"
log_message "[INFO] Root privileges confirmed"

# Create system backup information
print_message "$COLOR_INFO" "[INFO] Creating system backup information..."
log_message "[INFO] Creating system backup information..."
dpkg --get-selections > "${SCRIPT_DIR}/package-backup-$(date +%Y%m%d).txt" 2>/dev/null
if [ $? -eq 0 ]; then
    print_message "$COLOR_INFO" "[SUCCESS] Package list backup created"
else
    print_message "$COLOR_WARNING" "WARNING: Could not create package backup (non-Debian system)"
fi

echo
print_message "$COLOR_INFO" "========================================"
print_message "$COLOR_INFO" "    INITIATING SYSTEM CLEANUP"
print_message "$COLOR_INFO" "========================================"
log_message "[INFO] Starting system cleanup phase"

# 1. Clean package cache
print_message "$COLOR_INFO" "[1/10] Cleaning package cache..."
log_message "[1/10] Cleaning package cache..."

if command -v apt-get >/dev/null 2>&1; then
    apt-get clean >/dev/null 2>&1
    check_command "APT cache cleaned"
    apt-get autoclean >/dev/null 2>&1
    check_command "APT autoclean completed"
elif command -v yum >/dev/null 2>&1; then
    yum clean all >/dev/null 2>&1
    check_command "YUM cache cleaned"
elif command -v dnf >/dev/null 2>&1; then
    dnf clean all >/dev/null 2>&1
    check_command "DNF cache cleaned"
else
    print_message "$COLOR_WARNING" "WARNING: No supported package manager found"
fi

# 2. Remove orphaned packages
print_message "$COLOR_INFO" "[2/10] Removing orphaned packages..."
log_message "[2/10] Removing orphaned packages..."

if command -v apt-get >/dev/null 2>&1; then
    apt-get autoremove -y >/dev/null 2>&1
    check_command "Orphaned packages removed (APT)"
elif command -v yum >/dev/null 2>&1; then
    package-cleanup --orphans -y >/dev/null 2>&1
    check_command "Orphaned packages removed (YUM)"
elif command -v dnf >/dev/null 2>&1; then
    dnf autoremove -y >/dev/null 2>&1
    check_command "Orphaned packages removed (DNF)"
fi

# 3. Clean temporary files
print_message "$COLOR_INFO" "[3/10] Cleaning temporary files..."
log_message "[3/10] Cleaning temporary files..."

rm -rf /tmp/* >/dev/null 2>&1
check_command "Temporary files cleaned"

rm -rf /var/tmp/* >/dev/null 2>&1
check_command "Variable temporary files cleaned"

# 4. Clean user cache directories
print_message "$COLOR_INFO" "[4/10] Cleaning user cache directories..."
log_message "[4/10] Cleaning user cache directories..."

find /home -name ".cache" -type d -exec rm -rf {}/* \; >/dev/null 2>&1
check_command "User cache directories cleaned"

# 5. Clean system logs
print_message "$COLOR_INFO" "[5/10] Cleaning system logs..."
log_message "[5/10] Cleaning system logs..."

if command -v journalctl >/dev/null 2>&1; then
    journalctl --vacuum-time=7d >/dev/null 2>&1
    check_command "Systemd journal cleaned (kept 7 days)"
fi

find /var/log -name "*.log" -type f -mtime +30 -delete >/dev/null 2>&1
check_command "Old log files removed (older than 30 days)"

# 6. Clean browser caches
print_message "$COLOR_INFO" "[6/10] Cleaning browser caches..."
log_message "[6/10] Cleaning browser caches..."

# Chrome/Chromium
find /home -path "*/.cache/google-chrome*" -delete >/dev/null 2>&1
find /home -path "*/.cache/chromium*" -delete >/dev/null 2>&1
check_command "Chrome/Chromium cache cleaned"

# Firefox
find /home -path "*/.cache/mozilla*" -delete >/dev/null 2>&1
check_command "Firefox cache cleaned"

# 7. Clean thumbnail cache
print_message "$COLOR_INFO" "[7/10] Cleaning thumbnail cache..."
log_message "[7/10] Cleaning thumbnail cache..."

find /home -path "*/.cache/thumbnails*" -delete >/dev/null 2>&1
check_command "Thumbnail cache cleaned"

echo
print_message "$COLOR_INFO" "========================================"
print_message "$COLOR_INFO" "    EXECUTING SYSTEM MAINTENANCE"
print_message "$COLOR_INFO" "========================================"
log_message "[INFO] Starting system maintenance phase"

# 8. Update package database
print_message "$COLOR_INFO" "[8/10] Updating package database..."
log_message "[8/10] Updating package database..."

if command -v apt-get >/dev/null 2>&1; then
    apt-get update >/dev/null 2>&1
    check_command "APT package database updated"
elif command -v yum >/dev/null 2>&1; then
    yum check-update >/dev/null 2>&1
    print_message "$COLOR_INFO" "[INFO] YUM package database checked"
elif command -v dnf >/dev/null 2>&1; then
    dnf check-update >/dev/null 2>&1
    print_message "$COLOR_INFO" "[INFO] DNF package database checked"
fi

# 9. Check disk usage and clean if needed
print_message "$COLOR_INFO" "[9/10] Checking disk usage..."
log_message "[9/10] Checking disk usage..."

DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    print_message "$COLOR_WARNING" "WARNING: Disk usage is ${DISK_USAGE}% - Critical level"
    log_message "WARNING: Disk usage is ${DISK_USAGE}% - Critical level"
elif [ "$DISK_USAGE" -gt 80 ]; then
    print_message "$COLOR_WARNING" "WARNING: Disk usage is ${DISK_USAGE}% - High level"
    log_message "WARNING: Disk usage is ${DISK_USAGE}% - High level"
else
    print_message "$COLOR_INFO" "[SUCCESS] Disk usage is ${DISK_USAGE}% - Normal level"
fi

# 10. System optimization
print_message "$COLOR_INFO" "[10/10] Applying system optimizations..."
log_message "[10/10] Applying system optimizations..."

# Update locate database
if command -v updatedb >/dev/null 2>&1; then
    updatedb >/dev/null 2>&1
    check_command "Locate database updated"
fi

# Sync filesystem
sync
check_command "Filesystem synchronized"

echo
print_message "$COLOR_INFO" "========================================"
print_message "$COLOR_INFO" "    APPLYING PERFORMANCE OPTIMIZATIONS"
print_message "$COLOR_INFO" "========================================"
log_message "[INFO] Starting performance optimization phase"

# Optimize swappiness
print_message "$COLOR_INFO" "Optimizing swappiness..."
log_message "[INFO] Optimizing swappiness..."

echo 'vm.swappiness=10' > /etc/sysctl.d/99-swappiness.conf
sysctl vm.swappiness=10 >/dev/null 2>&1
check_command "Swappiness optimized to 10"

# Optimize file system cache
print_message "$COLOR_INFO" "Optimizing file system cache..."
log_message "[INFO] Optimizing file system cache..."

echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.d/99-swappiness.conf
sysctl vm.vfs_cache_pressure=50 >/dev/null 2>&1
check_command "VFS cache pressure optimized"

# Clean memory cache
print_message "$COLOR_INFO" "Cleaning memory cache..."
log_message "[INFO] Cleaning memory cache..."

echo 3 > /proc/sys/vm/drop_caches
check_command "Memory cache cleaned"

echo
print_message "$COLOR_INFO" "========================================"
print_message "$COLOR_INFO" "    FINALIZING OPTIMIZATION PROCESS"
print_message "$COLOR_INFO" "========================================"
log_message "[INFO] Starting finalization phase"

# Update man database
print_message "$COLOR_INFO" "Updating man database..."
log_message "[INFO] Updating man database..."

if command -v mandb >/dev/null 2>&1; then
    mandb >/dev/null 2>&1
    check_command "Man database updated"
fi

# Final timestamp
FINAL_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo
print_message "$COLOR_INFO" "========================================"
print_message "$COLOR_INFO" "    OPTIMIZATION PROCESS COMPLETED"
print_message "$COLOR_INFO" "========================================"
echo
echo "Operations performed:"
echo "- Package cache and orphaned packages cleanup"
echo "- Temporary files and user cache cleanup"
echo "- System logs and browser cache cleanup"
echo "- Package database update"
echo "- System performance optimizations"
echo "- Memory and filesystem optimization"
echo

log_message "========================================"
log_message "Optimization process completed: $FINAL_TIMESTAMP"
log_message "========================================"
echo >> "$LOG_FILE"

print_message "$COLOR_WARNING" "RECOMMENDATION: System restart is recommended"
print_message "$COLOR_WARNING" "to apply all optimization changes."
echo
print_message "$COLOR_INFO" "[INFO] Complete log saved to: $LOG_FILE"
echo
print_message "$COLOR_DEFAULT" "Press any key to exit..."
read -n 1 -s
