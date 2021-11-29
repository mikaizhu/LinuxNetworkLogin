#!/usr/bin/env bash
frpc_path=/home/zml/Desktop/frp_0.38.0_linux_amd64
username="xxxx" # 用户名
passwd="xxxxxx" # 密码
drcom_website="https://drcom.szu.edu.cn/a70.htm"
networkOk=

ping -c 1 baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
    echo 检测网络正常
    networkOk=true
else
    echo 检测网络连接异常
    networkOk=false
fi

if !(${networkOk});then # 注意使用否定的时候用！并且要加括号
  expect <<EOF
    spawn service network-manager restart
    expect {
    "Password" {send "123456\n"}
    }
    expect eof
EOF
  # 等待网卡重启, 然后登陆校园网
  sleep 2s
  
  curl \
    -s \
    -d "DDDDD=${username}" \
    -d "upass=${passwd}" \
    -d "0MKKey=123456" \
    -X POST "${drcom_website}" \
    | iconv --from-code=GB2312 --to-code=UTF-8 \
    > /dev/null 2>&1 # 因为curl会下载整个网页，这里进行删除
  
  # -c n 表示请求n次
  ping -c 1 baidu.com > /dev/null 2>&1
  if [ $? -eq 0 ];then
      echo 检测网络正常
  else
      echo 检测网络连接异常
      exit 1 # 非正常退出
  fi
fi

# 运行frp，因为这个脚本主要用在客户端上，服务端是公网，本来就应该连上网了
cd ${frpc_path}
nohub ./frpc -c ./frpc.ini &
cd -

