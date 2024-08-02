#!/bin/bash
echo -e ".output db_tmp.txt\nselect * from files;\n.exit" | sqlite3 av.db
cat db_tmp.txt >> av.list
rm db_tmp.txt
sort -u av.list > av.tmp
mv av.tmp av.list
sqlite3 av.db < av.sql
#drop table files;
#CREATE TABLE `files` (`files` TEXT);
#.tables
#select * from files;
#.import av.list files
#.exit

#sqlitebrowser av.db
