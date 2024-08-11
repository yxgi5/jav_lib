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
list=`find . -maxdepth 1 -type f -name "*.html" -o -name "*.htm" | xargs -d '\n' grep https://www.javbus.com/ja/ | sed 's/\"/\n/g' | sed 's/\ /\n/g' | sed 's/\#/\n/g'| sed 's/)/\n/g'| grep https://www.javbus.com/ja | sed 's/\#$//g' | grep - | sed 's/\//\n/g' | grep - | sort -u`
#lists=`cat *.html | grep https://www.javbus.com/ja/ | sed 's/\"/\n/g' | sed 's/\ /\n/g' | sed 's/\#/\n/g'| sed 's/)/\n/g'| grep https://www.javbus.com/ja | sed 's/\#$//g' | grep - | sed 's/\//\n/g' | grep - | sort -u` 
# #先从总数据库检查是否存在，如果有就不保留
# for i in $lists
# do
# #echo $i
# if [[ `sqlite3 av.db "select * from files where files like '%$i%'"` == "" ]]; then
# #   echo $i
#    todo_list+=($i)
# #else
# #   echo 0
# fi
# done

#清理
if [ -e tmp.* ]
    then rm tmp.*
fi
#已经保存的页面
#find . -maxdepth 1 -type d | sed -e 's/\s.*$//' | sed -e 's/.\///' | sed -e 's/^.$//g' | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' > tmp1.txt
find . -maxdepth 1 -type d | sed -e 's/\s.*$//' | sed -e 's/.\///' | sed -e 's/^[\.].*$//' | sed -e 's/save_page_tools//' | sed -e 's/^.$//g' | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' > tmp1.txt
#sort -u tmp1.txt > tmp.txt
#sed -i 's/^.$//g' tmp.txt
#cat tmp.txt | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' > tmp1.txt
#为后续排重更新总库
cat tmp1.txt >> av.list
if [ -e tmp.* ]
    then rm tmp.*
fi
source ./av_db_list_update.sh


#已经准备好要保存的页面链接，可能包括也可能不包括已经保存的页面
cat todo.md | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' | sed 's/[\<\>]*//g' | sed 's/https\:\/\/www.javbus.com\/ja\///g' >> tmp1.txt
sort -u tmp1.txt > tmp.txt
rm tmp1.txt

#先从总数据库检查是否存在，如果有就不保留
for i in $lists
do
#echo $i
if [[ `sqlite3 av.db "select * from files where files like '%$i%'"` == "" ]]; then
#   echo $i
   todo_list+=($i)
#else
#   echo 0
fi
done

# 上面两种情况(已经保存的页面,加todo.md里),去重后都放临时数据库
echo -e 'CREATE TABLE `files` (`files` TEXT);\n-- .tables\nselect * from files;\n.import tmp.txt files\n.exit\n' > tmp.sql
sqlite3 tmp.db < tmp.sql


#经过总数据库过滤剩下的再通过临时数据库过滤
for i in ${todo_list[@]}
do
#echo $i
if [[ `sqlite3 tmp.db "select * from files where files like '%$i%'"` == "" ]]; then
#   echo $i
   todo+=($i)
#else
#   echo 0
fi
done

rm tmp.*


#两次过滤剩下的就是完全没有记录过的，添加到临时链接页面
#echo $todo_list
if [ -e more_link.md ]
    then rm more_link.md
fi
touch more_link.md
for i in ${todo[@]}; do echo $i; echo "<https://www.javbus.com/ja/$i>">>more_link.md; done
sed -i 'N;s/^\n//g' more_link.md
sed -i 's/$/\n/g' more_link.md

#pause
cat more_link.md >> todo.md
if [ -e more_link.md ]
    then rm more_link.md
fi

#for i in $list;do echo "<https://www.javbus.com/ja/$i>">more_link.md; done
#sed -i 'N;s/^\n//g' more_link.md
#sed -i 's/$/\n/g' more_link.md
#cat more_link.md > todo.md
#rm more_link.md
#rm tmp.txt

#去空行
#sed -i 's/[ \t]*$//g' todo.md
#sed -i 's/^[ \t]*//g' todo.md
#sed -i '/^[ \t]*$/d' todo.md
#排序
#sort -u todo.md > todo1.md
#mv todo1.md todo.md
#sed -i 's/$/\n/g' todo.md

# #执行附件链接下载和整体打包 最好是放这，数量比较多的时候放这
# source ./proc.sh

#todo排序一下
cat todo.md | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' | sed 's/[\<\>]*//g' | sed 's/https\:\/\/www.javbus.com\/ja\///g' >> tmp1.txt
sort -u tmp1.txt > tmp.txt
sed -i 's/^.$//g' tmp.txt
cat tmp.txt | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' > tmp1.txt
mv tmp1.txt tmp.txt
#rm tmp1.txt

#pause
## empty an array in bash script
#unset todo1
todo1=()
list=$(cat tmp.txt)
rm tmp.txt
for i in $list
do
if [[ `sqlite3 av.db "select * from files where files like '%$i%'"` == "" ]]; then
    echo $i
    todo1+=($i)
fi
done

if [ -e more_link.md ]
    then rm more_link.md
fi
touch more_link.md
for i in ${todo1[@]}; do echo $i; echo "<https://www.javbus.com/ja/$i>">>more_link.md; done
sed -i 'N;s/^\n//g' more_link.md
sed -i 's/$/\n/g' more_link.md
mv more_link.md todo.md

#执行附件链接下载和整体打包. 为了快速出todo，放在这
source ./proc.sh

#rm packup_folder_name_with_space_del.sh
# restore $IFS
IFS=$SAVEIFS
