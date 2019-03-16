#!/bin/bash
#
#
cd /home/eth/ansible && git pull
rsync -av --include="miners/" --include="cuda/" --include="package/" root@monitor.skles.com:/ansible/ /home/eth/ansible/
