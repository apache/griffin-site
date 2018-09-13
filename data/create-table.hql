--replace data location with your own path

CREATE EXTERNAL TABLE `demo_src`(
  `id` bigint,
  `age` int,
  `desc` string)
PARTITIONED BY (
  `dt` string,
  `hour` string)
ROW FORMAT DELIMITED
  FIELDS TERMINATED BY '|'
LOCATION
  'hdfs:///griffin/data/batch/demo_src';

--replace data location with your own path

CREATE EXTERNAL TABLE `demo_tgt`(
  `id` bigint,
  `age` int,
  `desc` string)
PARTITIONED BY (
  `dt` string,
  `hour` string)
ROW FORMAT DELIMITED
  FIELDS TERMINATED BY '|'
LOCATION
  'hdfs:///griffin/data/batch/demo_tgt';
