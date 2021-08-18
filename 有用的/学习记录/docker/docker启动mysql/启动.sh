



--docker 启动mysql

docker run -d --name peach -p 3306:3306 --ip 172.17.64.1 -v C:\env\docker-mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD='peachyyds' 2c9028880e58

-name 表示mysql实例名
-p 3306:3306 表示本机端口号和虚拟机端口号映射
-ip 不知道
-v 表示数据存在虚拟机的哪里, 并且对应本机的哪里
-e MYSQL_ROOT_PASSWORD='peachyyds' 表示环境变量配密码
2c9028880e58 表示镜像id

