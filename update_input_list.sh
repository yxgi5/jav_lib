#!/bin/bash


#########################################################################################################
# 当前目录已有 *.tar.gz, 尝试提交到总库， 开始运行时当前目录也可能有下载打包好的 *.tar.gz 没有更新到总库

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
# 从 input.list 过滤已经有的，剩下没有的车牌 

# 如果存在 input.list 就排个序，并且去除空行， 如果不存在就创建一个空文件
if [ ! -e input.list ]; then
        touch input.list
    else
        sort -u input.list > input.list.tmp
        sed -i 's/^.$//g' input.list.tmp
        cat input.list.tmp | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d' > input.list
        rm input.list.tmp
fi

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
if [ -e 404_bango.list ]; then
    # cat 404_url.txt | sed 's/https\:\/\/www.javbus.com\/ja\///g' | sort -u >> tmp.txt
    cat 404_bango.list | sort -u > 404_bango.list.new
    mv 404_bango.list{.new,}
    echo -e 'CREATE TABLE files (files TEXT);\n-- .tables\nselect * from files;\n.import 404_bango.list files\n.exit\n' | sqlite3 404_bango.db
    todo1=()
    for i in ${todo[@]}
    do
        if [[ `sqlite3 tmp.db "select * from files where files like '%$i%'"` == "" ]]; then
            todo1+=($i)
        fi
    done
    rm tmp.*
    # 总库中没有的写入到 input.list，已经排除了总库中有的车牌
    rm input.list
    touch input.list
    for i in ${todo1[@]}; do echo $i>>input.list; done
    sed -i 'N;s/^\n//g' input.list
else
    # 总库中没有的写入到 input.list，已经排除了总库中有的车牌
    rm input.list
    touch input.list
    for i in ${todo[@]}; do echo $i>>input.list; done
    sed -i 'N;s/^\n//g' input.list
fi




