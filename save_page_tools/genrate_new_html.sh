#!/bin/bash

# BASH Shell: For Loop File Names With Spaces
# Set $IFS variable
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")


for files in `find . -maxdepth 1 -type f -name "*.html" | sed -e 's/.\///'`
do
    echo $files
    name=`echo $files | sed -e 's/\s.*$//' | sed -e 's/.\///'`.html
    echo $name
    cat $files | sed -e 's/\/pics\/cover\//\.\//' | sed -e 's/^\(.*<a class="sample-box" href="\).*\/\(.*.jpg">\).*$/\1\.\/\2/' > $name
    mv $name $files
    #cat $files | sed -e 's/\/pics\/cover\//\.\//' | sed -e 's/^\(.*<a class="sample-box" href="\).*\/\(.*.jpg"\).*$/\1\2/' | sed -e 's/^\(.*<img src="\)https:\/\/pics.dmm.co.jp\/digital\/video\/1acc00003\/\(.*\).*$/\1\.\/\2/' > $name
done
#a='<a class="sample-box" href="https://pics.dmm.co.jp/digital/video/1acc00003/1acc00003jp-2.jpg">'
#echo $a | sed -e 's/^.*\/\(.*.jpg\).*$/\1/'
#echo $a | sed -e 's/^.*\(<a class="sample-box" href="\).*\/\(.*.jpg"\).*$/\1\2/'
#a='<img src="https://pics.dmm.co.jp/digital/video/1acc00003/1acc00003-2.jpg"'
#echo $a | sed -e 's/^\(.*<img src="\).*\/\(.*\).*$/\1\2/'


# restore $IFS
IFS=$SAVEIFS
