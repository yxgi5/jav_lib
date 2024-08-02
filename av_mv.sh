#!/bin/bash

TARGET=../AV

#如果是文件，退出执行
if [ -f "${TARGET}" ]; then
    echo "../AV是文件而非目录"
    exit 1
fi

#如果文件夹不存在，创建文件夹
if [ ! -d "${TARGET}" ]; then
    echo "mkdir -p ${TARGET}"
    mkdir -p ${TARGET}
fi


for i in {0..9..1}
do
    mkdir -p ${TARGET}/${i}
done

for i in {a..z}
do
    mkdir -p ${TARGET}/${i}
done



mv -n *.tar.gz ${TARGET}

cd ${TARGET}


for i in {0..9..1}
do
    for file in `find . -type f -name "${i}*.tar.gz"`
    do
        echo "mv -n ${file} ${i}/"
        mv -n ${file} ${i}/
    done
done


for i in {a..z}
do
    for file in `find . -type f -name "${i}*.tar.gz"`
    do
        echo "mv -n ${file} ${i}/"
        mv -n ${file} ${i}/
    done

    for file in `find . -type f -name "${i^^}*.tar.gz"`
    do
        echo "mv -n ${file} ${i}/"
        mv -n ${file} ${i}/
    done
done

cd -



: <<COMMENT
for file in `find . -type f -name "A*.tar.gz" -o -name "a*.tar.gz"`
do
    mv -n ${file} a/ 
done
COMMENT



