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

#source ./update_input_list.sh


# 如果只需要除了总库中有的车牌的 input.list 在这断开就行
#echo pause
#pause

#######################################################################################################
# 调用 python 脚本 进行下载打包，爬新的车牌

# 每一行作为参数传进 python 脚本，我这里 python 环境是 python3.8，需要根据具体情况修改。运行完除了出错的，就是打包好了的。
for line in $(cat input.list)
do
    echo downloading $line
    if [ -e /usr/bin/python3.8 ]; then
        python3.8 save_page_tool.py $line
    else
        python3 save_page_tool.py $line
    fi
done

# todo.list 是 python 脚本 从每个页面提取的(一般每个页面有几个其他车牌的展示)
#if [ -e todo.list ]; then
#    sort -u todo.list >> input.list
#    rm todo.list
#fi

#source ./update_input_list.sh

# restore $IFS
IFS=$SAVEIFS
