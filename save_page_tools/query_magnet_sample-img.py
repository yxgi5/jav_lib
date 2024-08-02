#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import subprocess
import codecs
import sys

import urllib.request
import requests
import re
from bs4 import BeautifulSoup

proxy_addr = "127.0.0.1:8118"

def getAjax(avid):
    '''获取javbus的ajax'''

    url='https://www.javbus.com/ja/'+avid
    proxy = urllib.request.ProxyHandler({'https': proxy_addr})
    opener = urllib.request.build_opener(proxy, urllib.request.HTTPHandler)
    opener.addheaders = [
        ('accept-language', 'zh-CN,zh;q=0.9,zh-HK;q=0.8'),
        ('cache-control', 'max-age=0'),
        ('sec-ch-ua', '"Chromium";v="117", "Not;A=Brand";v="8"'),
        ('sec-ch-ua-mobile', '?0'),
        ('sec-ch-ua-platform', '"macOS"'),
        ('sec-fetch-dest', 'document'),
        ('sec-fetch-mode', 'navigate'),
        ('sec-fetch-site', 'none'),
        ('sec-fetch-user', '?1'),
        ('upgrade-insecure-requests', '1'),
        ('User-Agent',
         'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.101 Safari/537.36'),
        ('Host','www.javbus.com'),
        ('Connection','close'),
        ('X-Requested-With','XMLHttpRequest'),
        ('Referer',url)
    ]
    urllib.request.install_opener(opener)
    soup = BeautifulSoup(urllib.request.urlopen(url).read().decode('utf-8'), 'lxml')
    html=soup.prettify()
    print(html)
    # save_path = os.path.expanduser('~/Downloads/')
    save_path = os.getcwd()
    title=soup.find("title").text
    title=title[0:75]
    file_name = title + '.html'
    # print(file_name)
    complete_name = os.path.join(save_path, file_name)
    file_object = codecs.open(complete_name, "w", "utf-8")
    file_object.write(html)

    '''获取img'''
    img_pattern = re.compile(r"var img = '.*?'")
    match = img_pattern.findall(html)
    img=match[0].replace("var img = '","https://www.javbus.com/").replace("'","")
    print('封面为:',img)

    img_pattern = re.compile(r"<a class=\"sample-box\" href=\".*?\"")
    match = img_pattern.findall(html)
    image = []
    for i in range(len(match)):
        image.append(match[i].replace("<a class=\"sample-box\" href=\"","").replace("\"",""))

    for i in range(len(image)):
        print('sample:',image[i])

    '''获取uc'''
    uc_pattern = re.compile(r"var uc = .*?;")
    match = uc_pattern.findall(html)
    uc = match[0].replace("var uc = ", "").replace(";","")

    '''获取gid'''
    gid_pattern = re.compile(r"var gid = .*?;")
    match = gid_pattern.findall(html)
    gid = match[0].replace("var gid = ", "").replace(";","")

    '''获取ajax'''
    ajax="https://www.javbus.com/ajax/uncledatoolsbyajax.php?gid="+gid+"&lang=zh&img="+img+"&uc="+uc
    return ajax

def javbus(avid):
    '''获取javbus的磁力链接'''

    url=getAjax(avid)
    proxy = urllib.request.ProxyHandler({'https': proxy_addr})
    opener = urllib.request.build_opener(proxy, urllib.request.HTTPHandler)
    opener.addheaders = [
        ('accept-language', 'zh-CN,zh;q=0.9,zh-HK;q=0.8'),
        ('cache-control', 'max-age=0'),
        ('sec-ch-ua', '"Chromium";v="117", "Not;A=Brand";v="8"'),
        ('sec-ch-ua-mobile', '?0'),
        ('sec-ch-ua-platform', '"macOS"'),
        ('sec-fetch-dest', 'document'),
        ('sec-fetch-mode', 'navigate'),
        ('sec-fetch-site', 'none'),
        ('sec-fetch-user', '?1'),
        ('upgrade-insecure-requests', '1'),
        ('User-Agent',
         'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.101 Safari/537.36'),
        ('Host','www.javbus.com'),
        ('Connection','close'),
        ('X-Requested-With','XMLHttpRequest'),
        ('Referer',url)
    ]
    urllib.request.install_opener(opener)
    soup = BeautifulSoup(urllib.request.urlopen(url).read().decode('utf-8'), 'lxml')

    html=soup.prettify()
    title='ajax'
    save_path = os.getcwd()
    file_name = title + '.html'
    complete_name = os.path.join(save_path, file_name)
    file_object = codecs.open(complete_name, "w", "utf-8")
    file_object.write(html)

    avdist={'title':'','magnet':'','size':'','date':''}

    for tr in soup.find_all('tr'):
        i=0
        for td in tr:
            if(td.string):
                continue
            i=i+1
            avdist['magnet']=td.a['href']
            if (i%3 == 1):
                avdist['title'] = td.a.text.replace(" ", "").replace("\t", "").replace("\r\n","")
            if (i%3 == 2):
                avdist['size'] = td.a.text.replace(" ", "").replace("\t", "").replace("\r\n","")
            if (i%3 == 0):
                avdist['date'] = td.a.text.replace(" ", "").replace("\t", "").replace("\r\n","")
        print(avdist)

url="https://www.javbus.com/ja/BNST-036"
#有些网站会现在，但可伪装浏览器爬取 浏览器User-Agent的详细信息(可采用下面的进行爬虫伪装) 
#浏览器头信息代理可以直接搜Http Header之User-Agent，以下是谷歌浏览器的
headers = {
        'accept-language': 'zh-CN,zh;q=0.9,zh-HK;q=0.8',
        'cache-control': 'max-age=0',
        'sec-ch-ua': '"Chromium";v="117", "Not;A=Brand";v="8"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"macOS"',
        'sec-fetch-dest': 'document',
        'sec-fetch-mode': 'navigate',
        'sec-fetch-site': 'none',
        'sec-fetch-user': '?1',
        'upgrade-insecure-requests': '1',
        'Accept': 'application/json',
    };


# #使用requests方法
def use_requests(url,headers):
    #实践发现，request不用headers也可以爬到设了防爬限制的网站
    #response = requests.get(url)
    # 使用伪装浏览器的urllib方法
    response = requests.get(url,headers=headers)

    # 检查请求是否成功
    if response.status_code == 200:
        # 解析JSON数据
        data1 = response.json()
        print(data1)
    else:
        print('请求失败')

    data = response.text
    #print(data)
    #file_path="E:/Python/bilibili/bilibili.html"
    file_path="bilibili.html"
    #将爬到的内容保存到本地
    with open(file_path,"w",encoding="utf-8") as f:
        f.write(data)


if __name__ == '__main__':
    # url=getAjax('HMRK-016')
    # print(url)
# 
    javbus('BNST-036')

    # use_requests(url,headers)
