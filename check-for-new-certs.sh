#!/bin/sh

# the following variables can be overridden by the config file
CERT_DST="/usr/local/etc/ssl"
CERT_SERVER="https://certs.example.org/certs"

# a space separated list of domains for which certs will be downloads
MYCERTS="example.com"

# a space separated list of services to restart
SERVICES="apache24"

DOWNLOAD_DIR="/var/db/anvil"

# be sure to specify the agument & have no spaces in between the single quotes
USER_AGENT="--user-agent='Check-For-New-Certificate'"

# items below here are not usually altered

CONFIG="/usr/local/etc/anvil/check-for-new-certs.conf"

if [ -f ${CONFIG} ]; then
  . ${CONFIG}
fi

# initialize variables used below

SUDO_EXAMPLES=0
NEW_CERTS_FOUND=0

# various commands used by this script
BASENAME="/usr/bin/basename"
CP="/bin/cp"

#
# --mirror avoids replacement when identical
# --quiet avoids noise
# --no-mtime ensure newly downloaded fails are new and acted upon
#
FETCH="/usr/bin/fetch --mirror --quiet ${USER_AGENT} --no-mtime"

# we find newly downloaded files and install them.
# the -mtime should correspond to the frequency this script runs.
# -mtime 1 = 1 day - so this search catches anything less than one
# day old.  Since we are using --no-mtime above, any recent downloads
# should be just a few seconds old.
# No harm is done by running more frequently than daily.
# Or by reinstalling certs already downloaded. Services will be
# restarted. You might not like that.
FIND_NEW_FILES="/usr/bin/find ${DOWNLOAD_DIR} -mtime 1 -type f"

# if you want to disable logging, not recommend, put a hash before /usr
LOGGER="/usr/bin/logger -t anvil"
MV="/bin/mv"
SERVICE="/usr/sbin/service"
SUDO="/usr/local/bin/sudo"
TOUCH="/usr/bin/touch"

usage(){
  echo "Usage: $0 [-s] [-h]"
  exit 1
}

sudo_examples(){
  # this function prints out commands which you can use with visudo to copy/paste

  #
  # NOTE: the code here must closely match that within install_new_certs() & restart_services()
  #
  for cert in ${MYCERTS}
  do
    FILES_FETCHING="ca.cer ${cert}.cer ${cert}.fullchain.cer"
    for file in ${FILES_FETCHING}
    do
      echo "anvil   ALL=(ALL) NOPASSWD:${CP} -a ${file} ${CERT_DST}/${file}.tmp"
      echo "anvil   ALL=(ALL) NOPASSWD:${MV} ${CERT_DST}/${file}.tmp ${CERT_DST}/${file}"
    done
  done

  for service in ${SERVICES}
  do
    case ${service} in
      "apache24")
        echo "anvil   ALL=(ALL) NOPASSWD:${SERVICE} ${service} graceful"
        ;;

      "dovecot"|"postfix"|"nginx")
        echo "anvil   ALL=(ALL) NOPASSWD:${SERVICE} ${service} restart"
        ;;
    esac
  done
}

fetch_new_certs(){
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
}

install_new_certs(){
  ${LOGGER} looking for new files

  # for each new thing we find, move it over to the right place
  NEW_FILES=`${FIND_NEW_FILES}`
  for new_file in ${NEW_FILES}
  do
    filename=`${BASENAME} ${new_file}`
    ${LOGGER} installing ${filename}

    #
    # NOTE: the code here must closely match that within sudo_examples() & restart_services()
    #
    ${SUDO} ${CP} -a ${new_file} ${CERT_DST}/${filename}.tmp
    ${SUDO} ${MV} ${CERT_DST}/${filename}.tmp ${CERT_DST}/${filename}
  done
}


restart_services(){
  #
  # NOTE: the code here must closely match that within sudo_examples() & install_new_certs()
  #
  for service in ${SERVICES}
  do
    case ${service} in
      "apache24")
        ${LOGGER} doing a graceful on ${service}
        ${SUDO} ${SERVICE} ${service} graceful
        ;;

      # it might be better if we do a reload.
      # will that be sufficient?
      "dovecot"|"postfix"|"nginx")
        ${LOGGER} restarting ${service}
        ${SUDO} ${SERVICE} ${service} restart
        ;;
      
      *)
        ${LOGGER} "Unknown service requested in $0: ${service}"
        ;;
    esac
  done
}

#
# main code starts here
#

while getopts "hs" opt; do
  case $opt in
    s)
      SUDO_EXAMPLES=1
      shift
      ;;
    h)
      usage
      shift
      ;;
    * )
      usage
      ;;
  esac
done

if [ ${SUDO_EXAMPLES} == "1" ]; then
  sudo_examples
  exit
fi

${LOGGER} starting $0

fetch_new_certs

install_new_certs

if [ ${NEW_CERTS_FOUND} == "1" ]; then
  restart_services
else
  ${LOGGER} no new certs found
fi

${LOGGER} stopping $0
