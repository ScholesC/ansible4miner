#!/bin/bash
sleep 1m
#cd /home/eth/ClaymoreMiner && sh run.sh
#cd /home/eth/eth && sh /home/eth/eth/start.bash

cd  /home/eth/zec/ && ./run.sh
gpu_type=$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader | grep -oP "(?<=\s)\d+" | sort -u)
powerlimit=120

case $gpu_type in 
    1060)
    powerlimit=120
    ;;
    1070)
    powerlimit=160
    ;;
esac
sudo nvidia-smi -pm 1
sudo nvidia-smi -pl $powerlimit
