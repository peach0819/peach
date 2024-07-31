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

# cat > 的意思是重定向，如果已有源文件，直接覆盖，不然就新创建
#  <<_EOF_  *******    _EOF_  的意思是往文件里面写一模一样的内容，包括格式
# 这段shell指令的意思是 往这个文件里面写这部分内容
cat > ${pre_month_where} <<_EOF_
$pre_month_where
_EOF_

$pre_month_where 是指从环境变量里面取值
${pre_month_where} 是指从当前定义的局部变量里面取值

# dump 内存
jmap -dump:live,format=b,file=/alidata/log/heap-dump.hprof  37
tar -czf hsp09182.tar.gz heap-dump.hprof
curl ftp://172.16.222.129/dump/hsp0918.hprof -u ftpadmin:hipac.228 -T /alidata/log/heap-dump.hprof
curl ftp://172.16.222.129/dump/hsp09182.tar.gz -u ftpadmin:hipac.228 -T /alidata/log/hsp09182.tar.gz


# 看一个日志第几行的内容
sed -n '1800,1801p' hj_wx_chat_logger.log