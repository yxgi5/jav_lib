#!/bin/bash
sort -u fail_bango.list > fail_bango.list.new && mv fail_bango.list{.new,}
sqlite3 fail_bango.db <<EOF
drop table if exists files;
CREATE TABLE files (files TEXT);
-- .tables
select * from files;
.import fail_bango.list files
.exit
EOF

