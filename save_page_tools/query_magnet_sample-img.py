#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import subprocess
import codecs
import sys
import tarfile
import requests
import re
from bs4 import BeautifulSoup

html_global = ''
complete_name_globals = ''

headers = {
    'authority': 'www.javbus.com',
    'accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
    'accept-language': 'en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7',
    'cookie': '4fJN_2132_seccodecSeRRfg5=14339.4cce2e4f1ae59e531e; 4fJN_2132_seccodecSTVfEvf=9372.f1ae0a808eec67ca6a; 4fJN_2132_seccodecSXYwYAC=20246.0620c823cb43b800c7; 4fJN_2132_seccodecSM7ir7C=32974.501fed7ed7e50412ed; 4fJN_2132_seccodecSQTZPiM=26549.061809068ea08ce4ce; PHPSESSID=9ku0thftv26h49i683n1ml0ag1; existmag=mag; dv=1',
    'referer': 'https://www.javbus.com',
    'sec-ch-ua': '" Not A;Brand";v="99", "Chromium";v="104", "Opera";v="90"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Linux"',
    'sec-fetch-dest': 'document',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'same-origin',
    'sec-fetch-user': '?1',
    'upgrade-insecure-requests': '1',
    'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.102 Safari/537.36 OPR/90.0.4480.84',
    'X-Requested-With': 'XMLHttpRequest',
};

proxies = {
  "http": "http://127.0.0.1:8118",
  "https": "http://127.0.0.1:8118",
}

