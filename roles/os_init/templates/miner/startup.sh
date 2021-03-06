#!/bin/bash
#
# configure GPU
#

sleep 30

powerlimit=100
sudo nvidia-smi -pm 1

while read index gpu_type
do
    echo $index $gpu_type
    egrep 1080 <<<$gpu_type && powerlimit=200
    egrep -i p102 <<<$gpu_type && powerlimit=210
    egrep 1070 <<<$gpu_type && powerlimit=140
    egrep -i p104 <<<$gpu_type && powerlimit=120
    egrep 1660 <<<$gpu_type && powerlimit=100
    egrep 1060 <<<$gpu_type && powerlimit=100
    egrep -i P106 <<<$gpu_type && powerlimit=100
    sudo nvidia-smi -i $index -pl $powerlimit
done< <(nvidia-smi --query-gpu=index,gpu_name --format=csv,noheader | sed 's|,| |g')

sleep 30

# start miner
cd /home/eth/beam && ./run.sh
