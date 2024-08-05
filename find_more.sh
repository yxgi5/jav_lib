#!/bin/bash

# BASH Shell: For Loop File Names With Spaces
# Set $IFS variable
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")



#export https_proxy="127.0.0.1:8118"
#export http_proxy="127.0.0.1:8118"

function pause(){
    read -n 1
}


if [ ! -e input.list ]; then
        touch input.list
    else
        sort -u input.list > input.list.tmp
        sed -i 's/^.$//g' input.list.tmp
        cat input.list.tmp | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' > input.list
        rm input.list.tmp
fi

todo=()
list=$(cat input.list)
for i in $list
do
if [[ `sqlite3 av.db "select * from files where files like '%$i%'"` == "" ]]; then
    echo $i
    todo+=($i)
fi
done

rm input.list
touch input.list
for i in ${todo[@]}; do echo $i; echo $i>>input.list; done
sed -i 'N;s/^\n//g' input.list


for line in $(cat input.list)
do
    # echo $line
    python3.8 save_page_tool.py $line
done


if [ -e todo.list ]; then
    sort -u todo.list > input.list
    rm todo.list
fi

#清理
if [ -e tmp.* ]
    then rm tmp.*
fi

find . -maxdepth 1 -type f -name "*.tar.gz" | sed -e 's/\s.*$//' | sed -e 's/.\///' | sed -e 's/.tar.gz$//' | sed -e 's/^[\.].*$//' | sed -e 's/save_page_tools//' | sed -e 's/^.$//g' | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' > tmp1.txt
#为后续排重更新总库
cat tmp1.txt >> av.list
if [ -e tmp.* ]
    then rm tmp.*
fi
source ./av.sh

for line in $(cat input.list)
do
    if [[ `sqlite3 av.db "select * from files where files like '%$i%'"` == "" ]]; then
        todo_list+=($i)
    fi
done

if [ -e input.list ]
    then rm input.list
fi
touch input.list
#for i in ${todo[@]}; do echo $i; echo "<https://www.javbus.com/ja/$i>">>more_link.md; done
for i in ${todo[@]}; do echo $i; echo $i>>input.list; done
sed -i 'N;s/^\n//g' input.list
sed -i 's/$/\n/g' input.list

cat input.list | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' | sed 's/[\<\>]*//g' | sed 's/https\:\/\/www.javbus.com\/ja\///g' >> tmp1.txt
sort -u tmp1.txt > tmp.txt
sed -i 's/^.$//g' tmp.txt
cat tmp.txt | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' > tmp1.txt
mv tmp1.txt tmp.txt
mv tmp.txt input.list

#rm packup_folder_name_with_space_del.sh
# restore $IFS
IFS=$SAVEIFS
