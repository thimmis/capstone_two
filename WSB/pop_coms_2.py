import os
import psycopg2
import datetime as dt
from psaw import PushshiftAPI
from dotenv import load_dotenv



def coms_insert_context(stime, etime, host, database, user, password):

    with psycopg2.connect(host=host, database=database,user=user,password=password) as connection:
        try:
            cursor = connection.cursor() #set up the connection cursor

            cursor.execute(
                    """
                    SELECT id
                    FROM posts
                    WHERE posts.link ~ 'reddit.com/r/wallstreetbets';
                    """
                    )
            idlist = [entry[0] for entry in cursor.fetchall()] #list of necessary ids
            try:
                api = PushshiftAPI()
                comgen = api.search_comments(subreddit='wallstreetbets',after=stime, before=etime)
                for com in comgen:
                    if com.link_id.split('_')[1] in idlist:
                        
                        intup = (
                            com.id, 
                            com.link_id.split('_')[1],
                            com.parent_id, 
                            dt.datetime.fromtimestamp(com.created_utc), 
                            'FALSE', # ran into issue in 2019-07 where 'is_submitter' no longer appeared
                            com.author, 
                            com.body
                        )
                        try:
                            print(f'COMMENT TIME {dt.datetime.fromtimestamp(com.created_utc)}')
                            cursor.execute("""
                            INSERT INTO comments (id, post_id, parent_id, dt, is_op, author, body)
                            VALUES (%s, %s, %s, %s, %s, %s, %s)
                            """, intup)
                            connection.commit()
                        except Exception as e:
                            print(e)
                            connection.rollback()
            except Exception as e:
                print(e)
        except KeyboardInterrupt: #should close connection to pushshift
            connection.close()

start_time = int(dt.datetime(2016, 1, 1).timestamp())
end_time = int(dt.datetime(2019, 3, 31, 19, 10, 2).timestamp())


if __name__ == '__main__':
    load_dotenv()
    DB_HOST = os.getenv('DB_HOST')
    DB_NAME = os.getenv('DB_NAME')
    DB_USER = os.getenv('DB_USER')
    DB_PASS = os.getenv('DB_PASS')

    coms_insert_context(
        start_time,
        end_time, 
        DB_HOST, 
        DB_NAME,
        DB_USER,
        DB_PASS
    )
