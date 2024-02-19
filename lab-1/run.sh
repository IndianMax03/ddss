psql -h pg -d studs -f ~/ddss/main.sql 2>&1 | sed 's|.*NOTICE:  ||g'
