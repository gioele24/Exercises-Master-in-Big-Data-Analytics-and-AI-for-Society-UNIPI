"""
Starting from the URL https://it.wikipedia.org/wiki/Stati_membri_delle_Nazioni_Unite, retrieve all the countries
having the capital in the southern hemisphere, and write the results in a csv file with the following layout:

"State";"Capital"
"Angola";"Luanda"
"Argentina";"Buenos Aires"
"Australia";"Canberra"
...

"""

# TODO: import python modules used in the script
import csv
from selenium import webdriver
from selenium.webdriver.common.by import By
from time import sleep
from random import uniform

target_url = 'https://it.wikipedia.org/wiki/Stati_membri_delle_Nazioni_Unite'

# TODO: create a Chrome instance by means of the webdriver, and open the web page:
# https://it.wikipedia.org/wiki/Stati_membri_delle_Nazioni_Unite

print("Open a browser and navigate to {0} ...".format(target_url))

options = webdriver.ChromeOptions()
options.add_experimental_option("excludeSwitches", ["enable-automation"])
options.add_experimental_option("useAutomationExtension", False)
driver = webdriver.Chrome(options=options)

driver.get(target_url)
# TODO: by means of CSS selectors, select the countries links in the table
print("Retrieving the country page URLs...")
countries = driver.find_elements(By.CSS_SELECTOR, 'table.sortable tbody tr td:first-of-type > a')

# TODO: get (country_name, country_url) tuples:
country_tuples = [(country.text, country.get_attribute("href")) for country in countries]
# TODO: open the output csv file and create a proper writer
with open("southern_capitals.csv", "w", encoding="utf-8", newline='') as handle:
    file_writer = csv.writer(handle, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)

    file_writer.writerow(["State", "Capital"])
    # TODO: scan the list of countries URLs
    for country_name, country_url in country_tuples:
        print("Processing the country: {0}...".format(country_name))
        # TODO: open the wikipedia page of the target country (URL)
        driver.get(country_url)
        # TODO: open the wikipedia page of the target country (URL)
        # TODO: by means of a proper selector, point to the capital row in the country info table
        # (search google to understand what is XPATH and try to use it ("../.."))
        capital_row = driver.find_element(By.CSS_SELECTOR, "a[title=\"Capitale (città)\"]").find_element(By.XPATH, "../..")

        # TODO: select the capital link (use try-except to handle the case of a missing link)
        # if the link is missing skip (use continue)
        try:
            capital = capital_row.find_element(By.CSS_SELECTOR, "td > a:last-of-type")
        except:
            continue
        # TODO: retrieve the capital name
        capital_name = capital.text
        # TODO: click on the link to open the capital wikipedia page
        capital.click()
        # TODO: select the capital latitude
        latitude = driver.find_element(By.CSS_SELECTOR, ".mw-kartographer-maplink").text
        latitude = latitude.split(" ")[0]
        # TODO: if latitude ends with "S", the capital is in the southern hemisphere!
        if latitude[-1] == "S":
            # TODO: in this case, print a proper message is printed and save the result to csv file
            print("{0} is southern than equator, so I write {1}, {0} to the CSV file.".format(capital_name, country_name))
            file_writer.writerow([country_name, capital_name])
        else:
            # TODO: in the opposite case, print a proper message and discard the result
            print("{0} is northern than equator, so I discard {1}, {0}.".format(capital_name, country_name))
        # wait a random time interval between 0 and 1 second in order to avoid Wikipedia to stop my scraping
        # search Google to understand how time.sleep and random.uniform work...
        sleep(uniform(0, 1))


# TODO: quit the Chrome instance
driver.quit()
# an end message is printed
print("First browser instance closed. Finished with success!")
