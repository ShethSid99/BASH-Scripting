#!/bin/bash

#In this Bash script, following are the steps taken to reach to desired output. 
#Step #1: In order to obtain IP and location data, we are calling a given API. If there is already cached copy present, we are utilizing it rather than making a call to API.- L#12 to L#25
#Step #2: The next step is to parse IP and location file obtained in step #1 to get details of Latitiude and Longitude. - L#26 to L#36
#Step #3: We have created one key seperately than this script. In this step, Latitiude and Longitude details obtained in Step #2 and generated key is passed to weatherbit service to obtain weather forecast details for last 16 days in JSON file. - L#37 to L#40
#Step #4: In order to get day wise temperature details (high & low), we are parsing JSON file and stroing day wise data in output file. - L#41 to L#45
#Step #5: In fina step, we are printing output file on the console. - L#46 to L#48
#Note: Printing each intemediate step on the console is stopped and we are only displaying output in asked format. In case of debugging, please uncomment echo commands to troubleshoot.

#To stop bash script prinitng each command on console; helpful to get only Output on console
set +x

#To get Degree ('°') symbol
DEG=$(awk 'BEGIN { print "\xc2\xb0"; }')
#echo $DEG

#Check to see availabilty of cached IP from '.myipaddr' or whether script had to call the service to obtain the JSON describing IP and location
if [[ -f "./.myipaddr" ]]; then
                    echo "IP READ FROM CACHE" >> weather_output.txt
                        else
                                                echo "CALLING API TO QUERY MY IP" >> weather_output.txt
                                                                        curl -s https://ipinfo.io/geo > .myipaddr
fi

#Parsing Latitiude
LAT=$(cat .myipaddr | jq '.loc' | sed 's/"//g' |cut -d"," -f1)
#echo "Latitiude is $LAT"

#PArsing Longitude
LON=$(cat .myipaddr | jq '.loc' | sed 's/"//g' |cut -d"," -f2)
#echo "Longitude is $LON"

#Printing Latitiude and Longitude
echo "Forecast for my lat=$LAT$DEG, lon=$LON$DEG" >> weather_output.txt

#Calling weatherbit service to obtain weather forecast
curl -s "https://api.weatherbit.io/v2.0/forecast/daily?key=8df6656752f343f78e1bf47ba888d45d&lat=47.6062&lon=-122.3321" | jq . > forecast.json

#Parsing Day wise High Temperature and Low Temperature
for day in {0..15}
do
                        echo "Forecast for $(jq ".data[$day].datetime" forecast.json | sed 's/"//g') HI: $(jq ".data[$day].max_temp " forecast.json)$DEG"c" LOW: $(jq ".data[$day].min_temp" forecast.json)$DEG"c"" >> weather_output.txt
done

          #Printing Output data on Console
          echo "$(cat weather_output.txt)"