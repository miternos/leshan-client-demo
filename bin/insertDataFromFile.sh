#!/bin/bash

#Generic script to kill the existing inserter and start new ones.
#Just update the below information and run.

JAR_NAME="leshan-client-demo-1.0.0-SNAPSHOT-jar-with-dependencies.jar"
LWM2M_URL="URL_HERE"

SOURCE="Humidity000_data.txt"

DEV_TYPE="hum"
DEV_NAME="Humidity000"
TYPE_ID=3304

echo "Starting inserter for device $dev_name_full"
nohup java -jar $JAR_NAME -u $LWM2M_URL -n $DEV_NAME -device $DEV_TYPE -src $SOURCE &

echo "Wait for $DEV_NAME"
sleep 5

curl 'http://URL:8080/api/clients/'$DEV_NAME'/'$TYPE_ID'/0/observe?format=TLV'




