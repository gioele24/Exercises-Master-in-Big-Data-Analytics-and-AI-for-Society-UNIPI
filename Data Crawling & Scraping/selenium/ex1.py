"""
This script takes the admin and password tokens from the
http://the-internet.herokuapp.com/login
and use them to perform the login to the web page. Then the login message is printed.

Scraping is performed exploiting Selenium library and Chrome browser.

"""

# TO-DO: import python selenium module
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By

target_url = 'http://the-internet.herokuapp.com/login'

# TO-DO: create a Chrome instance by means of the webdriver, and open the web page:
# http://the-internet.herokuapp.com/login

print("Open a browser and navigate to {0} ...".format(target_url))

driver = webdriver.Chrome()
driver.get(target_url)

# Get credentials elements.
credentials = driver.find_elements(By.CSS_SELECTOR, "h4.subheader em")
username = credentials[0].text
password = credentials[1].text

# TO-DO: Find username field
# find_element_by_css_selector(...)
username_field = driver.find_element(By.CSS_SELECTOR, '#username')

print("Found the username: {0}".format(username))

# TO-DO: fill the username field with the username
# send_keys(...)
username_field.send_keys(username)

print("Username inserted!")

# TO-DO: retrieve the password field
# find_element_by_css_selector(...)
password_field = driver.find_element(By.CSS_SELECTOR, '#password')

# TO-DO: fill the password field with the retrieved password
# send_keys(...)
password_field.send_keys(password)

print("Password inserted!")


# TO-DO: select the login button and submit the form
# find_element_by_css_selector(...)
login_button = driver.find_element(By.CSS_SELECTOR, 'button[type="submit"]')
login_button.click()

print("Login button clicked!")

# TO-DO: print the login message
# find_element_by_css_selector(...)
result = driver.find_element(By.CSS_SELECTOR, 'div.flash.success')
print("Login message: {0}".format(result.text))

# TO-DO: quit the Chrome instance
driver.quit()

print("Browser instance closed. Finished with success!")
