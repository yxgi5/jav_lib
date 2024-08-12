#!/bin/bash
if [ -e 404_bango.db ]; then
    echo -e ".output db_tmp.txt\nselect * from files;\n.exit" | sqlite3 404_bango.db
    cat db_tmp.txt >> 404_bango.list && rm db_tmp.txt
fi
sort -u 404_bango.list > 404_bango.list.new && mv 404_bango.list{.new,}
sqlite3 404_bango.db <<EOF
drop table if exists files;
CREATE TABLE files (files TEXT);
-- .tables
select * from files;
.import 404_bango.list files
.exit
EOF


