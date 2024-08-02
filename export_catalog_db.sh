#!/bin/bash
sqlite3 catalog.db <<EOF
.mode csv
.header off
.separator |
.out catalog.csv
select * from catalog;
.exit
EOF
