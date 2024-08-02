#!/bin/bash

# BASH Shell: For Loop File Names With Spaces
# Set $IFS variable
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

lists=`find . -maxdepth 1 -name "*.tar.gz"`
for i in $lists
do
echo "tar zxf $i"
tar zxf $i
echo "rm $i"
rm $i
done

lists=`find . -maxdepth 1 -type d | sed -e 's/.\///' | sed 's/[ \t]*$//g' | sed 's/^[ \t]*//g' | sed '/^[ \t]*$/d'`
for i in $lists
do
echo "mv $i/*.html ."
mv $i/*.html .
done

#rm packup_folder_name_with_space_del.sh
# restore $IFS
IFS=$SAVEIFS
