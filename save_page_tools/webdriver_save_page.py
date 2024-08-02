#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import subprocess
import sys

# os.environ ['https_proxy']='127.0.0.1:8118'
# os.environ ['http_proxy']='127.0.0.1:8118'


import time
import pyautogui
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options

options = webdriver.ChromeOptions()
options.add_argument("user-data-dir=/home/andreas/.config/google-chrome")
driver = webdriver.Chrome(options=options)
# driver = webdriver.Chrome()
#driver.maximize_window()
driver.minimize_window()
driver.get('https://www.javbus.com/ja/BNST-036')
driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
driver.switch_to.window(driver.current_window_handle)

#time.sleep(2) # Pause to allow you to inspect the browser.

# 处理页面源代码...
# html = driver.page_source


get_title = driver.title
print(get_title)
# words=get_title.split()
# a=" ".join(words[0:2])
a=get_title[0:75]
driver.execute_script('document.title = "%s"' % a)

# pyautogui.hotkey('ctrl','s')
# pyautogui.press('enter')

#save_me = ActionChains(driver).key_down(Keys.CONTROL)\
#         .key_down('s').key_up(Keys.CONTROL).key_up('s')
#save_me.perform()

pyautogui.hotkey('ctrl', 's')
# print(a)
# pyautogui.typewrite(a + '.html')
time.sleep(1)
pyautogui.hotkey('enter') # in case of exist, replace
time.sleep(1)
pyautogui.hotkey('enter') 
time.sleep(3) # Pause to allow you to inspect the browser.
driver.quit()
