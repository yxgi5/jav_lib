# 前置说明

## 优点
1.自动抓取预览图并打包

2.增量存储车牌


## 缺点

自动失败的，需要手动存档页面。

## 依赖
```
aria2c，sqlite3，privoxy等
```


# 使用说明

## 自动流程, 从home页面直接拉取增量车牌

```
./update_new_bango_frome_home.sh
```

然后可以执行
```
for i in {0..20}
do
./auto_start.sh | tee -a auto_start.sh.log && ./move_tarballs.sh
mv *.tar.gz /opt/porno/AV_lib/New
done
```


## 手动流程1
手动更新`input.list`, 一般是处理 `fail_bango.list` 里面的车牌

先添加车牌到 `input.list`， 比如
```
CAWD-690
CAWD-700
CAWD-701
CAWD-702
```
另可参考 [批量提取 input.list](#batch_update_input.list)

然后可以执行
```
for i in {0..20}
do
./auto_start.sh | tee -a auto_start.sh.log && ./move_tarballs.sh
mv *.tar.gz /opt/porno/AV_lib/New
done
```


## 手动流程2
一些 `fail_bango.list` 里面的车牌页面比较特殊，python下载出错但是浏览器可以完整拉取，手动流程2主要是为了应对这种情况。

手动从`https://www.javbus.com/ja`点开有某个单独车牌页面，保存页面全部内容`save page all`，一般用chrome/opera浏览器。

然后执行
```
./find_more.sh | tee find_more.log && ./move_tarballs.sh
```

手动流程2错误处理
如果中间有啥问题，停止并且使用`./unpack.sh`



## 404_bango.list
一般就应该不会有这个页面了，没有再次尝试的必要。



## fail_bango.list
网络原因或其他原因造成了下载失败，这里记录下来，可以再次尝试。这个list必须手动贴到`input.list`，不会进行自动添加。



## 车牌数据库

产生已经存档的车牌数据库
```
./av_list_update_db_update.sh
```

## 车牌catalog数据库

导入已存档车牌catalog的sqlite3格式db数据库
```
./import_catalog_db.sh
```

更新已存档车牌catalog之后导出为文本
```
./export_catalog_db.sh
```

## 按照catalog去保存页面
`gen1000_single_bango_md_links_and_list.sh`用于产生`single_bango.md`和`single_bango.list`, 替换车牌基本上一个catalog的就全有连接了, 参数是车牌catalog
```
./gen1000_single_bango_md_links_and_list.sh AKKA
```


<span id="batch_update_input.list"></span>
# 批量提取 到 input.list

`navigation页面`是包含几个单体番号页面链接的集合页面，可能有`下一页`

先更新navigation.list， 比如填入`https://www.javbus.com/ja/search/GOJU` 或者 `https://www.javbus.com/ja`或者`https://www.javbus.com/ja/uncensored`

或者用 grep 过滤 html 源码，比如`actresses`导航页面复制源码段到 `tmp.txt`
```
cat tmp.txt | grep -e "https://www.javbus.com/ja/star/" | sed 's/^.*\(https:\/\/www.javbus.com\/ja\/star\/.*\)".*$/\1/' > navigation.list
```

然后下载`navigation.list`里面的`navigation页面`
```
./navigation_download.sh
```

更新的话根据情况在这里打断，并不需要全下载


然后提取所有单体番号页面链接到`input.list`
```
cat *.html | grep https://www.javbus.com/ja/ | sed 's/\"/\n/g' | sed 's/\ /\n/g' | sed 's/\#/\n/g'| sed 's/)/\n/g'| grep https://www.javbus.com/ja | sed 's/driver-verify.*$//' | sed 's/\#$//g' | grep - | sed 's/\//\n/g' | grep - | sort -u >> input.list && rm *.html
```

然后可以循环运行`./auto_start.sh`
```
for i in {0..20}
do
./auto_start.sh
mv *.tar.gz /opt/porno/AV_lib/New
done
```

如果打断之后，只想更新 input.list 为不在总库的车牌，先不要移动当前目录下打包好的，依次执行
```
./update_input_list.sh
./move_tarballs.sh
```


# 提取和更新总集

## 从0开始提取本站车牌总集
```
export https_proxy="127.0.0.1:8118"
export http_proxy="127.0.0.1:8118"


for i in {1..996}
do
    aria2c \
        --header 'sec-ch-ua: "Google Chrome";v="117", "Not;A=Brand";v="8", "Chromium";v="117"' \
        --header 'cookie: 4fJN_2132_seccodecSeRRfg5=14339.4cce2e4f1ae59e531e; 4fJN_2132_seccodecSTVfEvf=9372.f1ae0a808eec67ca6a; 4fJN_2132_seccodecSXYwYAC=20246.0620c823cb43b800c7; 4fJN_2132_seccodecSM7ir7C=32974.501fed7ed7e50412ed; 4fJN_2132_seccodecSQTZPiM=26549.061809068ea08ce4ce; PHPSESSID=9ku0thftv26h49i683n1ml0ag1; existmag=mag; dv=1' \
        --header 'Referer: https://www.javbus.com/' \
        --header 'sec-ch-ua-mobile: ?0' \
        --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36' \
        --header 'sec-ch-ua-platform: "Linux"' \
        -o `echo $i | sed -e 's/^.*\/\(.*\)$/\1/'`.html \
        https://www.javbus.com/ja/actresses/$i
done
cat *.html | grep "<a class=\"avatar-box text-center\" href=\"https://www.javbus.com/ja/star/" | sed -e 's/^.*href=\"\(.*\)\">.*$/\1/' > navigation.list && tar rvpf actresses_navigation_entrance.tar *.html && rm *.html

cat navigation.list | sort -u > navigation.list.new
mv navigation.list{.new,}

./navigation_download.sh
cat *.html | grep https://www.javbus.com/ja/ | sed 's/\"/\n/g' | sed 's/\ /\n/g' | sed 's/\#/\n/g'| sed 's/)/\n/g'| grep https://www.javbus.com/ja | sed 's/driver-verify.*$//' | sed 's/\#$//g' | grep - | sed 's/\//\n/g' | grep - | sort -u >> all_bango.list && tar rvpf actresses_entrance.tar *.html && rm *.html



for i in {1..442}
do
    aria2c \
        --header 'sec-ch-ua: "Google Chrome";v="117", "Not;A=Brand";v="8", "Chromium";v="117"' \
        --header 'cookie: 4fJN_2132_seccodecSeRRfg5=14339.4cce2e4f1ae59e531e; 4fJN_2132_seccodecSTVfEvf=9372.f1ae0a808eec67ca6a; 4fJN_2132_seccodecSXYwYAC=20246.0620c823cb43b800c7; 4fJN_2132_seccodecSM7ir7C=32974.501fed7ed7e50412ed; 4fJN_2132_seccodecSQTZPiM=26549.061809068ea08ce4ce; PHPSESSID=9ku0thftv26h49i683n1ml0ag1; existmag=mag; dv=1' \
        --header 'Referer: https://www.javbus.com/' \
        --header 'sec-ch-ua-mobile: ?0' \
        --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36' \
        --header 'sec-ch-ua-platform: "Linux"' \
        -o `echo $i | sed -e 's/^.*\/\(.*\)$/\1/'`.html \
        https://www.javbus.com/ja/uncensored/actresses/$i
done
cat *.html | grep "<a class=\"avatar-box text-center\" href=\"https://www.javbus.com/ja/uncensored/star/" | sed -e 's/^.*href=\"\(.*\)\">.*$/\1/' >> uncensored_navigation.list && tar rvpf uncensored_actresses_navigation_entrance.tar *.html && rm *.html

cat uncensored_navigation.list | sort -u > uncensored_navigation.list.new
mv uncensored_navigation.list{.new,}


mv uncensored_navigation.list navigation.list
./navigation_download.sh
cat *.html | grep https://www.javbus.com/ja/ | sed 's/\"/\n/g' | sed 's/\ /\n/g' | sed 's/\#/\n/g'| sed 's/)/\n/g'| grep https://www.javbus.com/ja | sed 's/driver-verify.*$//' | sed 's/\#$//g' | grep - | sed 's/\//\n/g' | grep - | sort -u >> all_bango.list && tar rvpf uncensored_actresses_entrance.tar *.html && rm *.html



for i in {0..20000}
do
./auto_start.sh | tee -a auto_start.sh.log
mv *.tar.gz /opt/porno/AV_lib/New
done
```


```
{ cat all_bango.list | sort -u; } > all_bango.list.new && mv all_bango.list{.new,}

```


在jav_lib_git上一层目录新建一个html目录，新建文件 watch_html.sh
```
#!/bin/bash

files=$(ls ../jav_lib_git/*.html 2> /dev/null | wc -l)
if [ "$files" != "0" ]; then
    echo "mv *.html ."
    mv ../jav_lib_git/*.html .
else
    exit 1
fi

cat *.html | grep https://www.javbus.com/ja/ | sed 's/\"/\n/g' | sed 's/\ /\n/g' | sed 's/\#/\n/g'| sed 's/)/\n/g'| grep https://www.javbus.com/ja | sed 's/driver-verify.*$//' | sed 's/\#$//g' | grep - | sed 's/\//\n/g' | grep - | sort -u >> all_bango.list
cat all_bango.list | sort -u > all_bango.list.new
mv all_bango.list{.new,}
mkdir -p tmp/
tar rvpf actresses_entrance.tar *.html && mv *.html tmp/    # 要分censored和unsensored来处理acresses
#tar rvpf uncensored_actresses_entrance.tar *.html && mv *.html tmp/    # 要分censored和unsensored来处理acresses

```
每隔10秒移动html并提取删除
```
watch -n 10 ./watch_html.sh
```

这里添加一个 all_bango.list,经过上述处理之后的包括404的本站所有车牌的总集。

## 更新总集
参考 [批量提取 input.list](#batch_update_input.list)

从
```
https://www.javbus.com/ja
https://www.javbus.com/ja/uncensored
```
获取车牌

写一个脚本来从home更新总库和新增input.list
```
./update_new_bango_frome_home.sh
```


# download sample image

like follows, dosen't need cookie

if need proxy and referer
```
aria2c --header 'sec-ch-ua: "Google Chrome";v="117", "Not;A=Brand";v="8", "Chromium";v="117"' --header 'sec-ch-ua-mobile: ?0' --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36' --header 'sec-ch-ua-platform: "Linux"' --header 'Referer: https://www.javbus.com/ja/' --all-proxy="http://127.0.0.1:8118" \
https://www.javbus.com/imgs/bigsample/16qx_b_4.jpg
```

if dosen't need proxy nor referer
```
aria2c --header 'sec-ch-ua: "Google Chrome";v="117", "Not;A=Brand";v="8", "Chromium";v="117"' --header 'sec-ch-ua-mobile: ?0' --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36' --header 'sec-ch-ua-platform: "Linux"' \
https://pics.dmm.co.jp/digital/video/h_1416ad00524/h_1416ad00524jp-3.jpg

```

过滤log文件记录的ERROR
```
cat auto_start.sh.log | grep -A 5 -B 5  ERROR
```
大概能够得到sample image下载失败的链接和压缩包名







