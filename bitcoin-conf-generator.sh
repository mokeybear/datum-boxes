#!/bin/bash

# Prompt the user for their inputs
read -p "Enter location for bitcoin.conf: " user_input1
read -p "Enter location for data: " user_input2
read -p "Enter value for 'prune': " user_input3
read -p "Enter value for 'dbcache': " user_input4
read -p "Enter value for 'rpcauth': " user_input5

# Create or overwrite file.txt with sudo
sudo bash -c "cat > $user_input1bitcoin.conf" << EOF
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

# Check if the operation was successful
if [ $? -eq 0 ]; then
    echo "File 'bitcoin.conf' has been updated successfully."
else
    echo "An error occurred while updating the file."
fi
