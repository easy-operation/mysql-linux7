# mysql集成部署解决方案

**适用于以下操作系统**

`centos7`
`RedHat7`

`mysql介质下载地址`

	https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-server-minimal-5.7.18-1.el7.x86_64.rpm
	https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-client-5.7.18-1.el7.x86_64.rpm
	https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-common-5.7.18-1.el7.x86_64.rpm
	https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-libs-5.7.18-1.el7.x86_64.rpm

> 上传介质至以下目录

	mysql-linux7/src

### 单机模式 ###

`单节点`

> 安装方式

	cd simple
	
	#执行
	sh install.sh

> 账号密码

	root/root

> 创建用户命令

	#默认用户名、密码、库名均一致
	mysql-init 用户名 

### 双工模式 ###

`互为主备`

> 安装方式

	cd cluster-duplex
	
	#修改配置文件
	vim install.sh

	#修改以下内容，保存退出（替换为实际IP地址与root口令）
	NODE1_IP=192.168.184.129
	NODE1_PASSWORD=123456
	NODE2_IP=192.168.184.137
	NODE2_PASSWORD=123456

	#执行
	sh install.sh

> 查看主从状态

	mysql -uroot -proot show slave status\G

> 账号密码

	root/root

> 创建用户命令

	#默认用户名、密码、库名均一致
	mysql-init 用户名 
