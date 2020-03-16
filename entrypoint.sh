#!/bin/bash -e

if [ "$1" == "bash" ];then
    exec /bin/bash
fi

# installing mysql credentials if file does not exist
mysql_config="/root/.my.cnf"
if [ ! -f "$mysql_config" ]; then
    echo '[xtrabackup]' > /root/.my.cnf
    echo "user=$MYSQL_USER" >> /root/.my.cnf
    echo "password=$MYSQL_PASS" >> /root/.my.cnf
    echo "host=$MYSQL_HOST" >> /root/.my.cnf
    echo "port=$MYSQL_PORT" >> /root/.my.cnf
fi

if [ ! -z "$COPY_BACK_ENABLE" -a "$COPY_BACK_ENABLE" == "true" ];then
    /bin/bash -c "/bin/copy-back"
else
    echo 0 > /tmp/backupnum

    exec go-cron -s "${SCHEDULE:-@every 120s}" -- /bin/bash -c "/bin/backup $BACKUP_TYPE"
fi