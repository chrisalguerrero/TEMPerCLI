#!/bin/bash
# TEMPer1F (3553:a001) Installation Script for RHEL 9.7
# Uses Python-based temper.py which supports newer TEMPer devices

set -e

echo "TEMPer1F Installation for RHEL 9.7"
echo "===================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# Install required dependencies
echo "Installing dependencies..."
dnf install -y python3 python3-pip git

# Install Python USB library
echo "Installing Python USB libraries..."
pip3 install pyusb

# Create working directory
WORK_DIR="/tmp/temper_install"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Clone the Python-based temper repository
echo "Cloning temper.py repository..."
if [ -d "temper" ]; then
    rm -rf temper
fi
git clone https://github.com/ccwienk/temper.git
cd temper

# Make temper.py executable
chmod +x temper.py

# Install to /usr/local/bin
echo "Installing temper.py to /usr/local/bin/..."
cp temper.py /usr/local/bin/temper-read
chmod +x /usr/local/bin/temper-read

# Create udev rules for device permissions
echo "Setting up udev rules..."
cat > /etc/udev/rules.d/99-temper.rules << 'EOF'
# TEMPer USB thermometer devices - allow non-root access
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0c45", ATTRS{idProduct}=="7401", MODE="0666", GROUP="plugdev"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0c45", ATTRS{idProduct}=="7402", MODE="0666", GROUP="plugdev"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="413d", ATTRS{idProduct}=="2107", MODE="0666", GROUP="plugdev"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="e025", MODE="0666", GROUP="plugdev"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="5523", MODE="0666", GROUP="plugdev"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="3553", ATTRS{idProduct}=="a001", MODE="0666", GROUP="plugdev"
EOF

# Create plugdev group if it doesn't exist
if ! getent group plugdev > /dev/null 2>&1; then
    groupadd plugdev
    echo "Created 'plugdev' group"
fi

# Add current user to plugdev group (if not root)
if [ -n "$SUDO_USER" ]; then
    usermod -a -G plugdev "$SUDO_USER"
    echo "Added user '$SUDO_USER' to 'plugdev' group"
fi

# Reload udev rules
udevadm control --reload-rules
udevadm trigger

echo ""
echo "Installation complete!"
echo "===================="
echo ""
echo "Your TEMPer1F device (3553:a001) is now supported!"
echo ""
echo "IMPORTANT: You need to log out and log back in for group membership to take effect!"
echo "Or run: newgrp plugdev"
echo ""
echo "After logging back in, unplug and replug your device, then run:"
echo "  temper-read"
echo ""
echo "For JSON output:"
echo "  temper-read --json"
echo ""
echo "To force reading your specific device:"
echo "  temper-read --force 3553:a001"
echo ""
echo "For detailed debugging:"
echo "  temper-read --force 3553:a001 --json"
echo ""

# Cleanup option
read -p "Remove temporary files? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd /
    rm -rf "$WORK_DIR"
    echo "Temporary files removed."
fi

echo ""
echo "Quick test (run as root):"
echo "  /usr/local/bin/temper-read --force 3553:a001"
