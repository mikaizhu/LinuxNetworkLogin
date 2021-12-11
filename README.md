# LinuxNetworkLogin

OS: Linux

代码说明：完成Linux自动检查是否联网，如果没有联网，则自动登陆账号连接

文件目录说明：
- src: 
    - main.sh 主文件
    - net_login.sh: 检测当前是否能上网，不能上网则自动连接

# 使用教程

step1: 配置好config文件中的所有信息

step2: 在Linux系统中，拷贝该仓库，然后运行下面代码
```
cd src/
chmod +x main.sh net_login.sh
./main.sh
```

# 流程说明

frp: 好像不需要客户端联网，也能连接

## Linux自动定时检测是否联网

任务分解：
- Linux定时执行任务
- 检测是否联网

检测是否联网代码：

```
ping -c 1 baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
    echo 检测网络正常
else
    echo 检测网络连接异常
fi
```

<details>
<summary>/dev/null 2>&1 是什么作用？</summary>

参考：https://stackoverflow.com/questions/10508843/what-is-dev-null-21/42919998#42919998

Let's break >> /dev/null 2>&1 statement into parts:

Part 1: >> output redirection

This is used to redirect the program output and append the output at the end of the file. More...

Part 2: /dev/null special file

This is a Pseudo-devices special file.

Command ls -l /dev/null will give you details of this file:

crw-rw-rw-. 1 root root 1, 3 Mar 20 18:37 /dev/null
Did you observe crw? Which means it is a pseudo-device file which is of character-special-file type that provides serial access.

/dev/null accepts and discards all input; produces no output (always returns an end-of-file indication on a read). Reference: Wikipedia

Part 3: 2>&1 (Merges output from stream 2 with stream 1)

Whenever you execute a program, the operating system always opens three files, standard input, standard output, and standard error as we know whenever a file is opened, the operating system (from kernel) returns a non-negative integer called a file descriptor. The file descriptor for these files are 0, 1, and 2, respectively.

So 2>&1 simply says redirect standard error to standard output.

& means whatever follows is a file descriptor, not a filename.

In short, by using this command you are telling your program not to shout while executing.

What is the importance of using 2>&1?

If you don't want to produce any output, even in case of some error produced in the terminal. To explain more clearly, let's consider the following example:

$ ls -l > /dev/null
For the above command, no output was printed in the terminal, but what if this command produces an error:

$ ls -l file_doesnot_exists > /dev/null
ls: cannot access file_doesnot_exists: No such file or directory
Despite I'm redirecting output to /dev/null, it is printed in the terminal. It is because we are not redirecting error output to /dev/null, so in order to redirect error output as well, it is required to add 2>&1:

$ ls -l file_doesnot_exists > /dev/null 2>&1
</details>

linux 定时执行任务：

## 内网穿透代码

需求：
1. frp内网穿透
2. 后台运行frp

后台运行：

```
nohup ./frps -c frps.ini >/dev/null 2>&1 &
nohup ./frpc -c ./frpc.ini >/dev/null 2>&1 &
```

查看后台是否运行：

```
lsof -i:7000 | grep frp
```

查看运行状态：

```
cat nohub.out
```

## linux自动输入

比如使用sudo命令，会要求我们输入管理员密码，还有其他操作可能会要求用户输入

使用expect，可以模拟输入流，不是明文输入

参考：https://github.com/dunwu/linux-tutorial/blob/master/docs/linux/expect.md

expect 中如何使用Linux脚本变量？

> 如果在shell脚本中使用expect脚本，在expect中直接使用$变量
> 如果两者是不同的文件，要在expect脚本使用linux变量, `export a="test"` `set a_exp \$::env(a)` 
> 参考：https://www.cnblogs.com/TDXYBS/p/11012089.html

## frp开机自启动

这里有两种选择，一是systemclt控制frp启动，二是通过shell控制脚本启动

## 内网穿透

## 文件传输

现在通过内网穿透，但是要传输文件的话，使用scp

```
scp -P 6000 your_file zwl@client_ip:path
```

# Linux翻墙教程

使用软件：
- v2ray-core
- v2rayA

安装方法：

```
# 先安装v2ray-core
curl -Ls https://mirrors.v2raya.org/go.sh | sudo bash

# 安装v2rayA
wget -qO - https://apt.v2raya.mzz.pub/key/public-key.asc | sudo apt-key add -
echo "deb https://apt.v2raya.mzz.pub/ v2raya main" | sudo tee /etc/apt/sources.list.d/v2raya.list
sudo apt update
sudo apt install v2raya

# 启动v2ray
sudo systemctl start v2raya.service

# 设置开机启动
sudo systemctl enable v2raya.service

# 设置v2ray
启动v2ray后, 服务器web：http://localhost:2017可以设置v2ray，但是远程ssh访问，
所以可以端口转发
# 通过端口转发连接服务器
ssh -p 6000 -L 8877:localhost:2017 zwl@117.50.172.250

# 在本地浏览器输入localhost:8877即可

# 测试可不可以翻墙使用curl命令而不是ping命令，ping不能走tcp协议
curl https://github.com/mikaizhu/SocialTrustProject
# 如果有返回说明成功
```
参考教程：
- https://zhuanlan.zhihu.com/p/414998586

# TODO
- [ ] 修改名字为LabLinuxService
- [ ] 添加自动检测IP，并可以自动修改脚本IP
- [ ] 客户端和服务端文件分离，添加说明文件
- [ ] 有时间看看YouTube上使用shell控制clash
- [ ] 电脑只要开机就能自动使用
- [ ] 使用Dockerfile配置成docker
- [x] 添加可以翻墙的脚本，自动检测翻墙
- [x] 添加信息控制文件，和Linux结合, 方便信息填写管理
