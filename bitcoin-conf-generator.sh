#!/bin/bash

# Function to check if a directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        echo "Error: Directory '$1' does not exist."
        exit 1
    fi
}

# Prompt the user for inputs with better handling
read -p "Enter the directory for 'bitcoin.conf' (e.g., /path/to/config/): " user_input1
read -p "Enter the directory for data (e.g., /path/to/data/): " user_input2
read -p "Enter value for 'prune': " user_input3
read -p "Enter value for 'dbcache' (default: 1000): " user_input4
user_input4=${user_input4:-1000} # Set default value if input is empty
read -s -p "Enter value for 'rpcauth' (input will be hidden): " user_input5
echo ""

# Remove trailing slashes and construct the full path for bitcoin.conf
conf_path="${user_input1%/}/bitcoin.conf"

# Validate directories
check_directory "$user_input1"
check_directory "$user_input2"

# Create or overwrite the configuration file with sudo
sudo bash -c "cat > $conf_path" << EOF
datadir=$user_input2
upnp=0
listen=1
noirc=0
txindex=0
daemon=0
server=1
rpcallowip=127.0.0.0/8
rpcport=28332
rpctimeout=30
testnet=0
rpcthreads=64
rpcworkqueue=64
logtimestamps=1
logips=1
blockprioritysize=0
blockmaxsize=3985000
blockmaxweight=3985000
blocknotify=killall -USR1 datum_gateway
maxconnections=40
maxmempool=1000
blockreconstructionextratxn=1000000
prune=$user_input3
maxorphantx=50000
assumevalid=000000000000000000014b9196b45c6641432d600fc43ae891fce1cd25620500
dbcache=$user_input4
rpcauth=$user_input5
EOF

# Check the result of the file creation
if [ $? -eq 0 ]; then
    echo "Configuration file 'bitcoin.conf' has been created successfully at: $conf_path"
else
    echo "An error occurred while creating the configuration file."
    exit 1
fi
