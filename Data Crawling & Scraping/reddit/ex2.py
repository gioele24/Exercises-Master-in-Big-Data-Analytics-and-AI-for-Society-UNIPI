"""
Exercise 2: retrieve the today's top items from the subreddit 'learningpython'
and save the found items in a csv file with the number of comments:

OPTIONAL: save in order of number of comments in the csv

"id","title","n_comments"
"10v61tb","Python Regex Help","11"
"10ux48n","How can you make your code run faster?","9"
"10v7nxc","How to automate marking the row on all sites of PDF document?","2"
"10un83g","need help with health bar to percentage","5"
"10v9oe5","Tetris python","2"

"""

# TO-DO: import python modules used in the script (praw, csv)
import praw
import csv


reddit = praw.Reddit(
    client_id='???',
    client_secret='???',
    user_agent='???'
)

# TO-DO: search for the DAILY top items in the subreddit 'learnpython' and create a list
submissions = reddit.subreddit("learnpython").top(time_filter="day")
submissions_list = [submission for submission in submissions]

# Optionally sort the posts in descending order of number of comments.
submissions_list = sorted(submissions_list, key=(lambda s:s.num_comments),reverse=True)

# TO-DO: open a CSV "submissions.csv" in write mode
csv_output_file = 'submissions.csv'

print("Saving submissions in {0}...".format(csv_output_file))

# TO-DO: scan the list, and write the item id (id), the number of comments (n_comments) and the title (title)
with open(csv_output_file, 'w', encoding='utf-8', newline='') as handle:
    file_writer = csv.writer(handle, delimiter=',', quotechar='"', quoting=csv.QUOTE_ALL)
    file_headers = ['id', 'name', 'n_comments']
    file_writer.writerow(file_headers)
    for sub in submissions_list:
        row = [sub.id, sub.title, sub.num_comments]
        file_writer.writerow(row)
print("Finish")
