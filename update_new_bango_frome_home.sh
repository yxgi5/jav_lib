#!/bin/bash

export https_proxy="127.0.0.1:8118"
export http_proxy="127.0.0.1:8118"

#########################################################################################################
# 一个暂停函数
function pause(){
    read -n 1
}

list='https://www.javbus.com/ja https://www.javbus.com/ja/uncensored'

for i in $list
do
    echo $i
    file_name=`echo $i | sed -e 's/^.*\/\(.*\)$/\1/'`.html
    aria2c \
        --header 'sec-ch-ua: "Google Chrome";v="117", "Not;A=Brand";v="8", "Chromium";v="117"' \
        --header 'cookie: 4fJN_2132_seccodecSeRRfg5=14339.4cce2e4f1ae59e531e; 4fJN_2132_seccodecSTVfEvf=9372.f1ae0a808eec67ca6a; 4fJN_2132_seccodecSXYwYAC=20246.0620c823cb43b800c7; 4fJN_2132_seccodecSM7ir7C=32974.501fed7ed7e50412ed; 4fJN_2132_seccodecSQTZPiM=26549.061809068ea08ce4ce; PHPSESSID=9ku0thftv26h49i683n1ml0ag1; existmag=mag; dv=1' \
        --header 'Referer: https://www.javbus.com/' \
        --header 'sec-ch-ua-mobile: ?0' \
        --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36' \
        --header 'sec-ch-ua-platform: "Linux"' \
        -o $file_name \
        $i \
    | tee -a navigation_download.log
    if [ -e $file_name ];then
        bango_list=`cat $file_name | grep https://www.javbus.com/ja/ | sed 's/\"/\n/g' | sed 's/\ /\n/g' | sed 's/\#/\n/g'| sed 's/)/\n/g'| grep https://www.javbus.com/ja | sed 's/driver-verify.*$//' | sed 's/\#$//g' | grep - | sed 's/\//\n/g' | grep - | sort -u`
    fi
    
    # 从input.list逐行对比总库中是否有车牌，没有就添加到todo这个列表里面
    todo=()
    for i in $bango_list
    do
    if [[ `sqlite3 av.db "select * from files where files like '$i%'"` == "" ]]; then
        # echo $i new
        todo+=($i)
    fi
    done

    # 排除404的车牌
    touch 404_bango.list
    source ./update_404_db.sh
    todo1=()
    for i in ${todo[@]}
    do
        if [[ `sqlite3 404_bango.db "select * from files where files like '%$i%'"` == "" ]]; then
            todo1+=($i)
        fi
    done

    # 排除fail的车牌
    touch fail_bango.list
    source ./update_fail_db.sh
    todo2=()
    for i in ${todo1[@]}
    do
        if [[ `sqlite3 404_bango.db "select * from files where files like '%$i%'"` == "" ]]; then
            todo2+=($i)
        fi
    done

    # pause

    for((; ;))
    do
        if [ "${#todo2[@]}" != '0' ]; then
            # rm input.list
            touch input.list
            for i in ${todo2[@]}; do echo $i>>input.list; done
            cat input.list | sed '/^$/d' | sed 's/^.$//g' | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' | sed 's/[\<\>]*//g' | sed 's/https\:\/\/www.javbus.com\/ja\///g' | sort -u >> input.list.new
            mv input.list{.new,}
            next=`cat $file_name | grep 下一頁 | sed -e 's/^.*href=\"\(.*\)".*$/https:\/\/www.javbus.com\1/'`
            rm $file_name
        else
            rm $file_name
            break
        fi

        if [ ! $next ]
        then
            break
        else
            aria2c \
                --header 'sec-ch-ua: "Google Chrome";v="117", "Not;A=Brand";v="8", "Chromium";v="117"' \
                --header 'cookie: 4fJN_2132_seccodecSeRRfg5=14339.4cce2e4f1ae59e531e; 4fJN_2132_seccodecSTVfEvf=9372.f1ae0a808eec67ca6a; 4fJN_2132_seccodecSXYwYAC=20246.0620c823cb43b800c7; 4fJN_2132_seccodecSM7ir7C=32974.501fed7ed7e50412ed; 4fJN_2132_seccodecSQTZPiM=26549.061809068ea08ce4ce; PHPSESSID=9ku0thftv26h49i683n1ml0ag1; existmag=mag; dv=1' \
                --header 'Referer: https://www.javbus.com/' \
                --header 'sec-ch-ua-mobile: ?0' \
                --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36' \
                --header 'sec-ch-ua-platform: "Linux"' \
                -o `echo $next | sed -e 's/^.*\/\(.*\/.*\)$/\1/' | sed -e 's/\//_/'`.html \
                $next \
            | tee -a navigation_download.log
            file_name=`echo $next | sed -e 's/^.*\/\(.*\/.*\)$/\1/' | sed -e 's/\//_/'`.html
            if [ -e $file_name ];then
                bango_list=`cat $file_name | grep https://www.javbus.com/ja/ | sed 's/\"/\n/g' | sed 's/\ /\n/g' | sed 's/\#/\n/g'| sed 's/)/\n/g'| grep https://www.javbus.com/ja | sed 's/driver-verify.*$//' | sed 's/\#$//g' | grep - | sed 's/\//\n/g' | grep - | sort -u`
            fi
            
            # 从input.list逐行对比总库中是否有车牌，没有就添加到todo这个列表里面
            todo=()
            for i in $bango_list
            do
            if [[ `sqlite3 av.db "select * from files where files like '$i%'"` == "" ]]; then
                # echo $i new
                todo+=($i)
            fi
            done

            # 排除404的车牌
            touch 404_bango.list
            source ./update_404_db.sh
            todo1=()
            for i in ${todo[@]}
            do
                if [[ `sqlite3 404_bango.db "select * from files where files like '%$i%'"` == "" ]]; then
                    todo1+=($i)
                fi
            done

            # 排除fail的车牌
            touch fail_bango.list
            source ./update_fail_db.sh
            todo2=()
            for i in ${todo1[@]}
            do
                if [[ `sqlite3 404_bango.db "select * from files where files like '%$i%'"` == "" ]]; then
                    todo2+=($i)
                fi
            done
        fi
    done

done

# pause
cat input.list >> all_bango.list
cat all_bango.list | sort -u >> all_bango.list.new
mv all_bango.list{.new,}
# source ./auto_start.sh


