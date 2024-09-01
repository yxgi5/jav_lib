#!/bin/bash

export https_proxy="127.0.0.1:8118"
export http_proxy="127.0.0.1:8118"

# list='https://www.javbus.com/ja/star/q8t'
# list='https://www.javbus.com/ja/search/GOJU'
list=$(cat navigation.list)

for i in $list
do
    echo $i
    aria2c \
        --header 'sec-ch-ua: "Google Chrome";v="117", "Not;A=Brand";v="8", "Chromium";v="117"' \
        --header 'cookie: 4fJN_2132_seccodecSeRRfg5=14339.4cce2e4f1ae59e531e; 4fJN_2132_seccodecSTVfEvf=9372.f1ae0a808eec67ca6a; 4fJN_2132_seccodecSXYwYAC=20246.0620c823cb43b800c7; 4fJN_2132_seccodecSM7ir7C=32974.501fed7ed7e50412ed; 4fJN_2132_seccodecSQTZPiM=26549.061809068ea08ce4ce; PHPSESSID=9ku0thftv26h49i683n1ml0ag1; existmag=all; dv=1' \
        --header 'Referer: https://www.javbus.com/' \
        --header 'sec-ch-ua-mobile: ?0' \
        --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36' \
        --header 'sec-ch-ua-platform: "Linux"' \
        -o `echo $i | sed -e 's/^.*\/\(.*\)$/\1/'`.html \
        $i \
    | tee -a navigation_download.log

    file_name=`echo $i | sed -e 's/^.*\/\(.*\)$/\1/'`.html
    

    for((j=0; ;++j))
    do
        echo $j
        #if [ $next != '' ]
        #if [ $next == '' ]
        next=`cat $file_name | grep 下一頁 | sed -e 's/^.*href=\"\(.*\)".*$/https:\/\/www.javbus.com\1/'`


        if [ ! $next ]
        then
            echo break
            break
        else
            aria2c \
                --header 'sec-ch-ua: "Google Chrome";v="117", "Not;A=Brand";v="8", "Chromium";v="117"' \
                --header 'cookie: 4fJN_2132_seccodecSeRRfg5=14339.4cce2e4f1ae59e531e; 4fJN_2132_seccodecSTVfEvf=9372.f1ae0a808eec67ca6a; 4fJN_2132_seccodecSXYwYAC=20246.0620c823cb43b800c7; 4fJN_2132_seccodecSM7ir7C=32974.501fed7ed7e50412ed; 4fJN_2132_seccodecSQTZPiM=26549.061809068ea08ce4ce; PHPSESSID=9ku0thftv26h49i683n1ml0ag1; existmag=all; dv=1' \
                --header 'Referer: https://www.javbus.com/' \
                --header 'sec-ch-ua-mobile: ?0' \
                --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36' \
                --header 'sec-ch-ua-platform: "Linux"' \
                -o `echo $next | sed -e 's/^.*\/\(.*\/.*\)$/\1/' | sed -e 's/\//_/'`.html \
                $next \
            | tee -a navigation_download.log

            file_name=`echo $next | sed -e 's/^.*\/\(.*\/.*\)$/\1/' | sed -e 's/\//_/'`.html
        fi
    done

done


# { cat navigation_download.log | grep -e "errorCode.*URI=" | sed -e 's/^.*URI=\(.*\)$/\1/'; cat navigation.list; } > navigation.list.new && mv navigation.list{.new,} && rm navigation_download.log

# { cat navigation_download.log | grep -e "errorCode.*URI=" | sed -e 's/^.*URI=\(.*\)$/\1/'; cat navigation.list; } > navigation.list.new && mv navigation.list{.new,} && rm navigation_download.log && { cat navigation.list | sort -u; } > navigation.list.new && mv navigation.list{.new,}





