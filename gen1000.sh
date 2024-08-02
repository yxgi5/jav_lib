#!/bin/bash

#NAME=AVKH
NAME=$1
rm simple_link.md
for i in {001..999..1}; do echo $NAME-$i; echo "<https://www.javbus.com/ja/$NAME-$i>">>simple_link.md; done
sed -i 'N;s/^\n//g' simple_link.md
sed -i 's/$/\n/g' simple_link.md
