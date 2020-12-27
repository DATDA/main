#/bin/bash!

# Root-check
if [ "$EUID" -ne 0 ]
	then echo "Must be run as root :("
	exit
fi

echo "This script adds a new operator to your ngIrcd server,"
echo "then restarts the server so the operator is active."
echo ""

read -p "Press [Enter] to continue..." throwaway

read -p "Operator Name (not nick): " name

read -p "Operator Password: " pass

# Strip off the last line of the file (the # -eof-)
head -n -1 /etc/ngircd/ngircd.conf > /etc/ngircd/tmp ; mv /etc/ngircd/tmp /etc/ngircd/ngircd.conf
echo "[Operator]" >> /etc/ngircd/ngircd.conf
echo "Name = "$name >> /etc/ngircd/ngircd.conf
echo "Password = "$pass >> /etc/ngircd/ngircd.conf
echo "# -eof-" >> /etc/ngircd/ngircd.conf

# Restart the ngIrcd service to push the new config
systemctl restart ngircd.service

# Wait for a sec to let it reload
sleep 1

echo "Everything should be setup and running!"

