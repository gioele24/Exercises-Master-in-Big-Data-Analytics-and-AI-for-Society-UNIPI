"""
This exercise navigates from https://webscraper.io/test-sites/e-commerce/allinone
to https://webscraper.io/test-sites/e-commerce/allinone/computers/tablets
using the menu

Scraping is performed exploiting Selenium library and Chrome browser.

"""

"""
This exercise navigates from https://webscraper.io/test-sites/e-commerce/allinone
to https://webscraper.io/test-sites/e-commerce/allinone/computers/tablets
using the menu

Scraping is performed exploiting Selenium library and Chrome browser.

"""

# TODO: import python modules used in the script
import time

# TODO: import python selenium module and the By module
from selenium import webdriver
from selenium.webdriver.common.by import By

target_url = 'https://webscraper.io/test-sites/e-commerce/allinone'

# TODO: create a Chrome instance by means of the webdriver
print("Open a browser and navigate to {0} ...".format(target_url))

options = webdriver.ChromeOptions()
options.add_experimental_option("excludeSwitches", ["enable-automation"])
options.add_experimental_option("useAutomationExtension", False)
driver = webdriver.Chrome(options=options)
# TODO: the webpage is responsive, we must set a size with min. widht 992, use driver.set_window_size(x, y)
driver.set_window_size(1600, 900)

# open the web page:
# https://webscraper.io/test-sites/e-commerce/allinone
driver.get(target_url)

# TODO: find the cookies button and click it
# accept_cookies = driver.find_element(By.CSS_SELECTOR, '.acceptCookies')
# if accept_cookies is not None:
#   accept_cookies.click()

# TODO: find the menu div
menu = driver.find_element(By.CSS_SELECTOR, '#side-menu')
# TODO: find the voices inside the menu
voices = menu.find_elements(By.CSS_SELECTOR, 'li')

# TODO: click the second voice
voices[1].click()

# TODO: repeat, find the menu and the voices
menu = driver.find_element(By.CSS_SELECTOR, '#side-menu')
voices = menu.find_elements(By.CSS_SELECTOR, 'li')

# TODO: this time click the second sub voice inside the second voice
sub_voices = voices[1].find_elements(By.CSS_SELECTOR, 'li')
sub_voices[1].click()

# TODO: sleep 10 seconds
time.sleep(10)

# TODO: quit the Chrome instance
driver.quit()
print("Browser instance closed. Finished with success!")