# 云帮mysql数据库备份插件

```
# 支持变量
BACKUP_ENABLE 是否开启备份
BACKUP_TYPE 备份类型(full,incremental)
SCHEDULE 定时任务时间，支持格式("* * * * *")
BACKUP_CYCLE 增量备份周期，每周期进行一次全备份，在此基础上进行增量备份
CLEAN_TIME 备份文件保留时间（天），超出该时间的备份文件将被清理
DINGTOKEN 备份通知
```