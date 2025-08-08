"""
This script goes to page http://www.uitestingplayground.com/ajax, press the
button "Button Triggering AJAX Request" and wait for the content dynamically loaded
with the AJAX request. After the content has been loaded, it will be printed on
standard out.

Scraping is performed exploiting Selenium library and Chrome browser.

"""

# TO-DO: import python selenium module and the By module
from selenium import webdriver
from selenium.common import TimeoutException
from selenium.webdriver.common.by import By
# TO-DO: import expected_conditions and WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait


target_url = 'http://www.uitestingplayground.com/ajax'



# TO-DO: create a Chrome instance by means of the webdriver, and open the web page:
# http://www.uitestingplayground.com/ajax

print("Open a browser and navigate to {0} ...".format(target_url))


driver = webdriver.Chrome()
driver.get(target_url)


# TO-DO: find the  AJAX button and click it.
ajax_button = driver.find_element(By.CSS_SELECTOR, '#ajaxButton')
ajax_button.click()

print("AJAX button clicked!")

# TO-DO: wait for AJAX request to be completed with the new content. You can use WebDriverWait class to perform this action. Be sure to have set a big enough timeout.
try:
    wait = WebDriverWait(driver, 20)
    element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, '.bg-success')))
except TimeoutException:
    print("Sorry, timed out!")
    exit(-1)

# TO-DO: print scraped text from content loaded by AJAX request.
print(element.text)


# TO-DO: quit the Chrome instance
driver.quit()

print("Browser instance closed. Finished with success!")