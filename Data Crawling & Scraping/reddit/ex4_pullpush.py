"""
Exercise 4: Using pullpush API and starting from the submissions csv file ("submissions2.csv" file), retrieve the
comments for each item and write them in a csv file named 'comments' with the following format:

"submission_id","comment_id","comment","author"
"11eldu6","jaev9wo","It’s definitely possible. You just need a time machine and enough capital to push the price to $100k.","Bunker_Beans"
"11eldu6","jaf0h1k","Plus Forbes","Xpressivee"
"11eldu6","jaf2e6m","![gif](giphy|3og0IvAdrwbryA5sLm|downsized)","Main_Sergeant_40"
"11eldu6","jafkfxf","Is this financial advise?","UsedTableSalt"
"""

# TO-DO: import python modules used in the script (praw, pmaw, csv)
import praw
import csv

import requests

input_file = 'submissions2.csv'
output_file = 'comments.csv'

# TO-DO: open the file "submissions2.csv" in read mode
print("Scan the input file {0} for submissions...".format(input_file))
with open(input_file, 'r', encoding='utf-8') as handle:
    csv_reader = csv.reader(handle, delimiter=',', quotechar='"')
    # TO-DO: skip the file header (the first row)
    next(csv_reader, None)
    # TO-DO: open a CSV "comments.csv" in write mode
    with open(output_file, 'w', encoding='utf-8', newline='') as handle:
        csv_writer = csv.writer(handle, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)
        file_header = ['submission_id', 'comment_id', 'comment', 'author']
        csv_writer.writerow(file_header)
        # TO-DO: scan the submission2.csv file and retrieve the submission id for each row
        for row in csv_reader:
            submission_id = row[0]

            # Retrieve the comments using pullpush API
            url = f"https://api.pullpush.io/reddit/comment/search/?link_id={submission_id}&limit=100"
            response = requests.get(url)
            if response.status_code == 200:
                comments = response.json().get('data', [])
                for comment in comments:
                    # Write the submission id, comment id ("id"), comment body ("body"), and comment author name ("author")
                    comment_id = comment['id']
                    comment_text = comment['body']
                    author = comment['author']
                    # Scrivi i dettagli del commento nel file CSV
                    csv_writer.writerow([submission_id, comment_id, comment_text, author])



