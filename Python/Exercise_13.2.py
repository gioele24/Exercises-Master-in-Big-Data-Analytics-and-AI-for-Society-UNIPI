"""
Exercise 13.2 The code block below shows a list of movies. For each movie it also shows
a list of ratings. Convert this code in such a way that it stores all this data in one dictionary,
then use the dictionary to print the average rating for each movie, rounded to one decimal
"""


def create_dict(key_list, val_list):
    d = {}
    val = 0
    for key in key_list:
        d[key] = val_list[val]
        val += 1
    return d

def average_rate(d_ratings : dict):
    list_average = []
    for key in d_ratings.keys():
        list_average.append(round(sum(d_ratings[key])/len(d_ratings[key]), 1))
    return list_average

def display_rate(d : dict, l : list):
    index = 0
    for key in d.keys():
        print(key, l[index])
        index += 1

movies = ["Monty Python and the Holy Grail",
          "Monty Python 's Life of Brian",
          "Monty Python 's Meaning of Life",
          "And Now For Something Completely Different"]

grail_ratings = [9, 10, 9.5, 8.5, 3, 7.5, 8]
brian_ratings = [10, 10, 0, 9, 1, 8, 7.5, 8, 6, 9]
life_ratings = [7, 6, 5]
different_ratings = [6, 5, 6, 6]

rating_list = [grail_ratings, brian_ratings, life_ratings, different_ratings]

movie_dict = create_dict(movies, rating_list)
movie_rate = average_rate(movie_dict)
display_rate(movie_dict, movie_rate)