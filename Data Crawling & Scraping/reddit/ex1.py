"""
Exercise 1: Authenticate on the Reddit API, instantiate an api object and verify that everything is working properly
by printing your own Reddit name.
"""


import praw


reddit = praw.Reddit(
    client_id='???',
    client_secret='???',
    password='???',
    user_agent='???',
    username='???',
)

print(reddit.user.me())

