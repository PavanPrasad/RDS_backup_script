#!/bin/bash
###Description:Database backup from RDS instance to be copied to s3###
###Author: PAVAN PRASAD###

echo "\n--------------------------------------------------------"
echo "Starting PID =>  $$"
echo "Backup started at $(date +%F_%H:%M:%S)"

cd /backup/rdsbackup
db="DB_Name"
db_file="$db"_"$(date +%F_%H-%M-%S).sql.gz"
sql=$(for i in $db;do /opt/lampp/bin/mysqldump -h 'DB_name.ap-southeast-2.rds.amazonaws.com' --ssl-ca=/var/mysql-certs/rds-combined-ca-bundle.pem -vv -u'root' -p'password' $i | gzip > ${db_file}; done)

if [ $? -eq 0 ]; then

 /usr/bin/aws s3 cp "${db_file}" s3://DB-rds/

if [ $? -eq 0 ];then

echo "RDS DB Backup sync to S3 Succeeded " | mailx -s "Success-Back-alert  RDS DB -172.16.27.9" -a "From: user@mail" user@mail

else

echo "RDS DB Backup sync to S3 Failed " | mailx -s "Failure-Back-alert RDS DB -172.16.27.9" -a "From: user@mail" user@mail

fi

 du -sh  ${db_file}
 /bin/rm -f ${db_file}
fi
