# anvil

Tools for distributing ssl certificates

Designed on FreeBSD, it uses fetch by default, but can also use wget or curl.
Set FETCH_TOOL in the configuration file to either wget or curl. Any other
value will invoke fetch.

It also uses sudo, with the goal of this running as non-root and only allowing the cp & mv via sudo.

These tools were designed with acme.sh & Let's Encrypt in mind, but they
should with with any certificates generated by any means.

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

<p align="center">Overview of anvil use</p>
<img src ="https://github.com/dlangille/anvil/blob/master/images/anvil-overiew.png?raw=true" title="Overview of anvil use" alt="Overview of anvil use"/>


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
SERVICES_RELOAD="postgresql"
SERVICES_RESTART="postfix"
DOWNLOAD_DIR="/var/db/check-for-new-certs"
USER_AGENT="--user-agent='anvil-cert-puller'"
FETCH="/usr/bin/fetch --mirror --quiet --user-agent=${USER_AGENT}'"
CURL="/usr/local/bin/curl --silent --user-agent '${USER_AGENT}' --remote-time"
WGET="/usr/local/bin/wget --quiet --user-agent='${USER_AGENT}'"
FETCH_OPTIONS="-4"
CURL_OPTIONS="-4"
WGET_OPTIONS="-4"
```

After getting new certs, services need to be restarted/reloaded.


* Services which can be restarted/reloaded by SERVICES: apache22, apache24, dovecot, mosquitto,
  nginx, postfix, postgresql

* Services which can be restarted by SERVICES_RESTART: unlimited, anything you
  want.

* Services which can be reloaded by SERVICES_RELOAD: unlimited, anything you
  want.

To use wget, set FETCH_TOOL="wget" in cert-puller.conf
To use curl, set FETCH_TOOL="curl" in cert-puller.conf
To use fetch, set FETCH_TOOL to any other value, or remove it from the file.

Yep, lots to work on here.
