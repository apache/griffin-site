---
layout: doc
title:  "Streaming Use Cases" 
permalink: /docs/usecases.html
---

## User Story
Say we have two streaming data sets in different kafka topics(source, target), we need to know what is the data quality for target data set, based on source data set.

For simplicity, suppose both two topics' data are json string which would be like this:
```
{"id": 1, "name": "Apple", "color": "red", "time": "2018-09-12_06:00:00"}
{"id": 2, "name": "Banana", "color": "yellow", "time": "2018-09-12_06:01:00"}
...
```

## Environment Preparation
You need to prepare the environment for Apache Griffin measure module, including the following software:
- JDK (1.8+)
- Hadoop (2.6.0+)
- Spark (2.2.1+)
- Kafka (0.8.x)
- Zookeeper (3.5+)

## Build Apache Griffin Measure Module
1.  Download Apache Griffin source package [here](https://www.apache.org/dist/incubator/griffin/0.3.0-incubating).
2.  Unzip the source package.
    ```
    unzip griffin-0.3.0-incubating-source-release.zip
    cd griffin-0.3.0-incubating-source-release
    ```
3.  Build Apache Griffin jars.
    ```
    mvn clean install
    ```
    
    Move the built apache griffin measure jar to your work path.
    
    ```
    mv measure/target/measure-0.3.0-incubating.jar <work path>/griffin-measure.jar
    ```
    
## Data Preparation

For our quick start, We will create two kafka topics(source, target) and generate data in json string format for them minutely.
```
# create topics
# Note: it just works for kafka 0.8
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic source
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic target
```
The data would be generated like this:
```
{"id": 1, "name": "Apple", "color": "red", "time": "2018-09-12_06:00:00"}
{"id": 2, "name": "Banana", "color": "yellow", "time": "2018-09-12_06:01:00"}
```
For topic source and target, there could be some different items between each other. 
You can download [demo data](/data/streaming) and execute `./streaming-data.sh` to generate json string data file and produce them into kafka topics minutely.

## Define data quality measure

#### Apache Griffin env configuration 
The environment config file: env.json
```
{
  "spark": {
    "log.level": "WARN",
    "checkpoint.dir": "hdfs:///griffin/checkpoint",
    "batch.interval": "20s",
    "process.interval": "1m",
    "init.clear": true,
    "config": {
      "spark.default.parallelism": 4,
      "spark.task.maxFailures": 5,
      "spark.streaming.kafkaMaxRatePerPartition": 1000,
      "spark.streaming.concurrentJobs": 4,
      "spark.yarn.maxAppAttempts": 5,
      "spark.yarn.am.attemptFailuresValidityInterval": "1h",
      "spark.yarn.max.executor.failures": 120,
      "spark.yarn.executor.failuresValidityInterval": "1h",
      "spark.hadoop.fs.hdfs.impl.disable.cache": true
    }
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
  ],
  "griffin.checkpoint": [
    {
      "type": "zk",
      "config": {
        "hosts": "zk:2181",
        "namespace": "griffin/infocache",
        "lock.path": "lock",
        "mode": "persist",
        "init.clear": true,
        "close.clear": false
      }
    }
  ]
}
```

#### Define griffin data quality 
The DQ config file: dq.json

```
{
  "name": "streaming_accu",
  "process.type": "streaming",
  "data.sources": [
    {
      "name": "src",
      "baseline": true,
      "connectors": [
        {
          "type": "kafka",
          "version": "0.8",
          "config": {
            "kafka.config": {
              "bootstrap.servers": "kafka:9092",
              "group.id": "griffin",
              "auto.offset.reset": "largest",
              "auto.commit.enable": "false"
            },
            "topics": "source",
            "key.type": "java.lang.String",
            "value.type": "java.lang.String"
          },
          "pre.proc": [
            {
              "dsl.type": "df-opr",
              "rule": "from_json"
            }
          ]
        }
      ],
      "checkpoint": {
        "type": "json",
        "file.path": "hdfs:///griffin/streaming/dump/source",
        "info.path": "source",
        "ready.time.interval": "10s",
        "ready.time.delay": "0",
        "time.range": ["-5m", "0"],
        "updatable": true
      }
    }, {
      "name": "tgt",
      "connectors": [
        {
          "type": "kafka",
          "version": "0.8",
          "config": {
            "kafka.config": {
              "bootstrap.servers": "kafka:9092",
              "group.id": "griffin",
              "auto.offset.reset": "largest",
              "auto.commit.enable": "false"
            },
            "topics": "target",
            "key.type": "java.lang.String",
            "value.type": "java.lang.String"
          },
          "pre.proc": [
            {
              "dsl.type": "df-opr",
              "rule": "from_json"
            }
          ]
        }
      ],
      "checkpoint": {
        "type": "json",
        "file.path": "hdfs:///griffin/streaming/dump/target",
        "info.path": "target",
        "ready.time.interval": "10s",
        "ready.time.delay": "0",
        "time.range": ["-1m", "0"]
      }
    }
  ],
  "evaluate.rule": {
    "rules": [
      {
        "dsl.type": "griffin-dsl",
        "dq.type": "accuracy",
        "out.dataframe.name": "accu",
        "rule": "src.id = tgt.id AND src.name = tgt.name AND src.color = tgt.color AND src.time = tgt.time",
        "details": {
          "source": "src",
          "target": "tgt",
          "miss": "miss_count",
          "total": "total_count",
          "matched": "matched_count"
        },
        "out":[
          {
            "type":"metric",
            "name": "accu"
          },
          {
            "type":"record",
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
--driver-memory 1g --executor-memory 1g --num-executors 3 \
<path>/griffin-measure.jar \
<path>/env.json <path>/dq.json
```

## Report data quality metrics
Then you can get the calculation log in console, when the job runs, you can get the result metrics printed minutely. The related results will also be saved in hdfs: `hdfs:///griffin/persist/<job name>/`, listing in different directoies named by calculate timestamps.

## Refine Data Quality report
Depends on your business, you might need to refine your data quality measure further till your are satisfied.

## More Details
For more details about apache griffin measures, you can visit our documents in [github](https://github.com/apache/incubator-griffin/tree/master/griffin-doc).


