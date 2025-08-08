import datetime
import json
import time

import requests


def get_pullpush_data(data_type, q='', after='', size=25, sort='desc', sort_type='score'):
    """
    Fetch data from the Pullpush API.

    :param data_type: Type of data to fetch ('comment' or 'submission').
    :param q: Query string to search for.
    :param after: Duration string to filter results from (e.g., '30d' for the last 30 days).
    :param size: Number of results to return.
    :param sort_type: Sort field (e.g., 'score', 'num_comments').
    :param sort: Order of the results ('asc' for ascending, 'desc' for descending).
    :return: JSON response containing the requested data.
    """
    base_url = 'https://api.pullpush.io/reddit/search/'

    # Construct the URL based on the function parameters
    url = f'{base_url}{data_type}/?q={q}&size={size}&sort={sort}&sort_type={sort_type}'

    if after:
        url += f'&after={after}'

    # Make the request to the Pushshift API
    response = requests.get(url)

    # Check if the request was successful
    if response.status_code == 200:
        return response.json()
    else:
        print(f'Error fetching data: HTTP {response.status_code}')
        return None




def getDataWithPagination(data_type, after, q = None, subreddit=None, before=None, limit_size=100):
   previous_epoch = after
   data = []
   while True:
       req = f"https://api.pullpush.io/reddit/{data_type}/search?limit={limit_size}&sort=asc&sort_type=created_utc&after={previous_epoch}"
       if q is not None:
           req += f"&q={q}"
       if subreddit is not None:
           req += f"&subreddit={subreddit}"
       if before is not None:
           req += f"&before={before}"

       response = requests.get(req)
       time.sleep(1)
       try:
           json_data = response.json()
           if 'data' not in json_data: # No more data to retrieve
               break
       except json.decoder.JSONDecodeError:
           # pushshift has a rate limit, if we send requests too fast it will start returning error messages
           time.sleep(5)
           continue
       objects = json_data['data']
       if len(objects) == 0:
           break # No more data to retrieve

       for obj in objects:
           previous_epoch = int(obj['created_utc'] + 1)
           data.append(obj)

   return data




if __name__ == "__main__":
    data_type = "submission"  # Use 'comment' for searching comment, use 'submission' to search for submission
    query = "python"  # Add your query
    duration = "30d"  # Select the timeframe. Epoch value or Integer + "s,m,h,d" (i.e. "second", "minute", "hour", "day")
    size = 100  # maximum 100 comments
    sort_type = "score"  # Sort by score (Accepted: "score", "num_comments", "created_utc")
    sort = "desc"  # sort descending ('desc') or ascending ('asc')

    #ret = get_pullpush_data(data_type, q=query, after=duration, size=size, sort=sort, sort_type=sort_type)
    #print(ret.data)

    start_from = int(datetime.datetime(2025, 2, 1).timestamp())
    data = getDataWithPagination("submission", start_from, q="trump", subreddit="worldnews")
    print(data[0])

