#!/bin/bash

# BASH Shell: For Loop File Names With Spaces
# Set $IFS variable
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

lists=`find . -maxdepth 1 -type f -name "*.tar.gz" | sed -e 's/\s.*$//' | sed -e 's/.\///' | sed -e 's/.tar.gz$//' | sed -e 's/^[\.].*$//' | sed -e 's/save_page_tools//' | sed -e 's/^.$//g' | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d'`
for i in $lists
do
    echo "tar zxf $i.tar.gz"
    tar zxf $i.tar.gz
    echo "rm $i.tar.gz"
    rm $i.tar.gz
    html_file_num=$(ls $i/*.html 2> /dev/null | wc -l)
    if [ "$html_file_num" != "0" ]; then
        echo "mv $i/*.html ."
        mv $i/*.html .
    fi
done

# restore $IFS
IFS=$SAVEIFS
