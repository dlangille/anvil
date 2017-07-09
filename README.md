# check-for-new-certs
Tool for downloading and installing new certs

Designed for FreeBSD (it uses fetch, not wget or curl [yet]). 

It also uses sudo, with the goal of this running as non-root and only allowing the cp & mv via sudo.

Before using: mkdir /var/db/check-for-new-certs && chown USER:GROUP /var/db/check-for-new-certs

Default configuration file is /usr/local/etc/check-for-new-certs/check-for-new-certs.conf

Variables which can be set in that file:

CERT_DST="/usr/local/etc/ssl"

CERT_SERVER="https://certs.example.org/certs"

MYCERTS="example.com"
SERVICES="apache24"
DOWNLOAD_DIR="/var/db/check-for-new-certs"

# be sure to specify the agument & have no spaces in between the single quotes
USER_AGENT="--user-agent='Check-For-New-Certificate'"


Services which can be restarted by this code: apache24, dovecot, postfix.

Yep, lots to work on here.
