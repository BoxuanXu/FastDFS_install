#!/bin/bash

   
echo "Begin edit configure file"
   
#create three dir to save tracker storage and client data
mkdir -p /data/fastdfs/storage
mkdir -p /data/fastdfs/client
   
#edit fastdfs's configure file
   
cd /etc/fdfs
cp client.conf.sample client.conf
cp tracker.conf.sample tracker.conf

#edit tracker's configure file
sed -i "s/base_path=\/home\/yuqing\/fastdfs/base_path=\/data\/fastdfs\/tracker/g" tracker.conf 
   
   
#edit client's configure file
    
sed -i "s/base_path=\/home\/yuqing\/fastdfs/base_path=\/data\/fastdfs\/client/g" client.conf 
sed -i "s/tracker_server=192.168.0.197:22122/tracker_server=$TRACKER_HOST:22122/g" client.conf

sed -i "s/store_path0=\/home\/yuqing\/fastdfs/store_path0=\/data\/fastdfs\/storage/g" mod_fastdfs.conf
sed -i "s/tracker_server=tracker:22122/tracker_server=tracker_ip:22122/g" mod_fastdfs.conf
sed -i "s/url_have_group_name = false/url_have_group_name = true/g" mod_fastdfs.conf

arr=$(echo $ALL_GROUP|tr "," "\n")
group_num = ${#arr[@]}
sed -i "s/group_count = 0/group_count = $group_num/g" mod_fastdfs.conf
group_name=group1
for g in $arr;do
    group_name=$group_name"/group"$g  
    echo [group$g] >> mod_fastdfs.conf
    echo group_name=group$g >> mod_fastdfs.conf
    if [ ${#g} -lt 2 ];then
       echo storage_server_port=2300$g >> mod_fastdfs.conf
    elif [ ${#g} -lt 3 ];then
       echo storage_server_port=230$g >> mod_fastdfs.conf
    elif [ ${#g} -lt 4 ];then
       echo storage_server_port=23$g >> mod_fastdfs.conf
    fi
    echo store_path_count=1 >> mod_fastdfs.conf
    echo store_path0=/data/fastdfs/storage$g >> mod_fastdfs.conf

    sed -i "N;46a\}" /usr/local/nginx/nginx.conf;
    sed -i "N;46angx_fastdfs_module;" /usr/local/nginx/nginx.conf;
    sed -i "N;46alocation /group$g/M00 {" /usr/local/nginx/nginx.conf;
done
sed -i "s/group_name=group1/$group_name/g" mod_fastdfs.conf


echo "finish edit configure file"

 
/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf
kill -9 `ps -ef | grep nginx | grep -v grep | awk '{print $2}'` 
if [ "${sn}" = "" ];then
  /usr/local/nginx/nginx
else
  kill -9 $pid
  /usr/local/nginx/nginx
fi
