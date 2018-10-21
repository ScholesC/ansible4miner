#!/bin/bash
#****************************************************************#
# ScriptName: renew_hosts_file.sh
# Create Date: 2017-10-15 19:50
# Modify Date: 2017-10-15 19:50
#***************************************************************#
export PATH=/usr/bin:/usr/sbin:/bin:/sbin
hostsfile=/home/eth/hosts
if ! grep -P "127.0.0.1\s+$HOSTNAME\s+localhost" $hostsfile
then
  echo "127.0.0.1  $HOSTNAME localhost" >> $hostsfile
fi
int_name=$(ip -o addr | grep -oP "eth\d+" | sort -u)
IP_LIST=$(sudo arp-scan --interface $int_name --localnet | egrep ^192.168 | awk '{print $1}')
PSSH_DIR=/tmp/PSSHDIR_$$
mkdir $PSSH_DIR
#echo 23835261 | sshpass -ppassword pssh -o $PSSH_DIR -t 5 -p 100 -H "$IP_LIST" 'uname -n' &>/dev/null
pssh -o $PSSH_DIR -t 5 -p 100 -H "$IP_LIST" 'uname -n' &>/dev/null
empty_file_list=$(find $PSSH_DIR -empty -printf "%f\n")
sshpass -f /home/eth/remotePasswordFile pssh -O " PreferredAuthentications=password" -O " PubkeyAuthentication=no" -A -o $PSSH_DIR -t 5 -p 100 -H "$empty_file_list" 'uname -n' &>/dev/null
num_of_hosts=$(find $PSSH_DIR ! -empty | wc -l)
#if [[ $num_of_hosts -gt 10 ]]
#then
#cat /dev/null > /home/eth/hosts 
cat /dev/null > /home/eth/.ssh/known_hosts

for IP in $(ls -1 $PSSH_DIR)
do
  HOST_NAME=$(cat $PSSH_DIR/$IP)
#  if [[ -n $HOST_NAME ]]
#  then
#    OLD_IP=$(egrep $HOST_NAME /etc/hosts.base | awk '{print $1}' | sort -u) 
#  else
#    OLD_IP='NONE'
#  fi
  #echo  "$IP    $HOST_NAME    # $OLD_IP " >> /home/eth/hosts
  
  host_entry_name=$(grep -P "$IP " $hostsfile | awk '{print $2}')
  if ! grep -P "$IP\s+$HOST_NAME " $hostsfile
  then
    if [[ -n $HOST_NAME ]]
    then
#      echo "$IP - $HOST_NAME - $host_entry_name"
      if [[ $HOST_NAME != $host_entry_name ]]
      then
        #echo "doesn't match"
        sed -i "/ $HOST_NAME /d" $hostsfile
        sed -i "/$IP /d" $hostsfile
        echo  "$IP    $HOST_NAME " >> $hostsfile
        #sed -i "/$IP / s|$host_entry_name|$HOST_NAME|g" $hostsfile
      fi
    #else
    #  echo  "$IP    $HOST_NAME " >> $hostsfile
    fi
  else
    if [[ -n $HOST_NAME ]]
    then
      if [[ $(grep -P " $HOST_NAME " $hostsfile | wc -l) -gt 1 ]]
      then
        for IPX in $(grep -P " $HOST_NAME " $hostsfile | awk '{print $1}')
        do
          IPX_HOSTNAME=$(cat $PSSH_DIR/$IPX)
          if  [[ $HOST_NAME != $IPX_HOSTNAME ]]
          then
            perl -n -i -e "print unless m/$IPX\s+$IPX_HOSTNAME\s+/" $hostsfile
          fi
        done
      fi
    fi
  fi
done
#while read IP HOST_NAME
#do
#  if [[ -n $HOST_NAME ]]
#  then
#    [[ $(egrep -w $HOST_NAME /home/eth/hosts) ]] || echo "#$IP    $HOST_NAME     # OLD hosts " >> /home/eth/hosts
#  fi
#done</etc/hosts.base
#fi

rm -rf $PSSH_DIR

grep -P "^\d+" /home/eth/hosts | grep -v " $HOSTNAME " | awk '/^[^#]/{print $1}' > /home/eth/hosts.ip
