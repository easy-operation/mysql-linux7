#!/bin/bash
DIR=`cd ../src/ && pwd`
NODE1_IP=192.168.184.129
NODE1_PASSWORD=123456
NODE2_IP=192.168.184.137
NODE2_PASSWORD=123456

yum install -y gcc > /dev/null
if [ $? -ne 0 ];
then
        echo "Check yum ..."
        exit 1
fi

if [ ! -f /usr/bin/sshpass ];then
	cp $DIR/sshpass-1.06.tar.gz /tmp
	cd /tmp && tar zxvf sshpass-1.06.tar.gz && cd sshpass-1.06
	./configure --prefix=/opt/sshpass && make && make install
	cp /opt/sshpass/bin/sshpass /usr/bin/
fi

sshpass -p "$NODE1_PASSWORD" scp -o StrictHostKeyChecking=no $DIR/*.rpm $NODE1_IP:/tmp/
sshpass -p "$NODE1_PASSWORD" scp -o StrictHostKeyChecking=no $DIR/install-duplex.sh $NODE1_IP:/tmp/
sshpass -p "$NODE1_PASSWORD" scp -o StrictHostKeyChecking=no $DIR/mysql-init $NODE1_IP:/usr/bin/

sshpass -p "$NODE2_PASSWORD" scp -o StrictHostKeyChecking=no $DIR/*.rpm $NODE2_IP:/tmp/
sshpass -p "$NODE2_PASSWORD" scp -o StrictHostKeyChecking=no $DIR/install-duplex.sh $NODE2_IP:/tmp/
sshpass -p "$NODE2_PASSWORD" scp -o StrictHostKeyChecking=no $DIR/mysql-init $NODE2_IP:/usr/bin/

sshpass -p "$NODE1_PASSWORD" ssh -o StrictHostKeyChecking=no $NODE1_IP "cd /tmp && sh install-duplex.sh 1 $NODE2_IP"
sshpass -p "$NODE2_PASSWORD" ssh -o StrictHostKeyChecking=no $NODE2_IP "cd /tmp && sh install-duplex.sh 2 $NODE1_IP"

