-- Drop table if exists
DROP TABLE IF EXISTS taxis;

-- Create table that will hold the required information for querying
CREATE TABLE IF NOT EXISTS taxis
(
    id                      char(9),
    passenger_count         int,
    haversine_distance      float,
    precipitation         	float,
    snow_fall             	float,
    weekDay                 int,
    pickup_area             char(15),
    dropoff_area            char(15),
    route                   char(25),
    hour                    char(6),
    time                    char(19),
    duration                float,
    isDaytime               int
)
row format delimited fields terminated by ',';
-- Load pre processed data
load data local inpath '/root/work/pre_processed.csv' overwrite into TABLE taxis;


-- EXERCISE 1

CREATE TEMPORARY TABLE IF NOT EXISTS tmp2 AS 
SELECT weekDay, hour, route, count(route)
FROM taxis
GROUP BY weekDay, hour, route;

INSERT OVERWRITE LOCAL DIRECTORY '/root/work/results_ex1' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
SELECT weekDay, hour, collect_set(route) 
FROM (
	SELECT weekDay, hour, route, 
	row_number() over (partition BY weekDay, hour ORDER BY `_c3` DESC) AS row_number
	FROM tmp2 ) taxis where row_number <= 10 GROUP BY weekDay, hour;


-- EXERCISE 2

INSERT OVERWRITE LOCAL DIRECTORY '/root/work/results_ex2' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
SELECT pickup_area, weekDay, time, avg(duration), avg(haversine_distance) FROM taxis
GROUP BY pickup_area, weekDay, time;


-- EXERCISE 3

CREATE TEMPORARY TABLE IF NOT EXISTS tm3 AS 
SELECT pickup_area, 
CASE WHEN precipitation > 0 OR snow_fall>0 THEN passenger_count ELSE 0 END AS wet_weather, 
CASE WHEN precipitation=0 OR snow_fall=0 THEN passenger_count ELSE 0 END AS dry_weather 
FROM taxis;

INSERT OVERWRITE LOCAL DIRECTORY '/root/work/results_ex3' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
SELECT pickup_area, 
CASE WHEN sum(dry_weather)=0 THEN 1 
   ELSE sum(wet_weather)/sum(dry_weather) 
END AS factor 
FROM tm3 
GROUP BY pickup_area;


-- EXERCISE 4

INSERT OVERWRITE LOCAL DIRECTORY '/root/work/results_ex4' 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ',' 
SELECT weekDay, isDaytime, count(id)
FROM taxis 
GROUP BY weekDay, isDaytime ORDER BY weekDay, isDaytime;

