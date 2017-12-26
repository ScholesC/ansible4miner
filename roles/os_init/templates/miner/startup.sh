#!/bin/bash
#
# configure GPU
#
gpu_type=$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader | grep -oP "(?<=\s)\d{2,}" | sort -u)
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

sleep 60

# start miner
while true
do
    if [[ $(nvidia-smi --query-compute-apps=process_name --format=csv,noheader | wc -l) -lt 1 ]]
    then
        #cd /home/eth/ClaymoreMiner && sh run.sh
        #cd /home/eth/eth && sh /home/eth/eth/start.bash
        cd  /home/eth/zec/ && ./run.sh
        #cd /home/eth/ccminer && ./run.sh
    fi
    sleep 30
done