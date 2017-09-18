#!/bin/bash
sleep 1m
#cd /home/eth/ClaymoreMiner && sh run.sh
#cd /home/eth/eth && sh /home/eth/eth/start.bash
cd  /home/eth/zec/ && ./run.sh
gpu_type=$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader | grep -oP "(?<=\s)\d+(?=\s)" | sort -u)
case gup_type in 
    1060)
    poqwelimir=120
    ;;
    1070)
    powerlimit=160
    ;;
esac
nvidia-smi -pm 1
nvidia-smi -pl $powerlimit
