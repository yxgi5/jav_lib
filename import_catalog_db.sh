#!/bin/bash

sqlite3 catalog.db <<EOF
drop table if exists catalog;
CREATE TABLE IF NOT EXISTS "catalog" (
	"catalog"	TEXT,
	"status"	TEXT
);
.mode csv
.separator |
.header off
.import catalog.csv catalog
.exit
EOF
