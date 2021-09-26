SELECT *, round(CAST(extract(epoch from date_time) AS numeric), -3)
FROM rssi_records
WHERE position_no_leap BETWEEN 315000 AND 316000;

SELECT min(date_time) AS date_time, 315000 AS position_no_leap, avg(a2_rssi) AS rssi
FROM (SELECT *, round(CAST(extract(epoch from date_time) AS numeric), -3) as "group"
      FROM rssi_records
      WHERE position_no_leap BETWEEN 97000 AND 98000) time_grouped
GROUP BY time_grouped.group;

SELECT var_pop(samples.rssi) AS variance FROM (SELECT min(date_time) AS date_time, 315000 AS position_no_leap, avg(a2_rssi) AS rssi
FROM (SELECT *, round(CAST(extract(epoch from date_time) AS numeric), -3) as "group"
      FROM rssi_records
      WHERE position_no_leap BETWEEN 97000 AND 98000) time_grouped
GROUP BY time_grouped.group) samples;

SELECT min(position_no_leap) FROM rssi_records;

SELECT max(position_no_leap) FROM rssi_records;

SELECT date_time AS date_time, position_no_leap AS position_no_leap, a2_rssi AS rssi
FROM (SELECT *, round(CAST(extract(epoch from date_time) AS numeric), -3) as "group"
      FROM rssi_records
      WHERE position_no_leap BETWEEN 97000 AND 98000) time_grouped;

SELECT extract(epoch from date_time) AS numeric, position_no_leap AS position_no_leap, a2_rssi AS rssi
FROM (SELECT * FROM rssi_records WHERE position_no_leap BETWEEN 97000 AND 98000) time_grouped;

SELECT (extract(epoch from date_time) - 1580000000) AS unix_time, position_no_leap, a2_rssi AS rssi
FROM rssi_records
WHERE (position_no_leap BETWEEN 97600 AND 97610);

SELECT min(date_time) AS date_time, 315000 AS position_no_leap, avg(a2_rssi) AS rssi
FROM (SELECT *, round(CAST(extract(epoch from date_time) AS numeric), -1) as "group"
      FROM rssi_records
      WHERE position_no_leap BETWEEN 97600 AND 97610) time_grouped
GROUP BY time_grouped.group;

SELECT *, extract(epoch from date_time)
FROM rssi_records
WHERE date_time = to_timestamp('2020-04-06 19:25:27', 'YYYY-MM-DD HH24:MI:SS');

SELECT a2_rssi, date_time, a1_total_tel, a1_valid_tel, position_no_leap
FROM rssi_records
WHERE date_time BETWEEN to_timestamp('2020-02-11 12:58:04', 'YYYY-MM-DD HH24:MI:SS') -
                        INTERVAL '1 day' AND to_timestamp('2020-02-11 12:58:04', 'YYYY-MM-DD HH24:MI:SS');


SELECT to_timestamp('2020-02-26 18:13:10', 'YYYY-MM-DD HH24:MI:SS') as timestamp,
       COUNT(a2_rssi)                                               as failures_last_week,
       position,
       min(longitude)                                               as longitude,
       min(latitude)                                                as latitude
FROM (SELECT a2_rssi, round(position_no_leap, -1) as position, longitude, latitude
      FROM rssi_records
      WHERE (date_time BETWEEN to_timestamp('2020-02-26 18:13:10', 'YYYY-MM-DD HH24:MI:SS') -
                               INTERVAL '1 week' AND to_timestamp('2020-02-26 18:13:10', 'YYYY-MM-DD HH24:MI:SS'))
        AND a2_rssi < 1) as positions
GROUP BY position
ORDER BY position;

SELECT *, round(CAST(extract(epoch from date_time) AS numeric), -2) as "group"
FROM rssi_records;

SELECT * FROM (SELECT min(date_time) as date_time, count(*) incidents, position, avg(avg_rssi), min(latitude) AS latitude, min(longitude) AS longitude
FROM (SELECT min(date_time)        AS date_time,
             count(*)              as lost_telegrams,
             min(position_group) as position,
             avg(a2_rssi)          AS avg_rssi,
             min(latitude) AS latitude,
             min(longitude) AS longitude
      FROM (SELECT *, round(position_no_leap, -2) as position_group, round(CAST(extract(epoch from date_time) AS numeric), -1) as time_group
            FROM rssi_records) grouped
      GROUP BY grouped.time_group, a2_valid_tel
      ORDER BY count(*) desc) agg
WHERE lost_telegrams = 2
GROUP BY position) a WHERE incidents > 9;

SELECT min(date_time),
       min(position_no_leap),
       min(longitude),
       min(latitude),
       count(a2_valid_tel),
       avg(a2_rssi)
FROM rssi_records
GROUP BY a2_valid_tel;

SELECT count(a2_valid_tel),
       min(longitude) as longitude,
       min(latitude)  as latitude
FROM (SELECT a2_valid_tel, round(position_no_leap, -2) as position, longitude, latitude
      FROM rssi_records) as positions
GROUP BY a2_valid_tel;

