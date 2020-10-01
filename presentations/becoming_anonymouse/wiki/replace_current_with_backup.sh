#/bin/bash!

echo "This command replaces the current web files with those from a given backup"
echo "Make sure you have a current backup FIRST so you can revert again if things go awry."

read -p "Backup Name [160xxxxxx]" backup

# Remove what's currently there so there aren't any left-overs
rm -rf /var/www/html/*

# Make a new tmp dir for holding the restored backup
mkdir /root/tmp

# Head in there cause you can't re-point borg's extract command
cd /root/tmp

# Extract the archive associated with the NAME given
borg extract /root/borg::$backup

# Move on over only the actual stuff we wanted to their propper place
mv /root/tmp/var/www/html/* /var/www/html/

# Get on out of that tmp dir
cd

# Remove the tmp dir since it's no longer needed
rm -rf /root/tmp
