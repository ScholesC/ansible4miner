#!/bin/bash
#
# configure GPU
#

sleep 30

powerlimit=120
sudo nvidia-smi -pm 1

while read index gpu_type
do
    echo $index $gpu_type
    egrep 1080 <<<$gpu_type && powerlimit=230
    egrep 1070 <<<$gpu_type && powerlimit=160
    egrep 1060 <<<$gpu_type && powerlimit=120
    egrep P106 <<<$gpu_type && powerlimit=120
    sudo nvidia-smi -i $index -pl $powerlimit
done< <(nvidia-smi --query-gpu=index,gpu_name --format=csv,noheader | sed 's|,| |g')

sleep 30

# start miner
#cd /home/eth/ClaymoreMiner && sh run.sh
#cd /home/eth/eth && sh /home/eth/eth/start.bash
cd  /home/eth/zec/ && ./run.sh
#cd /home/eth/ccminer && ./run.sh
#cd /home/eth/eth && ./run.sh
#cd /home/eth/btm && ./run.sh
