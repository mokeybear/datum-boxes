# Prompt the user for input
read -p "Enter the text to replace 'defaultuser' with: " user_input

# Write the content to the service file with sudo
sudo bash -c "cat > /etc/systemd/system/datum.service" << EOF
[Unit]
Description=Datum Gateway Service
After=network.target

[Service]
LimitNOFILE=65535
ExecStart=/home/$user_input/datum/datum_gateway --config=/home/$user_input/datum/datum_gateway_config.json
Restart=always
User=$user_input
Group=$user_input

[Install]
WantedBy=multi-user.target
EOF

# Check if the operation was successful
if [ $? -eq 0 ]; then
    echo "File 'datum.service' has been created and user inserted correctly."
else
    echo "An error occurred while creating or editing the file."
fi
