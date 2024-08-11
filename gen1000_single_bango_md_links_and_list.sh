#!/bin/bash

#NAME=AVKH
NAME=$1

if [ [${NAME} == ""] ];then
    echo -e "No name provided. \nexit"
    exit
else
    echo ${NAME}
fi

if [ -e single_bango.md ];then
    rm single_bango.md
fi

for i in {001..999..1}; do echo $NAME-$i; echo "<https://www.javbus.com/ja/$NAME-$i>" >> single_bango.md; done
sed -i 'N;s/^\n//g' single_bango.md
sed -i 's/$/\n/g' single_bango.md

if [ -e single_bango.list ];then
    rm single_bango.list
fi

for i in {001..999..1}; do echo $NAME-$i; echo $NAME-$i >> single_bango.list; done
sed -i 'N;s/^\n//g' single_bango.list

