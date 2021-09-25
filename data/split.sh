#!/bin/bash

if [ ! -f 'rssi.csv' ]; then
	unzip rssi.zip
fi

rm rssi_*.csv

echo 'ID,DateTime,AreaNumber,Track,Position,PositionNoLeap,Latitude,Longitude,A1_TotalTel,A1_ValidTel,A2_RSSI,A2_TotalTel,A2_ValidTel' > rssi_jan.csv
cp rssi_jan.csv rssi_feb.csv
cp rssi_jan.csv rssi_mar.csv
cp rssi_jan.csv rssi_apr.csv
cp rssi_jan.csv rssi_may.csv

cat rssi.csv | grep '2020-01-' >> rssi_jan.csv
cat rssi.csv | grep '2020-02-' >> rssi_feb.csv
cat rssi.csv | grep '2020-03-' >> rssi_mar.csv
cat rssi.csv | grep '2020-04-' >> rssi_apr.csv
cat rssi.csv | grep '2020-05-' >> rssi_may.csv

#echo num entries per month
for item in ./rssi_*; do cat "$item" | wc -l; done


echo "ID","DateTime","DisruptionCode","Description" >> disrupt_jan.csv
cp disrupt_jan.csv disrupt_feb.csv
cp disrupt_jan.csv disrupt_mar.csv
cp disrupt_jan.csv disrupt_apr.csv
cp disrupt_jan.csv disrupt_may.csv


cat disruptions.csv | grep '2020-01-' >> disrupt_jan.csv
cat disruptions.csv | grep '2020-02-' >> disrupt_feb.csv
cat disruptions.csv | grep '2020-03-' >> disrupt_mar.csv
cat disruptions.csv | grep '2020-04-' >> disrupt_apr.csv
cat disruptions.csv | grep '2020-05-' >> disrupt_may.csv

#echo num of disrupts per month
for item in ./disrupt_*; do cat "$item" | wc -l; done