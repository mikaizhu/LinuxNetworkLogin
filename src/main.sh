#!/usr/bin/env bash
# part0: 设置crontab，并且每几分钟检测是否联网
main_dir=/home/zml/Desktop # main.sh 脚本的目录
frp_dir=
networkOk=

crontab -e
# 使用默认的编辑器，这样进入crontab就不用选择编辑器了
echo export EDITOR=/usr/bin/vim >> ~/.bashrc
# 本来可以使用crontab -e写入程序的，现在可以使用下面命令直接输入
# 参考：https://stackoverflow.com/questions/4880290/how-do-i-create-a-crontab-through-a-script
# 使用crontab -l检查是否写入
(crontab -l 2>/dev/null; echo "*/30 * * * * cd ${main_dir} && ./main.sh") | crontab -
# cron restart 使得crontab内容生效
expect <<EOF
  spawn service cron restart
  expect "Password*" {send "1234\n"}
  expect eof
EOF
# 然后应该通过日志检查crontab的运行效果，日志位置/var/log/syslog, 自己通过sudo查看

# part1: 检测上网是否成功

ping -c 1 baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
    networkOk=true
else
    networkOk=false
fi

# 如果没连上网，则自动联网
./net_login.sh ${networkOk}

# part2: 检测frp是否成功开启
# 配置frpc开机自动启动, 这里两种选择1. 自动使用脚本启动，2. 使用systermctl命令，配置文件开机启动
# option1:

# option2: 注意要修改frp的文件内容
# cat frp.service > /lib/systemd/system/frp.service
# 检测frp是否开启
# 检测端口是否正在监听

frp_listening=

# 如果使用grep，那么grep本身的进程，也会显示下，即无论搜索什么，都会有进程
# 使用lsof查看端口是否监听，注意和netstat -ant区分
lsof -i:7000 | pgrep frp
if [ $? -eq 0 ]; then
  frp_listening=true
  echo "frp正在监听"
  exit 0 # 监听的话则正常退出
else
  frp_listening=false
fi

if !(${frp_listening}); then
  nohub ./${frp_dir}/frpc -c ./${frp_dir}/frpc.ini >/dev/null 2>&1 &
  lsof -i:7000 | pgrep frp
  if [ $? -eq 0]; then
    echo "监听成功"
  else
    echo "监听失败"
  fi
fi