def getAjax(avid):
    '''获取javbus的ajax'''

    url='https://www.javbus.com/ja/'+avid
    headers['Referer'] = url

    for i in range(5):
        try:
            response = requests.get(url, headers=headers, proxies=proxies, timeout=10)
            if response.status_code == 200:
                break
            elif response.status_code == 404:
                with open('404_url.txt', 'a') as fd:
                    fd.write('%s\n' % url)
                return
            else:
                response.raise_for_status()

        except Exception as ret:
            print(ret)
            if i == 4:
               with open('fail_url.txt', 'a') as fd:
                    fd.write('%s\n' % url)
               raise       # give up after 5 attempts
            

    try:
        os.mkdir(avid)
    except FileExistsError:
        pass

    html = response.content
    # soup = BeautifulSoup(html.decode('utf-8', errors='ignore'), 'html.parser')
    soup = BeautifulSoup(html.decode('utf-8', errors='ignore'), 'lxml')
    html = soup.prettify()
    html = html.replace("<div id=\"movie-loading\">","<div id=\"movie-loading\" style=\"display: none;\">")
    print(html)

    save_path = os.getcwd()
    title=soup.find("title").text
    title=title[0:75]
    file_name = title + '.html'
    # print(file_name)
    complete_name = os.path.join(save_path, file_name)

    global html_global
    global complete_name_globals
    html_global = html
    complete_name_globals = complete_name
    
    '''获取img'''
    img_pattern = re.compile(r"var img = '.*?'")
    match = img_pattern.findall(html)
    img=match[0].replace("var img = '","https://www.javbus.com").replace("'","")
    print('封面为:',img)
    for i in range(5):
        try:
            response = requests.get(img, headers=headers, proxies=proxies, timeout=10)
            if response.status_code == 200:
                break
            else:
                response.raise_for_status()
                
        except Exception as ret:
            print(ret)
            if i == 4:
               raise       # give up after 5 attempts

    if response.history:
        # print("Request was redirected")
        # for resp in response.history:
            # print(resp.status_code, resp.url)
        # print("Final destination:")
        # print(response.status_code, response.url)
        pass
    elif response.status_code == 200:
        # print("Request was not redirected")
        pic = response.content
        if len(pic) > 200:
            pic_name = os.path.basename(img)
            fp = open(avid+'/'+pic_name, 'wb')
            fp.write(pic)
            fp.close()


    file_object = codecs.open(avid + '/' + avid + ".txt", "w", "utf-8")
    img_pattern = re.compile(r"<a class=\"sample-box\" href=\".*?\"")
    match = img_pattern.findall(html)
    image = []
    for i in range(len(match)):
        image.append(match[i].replace("<a class=\"sample-box\" href=\"","").replace("\"","").replace("/imgs/bigsample/","https://www.javbus.com//imgs/bigsample/"))

    for i in range(5):
        try:
            response = requests.get(image[0], headers=headers, proxies=proxies, timeout=10)
            if response.status_code == 200:
                break
            else:
                response.raise_for_status()

        except Exception as ret:
            print(ret)
            if i == 4:
               raise       # give up after 5 attempts

    if response.history:
        # print("Request was redirected")
        # for resp in response.history:
            # print(resp.status_code, resp.url)
        # print("Final destination:")
        # print(response.status_code, response.url)
        pass
    elif response.status_code == 200:
        # print("Request was not redirected")
        for j in range(len(image)):
            print('sample:',image[j])
            # for i in range(5):
            #     try:
            #         pic = urllib.request.urlopen(image[j]).read()
            #         break
            #     # except BaseException as ret:
            #     #     print(ret)
            #     #     # print('错误，当前图片无法下载')
            #     # except IncompleteRead:
            #     except Exception as ret:
            #         print(ret)
            #         if i == 4:
            #             raise       # give up after 5 attempts

            # if len(pic) > 200:
            #     pic_name = os.path.basename(image[j])
            #     fp = open(avid + '/' + pic_name, 'wb')
            #     fp.write(pic)
            #     fp.close()
            #     # with tarfile.open(avid + '.tar', 'a') as tar:
            #     #     tar.add(pic_name)
            #     #     os.system('rm '+ pic_name)

            file_object.write(image[j] + '\n')
        file_object.close()

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
    try:
        url=getAjax(avid)
    except Exception as ret:
        # raise Exception(ret)
        print(ret)
        return
    
    if url == None:
        return

    headers['Referer'] = 'https://www.javbus.com/ja/'+avid
    for i in range(5):
        try:
            response = requests.get(url, headers=headers, proxies=proxies, timeout=10)
            if response.status_code == 200:
                break
            else:
                response.raise_for_status()

        except Exception as ret:
            print(ret)
            if i == 4:
               raise       # give up after 5 attempts

    html = response.content
    # soup = BeautifulSoup(html.decode('utf-8', errors='ignore'), 'html.parser')
    soup = BeautifulSoup(html.decode('utf-8', errors='ignore'), 'lxml')
    html = soup.prettify()

    html = "\n".join(html.split('\n')[2:])
    html = "\n".join(html.split('\n')[:-3])
    html = html + '\n'
    html = html + "    </table>\n    <div id=\"movie-loading\" style=\"display: none;\">\n"
    global html_global
    global complete_name_globals
    
    pattern = re.compile(r"<a class=\"movie-box\" href=\"https://www.javbus.com/ja/.*?\"")
    match = pattern.findall(html_global)

    file_object = codecs.open("todo.list", "a", "utf-8")
    linsk = []
    for i in range(len(match)):
        linsk.append(match[i].replace("<a class=\"movie-box\" href=\"https://www.javbus.com/ja/","").replace("\"",""))
    for i in range(len(linsk)):
        file_object.write(linsk[i] + '\n')
    file_object.close()

    html_global = html_global.replace("/pics/cover/", "./")
    html_global = re.sub("<a class=\"sample-box\" href=\".*/(.*.jpg\")", "<a class=\"sample-box\" href=\"./\\1", html_global)
    html_global = html_global.replace("    </table>\n    <div id=\"movie-loading\" style=\"display: none;\">\n", html)
    file_object = codecs.open(avid + '/' + os.path.basename(complete_name_globals), "w", "utf-8")
    file_object.write(html_global)
    file_object.close()

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

    os.system('aria2c -d ' + avid + ' -j 10 -x 2 -i ' + avid + '/' + avid +".txt " + '--header \'sec-ch-ua: \"Google Chrome\";v=\"117\", \"Not;A=Brand\";v=\"8\", \"Chromium\";v=\"117\"\' --header \'sec-ch-ua-mobile: ?0\' --header \'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36\' --header \'sec-ch-ua-platform: \"Linux\"\' --header \'Referer: https://www.javbus.com/ja/' + avid + '\' ' + ' | tee ' + avid + '/' + avid + '_tee.log' )
    os.system('rm '+ avid + '/now_printing*')
    with tarfile.open(avid + '.tar.gz', 'w:gz') as tar:
        tar.add(avid)
        os.system('rm -rf '+ avid)
    pass


if __name__ == '__main__':
    # url=getAjax('HMRK-016')
    # print(url)
# 
    # javbus('BNST-036')
    # javbus('HHHA-001') # test HTTP Error 404: Not Found
	# javbus('HEYZO-3379')

    # for arg in sys.argv:
    #    print(arg)
    # print(sys.argv[1])

    javbus(sys.argv[1])
    pass

    # use_requests(url,headers)
