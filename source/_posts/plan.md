---
title: Plan
date: 2017-03-03 10:49:47
tags:
---

## Features

| Group        | Component           | Description  |
| ------------- |:-------------:| -----:|
| Measure      | accuracy | accuracy measure between single source of truth and target |
| Measure      | profiling | profiling target data asset, providing statistics by different rules or dimensions |
| Measure      | completeness | are all data persent|
| Measure      | timeliness | are data available at the specified time  |
| Measure      | anomaly detection | data asset conform to an expected pattern or not |
| Measure      | validity | are all data valid or not according to domain business |
| Service      | web service | restful service accessing data assets|
| Web UI      | ui page | web page to explore apache griffin features|
| Connector      | spark connector | execute jobs in spark cluster|
| Schedule      | schedule | schedule measure jobs on different clusters|

## Plan

#### 2017.04 batch accuracy onboard


- Week01: headless batch accuracy measure
  * headless batch accuracy measure use case onboard.
  * headless batch accuracy measure usage document.

- Week02: batch accuracy measure with service
  * release batch accuracy measure with service enabled. 
  * end2end headless workable use case, including guidance, metrics report. 
  * prepare data in hive, explore data asset from ui, generate accuracy measure in ui, trigger accuracy measure in script.

- Week03: batch accuracy measure with UI Page
  * UI Page refine: remove 'create data asset' 
  * end2end ui enabled workable use case. 
  * prepare data in hive, explore data asset from ui, generate accuracy measure in ui, trigger accuracy measure in script.

- Week04: release batch accuracy measure with UI, Service, Scheduler, Measure.
  * end to end full pipeline use case enabled.


#### 2017.05 streaming accuracy 

#### 2017.06 streaming accuracy onboard

#### 2017.07 schedule

#### 2017.08 profiling

#### 2017.09 completeness

#### 2017.10 timeliness

#### 2017.11 anomaly detection

#### 2017.12 validity


## Release Notes

2017.03.30 release streaming measures 



