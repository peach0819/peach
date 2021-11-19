##查看机器的6379端口信息
netstat -ano | grep '6379'

#准备工作
cd /alidata
wget http://cloud.yangtuojia.com/chaos/sandbox-stable-bin.zip
unzip sandbox-stable-bin.zip
cd /alidata/sandbox/sandbox-module/
wget http://cloud.yangtuojia.com/chaos/sandbox-jvm-wrecker-1.0.0-jar-with-dependencies.jar

# 挂载目标java程序
cd /alidata/sandbox/bin
./sandbox.sh -p [pid]

# 5：卸载jvm-sandbox
./sandbox.sh -p [pid] -S
jvm-sandbox[default] shutdown finished.


top 去看进程
ps -T -p [pid]  去看进程下的线程

java -jar arthas-boot.jar
dashboard  去看arthas
thread -b 去看线程阻塞
thread [threadid] 去看具体线程dump
thread -n 3 -i 5000  去看最近5秒内最忙的3个线程（会等待5秒）

top -H -p <pid> 去看一个进程中的子进程