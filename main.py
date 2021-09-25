import psycopg2 as psycopg2
from config import config
import matplotlib.pyplot as plt


def connect():
    """ Connect to the PostgreSQL database server """
    conn = None
    try:
        # read connection parameters
        params = config()

        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    return conn


def fetch_one(conn, query):
    # create a cursor
    cur = conn.cursor()

    # execute a statement
    cur.execute(query)

    # display the PostgreSQL database server version
    result = cur.fetchone()

    # close the communication with the PostgreSQL
    cur.close()

    return result


def fetch_all(conn, query):
    # create a cursor
    cur = conn.cursor()

    # execute a statement
    cur.execute(query)

    # display the PostgreSQL database server version
    result = cur.fetchall()

    # close the communication with the PostgreSQL
    cur.close()

    return result


if __name__ == '__main__':
    conn = connect()

    # execute a statement
    result = fetch_all(conn,
                       'SELECT (extract(epoch from date_time) - 1580000000) AS unix_time, position_no_leap, a2_rssi AS rssi FROM rssi_records WHERE (position_no_leap BETWEEN 97600 AND 97610) AND (date_time < to_timestamp(\'2020-02-08 04:40:00\', \'YYYY-MM-DD HH:MI:SS\'));')

    x_val = [x[0] for x in result]
    y_val = [x[2] for x in result]

    plt.clf()
    plt.scatter(x_val, y_val)
    plt.axvline(x=1136645, color='red')
    plt.show()
