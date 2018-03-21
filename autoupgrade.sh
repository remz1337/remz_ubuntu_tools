#!/bin/bash
# This script requires Postfix to be installed and configured to send email
# It can be done simply with an external smtp server like Microsoft Exchange

# First, install Postfix
# sudo apt-get install postfix
# Then configure the relayhost
# sudo postconf -e "relayhost = smtp.mydomain.com"
# and restart it
# sudo systemctl restart postfix
# then make this file executable
# sudo chmod +x autoupgrade.sh
# and set it as a cron job to run every Sunday at 10pm
# sudo crontab -e
# by adding this line at the end of the file
# 0 22 * * Sun /home/myuser/autoupgrade.sh

MAILTO=me@mydomain.com
MAILFROM=root@$(hostname)
#mail server is configured in postfix configuration

msg_tmpfile=$(mktemp)
#tmp subject
subject="Aptitude cron $(date)"

echo "Beginning of log:" >> ${msg_tmpfile}
echo "apt-get update" >> ${msg_tmpfile}
sudo apt-get -qy update >> ${msg_tmpfile}
echo "" >> ${msg_tmpfile}
echo "apt-get upgrade" >> ${msg_tmpfile}
sudo apt-get -qy upgrade >> ${msg_tmpfile}
echo "" >> ${msg_tmpfile}
echo "apt-get autoremove" >> ${msg_tmpfile}
sudo apt-get -qy autoremove >> ${msg_tmpfile}
echo "Upgrade script complete" >> ${msg_tmpfile}

message=$(<${msg_tmpfile})
#Send email only if upgrade failed
if grep -q 'E: \|W: ' ${msg_tmpfile} ; then
        subject="Failed to upgrade Ubuntu Server"
#else
#        subject="Successfully upgraded Ubuntu Server"
#fi

# now send the email (and ignore output)
# check sendmail path with sudo find / -name "sendmail"
/usr/sbin/sendmail $MAILTO << EOF
From:$MAILFROM
Subject:$subject
$message
.
EOF

fi

# and remove temp files
rm -f ${msg_tmpfile}

# Wait for email to be sent by system
sleep 2

# Reboot server once it is done
sudo reboot
