# anvil

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
* run cert-shifter (see https://github.com/dlangille/anvil-certs/blob/master/collect-certs)
* rsync from /var/db/certs-for-rsync to https://example.org/certs
* run cert-puller to download and install new certs

The distribution of private keys is outside scope.

Before using: 

```
mkdir /var/db/anvil && chown USER:GROUP /var/db/anvil
```

Where USER & GROUP is the user which will be invoking this script. We
suggest anvil:anvil

Said user will also need sudo rights to cp and mv within CERT_DST.

Default configuration files are in /usr/local/etc/anvil/

Variables which can be set in cert-shifter.conf:

```
CERT_SRC="/var/db/acme/certs"

CERT_DST_ROOT="/var/db/certs-for-rsync"
CERT_DST_CERTS="${CERT_DST_ROOT}/certs"

TMP="${CERT_DST_ROOT}/tmp"
```

Variables which can be set in cert-puller.conf:

```
CERT_DST="/usr/local/etc/ssl"
CERT_SERVER="https://certs.example.org/certs"
MYCERTS="example.com"
SERVICES="apache24"
DOWNLOAD_DIR="/var/db/check-for-new-certs"
USER_AGENT="--user-agent='anvil-cert-puller'"
```

Services which can be restarted by this code: apache24, dovecot, postfix.

Yep, lots to work on here.
