#!/bin/bash

#Generic script to kill the existing inserter and start new ones.
#Just update the below information and run.

JAR_NAME="leshan-client-demo-1.0.0-SNAPSHOT-jar-with-dependencies.jar"
LWM2M_URL="URL_HER"

DEV_TYPE="tmp"
DEV_NAME_PREFIX="Prefix"
TYPE_ID=3303
DEV_ID_START=1
DEV_ID_END=49

START_VAL=20
MIN_VAL=-10
MAX_VAL=43



for ((i=$DEV_ID_START;i<=$DEV_ID_END;i++))
do

   dev_name_full="$DEV_NAME_PREFIX$i"

   # Add leading 0 for ids between 0-9 comment out if not neccesary
   if [ $i -ge 0 ] && [ $i -le 9 ]
   then
      dev_name_full="$DEV_NAME_PREFIX"0"$i"
   fi
   ########

   pid=$(ps -ef | grep java | grep $JAR_NAME | grep " $dev_name_full" | grep -v grep | awk '{print $2}')
   echo "Killing $dev_name_full inserter with PID $pid"
   kill $pid

   echo "Starting inserter for device $dev_name_full"
   nohup java -jar $JAR_NAME -u $LWM2M_URL -n $dev_name_full -device $DEV_TYPE -val $START_VAL -min $MIN_VAL -max $MAX_VAL &

   echo "Wait for $dev_name_full"
   sleep 1
   curl 'http://URL:8080/api/clients/'$dev_name_full'/'$TYPE_ID'/0/observe?format=TLV' -X POST -H 'Origin: http://URL:8080' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.8,tr;q=0.6,fr;q=0.4' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36' -H 'Content-Type: application/json;charset=utf-8' -H 'Accept: application/json, text/plain, */*' -H 'Referer: http://iotadev2-appiot-lwm2m-server.westeurope.cloudapp.azure.com:8080/' -H 'Cookie: MSFPC=ID=79cd6d69d9275f4081728d213d51ff10&CS=3&LV=201705&V=1; utag_main=v_id:015c57b8f7d4004423482d273c600506900c106100bd0$_sn:2$_ss:1$_st:1496842083401$dc_visit:2$ses_id:1496840283401%3Bexp-session$_pn:1%3Bexp-session$dc_event:1%3Bexp-session$dc_region:eu-central-1%3Bexp-session; AMCV_EA76ADE95776D2EC7F000101%40AdobeOrg=-179204249%7CMCMID%7C26607953899210452672222327251570691878%7CMCAAMLH-1497445086%7C6%7CMCAAMB-1497445086%7CNRX38WO0n5BH8Th-nqAG_A%7CMCOPTOUT-1496847486s%7CNONE%7CMCAID%7CNONE%7CMCCIDH%7C-1809902749; AAMC_mscom_0=AMSYNCSOP%7C411-17332; mp_1d92e3abd14a2d65f748d1314dd24b99_mixpanel=%7B%22distinct_id%22%3A%20%2215c57b8f6cfb6b-08d687f5235946-38750f56-1fa400-15c57b8f6d0135a%22%2C%22%24initial_referrer%22%3A%20%22https%3A%2F%2Flogin.microsoftonline.com%2Fcommon%2Foauth2%2Fauthorize%3Fclient_id%3D15689b28-1333-4213-bb64-38407dde8a5e%26response_mode%3Dform_post%26response_type%3Dcode%2Bid_token%26scope%3Dopenid%2Bprofile%26state%3DOpenIdConnect.AuthenticationProperties%253d0XfRqcxXCD9gJPBcJQp29BUVgA5UwAf__YXv_pJmcTXaI1uGmcj89pR8qMtZAW9rMs4Dmzmm-aadi7FSUViEcQ0GPENPJm-0k-FRyxJXaHbdTDuts_KXb8fag_M5PIfbBDq94fBEB1Ey4DHpQupxttoTUUH873YumGkw_uMtxuIOSFwmZ_MwreoFiLQoGIWq6mQppwtcfkdXd4MJ7Vh7pxyuQ2buZ5kC0NbzSb3dga5HJ_JwkLy4k7efSmJGtApPu_PH5VLqY2ZKQdRtl9oLvXD1jRsjsB8qs6eCLFBro7CHisRJ5fM9r0OGNbvCvvyfyC00yEGn7P-P0U9my0_gs7pM1EY%26nonce%3D636317171473478416.MzU2YmU0MDMtZThhNi00OGFiLTk1YTYtOTcwNmZiMGZmODFmNDM0NmJkNTYtZWJkOC00MzFjLTgyYzMtY2ZiNzFjYzIwM2I3%26redirect_uri%3Dhttps%253a%252f%252faccount.azure.com%252fsignup%253foffer%253dms-azr-0044p%2526appId%253d102%2526redirectURL%253dhttps%25253a%25252f%25252fazure.microsoft.com%25252fen-gb%25252fget-started%25252fwebinar%25252f%2526correlationId%253d48ff2a69-1838-4c13-9b90-6d1406755735%26post_logout_redirect_uri%3Dhttps%253a%252f%252faccount.azure.com%26msafed%3D1%26lw%3D1%26fl%3Deasi2%22%2C%22%24initial_referring_domain%22%3A%20%22login.microsoftonline.com%22%7D; __cfduid=d107dcf82a367f01f5fbacac77ff9fff61504768411; __utma=199044223.1279440809.1504768413.1504768413.1504768413.1; __utmz=199044223.1504768413.1.1.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); mp_super_properties=%7B%22all%22%3A%20%7B%22%24initial_referrer%22%3A%20%22https%3A//www.google.com.tr/%22%2C%22%24initial_referring_domain%22%3A%20%22www.google.com.tr%22%7D%2C%22events%22%3A%20%7B%7D%2C%22funnels%22%3A%20%7B%7D%7D; _vwo_uuid_v2=33EDAA94E6C5FB59172F74674C6B057F|cb5437c250dd3cc24ed68bb4b7c30f66' -H 'Connection: keep-alive' -H 'Content-Length: 0' --compressed

done


