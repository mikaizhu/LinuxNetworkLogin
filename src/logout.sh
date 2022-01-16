#!/usr/bin/env bash
# 关闭自动登陆上网
# 这里本来想通过sed删除crontab中的指定行
line_num=$(crontab -l | grep -ns "Desktop1" | cut -f1 -d:)
# 这里使用crontab -r 删除所有任务, 没找到从crontab删除指定行的方法
crontab -r
