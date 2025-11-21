#!/bin/bash

# Detect machine architecture using uname -m
ARCH=$(uname -m)
HOSTNAME=$(hostname)

echo "System Information:"
echo "  Architecture: $ARCH"
echo "  Hostname: $HOSTNAME"
echo ""

# Function to list all wireless interfaces starting with 'wl'
list_wl_interfaces() {
    echo "Scanning for wireless interfaces (wl*)..."
    local found=0
    
    for iface in $(ip link show | grep -oP '(?<=: )wl[^:]+(?=:)'); do
        found=1
        local state=$(ip link show "$iface" | grep -oP '(?<=state )\w+')
        local ip_addr=$(ip -4 addr show "$iface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
        
        echo "  Found: $iface"
        echo "    State: $state"
        if [[ -n "$ip_addr" ]]; then
            echo "    IP: $ip_addr"
        else
            echo "    IP: Not assigned"
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        echo "  No wireless interfaces (wl*) found."
    fi
    echo ""
}

# Function to find the first active wireless interface with IP
find_active_wl_interface() {
    for iface in $(ip link show | grep -oP '(?<=: )wl[^:]+(?=:)'); do
        # Check if interface is UP and has an IP address
        if ip link show "$iface" 2>/dev/null | grep -q "state UP"; then
            IP_ADDR=$(ip -4 addr show "$iface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
            if [[ -n "$IP_ADDR" ]]; then
                echo "$iface"
                return 0
            fi
        fi
    done
    return 1
}

# List all wireless interfaces
list_wl_interfaces

# Determine machine type and network interface based on architecture
if [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
    # ARM64 architecture - Jetson Xavier NX
    MACHINE_TYPE="JETSON"
    
    # Try to find active wireless interface first
    ACTIVE_WL=$(find_active_wl_interface)
    if [[ -n "$ACTIVE_WL" ]]; then
        NETWORK_INTERFACE="$ACTIVE_WL"
        echo "Selected active wireless interface: $NETWORK_INTERFACE"
    elif ip link show wlan0 &> /dev/null && ip link show wlan0 | grep -q "state UP"; then
        NETWORK_INTERFACE="wlan0"
        echo "Using wlan0"
    elif ip link show eth0 &> /dev/null && ip link show eth0 | grep -q "state UP"; then
        NETWORK_INTERFACE="eth0"
        echo "Fallback to eth0 (wired)"
    else
        echo "Warning: No active network interface found. Using auto."
        NETWORK_INTERFACE="auto"
    fi
    
elif [[ "$ARCH" == "x86_64" ]] || [[ "$ARCH" == "amd64" ]]; then
    # x86_64 architecture - Laptop
    MACHINE_TYPE="LAPTOP"
    
    # Try to find active wireless interface first
    ACTIVE_WL=$(find_active_wl_interface)
    if [[ -n "$ACTIVE_WL" ]]; then
        NETWORK_INTERFACE="$ACTIVE_WL"
        echo "Selected active wireless interface: $NETWORK_INTERFACE"
    elif ip link show eth0 &> /dev/null && ip link show eth0 | grep -q "state UP"; then
        NETWORK_INTERFACE="eth0"
        echo "Fallback to eth0 (wired)"
    else
        echo "Warning: No active network interface found. Using auto."
        NETWORK_INTERFACE="auto"
    fi
    
else
    # Unknown architecture
    echo "WARNING: Unknown architecture: $ARCH"
    NETWORK_INTERFACE="auto"
    MACHINE_TYPE="UNKNOWN"
fi

echo ""
echo "Configuration:"
echo "  Machine Type: $MACHINE_TYPE"
echo "  Network Interface: $NETWORK_INTERFACE"

# Display interface details if not auto
if [[ "$NETWORK_INTERFACE" != "auto" ]]; then
    if ip link show "$NETWORK_INTERFACE" 2>/dev/null | grep -q "state UP"; then
        echo "  Interface Status: UP ✓"
        
        # Get IP address
        IP_ADDR=$(ip -4 addr show "$NETWORK_INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
        if [[ -n "$IP_ADDR" ]]; then
            echo "  IP Address: $IP_ADDR"
        fi
        
        # Get MAC address
        MAC_ADDR=$(ip link show "$NETWORK_INTERFACE" | grep -oP '(?<=link/ether\s)[0-9a-f:]+' | head -1)
        if [[ -n "$MAC_ADDR" ]]; then
            echo "  MAC Address: $MAC_ADDR"
        fi
        
        # Get network statistics
        RX_BYTES=$(cat /sys/class/net/"$NETWORK_INTERFACE"/statistics/rx_bytes 2>/dev/null)
        TX_BYTES=$(cat /sys/class/net/"$NETWORK_INTERFACE"/statistics/tx_bytes 2>/dev/null)
        if [[ -n "$RX_BYTES" && -n "$TX_BYTES" ]]; then
            RX_MB=$((RX_BYTES / 1024 / 1024))
            TX_MB=$((TX_BYTES / 1024 / 1024))
            echo "  Traffic: RX ${RX_MB}MB / TX ${TX_MB}MB"
        fi
    fi
fi

# Generate CycloneDDS configuration

# Create the config file with substituted values
cat > $HOME/cyclonedds_config.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<CycloneDDS xmlns="https://cdds.io/config" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://cdds.io/config https://raw.githubusercontent.com/eclipse-cyclonedds/cyclonedds/master/etc/cyclonedds.xsd">
    <Domain id="${ROS_DOMAIN_ID}">
        <General>
            <NetworkInterfaceAddress>${NETWORK_INTERFACE}</NetworkInterfaceAddress>
            <AllowMulticast>true</AllowMulticast>
        </General>
        <Internal>
            <MaxMessageSize>65500B</MaxMessageSize>
        </Internal>
    </Domain>
</CycloneDDS>
EOF

# Export the file path
export CYCLONEDDS_URI=file://$HOME/cyclonedds_config.xml

echo ""
echo "ROS2 DDS configured successfully!"
echo "ROS_DOMAIN_ID=$ROS_DOMAIN_ID"
echo "RMW_IMPLEMENTATION=$RMW_IMPLEMENTATION"
