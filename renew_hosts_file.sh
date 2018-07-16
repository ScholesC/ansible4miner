#!/bin/bash
#****************************************************************#
# ScriptName: renew_hosts_file.sh
# Create Date: 2017-10-15 19:50
# Modify Date: 2017-10-15 19:50
#***************************************************************#
cat /dev/null > /home/eth/.ssh/known_hosts
int_name=$(ip -o addr | grep -oP "eth\d+" | sort -u)
IP_LIST=$(sudo arp-scan --interface $int_name --localnet | egrep ^192.168 | awk '{print $1}')
#IP_LIST=$(sudo arp-scan --interface eth1 --localnet | egrep ^192.168 | awk '{print $1}')
PSSH_DIR=/tmp/PSSHDIR_$$
mkdir $PSSH_DIR
#pssh -o $PSSH_DIR -t 5 -p 100 -H "$IP_LIST" 'uname -n' &>/dev/null
#echo 23835261 | sshpass -ppassword pssh -o $PSSH_DIR -t 5 -p 100 -H "$IP_LIST" 'uname -n' &>/dev/null
sshpass -f /home/eth/remotePasswordFile pssh -O " PreferredAuthentications=password" -O " PubkeyAuthentication=no" -A -o $PSSH_DIR -t 5 -p 100 -H "$IP_LIST" 'uname -n' &>/dev/null
num_of_hosts=$(find $PSSH_DIR ! -empty | wc -l)
#if [[ $num_of_hosts -gt 10 ]]
#then
cat /dev/null > /home/eth/hosts 
echo "127.0.0.1  $HOSTNAME localhost" >> /home/eth/hosts
for IP in $(ls -1 $PSSH_DIR)
do
  HOST_NAME=$(cat $PSSH_DIR/$IP)
  if [[ -n $HOST_NAME ]]
  then
    OLD_IP=$(egrep $HOST_NAME /etc/hosts.base | awk '{print $1}' | sort -u) 
  else
    OLD_IP='NONE'
  fi
  echo  "$IP    $HOST_NAME    # $OLD_IP " >> /home/eth/hosts
done
while read IP HOST_NAME
do
  if [[ -n $HOST_NAME ]]
  then
    [[ $(egrep -w $HOST_NAME /home/eth/hosts) ]] || echo "#$IP    $HOST_NAME     # OLD hosts " >> /home/eth/hosts
  fi
done</etc/hosts.base
#fi

rm -rf $PSSH_DIR

grep -P "^\d+" /home/eth/hosts |  awk '/^[^#]/{print $1}' > /home/eth/hosts.ip
