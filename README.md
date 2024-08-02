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
av_mv.sh
```


## 错误处理
如果中间有啥问题，停止并且使用`unpack.sh`



## 车牌数据库

查看已经存档的车牌数据库
```
generate_db_from_list.sh
```

## 车牌catalog数据库

导入已存档车牌catalog的sqlite3格式db数据库
```
import_catalog_db.sh
```

更新已存档车牌catalog之后导出为文本
```
export_catalog_db.sh
```


## 按照catalog去保存页面
`gen1000.sh`用于产生`simple_link.md`, 替换车牌基本上一个catalog的就全有连接了, 参数是车牌catalog
```
./gen1000.sh AKKA
```




