# check-for-new-certs
Tool for downloading and installing new certs

Designed for FreeBSD (it uses fetch, not wget or curl [yet]). 

It also uses sudo, with the goal of this running as non-root and only allowing the cp & mv via sudo.

Relevant background:

* The certificates are being generated via acme.sh in a centralized location.
* certs are not generated where they are used.
* Distribution of private keys is outside scope.
* New certs are pulled by the servers/VMs/jails/etc which need them.

The steps to use this stuff:

* create certs in /var/db/acme
* run collect-certs (see https://github.com/dlangille/collect-certs/blob/master/collect-certs)
* rsync from /var/db/certs-for-rsync to https://example.org/certs
* run check-for-new-certs to download and install new certs

The distribution of private keys is outside scope.

Before using: 

```
mkdir /var/db/check-for-new-certs && chown USER:GROUP /var/db/check-for-new-certs
```

Where USER & GROUP is the user which will be invoking this script.

Said user will also need sudo rights to cp and mv within CERT_DST.

Default configuration file is /usr/local/etc/check-for-new-certs/check-for-new-certs.conf

Variables which can be set in that file:

```
CERT_DST="/usr/local/etc/ssl"
CERT_SERVER="https://certs.example.org/certs"
MYCERTS="example.com"
SERVICES="apache24"
DOWNLOAD_DIR="/var/db/check-for-new-certs"
USER_AGENT="--user-agent='Check-For-New-Certificate'"
```

Services which can be restarted by this code: apache24, dovecot, postfix.

Yep, lots to work on here.
