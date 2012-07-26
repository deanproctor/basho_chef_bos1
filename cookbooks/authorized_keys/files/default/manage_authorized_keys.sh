#!/bin/bash

if [ $# == 0 ]; then
  echo "Usage: $0 <gid_1> <gid_2>"
  exit 1
fi

declare -A LDAP_USERS

#
# Setup authorized_keys for users in groups assigned to this server
#
for GID in "$@"
do
  USERS=$(ldapsearch -LLL -x -H ldap://ldap1.bos1 -b dc=bos1 "gidNumber=${GID}" uid | grep "uid: " | cut -f2 -d' ')

  for USER in $USERS
  do
    HOME_DIR="/home/$USER"

#    if [ ! -s "$HOME_DIR/.ssh/authorized_keys" ]; then
      mkdir -p $HOME_DIR/.ssh
      wget -O $HOME_DIR/.ssh/authorized_keys https://raw.github.com/basho/ssh_keys/master/$USER
      chmod 700 $HOME_DIR
      chmod 700 $HOME_DIR/.ssh
      chmod 600 $HOME_DIR/.ssh/authorized_keys
      chown -R $USER:$GID $HOME_DIR
#    fi

    LDAP_USERS[$USER]="1"
  done
done

#
# Remove authorized keys files from users not assigned to this server
#
LOCAL_USERS=$(ls /home)
for USER in $LOCAL_USERS
do
  if [[ ! ${LDAP_USERS[$USER]+_} ]]; then
    rm -f /home/$USER/.ssh/authorized_keys
  fi
done

exit 0
