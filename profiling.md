---
layout: doc
title:  "Profiling Use Case" 
permalink: /docs/profiling.html
---
## User Story
Say we have one data set(demo_src), partitioned by hour, we want to know what is the data like for each hour.

For simplicity, suppose both two data set have the same schema as this:
```
id                      bigint                                      
age                     int                                         
desc                    string                                      
dt                      string                                      
hour                    string 
```
both dt and hour are partitions, 

as every day we have one daily partition dt(like 20180912), 

for every day we have 24 hourly partitions(like 00, 01, 02, ..., 23).

## Environment Preparation
You need to prepare the environment for Apache Griffin measure module, including the following software:
- JDK (1.8+)
- Hadoop (2.6.0+)
- Spark (2.2.1+)
- Hive (2.2.0)

## Build Apache Griffin Measure Module
1.  Download Apache Griffin source package [here](https://www.apache.org/dist/griffin/0.4.0/).
2.  Unzip the source package.
    ```
    unzip griffin-0.4.0-source-release.zip
    cd griffin-0.4.0-source-release
    ```
3.  Build Apache Griffin jars.
    ```
    mvn clean install
    ```
    
    Move the built apache griffin measure jar to your work path.
    
    ```
    mv measure/target/measure-0.4.0.jar <work path>/griffin-measure.jar
    ```

## Data Preparation

For our quick start, We will generate a hive table demo_src.
```
--create hive tables here. hql script
--Note: replace hdfs location with your own path
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
```
The data could be generated this:
```
1|18|student
2|23|engineer
3|42|cook
...
```
You can download [demo data](/data/batch) and execute `./gen_demo_data.sh` to get the data source file.
Then we will load data into hive table for every hour.
```
LOAD DATA LOCAL INPATH 'demo_src' INTO TABLE demo_src PARTITION (dt='20180912',hour='09');
```
Or you can just execute `./gen-hive-data.sh` in the downloaded directory above, to generate and load data into the tables hourly.

## Define data quality measure

#### Apache Griffin env configuration 
The environment config file: env.json
```
{
  "spark": {
    "log.level": "WARN"
  },
  "sinks": [
    {
      "type": "console"
    },
    {
      "type": "hdfs",
      "config": {
        "path": "hdfs:///griffin/persist"
      }
    },
    {
      "type": "elasticsearch",
      "config": {
        "method": "post",
        "api": "http://es:9200/griffin/accuracy"
      }
    }
  ]
}
```

#### Define Apache Griffin data quality 
The DQ config file: dq.json

```
{
  "name": "batch_prof",
  "process.type": "batch",
  "data.sources": [
    {
      "name": "src",
      "baseline": true,
      "connectors": [
        {
          "type": "hive",
          "version": "1.2",
          "config": {
            "database": "default",
            "table.name": "demo_tgt"
          }
        }
      ]
    }
  ],
  "evaluate.rule": {
    "rules": [
      {
        "dsl.type": "griffin-dsl",
        "dq.type": "profiling",
        "out.dataframe.name": "prof",
        "rule": "src.id.count() AS id_count, src.age.max() AS age_max, src.desc.length().max() AS desc_length_max",
        "out": [
          {
            "type": "metric",
            "name": "prof"
          }
        ]
      }
    ]
  },
  "sinks": ["CONSOLE", "HDFS"]
}
```

## Measure data quality
Submit the measure job to Spark, with config file paths as parameters.

```
spark-submit --class org.apache.griffin.measure.Application --master yarn --deploy-mode client --queue default \
--driver-memory 1g --executor-memory 1g --num-executors 2 \
<path>/griffin-measure.jar \
<path>/env.json <path>/dq.json
```

## Report data quality metrics
Then you can get the calculation log in console, after the job finishes, you can get the result metrics printed. The metrics will also be saved in hdfs: `hdfs:///griffin/persist/<job name>/<timestamp>/_METRICS`.

## Refine Data Quality report
Depends on your business, you might need to refine your data quality measure further till your are satisfied.

## More Details
For more details about apache griffin measures, you can visit our documents in [github](https://github.com/apache/griffin/tree/master/griffin-doc).
