#! usr/bin/python3

import config
import psycopg2
from psaw import PushshiftAPI
import datetime as dt
import re

connection = psycopg2.connect(host=config.DB_HOST, 
                            database=config.DB_NAME, 
                            user=config.DB_USER, 
                            password=config.DB_PASS)
cursor = connection.cursor()

cursor.execute('SELECT symbol FROM stocks')
symlist = [entry[0] for entry in cursor.fetchall()]

api = PushshiftAPI()
start_time = int(dt.datetime(2016, 1, 1).timestamp())
end_time = int(dt.datetime(2021,3,5,1,15,0).timestamp())
submissions = api.search_submissions(after=start_time,
                                    subreddit='wallstreetbets')

for submission in submissions:
    try:
        words = set(re.sub('[!#&$?.,]+', ' ',submission.title + submission.selftext).split())
        body = submission.selftext
    except Exception as e:
        words = set(re.sub('[!#&$?.,]+', ' ',submission.title).split())
        body = ''
    mentions = [word for word in words if word in symlist]
    intup = (submission.id, dt.datetime.fromtimestamp(submission.created_utc),
            submission.title, submission.author, mentions, body, submission.url)
    
    try:
        cursor.execute("""
        INSERT INTO posts (id, dt, title, author, mentions, body, link)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """,intup)

        connection.commit()
    except Exception as e:
        print(e)
        connection.rollback()
