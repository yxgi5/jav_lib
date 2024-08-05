# 前置说明

## 优点
1.自动抓取预览图并打包

2.增量存储车牌


## 缺点

需要手动存档页面

## 依赖
```
aria2c，tetext，sqlite3，privoxy等
```


# 使用说明

## 一般流程
手动从`https://www.javbus.com/ja`点开有关页面，保存页面`save page all`，一般用chrome/opera浏览器。

++自动下载页面并打包的脚本是
```
./auto_start.sh
```
需要先定义 input.list， 比如
```
CAWD-690
CAWD-700
CAWD-701
CAWD-702
```

自动下载页面及封面的脚本有些情况下不能下载，还是在input.list，然后可以按手动存档流程执行，比如添加到 todo.md 。


如果是骑兵，执行命令
```
./find_more.sh | tee log.log
```
如果是步兵，执行命令
```
./find_more_proxy.sh | tee log.log
```
av.list被自动更新

然后从 todo.md 再去打开并存档页面，直到没有为止。

保存为 tar.gz 格式，mv除去另外处理
```
./av_mv.sh
```


## 错误处理
如果中间有啥问题，停止并且使用`./unpack.sh`



## 车牌数据库

查看已经存档的车牌数据库
```
./generate_db_from_list.sh
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
`gen1000.sh`用于产生`simple_link.md`, 替换车牌基本上一个catalog的就全有连接了, 参数是车牌catalog
```
./gen1000.sh AKKA
```



# 存储整个页面的自动化

## requests
```
conda activate python3.10
conda install requests 
pip install pymysql scrapy scrapy-splash scrapyd scrapyd-client -i https://mirrors.163.com/pypi/simple
pip install bs4 -i https://mirrors.163.com/pypi/simple
pip install -i https://mirrors.163.com/pypi/simple pyautogui selenium webdriver-manager
```

## 下面试验性的写了几个脚本

由于需要爬取的网页是Ajax动态渲染，所以需要用Selenium启动一个真实的浏览器环境，然后通过这个环境来获取动态加载的内容
```
save_page_tools/webdriver_save_page.py
```
缺陷: 目前还不能
```
检测是否 No Page
已经在的覆盖策略有待改善
网络不佳加载未完成的情况处理
写入磁盘慢的情况处理
```
没有精力做了。用的时候做个循环传参数基本上也能省一些力。

save_page_tools这里面放了一个更新的查询sample图片链接和magnet链接的python工具
```
save_page_tools/query_magnet_sample-img.py
```
想法:
```
BeautifulSoup不完全靠谱有时候会失败，可能需要加大超时限制
后续这个加上ari2c/curl什么的就直接替代之前bash脚本的实现，遗憾的是存 page 还是有缺少。
如果仅用 webdriver 保存出 page only，再改进这个脚本，把 sample image 和 magnet link 都存下来，基本也和 save page all等效，去掉了不需要的零碎
再进一步的想法，其实不需要用 webdriver，只差 magnet link 而已，查询到 magnet link 再按合理的格式写到 page 里面，不就可以了？还可以把图片的链接都搞成本地，也不需要目录了
```




