---
layout: doc
title:  "Quick Start" 
permalink: /docs/quickstart.html
---

## Environment Preparation
Prepare the environment for Apache Griffin. 
You can use our pre-built docker images as the environment.
Follow the [docker guide](https://github.com/apache/incubator-griffin/blob/master/griffin-doc/docker/griffin-docker-guide.md#environment-preparation) to start up the docker images, and login to the griffin container.
```
docker exec -it <griffin docker container id> bash
cd ~/measure
```

## Data Preparation
Prepare the test data in Hive.
In the docker image, we've prepared two Hive tables named `demo_src` and `demo_tgt`, and the test data is generated hourly.
The schema is like this:
```
id                      bigint                                      
age                     int                                         
desc                    string                                      
dt                      string                                      
hour                    string 
```
In which `dt` and `hour` are the partition columns, with string values like `20180912` and `06`.

## Configuration Files
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

## Submit Measure Job
Submit the measure job to Spark, with config file paths as parameters.
```
spark-submit --class org.apache.griffin.measure.Application --master yarn --deploy-mode client --queue default \
--driver-memory 1g --executor-memory 1g --num-executors 2 \
<path>/griffin-measure.jar \
<path>/env.json <path>/batch-accu-config.json
```
Then you can get the calculation log in console, after the job finishes, you can get the result metrics printed. The metrics will also be saved in hdfs: `hdfs:///griffin/persist/<job name>/<timestamp>/_METRICS`.

## More Details
For more details about griffin measures, you can visit our documents in [github](https://github.com/apache/incubator-griffin/tree/master/griffin-doc).
