import psycopg2 as psycopg2
from config import config
import matplotlib.pyplot as plt
import json
from datetime import datetime, timedelta


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

# Draws a graph for inspecting a material failure
def draw_test_graph(conn):
    # execute a statement
    result = fetch_all(conn,
                       "SELECT COUNT(a2_rssi) as failures, position FROM (SELECT a2_rssi, round(position_no_leap, -1) as position FROM rssi_records WHERE (date_time BETWEEN to_timestamp('2020-02-08 04:37:25', 'YYYY-MM-DD HH24:MI:SS') - INTERVAL '1 WEEKS' AND to_timestamp('2020-02-08 04:37:25', 'YYYY-MM-DD HH24:MI:SS') - INTERVAL '2 days') AND a2_rssi < 1) as positions GROUP BY position ORDER BY position;")
    x_val = [x[1] for x in result]
    y_val = [x[0] for x in result]

    plt.clf()
    plt.scatter(x_val, y_val)
    plt.axvline(x=97605, color='red')
    plt.show()

# For every day it calculates the average RSSI for every track segment and saves it into a JSON for further processing
# if it is below a specified threshold.
def save_low_rssi_per_day(conn):
    rssi_threshold = 1

    start_date = datetime(2020, 1, 1, 0, 0, 0)
    end_date = datetime(2021, 1, 1, 0, 0, 0)

    current_date = start_date

    all_failures = {}
    while current_date < end_date:
        # execute a statement
        result = fetch_all(conn,
                           f"SELECT * FROM (SELECT to_timestamp('{str(current_date)}', 'YYYY-MM-DD HH24:MI:SS') as timestamp, COUNT(a2_rssi) as failures_last_week, position, min(longitude) as longitude, min(latitude) as latitude FROM (SELECT a2_rssi, round(position_no_leap, -1) as position, longitude, latitude FROM rssi_records WHERE (date_time BETWEEN to_timestamp('{str(current_date)}', 'YYYY-MM-DD HH24:MI:SS') - INTERVAL '1 week' AND to_timestamp('{str(current_date)}', 'YYYY-MM-DD HH24:MI:SS')) AND a2_rssi < {rssi_threshold}) as positions GROUP BY position ORDER BY position) as all_failures WHERE failures_last_week > 100;")

        result = [{"failures_last_week": x[1],
                   "position": x[2],
                   "latitude": x[3],
                   "longitude": x[4]} for x in result]

        if len(result) > 0:
            all_failures[str(current_date)] = result

        current_date = current_date + timedelta(days=1)

    with open('low_rssi.json', 'w', encoding='utf-8') as f:
        json.dump(all_failures, f, default=str, ensure_ascii=False, indent=4)

# Calculates how many low telegram rate incidents happened at every track segment. If they surpass a given threshold
# we save it into a JSON for further processing.
def save_low_telegram(conn):
    result = fetch_all(conn,
                       f"SELECT * FROM(SELECT min(date_time) as date_time, count(*) incidents, position, avg(avg_rssi), min(latitude) AS latitude, min(longitude) AS longitude FROM (SELECT min(date_time) AS date_time, count(*) as lost_telegrams, min(position_group) as position, avg(a2_rssi) AS avg_rssi, min(latitude) AS latitude, min(longitude) AS longitude FROM (SELECT *, round(position_no_leap, -2) as position_group, round(CAST(extract(epoch from date_time) AS numeric), -1) as time_group FROM rssi_records) grouped GROUP BY grouped.time_group, a2_valid_tel ORDER BY count(*) desc) agg WHERE lost_telegrams = 2 GROUP BY position) a WHERE incidents > 9;")

    result = [{"first_incident": x[0],
               "low_tele_incidents": x[1],
               "position": x[2],
               "avg_rssi": x[3],
               "latitude": x[4],
               "longitude": x[5]} for x in result]

    with open('low_tele.json', 'w', encoding='utf-8') as f:
        json.dump(result, f, default=str, ensure_ascii=False, indent=4)

if __name__ == '__main__':
    conn = connect()

    # save_low_rssi_per_day(conn)
    # save_low_telegram(conn)
