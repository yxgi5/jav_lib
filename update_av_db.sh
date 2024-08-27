#!/bin/bash
if [ -e av.db ]; then
    echo -e ".output db_tmp.txt\nselect * from files;\n.exit" | sqlite3 av.db
    cat db_tmp.txt | sed 's/[a-z]/\U&/g' >> av.list && rm db_tmp.txt
fi
cat av.list | sed 's/[a-z]/\U&/g' | sort -u > av.list.new && mv av.list{.new,}
sqlite3 av.db <<EOF
drop table if exists files;
CREATE TABLE files (files TEXT);
-- .tables
select * from files;
.import av.list files
.exit
EOF


