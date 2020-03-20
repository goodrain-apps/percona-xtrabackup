#!/bin/bash
fullPath="/data/backup/full"
incrPath="/data/backup/incremental"
bakdate=`date +'%F-%H-%M'`
backupNum=`cat /tmp/backupnum`
BakBin="/usr/bin/xtrabackup \
--backup \
--throttle=1"

[ -d "$fullPath" ] || mkdir -p "$fullPath"
[ -d "$incrPath" ] || mkdir -p "$incrPath"

# full backup function
function hotbackup_full(){
  logfile=$1
  bakpath=$2
  $BakBin --target-dir=$bakpath > $logfile 2>&1
}

# incremental backup function
function hotbackup_inc(){
  logfile=$1
  bakpath=$2
  backupcycle=$3
  backupnum=$4
  let j=backupcycle+1
  let i=backupnum%j
  if [ "$i" = 0 ]; then
    main "full"
  elif [ "$i" = 1 ]; then
    basefile=`ls $fullPath | grep -v log | sort -r | head -n 1`
    basepath="$fullPath/$basefile"
    $BakBin --target-dir=$bakpath --incremental-basedir $basepath > $logfile 2>&1
  else
    basefile=`ls $incrPath | grep -v log | sort -r | head -n 1`
    basepath="$incrPath/$basefile"
    $BakBin --target-dir=$bakpath --incremental-basedir $basepath > $logfile 2>&1
  fi
}

# backup status
function status(){
  if [ "$1" == 0 ];then
    status_info="Full Backup complete"
    curl 'https://oapi.dingtalk.com/robot/send?access_token='$DINGTOKEN''  -H 'Content-Type: application/json' -d '{"msgtype": "text","text": {"content": "Full Backup complete"}}'
  else
    status_info="Full Backup not complete"
    curl 'https://oapi.dingtalk.com/robot/send?access_token='$DINGTOKEN''  -H 'Content-Type: application/json' -d '{"msgtype": "text","text": {"content": "Full Backup not complete"}}'
  fi
  echo "$status_info -- $DINGTOKEN"
}

function clean_timeout_file(){
  find ${fullPath}/ -mtime +$1 -name 2* -exec rm -rf {} \;
  find ${incrPath}/ -mtime +$1 -name 2* -exec rm -rf {} \;
}

# ============= Main =============
function main(){
  echo `ls ${fullPath}/ | grep -v log | wc -l` || clean_timeout_file $CLEAN_TIME
  if [ "$1" == "full" ];then
    hotbackup_full "${fullPath}/${bakdate}.log" "$fullPath/$bakdate"
    status $? >> ${fullPath}/dd.log
  elif [ "$1" == "incremental" ];then
    hotbackup_inc "${incrPath}/${bakdate}.log" "$incrPath/$bakdate" "$BACKUP_CYCLE" "$2"
    status $? >> ${incrPath}/dd.log
  else
    echo ‘The variable BACKUP_TYPE can be set to "full or incremental"’
  fi
}

# ============= Run ==================
if [ ! -z "$BACKUP_ENABLE" -a "$BACKUP_ENABLE" = "true" ];then
  main $1 $backupNum && ((backupNum+=1))
else
  echo ""
fi

echo $backupNum > /tmp/backupnum