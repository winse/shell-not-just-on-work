#!/bin/sh

if [ $# -ne 1 ] ; then
  echo "$0 <m3u8_url>"
  exit 1
fi

tmp_dir=/mnt/d/m3u8_tmp

mkdir $tmp_dir
cd $tmp_dir

url=$1
raw_url=${url%\?*}
base_url=${raw_url%/*}
#curl -s $url | grep '^http' | grep '.ts' | while read ts ; do wget $ts ; done 
curl -s $url | grep '.ts' | while read ts ; do if ! echo $ts | grep '^http' ; then ts=$base_url/$ts; fi ; wget $ts ; done 

ls -1 *.ts* | while read i ; do mv "$i" `echo "$i" | cut -d? -f1 | sed 's/,/-/g' ` ; done

ls -1 | sort -t- -k2,2n | while read f ; do echo "file '$f'" ; done >mylist.txt
ffmpeg.exe -f concat -i mylist.txt -c copy all-seg.ts
ffmpeg.exe -i all-seg.ts -acodec copy -vcodec copy all.mp4 
