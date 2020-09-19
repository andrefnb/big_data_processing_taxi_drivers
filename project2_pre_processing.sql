-- Drop both tables if exists
DROP TABLE taxis_raw;
DROP TABLE taxis;

-- Create table that will hold the raw data
CREATE TABLE IF NOT EXISTS taxis_raw
(
	number					int,
    id           			char(9),
    vendor_id               int,
	pickup_datetime			char(19),
    dropoff_datetime        char(19),
    passenger_count         int,
    pickup_longitude        float,
    pickup_latitude         float,
	dropoff_longitude		float,
	dropoff_latitude		float,
    haversine_distance      float,
    maximum_temperature     int,
    minimum_temperature     int,
    average_temperature     float,
    precipitation         	float,
    snow_fall             	float,
    snow_depth            	float
)
row format delimited fields terminated by ',' tblproperties("skip.header.line.count"="1");
-- Load data into table
load data local inpath '/root/work/taxis.csv' overwrite into table taxis_raw;

-- Create a new table with only the needed data
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
);

-- Populate table above with the required data
INSERT OVERWRITE TABLE taxis
SELECT
    id,
    passenger_count,
    haversine_distance,
    precipitation,
    snow_fall,
    -- Extract weekday from the pickup datetime (monday will be 1 and sunday will be 7)
    from_unixtime(unix_timestamp(pickup_datetime),'u'),
    -- Pickup area, dropoff area and route are obtained be concatenating longitude and latitude, rounded to 2 decimal cases 
    concat_ws(":", CAST(round(pickup_longitude-0.005,2) AS string), CAST(round(pickup_latitude-0.005,2) AS string)),
    concat_ws(":", CAST(round(dropoff_longitude-0.005,2) AS string), CAST(round(dropoff_latitude-0.005,2) AS string)),
    concat_ws("|", concat_ws(":", CAST(round(pickup_longitude-0.005,2) AS string), CAST(round(pickup_latitude-0.005,2) AS string)), concat_ws(":", CAST(round(dropoff_longitude-0.005,2) AS string), CAST(round(dropoff_latitude-0.005,2) AS string))),
    -- Hour is obtained from pickup datetime
    substring(pickup_datetime, 12, 2),
    -- Times intervals of 15 minutes are obtained from pickup datetime using conditions
    CASE 
        WHEN CAST(substring(pickup_datetime, 15, 2) AS int) BETWEEN 0 AND 14 THEN concat(substring(pickup_datetime, 0, 14), "00")
        WHEN CAST(substring(pickup_datetime, 15, 2) AS int) BETWEEN 15 AND 29 THEN concat(substring(pickup_datetime, 0, 14), "15")
        WHEN CAST(substring(pickup_datetime, 15, 2) AS int) BETWEEN 30 AND 44 THEN concat(substring(pickup_datetime, 0, 14), "30")
        ELSE concat(substring(pickup_datetime, 0, 14), "45")
    END AS time,
    -- The duration of a taxi ride is obtained from the dropoff datetime and the pickup datetime, using the unix_timestamp function
    (unix_timestamp(dropoff_datetime) - unix_timestamp(pickup_datetime))/60,
    -- If the hour is between 7 a.m. and 7 p.m. then it is day time (1), otherwise it is night time (0) 
    CASE 
        WHEN substring(pickup_datetime, 12, 2) BETWEEN 7 AND 19 THEN 1
        ELSE 0
    END AS isDaytime
FROM taxis_raw;

-- Write to file
insert overwrite local directory '/root/work/pre_processed/' row format delimited fields terminated BY ',' SELECT * FROM taxis;



