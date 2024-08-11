#!/bin/bash

# BASH Shell: For Loop File Names With Spaces
# Set $IFS variable
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")


#########################################################################################################
# javbus 域名的页面图片在我的网络条件需要挂代理，根据具体情况修改

# 实际上是为了应对 python 脚本里用 aria2c 批量下载无码区 sample image 的情况，一般有码的不需要 在这里设置
export https_proxy="127.0.0.1:8118"
export http_proxy="127.0.0.1:8118"



#########################################################################################################
# 一个暂停函数
function pause(){
    read -n 1
}


source ./update_input_list.sh


# 如果只需要除了总库中有的车牌的 input.list 在这断开就行
#echo pause
#pause



#######################################################################################################
# 调用 python 脚本 进行下载打包，爬新的车牌

# 每一行作为参数传进 python 脚本，我这里 python 环境是 python3.8，需要根据具体情况修改。运行完除了出错的，就是打包好了的。
for line in $(cat input.list)
do
    echo downloading $line
    python3.8 save_page_tool.py $line
done

# todo.list 是 python 脚本 从每个页面提取的(一般每个页面有几个其他车牌的展示)
if [ -e todo.list ]; then
    sort -u todo.list >> input.list
    rm todo.list
fi



#########################################################################################################
# 当前目录已有 *.tar.gz, 尝试提交到总库， 执行完一次 python 脚本 提交一次， 写入就没那么频繁了

# 清理临时文件
if [ -e tmp.* ]
    then rm tmp.*
fi

# 只提取当前目录已有 *.tar.gz 的 basename，其实就是车牌
find . -maxdepth 1 -type f -name "*.tar.gz" | sed -e 's/\s.*$//' | sed -e 's/.\///' | sed -e 's/.tar.gz$//' | sed -e 's/^[\.].*$//' | sed -e 's/save_page_tools//' | sed -e 's/^.$//g' | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' > tmp.txt

# 为后续 排重更新总库
cat tmp.txt >> av.list
if [ -e tmp.* ]
    then rm tmp.*
fi
source ./update_av_db.sh


#########################################################################################################
# 更新总库后，再更新 input.list，剩下出错的(没有打包出来的车牌)

# 过滤出 input.list 里没有进总库的
for line in $(cat input.list)
do
    if [[ `sqlite3 av.db "select * from files where files like '$line%'"` == "" ]]; then
        todo_list+=($line)
        echo $line not in db
    else
        echo $line exits in db
    fi
done

# 清空 input.list
if [ -e input.list ]
    then rm input.list
fi
touch input.list

# 过滤 input.list 里没有进总库的 车牌 写入 空的 input.list
#for i in ${todo_list[@]}; do echo $i; echo "<https://www.javbus.com/ja/$i>">>more_link.md; done
for i in ${todo_list[@]}; do echo $i>>input.list; done
sed -i 'N;s/^\n//g' input.list
sed -i 's/$/\n/g' input.list
cat input.list | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' | sed 's/[\<\>]*//g' | sed 's/https\:\/\/www.javbus.com\/ja\///g' >> tmp1.txt
sort -u tmp1.txt > tmp.txt
sed -i 's/^.$//g' tmp.txt
cat tmp.txt | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' > tmp1.txt
mv tmp1.txt tmp.txt
mv tmp.txt input.list

# restore $IFS
IFS=$SAVEIFS
