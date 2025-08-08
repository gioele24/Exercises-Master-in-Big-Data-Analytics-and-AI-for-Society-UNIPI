# Retrieve posts from the subreddit "learnpython" between the 1st and the 15th of February 2023 that received a significant number of first-level comments (greater than 20). For each post, gather the following:
# 	1.	The post’s ID, title, number of comments, and the number of upvotes.
# 	2.	For each post, collect the comment with maximum "score" (difference between upvotes and downvotes).
# 	3.	Save this information in a CSV file named february_learnpython.csv with the following columns:
# 	•	post_id
# 	•	title
# 	•	n_comments
# 	•	upvotes
# 	•	top_comment_id
# 	•	top_comment_text
# 	•	top_comment_score

# Sort the data in descending order of the number of score for the top comment.


import praw
import datetime
import csv

from reddit.RedditUtils import getDataWithPagination

# Create a PRAW instance for Reddit API access
reddit = praw.Reddit(
    client_id='???',
    client_secret='???',
    password='???',
    user_agent='???',
    username='???',
)



# Specify the date range for February 1, 2023 to February 15, 2023
start_date = int(datetime.datetime(2023, 2, 1).timestamp())
end_date = int(datetime.datetime(2023, 2, 15).timestamp())

# Define the subreddit
subreddit = 'learnpython'

# Fetch posts from pullpush API within the specified date range. Use pagination for this.
posts = getDataWithPagination("submission",after=start_date, before=end_date, subreddit=subreddit)


# Create a list to store the result data
data = []

# Iterate over the retrieved posts
for post in posts:
    # Only consider posts with more than 20 comments
    if post["num_comments"] > 25:
        # Get the post's PRAW submission object to fetch the top comment
        praw_post = reddit.submission(id=post["id"])

        # Try to retrieve the top comment for the post
        try:
            # Sort comments by upvotes and get the most upvoted one
            praw_post.comments.replace_more(limit=None)  # Load all comments

            # Select only first level comments.
            flc = []
            for comment in praw_post.comments:
                if comment.parent_id.startswith("t3_"):
                    # It is a first level comment. Check https://praw.readthedocs.io/en/stable/code_overview/models/comment.html
                    flc.append(comment)
            top_comment = max(flc, key=lambda x: x.score)

            # Append the post data with the top comment information
            data.append({
                'post_id': post["id"],
                'title': post["title"],
                'n_comments': post["num_comments"],
                'upvotes': reddit.submission(id=post["id"]).ups,
                'top_comment_id': top_comment.id,
                'top_comment_text': top_comment.body,
                'top_comment_upvotes': top_comment.score
            })
        except Exception as e:
            print(f"Error retrieving comments for post {post.id}: {e}")

# Sort the data by the number of upvotes for the top comment in descending order
data_sorted = sorted(data, key=lambda x: x['top_comment_upvotes'], reverse=True)

# Save the data to a CSV file
with open('february_learnpython.csv', 'w', newline='', encoding='utf-8') as csvfile:
    fieldnames = ['post_id', 'title', 'n_comments', 'upvotes', 'top_comment_id', 'top_comment_text',
                  'top_comment_upvotes']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()
    writer.writerows(data_sorted)

print("Data extraction completed and saved to 'february_learnpython.csv'.")