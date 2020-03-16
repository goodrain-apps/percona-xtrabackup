# 云帮mysql数据库备份插件

```
# 支持变量
BACKUP_ENABLE 是否开启备份
BACKUP_TYPE 备份类型(full,incremental)
SCHEDULE 定时任务时间，支持格式("* * * * *", "@every 150s")
BACKUP_CYCLE 增量备份周期，每周期进行一次全备份，在此基础上进行增量备份
DINGTOKEN 备份通知
```

# Todo

- 支持增量备份
- 支持恢复备份
- 支持同步备份到远端