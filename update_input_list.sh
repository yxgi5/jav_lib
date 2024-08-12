#!/bin/bash


# 如果存在 input.list 就排个序，并且去除空行， 如果不存在就创建一个空文件
if [ ! -e input.list ]; then
        touch input.list
    else
        cat input.list | sed '/^$/d' | sed 's/^.$//g' | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' | sed 's/[\<\>]*//g' | sed 's/https\:\/\/www.javbus.com\/ja\///g' | sort -u >> input.list.new
        mv input.list{.new,}
fi


#########################################################################################################
# 当前目录已有 *.tar.gz, 尝试提交到总库， 开始运行时当前目录也可能有下载打包好的 *.tar.gz 没有更新到总库

# 清理临时文件
if [ -e tmp.* ]
    then rm tmp.*
fi

# 只提取当前目录已有 *.tar.gz 的 basename，其实就是车牌
find . -maxdepth 1 -type f -name "*.tar.gz" | sed '/^$/d' | sed -e 's/\s.*$//' | sed -e 's/.\///' | sed -e 's/.tar.gz$//' | sed -e 's/^[\.].*$//' | sed -e 's/save_page_tools//' | sed -e 's/^.$//g' | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' >> av.list
source ./update_av_db.sh


#########################################################################################################
# 从 input.list 过滤已经有的，剩下没有的车牌 

# 从input.list逐行对比总库中是否有车牌，没有就添加到todo这个列表里面
todo=()
list=$(cat input.list)
for i in $list
do
if [[ `sqlite3 av.db "select * from files where files like '$i%'"` == "" ]]; then
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

# 总库中没有的写入到 input.list，已经排除了总库中有的车牌
rm input.list
touch input.list
for i in ${todo2[@]}; do echo $i>>input.list; done
cat input.list | sed '/^$/d' | sed 's/^.$//g' | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' | sed 's/[\<\>]*//g' | sed 's/https\:\/\/www.javbus.com\/ja\///g' | sort -u >> input.list.new
mv input.list{.new,}


