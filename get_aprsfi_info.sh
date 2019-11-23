#!/bin/ash
wget --no-check-certificate -O /tmp/html/tmp_weather.html "https://aprs.fi/weather/BD7NWR-13?lang=zh-cn"

echo "<table border='0'>" > /tmp/html/iframe_aprs.html
cat /tmp/html/tmp_weather.html | fgrep "<tr><th valign='top'>" | fgrep -v "<a href" | fgrep -v "<span id='loc_ago_t'>" >> /tmp/html/iframe_aprs.html
echo "</table>" >> /tmp/html/iframe_aprs.html

wget --no-check-certificate -O /tmp/aprs_info_tmp "https://aprs.fi/info/a/BD7NWR-10"
aa=$(sed -n -e "/Stations heard directly by/=" /tmp/aprs_info_tmp)
bb=$(expr $aa + 10)
cat /tmp/aprs_info_tmp | sed -n "$bb p" | sed -r "s/<\/tr>/<\/tr>\n/g" | sed -r "s/^.*\/a\/([A-Z,0-9,\-]){3,10}'>//g" | sed -r "s/<\/a><\/th>\s<td.*'[0-9,\.]{3,9}'>/ /g" | sed -r "s/<\/td>\s<td\sclass=.*1)'>/ /g" | sed -r "s/<\/td><\/tr>//g" > /tmp/aprs_info

echo "<table border=0><pre>" > /tmp/html/aprs_info.html
awk '{print $2,$1,$3,$4,$5}' /tmp/aprs_info | sort -n -r | head -n 5 >> /tmp/html/aprs_info.html
echo "</pre></table>"  >> /tmp/html/aprs_info.html
time1=$(date +%s)
cat /tmp/aprs_info | grep `date +%Y-%m-%d` | awk '{print $5,$2,$1,$3,$4}' | sort -n -r | while read line
do
        aa=$(echo $line | awk '{print $5,$1}')
        time2=$(date +%s -d "$aa")
        bb=$(expr $time1 - $time2)
        if [ $bb -lt 300 ]; then
                cc=$(echo $line | awk '{print $2}' | cut -d "." -f 1)
                dd=$(expr $cc \> 250 )
                if [ $dd -eq 1 ]; then
                        ee=$(echo $line | awk '{print $3,$2,$4,$5,$1}' | sed 's/ /, /g' )
#                       wget -O - "http://10.8.8.1:8001/?usr=aaaaa|bbbbb&msg=aprs%3E250km:%20$ee"
                        ff=$(echo $ee | sed 's/ / /g' | sed 's/°/dig/g' )
                        . /etc/config/send_email.sh "aprs>250km: $ff" "bbbbbb@163.com"
                        . /etc/config/send_email.sh "aprs>250km: $ff" "aaaaaa@139.com"
                fi
        fi
done
