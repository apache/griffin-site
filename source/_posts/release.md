---
title: Release
date: 2017-11-07 09:15:12
tags:
---

## Release Notes - Apache Griffin 0.1.6 (incubating)

- Highlights
  * Streaming: measure streaming data quality based on defined measurements.
  * Support Griffin DSL and SQL to define data quality measurement.
  * Support multiple data connectors and data sources.
  * Fully support headless interact with restful api.


- New Feature
  * [GRIFFIN-40] - Enhance DSL of Griffin, to support more types of measurement as accuracy, profiling.
  * [GRIFFIN-6 ] - Onboard streaming model for accuracy, profiling.


- Improvement
  * [GRIFFIN-26] - Support profiling measure process in measurement
  * [GRIFFIN-52] - Upgrade angularJS to angular2 for ui


- Bug
  * [GRIFFIN-31] - Localedatestring is not valid for backend tracking
  * [GRIFFIN-38] - Fix bugs of job instance status in service
  * [GRIFFIN-48] - Fix measure deletion bug
  * [GRIFFIN-49] - Fix bug of cache for hive metastore data
  * [GRIFFIN-37] - Jobs, UI should update previous fire time and next fire time in real-time
  * [GRIFFIN-35] - Job instance state update problem
  * [GRIFFIN-33] - Target Partition form need validation as source partition
  * [GRIFFIN-34] - When create job, each input box should have a format check


- Task
  * [GRIFFIN-66] - Upgrade our maven build system for angular 2 integration
  * [GRIFFIN-64] - Document for griffin dsl and samples

## Release Notes - Apache Griffin 0.1.5 (incubating)

- Highlights
  * Batch: measure data quality based on user defined mesurements.
  * Standard process to define,measure and report data quality dimensions.
  * Dashboard to interact with griffin for whole data quality cycle.

- New Feature
  * [GRIFFIN-11]  - Enable data quality Accuracy measure in batch mode
  * [GRIFFIN-17]  - Create a scheduler to schedule measure jobs

- Improvement
  * [GRIFFIN-9] - Setup public live demo
  * [GRIFFIN-8] - New awesome griffin logo


- Bug
  * [GRIFFIN-32] - Fix license header, by using SOURCE FILE HEADERS FOR CODE DEVELOPED AT THE ASF
  * [GRIFFIN-31] - localedatestring is not valid for backend tracking
  * [GRIFFIN-18] - The selection of hive data source can not get correct metadata from the tables in non-default database
  * [GRIFFIN-23] - Modify 'models' to 'measures', and 'create dq model' to 'create dq measure'
  * [GRIFFIN-25] - Remove the portal of data assets registration from UI
  * [GRIFFIN-5]  - Fix error in merge PR script


- Task
  * [GRIFFIN-30] - Fix license issue reported by Justin.
  * [GRIFFIN-4] - Rename Griffin to Apache Griffin in documents
  * [GRIFFIN-2] - Setup griffin website on apache
  * [GRIFFIN-1] - Refactor service code to make it more open and extensible


## Apache Griffin (incubating)- Downloads
* [Apache dist](https://dist.apache.org/repos/dist/release/incubator/griffin/)
* [Other mirrors](https://www.apache.org/dyn/closer.cgi/incubator/griffin)


