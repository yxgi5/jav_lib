#!/bin/bash

export https_proxy="127.0.0.1:8118"
export http_proxy="127.0.0.1:8118"

function pause(){
    read -n 1
}

# BASH Shell: For Loop File Names With Spaces
# Set $IFS variable
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

#临时保存的页面内含有的可提取链接
lists=`find . -maxdepth 1 -type f -name "*.html" -o -name "*.htm" | xargs -d '\n' grep movie-box | grep https://www.javbus.com/ja/ | sed 's/\"/\n/g' | sed 's/\ /\n/g' | sed 's/\#/\n/g'| sed 's/)/\n/g'| grep https://www.javbus.com/ja | sed 's/\#$//g' | grep - | sed 's/\//\n/g' | grep - | sort -u`


#已经保存的页面
find . -maxdepth 1 -type d | sed -e 's/\s.*$//' | sed -e 's/.\///' | sed -e 's/^[\.].*$//' | sed -e 's/save_page_tools//' | sed -e 's/^.$//g' | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' >> av.list
source ./update_av_db.sh


#已经准备好要保存的页面链接，可能包括也可能不包括已经保存的页面
if [ -e todo.list ]; then
    cat todo.list | sed 's/[a-z]/\U&/g' | sort -u >> input.list
    rm todo.list
fi


#先从总数据库检查是否存在，如果有就不保留
todo=()
for i in $lists
do
#echo $i
if [[ `sqlite3 av.db "select * from files where files = '$i' COLLATE NOCASE limit 1"` == "" ]]; then
    echo $i new
    todo+=($i)
fi
done

# 排除404的车牌
touch 404_bango.list
source ./update_404_db.sh
todo1=()
for i in ${todo[@]}
do
    if [[ `sqlite3 404_bango.db "select * from files where files = '$i' COLLATE NOCASE limit 1"` == "" ]]; then
        todo1+=($i)
    fi
done

# 排除fail的车牌
touch fail_bango.list
source ./update_fail_db.sh
todo2=()
for i in ${todo1[@]}
do
    if [[ `sqlite3 fail_bango.db "select * from files where files = '$i' COLLATE NOCASE limit 1"` == "" ]]; then
        todo2+=($i)
    fi
done

touch input.list
for i in ${todo2[@]}; do echo $i>>input.list; done
cat input.list | sed '/^$/d' | sed 's/^.$//g' | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' | sed 's/[\<\>]*//g' | sed 's/https\:\/\/www.javbus.com\/ja\///g' | sed 's/[a-z]/\U&/g' | sort -u >> input.list.new
mv input.list{.new,}


cat input.list >> all_bango.list
cat all_bango.list | sort -u >> all_bango.list.new
mv all_bango.list{.new,}


#执行附件链接下载和整体打包. 为了快速出todo，放在这
source ./proc.sh

#rm packup_folder_name_with_space_del.sh
# restore $IFS
IFS=$SAVEIFS
