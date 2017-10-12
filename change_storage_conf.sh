#!/bin/bash
arr=$(echo $GROUP|tr "," "\n")
for g in $arr;do
    echo $g
    mkdir -p /data/fastdfs/storage$g
   
    #edit fastdfs's configure file
    cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage_group$g.conf
   
    #edit storage's configure file
    
    sed -i "s/base_path=\/home\/yuqing\/fastdfs/base_path=\/data\/fastdfs\/storage$g/g" /etc/fdfs/storage.conf 
    sed -i "s/store_path0=\/home\/yuqing\/fastdfs/store_path0=\/data\/fastdfs\/storage$g/g" /etc/fdfs/storage.conf
    
    sed -i "s/tracker_server=192.168.209.121:22122/tracker_server=$TRACKER_HOST:22122/g" /etc/fdfs/storage.conf
    sed -i "s/group_name=group1/group_name=group$g/g" /etc/fdfs/storage.conf
    if [ ${#g} -lt 2 ];then
       sed -i "s/port=23000/port=2300$g/g" /etc/fdfs/storage.conf
    elif [ ${#g} -lt 3 ];then
       sed -i "s/port=23000/port=230$g/g" /etc/fdfs/storage.conf
    elif [ ${#g} -lt 4 ];then
       sed -i "s/port=23000/port=23$g/g" /etc/fdfs/storage.conf
    fi
done
/usr/bin/fdfs_storaged /etc/fdfs/storage.conf
kill -9 `ps -ef | grep nginx | grep -v grep | awk '{print $2}'` 
/usr/local/nginx/nginx
