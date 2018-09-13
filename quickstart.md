---
layout: doc
title:  "Quick Start" 
permalink: /docs/quickstart.html
---
## User Story
Say we have two hive tables(demo_src, demo_tgt), we need to know what is the data quality for target table, based on source table.

For simplicity, suppose both two table have the same schema as this:
```
id                      bigint                                      
age                     int                                         
desc                    string                                      
dt                      string                                      
hour                    string 
```
dt and hour are partitions, as every date we have one big partition dt(like 20180912), for every date we have 24 hour partitions(like 01,02, ...).

## Environment Preparation
You need to prepare the environment for Apache Griffin measure module, including the following software:
- JDK (1.8+)
- Hadoop (2.6.0+)
- Spark (2.2.1+)
- Hive (2.2.0)

## Build Griffin Measure Module
1.  Download Griffin source package [here](https://www.apache.org/dist/incubator/griffin/0.3.0-incubating).
2.  Unzip the source package.
    ```
    unzip griffin-0.3.0-incubating-source-release.zip
    cd griffin-0.3.0-incubating-source-release
    ```
3.  Build Griffin jars.
    ```
    mvn clean install
    ```
    
    Move the built griffin measure jar to your work path.
    
    ```
    mv measure/target/measure-0.3.0-incubating.jar <work path>/griffin-measure.jar
    ```
    
## Data Preparation

For our quick start, We will generate two Hive tables demo_src and demo_tgt.
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

--Note: replace hdfs location with your own path
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

```
and we will load data into both two tables for every hour.

```
#load data here...
```



## Define data quality measure

#### Griffin env configuration 
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

#### Define griffin data quality 
The DQ config file: dq.json

```
{
  "name": "batch_accu",
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
            "table.name": "demo_src"
          }
        }
      ]
    }, {
      "name": "tgt",
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
        "dq.type": "accuracy",
        "out.dataframe.name": "accu",
        "rule": "src.id = tgt.id AND src.age = tgt.age AND src.desc = tgt.desc",
        "details": {
          "source": "src",
          "target": "tgt",
          "miss": "miss_count",
          "total": "total_count",
          "matched": "matched_count"
        },
        "out": [
          {
            "type": "metric",
            "name": "accu"
          },
          {
            "type": "record",
            "name": "missRecords"
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
<path>/env.json <path>/batch-accu-config.json
```

## Report data quality metrics
Then you can get the calculation log in console, after the job finishes, you can get the result metrics printed. The metrics will also be saved in hdfs: `hdfs:///griffin/persist/<job name>/<timestamp>/_METRICS`.


## Refine Data Quality report
Depends on your business, you might need to refine your data quality measure further till your are satisfied.

## More Details
For more details about griffin measures, you can visit our documents in [github](https://github.com/apache/incubator-griffin/tree/master/griffin-doc).
