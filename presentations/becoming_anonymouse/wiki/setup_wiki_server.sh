#/bin/bash!

# Root-check
if [ "$EUID" -ne 0 ]
	then echo "Must be run as root :("
	exit
fi

echo "This script installs and configures Tor, Apache, and Borg."
echo "By the end it should leave you with a fully-operational mirror available as a Hidden Service"
echo "  and with automated backups and mirroring."
echo ""
echo "It tries not to be fancy or assuming but some compromises will always pop-up."
echo "Currently it's tested to work on Ubuntu Server 16.04/20.04, but will likely work fine for most"
echo " debian-based OSs."

read -p "Press [Enter] to continue..." throwaway

# Install Tor and ngIrcd
echo "Installing Tor, Apache, and Borg"

apt install tor apache2 borgbackup -y

# Wait a sec cause they gotta get all sorted out and started up
sleep 5

# Configure Tor
echo "Configuring Tor..."

# Append the extra config info onto torrc
echo "HiddenServiceDir /var/lib/tor/hidden_service/" >> /etc/tor/torrc
echo "HiddenServicePort 80 127.0.0.1:80" >> /etc/tor/torrc

# Restart the tor service to push the new config and generate the hidden service keys
systemctl restart tor.service

# Wait again cause things gotta get done like generating the hidden service keys
sleep 5

# Create new trusted_peers file
touch /root/trusted_peers.txt

# Configure Borg
echo "Configuring Borg..."

# Initialize the repo
borg init --encryption=none /root/borg

# Configure automated backup and syncing
echo "Configuring backups and mirroring to run automatically..."

# Append a line in crontab to run our script regularly (on a random minute so they're offset)
echo $(echo $((1 + RANDOM % 60)))" * * * * root /root/backup_and_wget.sh" >> /etc/crontab

echo "Everything should be setup and running!"
echo "Access your new web sever at:"
cat /var/lib/tor/hidden_service/hostname

