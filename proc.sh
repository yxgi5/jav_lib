#!/bin/bash

# BASH Shell: For Loop File Names With Spaces
# Set $IFS variable
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

#cat *.html | grep "https://pics.dmm.co.jp" | sed 's/\"/\n/g' | grep "https://pics.dmm.co.jp" > piclinks
#aria2c -j 10 -x 2 -i piclinks
# for folders in `find . -maxdepth 1 -type d | sed -e 's/\s.*$//' | sed -e 's/.\///'`
# do
# mkdir $folders
# #mv ${folders}* $folders
# done

for folders in `find . -maxdepth 1 -type d`
do
#echo $folders
#echo $folders | sed -e 's/\s.*$//' | sed -e 's/.\///'
if [ $folders != "." ]
then
    mkdir -p `echo $folders | sed -e 's/\s.*$//' | sed -e 's/.\///'`
    mv $folders `echo $folders | sed -e 's/\s.*$//' | sed -e 's/.\///'`
fi
done

#mv cap_e_* ../AV
#rm now_printing*
#for f in `ls h*.jpg`; do mv -f $f `echo $f | sed 's/^h_[0-9]* *//'`; done
#for f in `ls *.jpg`; do mv -f $f `echo $f | sed 's/^[0-9]* *//'`; done
#for folders in `find . -type d -maxdepth 1`
#do 
#mv `echo $folders |  tr '[A-Z]' '[a-z]' | sed 's/\-/00/'`* $folders
#mv `echo $folders |  tr '[A-Z]' '[a-z]' | sed 's/\-/0/'`* $folders
#mv `echo $folders |  tr '[A-Z]' '[a-z]' | sed 's/\-//'`* $folders
#done

#SAVEIFS=$IFS
#IFS=$(echo -en "\n\b")
for names in `find . -type f -name "*.html" | sed -e 's/.\///'`
do
    echo "donwloading for $names"
    cat $names | grep "https://pics.dmm.co.jp" | sed 's/\"/\n/g' | grep "https://pics.dmm.co.jp" > piclinks
    cat $names | grep "https://image.mgstage.com" | sed 's/\"/\n/g' | grep "https://image.mgstage.com" >> piclinks
    cat $names | grep "https://www.javbus.com/imgs/bigsample" | sed 's/\"/\n/g' | grep "https://www.javbus.com/imgs/bigsample" >> piclinks
    aria2c -j 10 -x 2 -i piclinks
    rm now_printing*
#    echo $names
#    echo $names | sed -e 's/\s.*$//' | sed -e 's/.\///' 
#    echo "mv *.jpg `echo $names | sed -e 's/\s.*$//' | sed -e 's/.\///' `"
    mv *.jpg `echo $names | sed -e 's/\s.*$//' | sed -e 's/.\///'`
    mv $names `echo $names | sed -e 's/\s.*$//' | sed -e 's/.\///'`
#    if [ ! -d `echo $names | sed -e 's/\s.*$//' | sed -e 's/.\///'` ]; then
    if [ -d `echo $names | sed -e 's/\s.*$//' | sed -e 's/.\///'` ]; then
        tar -zcvpf `echo $names | sed -e 's/\s.*$//' | sed -e 's/.\///'`.tar.gz `echo $names | sed -e 's/\s.*$//' | sed -e 's/.\///'`
        rm -rf `echo $names | sed -e 's/\s.*$//' | sed -e 's/.\///'`
    fi
    echo $names | sed -e 's/\s.*$//' | sed -e 's/.\///' >> av.list
done
#IFS=$SAVEIFS

#ls -l |grep ^d |awk '{print substr($0,index($0,$9))}' >> av.list

#for folders in `ls -l |grep ^d |awk '{print substr($0,index($0,$9))}'`
##FILES=*
##for folders in $FILES
#do 
#echo $folders
#tar -zcvpf $folders.tar.gz $folders/*
#rm -rf $folders
##7z a -sdel $folders.7z $folders/*
##7z a -sdel -t7z -mx9 -aoa $folders.7z $folders
#done

source ./av.sh

rm piclinks

#rm packup_folder_name_with_space_del.sh
# restore $IFS
IFS=$SAVEIFS



# a reverse ops

#for names in `find . -maxdepth 1 -type d -name "*" | sed -e 's/.\///'`
#do
#echo $names
#mv $names/* .
#rm -rf $names
#done
