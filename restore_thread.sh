#!/bin/bash

if [ $# -ne 1 ]
then
   echo "no thread id"
   exit 1
fi

threadID=$1

#clean database
echo "clean database..."
mysql -u root -N -e "drop view if exists view_1000_posts;" tmp
mysql -u root -N -e "show tables;" tmp | xargs -I{} mysql -u root -N -e "drop table if exists {};" tmp

#import backup
echo "import backup..."
nice -n19 mysql -u root tmp < database_mitsu-talk.sql 

#delete all but the ones we need
echo "delete unused tables..."
mysql -u root -N -e "drop view if exists view_1000_posts;" tmp
mysql -u root -N -e "show tables;" tmp | grep -v "^wbb1_1_post$" | grep -v "^wbb1_1_thread$" | grep -v "^wbb1_1_thread_subscription$" | grep -v "^wbb1_1_thread_visit$" | grep -v "^wbb1_1_savepost$" | grep -v "^wbb1_1_thread_announcement$" | grep -v "^wbb1_1_thread_rating$" | grep -v "^wbb1_1_thread_similar$" | xargs -I{} mysql -u root -N -e "drop table if exists {};" tmp

#delete all entries but the ones with searched threadID
mysql -u root -N -e "show tables;" tmp | while read tablename
do
   echo "deleting entries from $tablename..."
   nice -n19 mysql -u root -N -e "delete from $tablename where not threadID=$threadID;" tmp
done

#dump it
echo "dumping..."
nice -n19 mysqldump --skip-add-drop-table --no-create-info tmp > $threadID.sql
