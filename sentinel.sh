#!/bin/bash
while true
do

count_t=0
count_f=0
value="active"
triger=$(cat /root/triger)

function telega (){
    shost=$(hostname)
    token=$1
    chatid=$2
    subject=$3
    notification=$4
    /usr/bin/curl -s -H 'Content-Type: application/json' -X 'POST' -d "{\"chat_id\":\"${chatid}\",\"text\":\"${subject}\n${notification}${shost}\"}" "https://api.telegram.org/bot${token}/sendMessage"
}
export -f telega



for (( i=1; i <= 20; i++ ))
    do
        if [[ $(systemctl status $1 | awk 'NR==3' | awk '{print $2}') != $value ]]
        then
            let count_t=count_t+1
# echo $count_t
        else
            let count_f=count_f+1
 #echo $count_f
        fi
 sleep 2s
 done

if [[ $count_t > $count_f  && $triger == "0" ]]
 then
    telega token chat_id "SentinelOne Alert" "SentinelOne  was corrupted on "
    echo "SentinelOne on $shost  was corrupted" | systemd-cat
    echo "1" > /root/triger
 #echo $count_t $count_f

 elif [[ $count_t > $count_f && $triger == "1" ]]
    then
        echo "SentinelOne still down" | systemd-cat
        echo "1" > /root/triger

 elif [[ $count_t < $count_f && $triger == "1" ]]
    then
    telega 1019846742:AAE_I-M0B4tIGaZo2RhiZyZDbUZZhvCynAs -341602750 "SentinelOne Alert" "SentinelOne  was recovered on "
    echo "SentinelOne on $shost  was recovered" | systemd-cat
    echo "0" > /root/triger
elif [[ $count_t < $count_f && $triger == "0" ]]
    then
        echo "0" > /root/triger
 fi
  sleep 600s
