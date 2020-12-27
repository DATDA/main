#/bin/bash!

# Root-check
if [ "$EUID" -ne 0 ]
	then echo "Must be run as root :("
	exit
fi

echo "This script adds a new server to your irc network,"
echo "then restarts this server so the new server is connected."
echo ""

read -p "Press [Enter] to continue..." throwaway

read -p "Server Name (ircserver14): " name

read -p "Server Host (asdfqwerty.onion): " host

read -p "Server Port (6667): " port

read -p "This server's password: " mypassword

read -p "New Server's password: " peerpassword

# Strip off the last line of the file (the # -eof-)
head -n -1 /etc/ngircd/ngircd.conf > /etc/ngircd/tmp ; mv /etc/ngircd/tmp /etc/ngircd/ngircd.conf
echo "[Server]" >> /etc/ngircd/ngircd.conf
echo "Name = "$name >> /etc/ngircd/ngircd.conf
echo "Host = "$host >> /etc/ngircd/ngircd.conf
echo "Port = "$port >> /etc/ngircd/ngircd.conf
echo "MyPassword = "$mypassword >> /etc/ngircd/ngircd.conf
echo "PeerPassword = "$peerpassword >> /etc/ngircd/ngircd.conf
echo "# -eof-" >> /etc/ngircd/ngircd.conf

# Restart the ngIrcd service to push the new config
systemctl restart ngircd.service

# Wait for a sec to let it reload
sleep 1

echo "Everything should be setup and running!"

