#!/bin/bash

# BASH Shell: For Loop File Names With Spaces
# Set $IFS variable
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

#临时保存的页面内含有的可提取链接
lists=`cat *.html | grep https://www.javbus.com/ja/ | sed 's/\"/\n/g' | sed 's/\ /\n/g' | sed 's/\#/\n/g'| sed 's/)/\n/g'| grep https://www.javbus.com/ja | sed 's/\#$//g' | grep - | sed 's/\//\n/g' | grep - | sort -u` 

#清理
rm tmp.*
#已经保存的页面
find . -maxdepth 1 -type d | sed -e 's/\s.*$//' | sed -e 's/.\///' > tmp1.txt
cat tmp1.txt >> av.list
source ./av.sh
#已经准备好要保存的页面链接
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

#剩下的就是完全没有记录过的，添加到临时链接页面
rm more_link.md
for i in ${todo[@]}; do echo $i; echo "<https://www.javbus.com/ja/$i>">>more_link.md; done
sed -i 'N;s/^\n//g' more_link.md
sed -i 's/$/\n/g' more_link.md

cat more_link.md >> todo.md
rm more_link.md


#todo排序一下
cat todo.md | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' | sed 's/[\<\>]*//g' | sed 's/https\:\/\/www.javbus.com\/ja\///g' >> tmp1.txt
sort -u tmp1.txt > tmp.txt
sed -i 's/^.$//g' tmp.txt
cat tmp.txt | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' > tmp1.txt
mv tmp1.txt tmp.txt
#rm tmp1.txt

## empty an array in bash script
#unset todo1
todo1=()
list=$(cat tmp.txt)
for i in $list
do
if [[ `sqlite3 av.db "select * from files where files like '%$i%'"` == "" ]]; then
    echo $i
    todo1+=($i)
fi
done

rm more_link.md
touch more_link.md
for i in ${todo1[@]}; do echo $i; echo "<https://www.javbus.com/ja/$i>">>more_link.md; done
sed -i 'N;s/^\n//g' more_link.md
sed -i 's/$/\n/g' more_link.md
mv more_link.md todo.md


cat *.html | grep "https://pics.dmm.co.jp" | sed 's/\"/\n/g' | grep "https://pics.dmm.co.jp" > piclinks
aria2c -j 10 -x 2 -i piclinks
for folders in `find . -maxdepth 1 -type d | sed -e 's/\s.*$//' | sed -e 's/.\///'`
do
mkdir $folders
mv ${folders}* $folders
done

source ./packup_folder_name_with_space_del.sh

#rm packup_folder_name_with_space_del.sh
# restore $IFS
IFS=$SAVEIFS


