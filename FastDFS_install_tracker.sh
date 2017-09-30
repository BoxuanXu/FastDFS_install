#!/bin/bash
#__website__     = "www.seetatech.com"
#__author__      = "seetatech"
#__editor__      = "xuboxuan"
#__Date__        = "20170908"


s_pwd=$PWD

#begin install common
if [ ! -s "/usr/lib64/libfastcommon.so" ];then
   echo "Begin install common file"
   if [ ! -d "libfastcommon" ];then
      echo "Begin download libfastcommon"
      git clone https://github.com/happyfish100/libfastcommon.git
      cd libfastcommon
   else
      echo "Don't need to download libfastcommon"
      cd libfastcommon
   fi
   ./make.sh
   ./make.sh install
else
   echo "fastcommon has been installed"
fi


if [ -s "/usr/lib64/libfastcommon.so" ];then
   echo "common file install success"
else
   echo "common file install failed"
   exit 1
fi

cd $s_pwd

#begin install fastdfs-pro


if [ ! -s "/usr/bin/fdfs_test" ];then
   echo "Begin install fastdfs"
   if [ ! -d "fastdfs" ];then
      echo "Begin download fastdfs:"
      git clone https://github.com/happyfish100/fastdfs.git
      cd fastdfs
   else
      echo "Don't need to download fastdfs"
      cd fastdfs
   fi
   ./make.sh
   ./make.sh install

   #copy configure file to etc dir
   cp conf/http.conf conf/mime.types /etc/fdfs

   echo "Begin edit configure file"
   #create three dir to save tracker storage and client data
   mkdir -p /data/fastdfs/tracker
   mkdir -p /data/fastdfs/storage
   mkdir -p /data/fastdfs/client

   #edit fastdfs's configure file
   cd /etc/fdfs
   cp client.conf.sample client.conf
   #cp storage.conf.sample storage.conf
   cp tracker.conf.sample tracker.conf

   #edit tracker's configure file
   sed -i "s/base_path=\/home\/yuqing\/fastdfs/base_path=\/data\/fastdfs\/tracker/g" tracker.conf 


   #edit storage's configure file
   #sed -i "s/base_path=\/home\/yuqing\/fastdfs/base_path=\/data\/fastdfs\/storage/g" storage.conf 
   #sed -i "s/store_path0=\/home\/yuqing\/fastdfs/store_path0=\/data\/fastdfs\/storage/g" storage.conf

   #get local host ip
   #local_ip=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
 
   #sed -i "s/tracker_server=192.168.209.121:22122/tracker_server=tracker_ip:22122/g" storage.conf

   #edit client's configure file
   sed -i "s/base_path=\/home\/yuqing\/fastdfs/base_path=\/data\/fastdfs\/client/g" client.conf 
   sed -i "s/tracker_server=192.168.0.197:22122/tracker_server=tracker_ip:22122/g" client.conf

   echo "finish edit configure file"

else
   echo "fastdfs has been installed"
fi

if [ -s "/usr/bin/fdfs_test" ];then
   echo "fastdfs install success!!!"
else
   echo "fastdfs install failed"
   exit 1
fi

cd $s_pwd

#start fastdfs's service
kill -9 `ps -ef | grep fdfs_ | grep -v grep | awk '{print $2}'`
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf

echo "fastdfs's service started,if wrong here,please run this batch program again!"
#a test of fastdfs
sleep 10s 

echo "test" >> /tmp/test.tar.gz
result_fastdfs=`/usr/bin/fdfs_upload_file /etc/fdfs/client.conf /tmp/test.tar.gz`
echo "upload:"$result_fastdfs

if [[ ${result_fastdfs} =~ "group" && ! ${result_fastdfs} =~ "ERROR" ]];then
     echo "FastDFS install Success!!!"
else 
     echo "FastDFS install error!!!"
     exit 1;
fi

cd $s_pwd

#install fastdfs-nginx-model
if [ ! -d "fastdfs-nginx-module" ];then
   echo "Begin download fastdfs-nginx-module:"
   git clone https://github.com/happyfish100/fastdfs-nginx-module
   cd fastdfs-nginx-module/src 
else
   echo "Don't need to download fastdfs-nginx-module"
   cd fastdfs-nginx-module/src
fi

sed -i "s/store_path0=\/home\/yuqing\/fastdfs/store_path0=\/data\/fastdfs\/storage/g" mod_fastdfs.conf
sed -i "s/tracker_server=tracker:22122/tracker_server=tracker_ip:22122/g" mod_fastdfs.conf
sed -i "s/url_have_group_name = false/url_have_group_name = true/g" mod_fastdfs.conf
cp mod_fastdfs.conf /etc/fdfs



ln -s /data/fastdfs/storage/data/ /data/fastdfs/storage/data/M00

echo "FastDFS install success;"

cd $s_pwd
#download nginx-1.8.1

if [ ! -s "nginx-1.8.1.tar.gz" ];then
   echo "Begin download nginx-1.8.1.tar.gz:"
   wget -c -r http://nginx.org/download/nginx-1.8.1.tar.gz
   tar -xvf nginx.org/download/nginx-1.8.1.tar.gz -C /usr/local 
else
   echo "Don't need to download nginx-1.8.1.tar.gz"
   tar -xvf nginx-1.8.1.tar.gz -C /usr/local
fi



echo "nginx down success;"


unzip pcre-8.41.zip
cp -r pcre-8.41 /usr/local/pcre-8.41


tar zxvf openssl-1.0.2l.tar.gz
cp  -r    openssl-1.0.2l  /usr/local/openssl-1.0.2l

tar zxvf zlib-1.2.11.tar.gz
cp  -r    zlib-1.2.11   /usr/local/zlib-1.2.11

cd /usr/local/pcre-8.41/
./configure
make
make install

cd /usr/local/openssl-1.0.2l/
./config
make
make install

cd /usr/local/zlib-1.2.11/
./configure
make
make install

if [ ! -d "/usr/local/nginx" ];then
   cd /usr/local/nginx-1.8.1/
   ./configure --sbin-path=/usr/local/nginx/nginx --conf-path=/usr/local/nginx/nginx.conf --pid-path=/usr/local/nginx/nginx.pid --with-http_ssl_module --with-openssl=../openssl-1.0.2l --with-pcre=../pcre-8.41 --with-zlib=../zlib-1.2.11 --add-module=$s_pwd/fastdfs-nginx-module/src
   make
   make install

   cp $s_pwd/nginx.conf /usr/local/nginx/
else
   echo "nginx has been installed"
fi

if [ -s "/usr/local/nginx" ];then
   echo "nginx install success!!!"
else
   echo "nginx install failed"
   exit 1
fi
	
kill -9 `ps -ef | grep "nginx: " | grep -v grep | awk '{print $2}'`

cd /usr/local/nginx
./nginx


echo "Please enter the following URL:http://"$local_ip"/"$result_fastdfs" or http://localhost/"$result_fastdfs 
