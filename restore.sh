#!/bin/bash

fullPath="/data/backup/full"
incrPath="/data/backup/incremental"
FullPreBin="/usr/bin/innobackupex \
--apply-log"
IncPreBin="/usr/bin/innobackupex \
--apply-log \
--redo-only"
ResBin="/usr/bin/innobackupex \
--copy-back \
--datadir=/data/data"
fullfile=`ls $fullPath | grep -v log | sort -r | head -n 1`

function file_list(){
    incfile=`ls $fullPath | grep -v log | sort -r"
    echo $fullpath > /tmp/all_back.txt
    echo $incfile >> /tmp/all_back.txt
    cat /tmp/all_back.txt | tr ' ' '\n' | sort -r | grep -A $BACKUP_CYCLE $fullpath > /tmp/restore_back.txt
}

function restore_full(){
    $respath=$1
    $PreBin $respath
    $ResBin $respath
}

function restore_inc(){
    resfullpath=`sed -r '1p' /tmp/restore_back.txt`
    $IncPreBin $resfullpath
    sed -r '1d;$d' /tmp/restore_back.txt | while read resincfull ;do
        $IncPreBin $resfullpath --incremental-dir=$resincfull
    done
    /usr/bin/innobackupex --apply-log $resfullpath --incremental-dir=`sed -r '$p' /tmp/restore_back.txt`
    $ResBin $resfullpath
}

function main(){
    file_list
    
    FILE_NUM=`cat /tmp/restore_back.txt | wc -l`

    if [ "$FILE_NUM" -eq 0 ];then 
        echo "缺少备份文件，请检查/data/back"
    elif [ "$FILE_NUM" -gt "$BACKUP_CYCLE"];then
        echo "备份文件检测出错，请检查/data/back"
    elif [ "$FILE_NUM" -eq 1 ];then
        restore_full $fullPath/$fullfile
    else 
        restore_inc
    fi
}

main

