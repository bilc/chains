#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "error arguments $*; for example:"
    echo "./chains.sh config localfile"
    exit -1
elif [[ ! -f $1 ]]; then
    echo "arg 1 must be config file"
    exit -1
fi

CONFIG=$1
LOCALFILE=$2
if [[ -d $2 ]] ; then
    tar -cf $2.tar $2
    LOCALFILE="$2.tar"
elif [[ -f $2 ]]; then
    LOCALFILE=$2
else
    echo "arg2 must be exist file or dir"
    exit -1
fi

if [[ ! -f $LOCALFILE ]];then
    echo "arg2 must be file or dir"
    exit -1
fi

[[ ! -d tmp ]] && mkdir tmp 

COLUMN=5
declare -a HOSTS
declare -a PORTS
declare -a USERS
declare -a PASSWORDS
declare -a STOREFILES
declare -a NCLISTENPORTS

count=0
while read line
do
    strs=($line)
    if (( ${#strs[*]} == 0 ))
    then
        echo "space"
        continue
    elif (( ${#strs[*]} != $COLUMN ))
    then
        echo "line no$count $line is error"
        exit -1
    fi
    HOSTS[$count]=${strs[0]}
    PORTS[$count]=${strs[1]}
    USERS[$count]=${strs[2]}
    PASSWORDS[$count]=${strs[3]}
    STOREFILES[$count]=${strs[4]}"/"$LOCALFILE
    NCLISTENPORTS[$count]=12345

    (( count=$count+1 ))
done < $CONFIG

# 启动接收进程，最后一个节点
HOST=${HOSTS[$count-1]}
USER=${USERS[$count-1]}
PORT=${PORTS[$count-1]}
PASSWORD=${PASSWORDS[$count-1]}
STOREFILE=${STOREFILES[$count-1]}
NCLISTENPORT=${NCLISTENPORTS[$count-1]}
sed "s/HOST/$HOST/" recv.expect | sed "s/USER/$USER/" | sed "s/PASSWORD/$PASSWORD/"  \
    |sed "s/PORT/$PORT/" | sed "s/NCLISTENPORT/$NCLISTENPORT/" | sed "s:STOREFILE:$STOREFILE:" \
    > tmp/recv.expect.$HOST
expect tmp/recv.expect.$HOST  
sleep 1

# 启动接收传输进程，中间节点
for (( i=$count-2;i>=0;i-- )) 
do
    HOST=${HOSTS[$i]}
    USER=${USERS[$i]}
    PORT=${PORTS[$i]}
    PASSWORD=${PASSWORDS[$i]}
    STOREFILE=${STOREFILES[$i]}
    NCLISTENPORT=${NCLISTENPORTS[$i]}
    NEXTHOST=${HOSTS[$i+1]}
    NEXTNCLISTENPORT=${NCLISTENPORTS[$i+1]}

    sed "s/HOST/$HOST/" recvAndSend.expect | sed "s/USER/$USER/" | sed "s/PASSWORD/$PASSWORD/"  \
        |sed "s/PORT/$PORT/" | sed "s/NCLISTENPORT/$NCLISTENPORT/" | sed "s:STOREFILE:$STOREFILE:" \
        |sed  "s/NEXTNCLISTENPORT/$NEXTNCLISTENPORT/" | sed "s/NEXTHOST/$NEXTHOST/" |sed "s/RATE/$RATE/" \
        > tmp/recvAndSend.expect.$HOST
    expect tmp/recvAndSend.expect.$HOST  
    sleep 1
done

# 启动传输命令，发送给第一个中间节点
echo "send file**********"
HOST=${HOSTS[0]}
NCLISTENPORT=${NCLISTENPORTS[0]}
echo "cat $LOCALFILE | nc $HOST $NCLISTENPORT"
nc $HOST $NCLISTENPORT < $LOCALFILE

