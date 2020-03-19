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
    echo $1 > /tmp/all_back.txt
    ls $incrPath | grep -v log | sort -r >> /tmp/all_back.txt
    cat /tmp/all_back.txt | tr ' ' '\n' | sort | grep -A $BACKUP_CYCLE $1 > /tmp/restore_back.txt
}

function restore_full(){
    $PreBin $1
    $ResBin $1
}

function restore_inc(){
    resfullpath=`sed -nr '1p' /tmp/restore_back.txt`
    $IncPreBin $fullPath/$resfullpath
    if [ "$1" -gt 2 ];then
        sed -r '1d;$d' /tmp/restore_back.txt | while read resincfull ;do
            $IncPreBin $fullPath/$resfullpath --incremental-dir=$incrPath/$resincfull
        done
    fi
    /usr/bin/innobackupex --apply-log $fullPath/$resfullpath --incremental-dir=$incrPath/`sed -nr '$p' /tmp/restore_back.txt`
    $ResBin $fullPath/$resfullpath
}

function main(){
    file_list $fullfile
    
    FILE_NUM=`cat /tmp/restore_back.txt | wc -l`

    if [ "$FILE_NUM" -eq 0 ];then 
        status="缺少备份文件，请检查/data/back"
    elif [ "$FILE_NUM" -gt "$BACKUP_CYCLE" ];then
        status="备份文件检测出错，请检查/data/back"
    elif [ "$FILE_NUM" -eq 1 ];then
        restore_full $fullPath/$fullfile $FILE_NUM && status="成功恢复数据" || status="恢复失败，请检查备份文件"
    else 
        restore_inc $FILE_NUM && status="成功恢复数据" || status="恢复失败，请检查备份文件"
    fi

    while true;do
        echo $status
        sleep 100
    done
}

makdir /data/data 
main

