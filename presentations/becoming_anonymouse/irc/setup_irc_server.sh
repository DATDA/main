#/bin/bash!

# Root-check
if [ "$EUID" -ne 0 ]
	then echo "Must be run as root :("
	exit
fi

echo "This script installs and configures Tor and ngIrcd to run over Tor"
echo "By the end it should leave you with a fully-operational IRC server that runs over Tor"
echo ""
echo "It tries not to be fancy or assuming but some compromises will always pop-up."
echo "Currently it's tested to work on Ubuntu Server 16.04/20.04, but will likely work fine for most"
echo " debian-based OSs."

read -p "Press [Enter] to continue..." throwaway

read -p "irc server name (must contain a '.' and be unique in the irc network, ie: irc1.localdomain): " servername

# Install Tor and ngIrcd
echo "Installing Tor and ngIrcd and iptables-persistent"

apt install tor ngircd iptables-persistent -y

# Wait a sec cause they gotta get all sorted out and started up
sleep 5

# Configure Tor
echo "Configuring Tor..."

# Append the extra config info onto torrc to create a hidden service
echo "HiddenServiceDir /var/lib/tor/hidden_service/" >> /etc/tor/torrc
echo "HiddenServicePort 6667 127.0.0.1:6667" >> /etc/tor/torrc

# Setup transparent proxy for .onion resolution
echo "VirtualAddrNetworkIPv4 10.192.0.0/10" >> /etc/tor/torrc
echo "AutomapHostsOnResolve 1" >> /etc/tor/torrc
echo "TransPort 9040" >> /etc/tor/torrc
echo "DNSPort 53" >> /etc/tor/torrc

# Restart the tor service to push the new config and generate the hidden service keys
systemctl restart tor.service

# Configure the rest of the Transparent Proxy for .onions
echo "Configuring Transparent Proxy"

# Move the default resolve configuration
mv /etc/resolv.conf /etc/resolv.conf.default
echo "nameserver 127.0.0.1" >> /etc/resolv.conf

# Create an IP tables rule to redirect traffic through the proxy
iptables -t nat -A OUTPUT -p tcp -d 10.192.0.0/10 -j REDIRECT --to-ports 9040

# Make sure the iptables rules are persistant
/sbin/iptables-save > /etc/iptables/rules.v4

# Configure ngIrcd
echo "Configuring ngIrcd..."

# Make a copy of the default Config and MOTD files
mv /etc/ngircd/ngircd.conf /etc/ngircd/ngircd.conf.default
mv /etc/ngircd/ngircd.motd /etc/ngircd/ngircd.motd.default

# Create a new, breif-er config file
echo "[Global]" >> /etc/ngircd/ngircd.conf
echo "Name = "$servername >> /etc/ngircd/ngircd.conf
echo "Info = Yet another IRC Server running on Debian GNU/Linux" >> /etc/ngircd/ngircd.conf
echo "MotdPhrase = Hello. This is the Debian default MOTD sentence" >> /etc/ngircd/ngircd.conf
echo "PidFile = /var/run/ngircd/ngircd.pid" >> /etc/ngircd/ngircd.conf
echo "ServerGID = irc" >> /etc/ngircd/ngircd.conf
echo "ServerUID = irc" >> /etc/ngircd/ngircd.conf
echo "Listen = 127.0.0.1" >> /etc/ngircd/ngircd.conf
echo "[Limits]" >> /etc/ngircd/ngircd.conf
echo "ConnectRetry = 60" >> /etc/ngircd/ngircd.conf
echo "MaxConnections = 500" >> /etc/ngircd/ngircd.conf
echo "MaxConnectionsIP = 20" >> /etc/ngircd/ngircd.conf
echo "MaxJoins = 0" >> /etc/ngircd/ngircd.conf
echo "PingTimeout = 120" >> /etc/ngircd/ngircd.conf
echo "PongTimeout = 20" >> /etc/ngircd/ngircd.conf
echo "[Options]" >> /etc/ngircd/ngircd.conf
echo "PAM = no" >> /etc/ngircd/ngircd.conf
echo "AllowRemoteOper = no" >> /etc/ngircd/ngircd.conf
echo "CloakHost = cloaked.host" >> /etc/ngircd/ngircd.conf
echo "CloakUserToNick = yes" >> /etc/ngircd/ngircd.conf
echo "DNS = no" >> /etc/ngircd/ngircd.conf
echo "Ident = no" >> /etc/ngircd/ngircd.conf
echo "MorePrivacy = yes" >> /etc/ngircd/ngircd.conf
echo "OperCanUseMode = no" >> /etc/ngircd/ngircd.conf
echo "OperChanPAutoOp = no" >> /etc/ngircd/ngircd.conf
echo "OperServerMode = no" >> /etc/ngircd/ngircd.conf
echo "ScrubCTCP = yes" >> /etc/ngircd/ngircd.conf
echo "SyslogFacility = local1" >> /etc/ngircd/ngircd.conf
echo "# -eof-" >> /etc/ngircd/ngircd.conf

# Restart the ngIrcd service to push the new config
systemctl restart ngircd.service

# Wait again cause things gotta get done like generating the hidden service keys
sleep 5

echo "Everything should be setup and running!"
echo "Access your new IRC sever at:"
cat /var/lib/tor/hidden_service/hostname

