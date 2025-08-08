"""
Exercise 3: retrieve from the subreddit 'wallstreetbets' the submissions resulting from the query 'money'
between the 1st and the 7th of January 2023:

OPTIONAL: save in order of frequence in the csv

id","name","n_comments"
"11eg5af","Beginner's Python Cheat Sheets (updated)","27"
"11e75d2","A python script that send alert when a school website reservation is open","24"
"11e4dge","Concatenation in Python","20"
"11ed0yq","How to make Venn Diagram from 13 Boolean columns","4"
"11e4al8","Is it normal to feel overwhelmed and confused when learning python as your first language?","18"

"""

# TO-DO: import python modules used in the script (csv, datetime, requests)
import csv
import datetime as dt
import requests


# TO-DO: define the dates interval in timestamp format
since = int(dt.datetime(2023, 8, 1).timestamp())
until = int(dt.datetime(2023, 11, 1).timestamp())

# TO-DO: build the URL endpoint
search_link = 'https://api.pullpush.io/reddit/search/submission?q={0}&after={1}&before={2}&subreddit={3}&size={4}'
search_link = search_link.format('Bitcoin', since, until, 'CryptoCurrency', 100)
# TO-DO: query the endpoint trough requests.get()
retrieved_data = requests.get(search_link)
returned_submissions = retrieved_data.json()['data']

# Optionally sort the posts in descending order of number of comments.
returned_submissions = sorted(returned_submissions, key=(lambda s:s["num_comments"]),reverse=True)

# TO-DO: open a CSV "submissions2.csv" in write mode
csv_output_file = 'submissions2.csv'

# TO-DO: scan the list, and write the item id (id), the number of comments (n_comments) and the title (title)
print("Saving submissions in {0}...".format(csv_output_file))
with open(csv_output_file, 'w', encoding='utf-8', newline='') as handle:
    file_writer = csv.writer(handle, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)
    file_headers = ['id', 'title', 'n_comments']
    file_writer.writerow(file_headers)
    for sub in returned_submissions:
        row = [sub['id'], sub['title'], sub['num_comments']]
        file_writer.writerow(row)
