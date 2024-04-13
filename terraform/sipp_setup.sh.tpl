#!/bin/bash
apt update -y
apt install -y build-essential
apt install -y g++
apt install -y libncurses5-dev libncursesw5-dev
apt install -y libssl-dev
apt install -y libpcap-dev
apt install -y libnet1-dev
apt install -y lksctp-tools
apt install -y gsl-bin
apt install -y libsctp-dev
apt install -y net-tools
apt install -y cmake
apt install -y wget
apt install -y awscli
cd /home/ubuntu
wget https://github.com/SIPp/sipp/releases/download/v3.6.1/sipp-3.6.1.tar.gz
tar -xvzf sipp-3.6.1.tar.gz
cd /home/ubuntu/sipp-3.6.1

# Copy files from S3
sudo aws s3api get-object --bucket ${ASSET_BUCKET} --key uas.xml ./uas.xml

sudo aws s3api get-object --bucket ${ASSET_BUCKET} --key uas.sh ./uas.sh
# End of S3 copy

# Adding permission to the scripts
sudo chmod 555 ./uas.sh

file="$(ls)" && echo $file
checksctp
apt install libsctp-dev
apt-get install libsctp-dev lksctp-tools
cmake . -DUSE_SCTP=1 -DUSE_SSL=1 -DUSE_PCAP=1
make
