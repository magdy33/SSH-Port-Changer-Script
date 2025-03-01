########################################################
#Auther : magdi              #
#Description: this script will change the port in sshd_config file          #
#Date :                 #Sat Mar 1 10:44:42 AM EET 2025
#Modified :             #
########################################################
########################################################

#!/bin/bash

DEFAULT_PORT=9999
CONFIG_FILE="/etc/ssh/sshd_config"
BACKUP_FILE="/etc/ssh/sshd_config.bak"
NEW_PORT=""

########################################################

# Usage function to display help message
usage() {
    echo "Usage: $0 [-p port_number] [-h]"
    echo "  -p PORT   Specify the new SSH port (default: $DEFAULT_PORT)"
    echo "  -h        Show this help message and exit"
    exit 1
}

# If no options are provided, show usage
if [ $# -eq 0 ]; then
    usage
fi

# Parse command-line options
while getopts "p:h" opt; do
    case "$opt" in
        p) NEW_PORT=$OPTARG ;;  # Get the port number from -p option
        h) usage ;;             # Show help message
        *) usage ;;             # Invalid option
    esac
done


##############################################################

# If no port provided, use the default port
if [ -z "$NEW_PORT" ]; then
    NEW_PORT=$DEFAULT_PORT
fi

echo "Using SSH port: $NEW_PORT"

##############################################################

# Create a backup before modifying the file
if [ ! -f "$BACKUP_FILE" ]; then
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "Backup created at $BACKUP_FILE"
fi

##############################################################

# Modify the SSH port
if grep -q "^Port " "$CONFIG_FILE"; then
    sed -i "s/^Port .*/Port $NEW_PORT/" "$CONFIG_FILE"
else
    echo "Port $NEW_PORT" >> "$CONFIG_FILE"
fi

echo "Port changed to $NEW_PORT"

##############################################################

# Configure Firewall (iptables or firewalld)
if command -v firewall-cmd &> /dev/null; then
    echo "Configuring firewalld..."
    firewall-cmd --add-port=$NEW_PORT/tcp --permanent
    firewall-cmd --reload
elif command -v ufw &> /dev/null; then
    echo "Configuring UFW..."
    ufw allow $NEW_PORT/tcp
    ufw reload
else
    echo "No known firewall tool detected. Please configure the firewall manually if needed."
fi

########################################################################


# Configure SELinux if enabled
if command -v getenforce &> /dev/null && [ "$(getenforce)" == "Enforcing" ]; then
    echo "Configuring SELinux..."
    semanage port -a -t ssh_port_t -p tcp $NEW_PORT 2>/dev/null || semanage port -m -t ssh_port_t -p tcp $NEW_PORT
    echo "SELinux updated for SSH port $NEW_PORT"
fi

#############################################################################

# Restart the SSH service to apply changes
systemctl restart sshd && echo "SSH service restarted successfully" || echo "Failed to restart SSH service"

# Display the new port to confirm the change
sshd -T | grep "port"

