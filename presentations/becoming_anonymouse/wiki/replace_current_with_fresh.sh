#/bin/bash!

echo "This command replaces the current web files with brand-new ones from your trusted_peers.txt"
echo "Make sure you have a current backup FIRST so you can revert again if things go awry."

read -p "Let's Do this [Enter]..." backup

# Remove what's currently there so there aren't any left-overs
rm -rf /var/www/html/*

# Run that other script that does all this automatically
/root/backup_and_wget.sh
