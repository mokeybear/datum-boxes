#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Treat unset variables as an error

# Helper function for user input with default values
get_input() {
    read -p "$1 (default: $2): " input
    echo "${input:-$2}"
}

echo "### Cloning and Compiling datum_gateway"
sleep 2
mkdir -p ~/datum/source-code
cd ~/datum/source-code || exit 1
git clone https://github.com/OCEAN-xyz/datum_gateway || { echo "Failed to clone repository."; exit 1; }
cd datum_gateway || exit 1
cmake . && make || { echo "Compilation failed."; exit 1; }
cp datum_gateway ~/datum || { echo "Failed to copy compiled binary."; exit 1; }

echo "### Generating datum_gateway_config.json"
sleep 2

# Get configuration path
config_path=$(get_input "Enter path to store datum_gateway_config.json" "/home/bitcoin/datum/")
config_path="${config_path%/}"  # Remove trailing slash if any
sudo mkdir -p "$config_path" || { echo "Failed to create configuration directory."; exit 1; }
filename="$config_path/datum_gateway_config.json"

# Collect inputs
rpcurl=$(get_input "Enter bitcoind rpcurl" "localhost:28332")
rpcuser=$(get_input "Enter bitcoind rpcuser" "datumuser")
rpcpassword=$(get_input "Enter bitcoind rpcpassword" "")
work_update_seconds=$(get_input "Enter work_update_seconds" 40)
stratum_listen_port=$(get_input "Enter stratum listen_port" 23334)
max_clients_per_thread=$(get_input "Enter max_clients_per_thread" 2000)
max_threads=$(get_input "Enter max_threads" 10)
max_clients=$(get_input "Enter max_clients" 20000)
vardiff_min=$(get_input "Enter vardiff_min" 16384)
pool_address=$(get_input "Enter pool_address" "")
coinbase_tag_primary=$(get_input "Enter coinbase_tag_primary" "OCEAN")
coinbase_tag_secondary=$(get_input "Enter coinbase_tag_secondary" "")
api_listen_port=$(get_input "Enter API listen_port" 7152)
log_to_file=$(get_input "Log to file? (true/false)" true)
log_file=$(get_input "Enter log file path" "/home/bitcoin/datum/logs.txt")
log_level_file=$(get_input "Enter log level (0-3)" 0)
pool_host=$(get_input "Enter pool host" "datum-beta1.mine.ocean.xyz")
pool_port=$(get_input "Enter pool port" 28915)
pool_pass_workers=$(get_input "Pass workers to pool? (true/false)" true)
pool_pass_full_users=$(get_input "Pass stratum miner usernames as raw usernames to the pool? (true/false)" true)
pooled_mining_only=$(get_input "Pooled mining only? (true/false)" true)

# Create JSON content
json_content=$(cat <<EOF
{
  "bitcoind": {
    "rpcurl": "$rpcurl",
    "rpcuser": "$rpcuser",
    "rpcpassword": "$rpcpassword",
    "work_update_seconds": $work_update_seconds
  },
  "stratum": {
    "listen_port": $stratum_listen_port,
    "max_clients_per_thread": $max_clients_per_thread,
    "max_threads": $max_threads,
    "max_clients": $max_clients,
    "vardiff_min": $vardiff_min
  },
  "mining": {
    "pool_address": "$pool_address",
    "coinbase_tag_primary": "$coinbase_tag_primary",
    "coinbase_tag_secondary": "$coinbase_tag_secondary"
  },
  "api": {
    "listen_port": $api_listen_port
  },
  "logger": {
    "log_to_file": $log_to_file,
    "log_file": "$log_file",
    "log_level_file": $log_level_file
  },
  "datum": {
    "pool_host": "$pool_host",
    "pool_port": $pool_port,
    "pool_pass_workers": $pool_pass_workers,
    "pool_pass_full_users": $pool_pass_full_users,
    "pooled_mining_only": $pooled_mining_only
  }
}
EOF
)

# Write JSON content to file
echo "$json_content" | sudo tee "$filename" > /dev/null || { echo "Failed to create configuration file."; exit 1; }
sudo chown "$USER:$USER" "$filename" || { echo "Failed to set file ownership."; exit 1; }
echo "File '$filename' created successfully."

echo "### Creating Datum systemd service"
sleep 2

# Get systemd service user
user_input=$(get_input "Enter the user to run the Datum service" "$USER")

# Create systemd service file
sudo bash -c "cat > /etc/systemd/system/datum.service" <<EOF
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

# Reload systemd daemon and enable service
sudo systemctl daemon-reload || { echo "Failed to reload systemd daemon."; exit 1; }
sudo systemctl enable datum.service || { echo "Failed to enable datum.service."; exit 1; }
echo "Systemd service 'datum.service' created and enabled successfully."

echo "### Script completed successfully!"
