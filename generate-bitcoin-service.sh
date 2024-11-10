#!/bin/bash

# Prompt the user for input
read -p "Enter the text to replace 'defaultuser' with: " user_input

# Write the content to the service file with sudo
sudo bash -c "cat > /etc/systemd/system/bitcoin_knots.service" << EOF
[Unit]
Description=Bitcoin Knots Service
After=network.target

[Service]
ExecStart=/usr/local/bin/bitcoind
Restart=always
User=defaultuser
Group=defaultuser

[Install]
WantedBy=multi-user.target
EOF

# Check if the operation was successful
if [ $? -eq 0 ]; then
    echo "File 'datum.service' has been created and user inserted correctly."
else
    echo "An error occurred while creating or editing the file."
fi
