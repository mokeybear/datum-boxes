# Function to get user input with default value
get_input() {
    read -p "$1 (default: $2): " input
    echo "${input:-$2}"
}

echo "Where do you want to store datum_gateway_config.json?"
read -p "Enter path (default: /home/bitcoin/datum/): " config_path
config_path=${config_path:-/home/bitcoin/datum/}
filename="$config_path datum_gateway_config.json"

# Create JSON content with user inputs or defaults
json_content=$(cat <<EOF
{
  "bitcoind": {
    "rpcurl": "$(get_input "Enter bitcoind rpcurl" "localhost:28332")",
    "rpcuser": "$(get_input "Enter bitcoind rpcuser" "datumuser")",
    "rpcpassword": "$(get_input "Enter bitcoind rpcpassword" "")",
    "work_update_seconds": $(get_input "Enter work_update_seconds" 40)
  },
  "stratum": {
    "listen_port": $(get_input "Enter stratum listen_port" 23334),
    "max_clients_per_thread": $(get_input "Enter max_clients_per_thread" 2000),
    "max_threads": $(get_input "Enter max_threads" 10),
    "max_clients": $(get_input "Enter max_clients" 20000),
    "vardiff_min": $(get_input "Enter vardiff_min" 16384)
  },
  "mining": {
    "pool_address": "$(get_input "Enter pool_address" "")",
    "coinbase_tag_primary": "$(get_input "Enter coinbase_tag_primary" "OCEAN")",
    "coinbase_tag_secondary": "$(get_input "Enter coinbase_tag_secondary" "")"
  },
  "api": {
    "listen_port": $(get_input "Enter API listen_port" 7152)
  },
  "logger": {
    "log_to_file": $(get_input "Log to file? (true/false)" true),
    "log_file": "$(get_input "Enter log file path" "/home/bitcoin/datum/logs.txt")",
    "log_level_file": $(get_input "Enter log level (0-3)" 0)
  },
  "datum": {
    "pool_host": "$(get_input "Enter pool host" "datum-beta1.mine.ocean.xyz")",
    "pool_port": $(get_input "Enter pool port" 28915),
    "pool_pass_workers": $(get_input "Pass workers to pool? (true/false)" true),
    "pool_pass_full_users": $(get_input "Pass stratum miner usernames as raw usernames to the pool? (true/false)" true),
    "pooled_mining_only": $(get_input "Pooled mining only? (true/false)" true)
  }
}
EOF
)

# Write the JSON content to the file
echo "$json_content" | sudo tee "$filename" > /dev/null

# Check if file was created successfully
if [ $? -eq 0 ]; then
    echo "File '$filename' created successfully."
else
    echo "An error occurred while creating the file."
fi
