##安装故障注入工具
sh -c "$(curl -fsSL http://cloud.yangtuojia.com/sandbox/init.sh | sed 's/\r//g')"

##进入安装包
cd /root/sandbox/bin

##top查看java进程的pid， 测试的时候是39

##将故障注入工具加载到 JVM 进程里，后面pid都用39表示
./sandbox.sh -p 39

##查看是否注入成功
./sandbox.sh -p 39 -l


################1. cpu高负载注入
./sandbox.sh -p 39 -d 'hipac-chaos/cpuload?percent=100'  ##注入
./sandbox.sh -p 39 -d 'hipac-chaos/cpuloadC'             ##取消注入

################2. 抛异常
./sandbox.sh -p 39 -d 'hipac-chaos/exception?sign=com.yangt.hsp.api.impl.SPManagerApiImpl-querySPList&exception=java.lang.RuntimeException&msg="故障注入测试"'   ##注入
./sandbox.sh -p 39 -d 'hipac-chaos/exceptionC'   ##取消注入

################3. 堆内存 OOM
./sandbox.sh -p 39 -d 'hipac-chaos/hoom?percent=95'   ##注入
./sandbox.sh -p 39 -d 'hipac-chaos/hoomC'             ##取消注入
