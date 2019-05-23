#!/bin/bash
NODE_TAG=$1
MASTER_IP=$2

yum install unzip lua vim git gcc gcc-c++ wget make cmake automake autoconf libaio libtool net-tools bison-devel libaio-devel ncurses-devel perl-Data-Dumper -y > /dev/null
if [ $? -ne 0 ];
then
        echo "Check yum ..."
        exit 1
fi

function installMysql()
{
	yum remove -y mariadb-libs
	cd /tmp	
	rpm -ivh mysql-community-common-5.7.18-1.el7.x86_64.rpm 
	rpm -ivh mysql-community-libs-5.7.18-1.el7.x86_64.rpm 
	rpm -ivh mysql-community-client-5.7.18-1.el7.x86_64.rpm 
	rpm -ivh mysql-community-server-5.7.18-1.el7.x86_64.rpm

	echo "default-storage-engine=INNODB" >>/etc/my.cnf
	echo "character-set-server=utf8"  >>/etc/my.cnf
	echo "collation-server=utf8_general_ci"  >>/etc/my.cnf
	echo "lower_case_table_names=1" >>/etc/my.cnf
	echo "server-id=$NODE_TAG" >>/etc/my.cnf
	echo "binlog-format=Row" >>/etc/my.cnf
	echo "log-bin=/var/lib/mysql/mysql-bin" >>/etc/my.cnf
	echo "relay-log=localhost1-relay-bin" >>/etc/my.cnf

	#执行
	systemctl daemon-reload;systemctl enable mysqld;systemctl start mysqld
	firewall-cmd --permanent --zone=public --add-port=3306/tcp
	firewall-cmd --reload
	setenforce 0
	
}

function initMysql()
{
	password=`grep 'temporary password' /var/log/mysqld.log|awk '{print $NF}'`
	mysql -uroot -p$password --connect-expired-password <<EOF
	set global validate_password_policy=0;
	set global validate_password_length=1;
	set password=passworD("root");
	GRANT REPLICATION SLAVE ON *.* TO 'mysql'@'%' IDENTIFIED BY 'mysql';
	FLUSH PRIVILEGES;
	quit

EOF
	systemctl restart mysqld
	
	
}
function setSlave()
{

	mysql -uroot -proot <<EOF
	CHANGE MASTER TO
        MASTER_HOST="$MASTER_IP",
        MASTER_USER='mysql',
        MASTER_PASSWORD='mysql',
        MASTER_LOG_FILE='mysql-bin.000001',
        MASTER_LOG_POS=154;
EOF
	systemctl restart mysqld

	mysql -uroot -proot <<EOF
	stop slave;
	CHANGE MASTER TO Master_Log_File = 'mysql-bin.000002', Master_Log_Pos = 154;
        start slave;
EOF
        systemctl restart mysqld
	chmod +x /usr/bin/mysql-init
}

function main()
{
	installMysql
	initMysql
	setSlave
}

main
