#/bin/bash!

# This script is meant to run automatically (hourly, daily, etc.)
# It creates a backup of the current web files, prunes old backups, then tries to fetch a fresh version


# Perform a backup into an archive based on current system time
# Because it's a differential backup it's fine if it's 'wasted' (if the site is up-to-date)
borg create /root/borg::$(date +%s) /var/www/html/

# Prune old backups
borg prune --keep-within 3m /root/borg/

# Try to download a mirrored version of the site
# wget won't re-download unless the index file has been updated
# additionally, we're going through a file of urls so they're easier to manage
torsocks wget --mirror --directory-prefix=/var/www/html/ --no-host-directories --input-file=/root/trusted_peers.txt
