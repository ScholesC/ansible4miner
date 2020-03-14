#!/bin/bash
#
#
timenow=$(date +%H%m)
if [[ $timenow > 0000 ]] && [[ $timenow < 0200 ]]
then
  rsync -avz --include="cuda/*" --include="package/*" --include="minersapp/*" --include="miners/*" root@download.skles.com:/var/www/html/download/ansible/ /home/eth/ansible/
else
  rsync -avz root@download.skles.com:/var/www/html/download/ansible/miners/ /home/eth/ansible/miners/
fi
