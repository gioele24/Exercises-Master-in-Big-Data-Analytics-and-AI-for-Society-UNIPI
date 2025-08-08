"""
This exercise takes informations of tablet products listed at https://webscraper.io/test-sites/e-commerce/allinone/computers/tablets and write them in a CSV file with the following structure:

"Name", "Price", "Description" "Number of Stars", "Number of Reviews"
"Packard 255 G2", "$416.99", "15.6", AMD E2-3800 1.3GHz, 4GB, 500GB, Windows 8.1", "2", "2",

Scraping is performed exploiting Selenium library and Chrome browser.

"""

# TO-DO: import python modules used in the script
# csv
import csv

# TO-DO: import python selenium webdriver module
from selenium import webdriver
from selenium.webdriver.common.by import By

target_url = 'https://webscraper.io/test-sites/e-commerce/allinone/computers/tablets'

# TO-DO: create a Chrome instance by means of the webdriver, and open the web page:
# https://webscraper.io/test-sites/e-commerce/allinone/computers/tablets
print("Open a browser and navigate to {0} ...".format(target_url))

options = webdriver.ChromeOptions()
options.add_experimental_option("excludeSwitches", ["enable-automation"])
options.add_experimental_option("useAutomationExtension", False)
driver = webdriver.Chrome(options=options)
driver.get(target_url)

# TO-DO: open a writable CSV file "products.csv"
# TO-DO: write the CSV file header
with open('products.csv', 'w+') as handle:
    file_writer = csv.writer(handle,
                             delimiter=',',
                             quotechar='"',
                             quoting=csv.QUOTE_ALL)

    # write the header
    file_headers = [
        'Name', 'Price', 'Description', 'Number of Stars', 'Number of Reviews'
    ]
    file_writer.writerow(file_headers)

    # TO-DO: retrieve the products elements on the page
    print('Retrieving products...')

    # find_elements(...)
    products = driver.find_elements(By.CSS_SELECTOR, '.thumbnail')

    # for each product, extract name, price, description, stars and reviews
    for product in products:
        name = product.find_element(By.CSS_SELECTOR, '.title').text
        price = product.find_element(By.CSS_SELECTOR, '.price').text
        description = product.find_element(By.CSS_SELECTOR, '.description').text
        stars = len(product.find_elements(By.CSS_SELECTOR, '.ws-icon-star'))
        reviews = product.find_element(By.CSS_SELECTOR, '.review-count').text.split(' ')[0]

        # create a row containing the info
        row = [name, price, description, stars, reviews]

        # write the CSV row
        file_writer.writerow(row)

        print('Product retrieved')

# TO-DO: quit the Chrome instance
driver.quit()
print("Browser instance closed. Finished with success!")