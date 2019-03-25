#!/bin/bash
#
#
rsync -avz --include="cuda/*" --include="package/*" --include="minersapp/*" --include="miners/*" root@download.skles.com:/var/www/html/download/ansible/ /home/eth/ansible/
