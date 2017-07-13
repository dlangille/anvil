#!/bin/sh

CERT_DST="/usr/local/etc/ssl"

CERT_SERVER="https://certs.example.org/certs"

MYCERTS="example.com"
SERVICES="apache24"
DOWNLOAD_DIR="/var/db/anvil"

# be sure to specify the agument & have no spaces in between the single quotes
USER_AGENT="--user-agent='Check-For-New-Certificate'"

CONFIG="/usr/local/etc/anvil/check-for-new-certs.conf"

if [ -f ${CONFIG} ]; then
  . ${CONFIG}
fi

BASENAME="/usr/bin/basename"
CP="/bin/cp"
FETCH="/usr/bin/fetch --mirror --quiet -v ${USER_AGENT} --no-mtime"
FIND_NEW_FILES="/usr/bin/find ${DOWNLOAD_DIR} -mtime 1 -type f"
LOGGER="/usr/bin/logger"
MV="/bin/mv"
SERVICE="/usr/sbin/service"
SUDO="/usr/local/bin/sudo"
TOUCH="/usr/bin/touch"

# first, we fetch the certs are looking for.
cd ${DOWNLOAD_DIR}

for cert in ${MYCERTS}
do
  FILES_FETCHING="ca.cer ${cert}.cer ${cert}.fullchain.cer"
  for file in ${FILES_FETCHING}
  do
    ${FETCH} ${CERT_SERVER}/${cert}/${file}
  done
done

# for each new thing we find, move it over to the right place
NEW_FILES=`${FIND_NEW_FILES}`
for new_file in ${NEW_FILES}
do
  filename=`${BASENAME} ${new_file}`
  ${SUDO} ${CP} -a ${new_file} ${CERT_DST}/${filename}.tmp
  ${SUDO} ${MV} ${CERT_DST}/${filename}.tmp ${CERT_DST}/${filename}
done

for service in ${SERVICES}
do
  case ${service} in
    "apache24")
      ${SUDO} ${SERVICE} ${service} graceful
      ;;

    "dovecot"|"postfix"|"nginx")
      ${SUDO} ${SERVICE} ${service} restart
      ;;
      
    *)
      ${LOGGER} "Unknown service requested in $0: ${service}"
      ;;
  esac
done
