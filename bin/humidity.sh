#!/bin/bash

#Generic script to kill the existing inserter and start new ones.
#Just update the below information and run.

JAR_NAME="../target/leshan-client-demo-1.0.0-SNAPSHOT-jar-with-dependencies.jar"
LWM2M_URL="URL_HERE"

DEV_TYPE="hum"
DEV_NAME_PREFIX="Prefix"
TYPE_ID=3304
DEV_ID_START=0
DEV_ID_END=0

START_VAL=50
MIN_VAL=0
MAX_VAL=100

script_name=`basename "$0"`
kill=$1

if [ ''$kill != 'kill' ];
then
   echo "Started" > $script_name.out
fi



for ((i=$DEV_ID_START;i<=$DEV_ID_END;i++))
do

   dev_name_full="$DEV_NAME_PREFIX$i"

   # Add leading 0 for ids between 0-9 comment out if not neccesary
   #if [ $i -ge 0 ] && [ $i -le 9 ]
   #then
   #   dev_name_full="$DEV_NAME_PREFIX"0"$i"
   #fi
   ########

   pid=$(ps -ef | grep java | grep $JAR_NAME | grep " $dev_name_full" | grep -v grep | awk '{print $2}')
   echo "Killing $dev_name_full inserter with PID $pid"
   kill $pid

   if [ ''$kill != 'kill' ];
   then
       echo "Starting inserter for device $dev_name_full"
       #echo "java -jar $JAR_NAME -u $LWM2M_URL -n $dev_name_full -device $DEV_TYPE -val $START_VAL -min $MIN_VAL -max $MAX_VAL"
       nohup java -jar $JAR_NAME -u $LWM2M_URL -n $dev_name_full -device $DEV_TYPE -frq 1 -val $START_VAL -min $MIN_VAL -max $MAX_VAL >> $script_name.out &

       echo "Wait for $dev_name_full"
       sleep 5

       curl 'http://URL/api/clients/'$dev_name_full'/'$TYPE_ID'/0/observe?format=TLV' -X POST
   fi

done


