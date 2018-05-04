---
title: User Story
date: 2017-03-02 13:00:45
tags:
---

# Crawler 

 > The Crawler produces data according to passed in seed urls and extraction configuration. 
 > There could be a couple of dimensions of Data Quality which should be highlighted:

 * Data Completeness
 * Data Freshness

## Data Completeness(accuracy)

### Problem

Crawler needs a set of metrics to evaluate its data completeness.
Data Completeness is used to indicate whether every URL fed into crawler has its valid response in a reasonable duration.
 * if an URL has its corresponding response, called mapped URL.
 * Data Completeness is a ratio: the number unmapped URL compared with total number of URLs in a certain time window.
 * The time window here is the time window of input, not the duration mentioned above.

### Challenge

The input/output could be more complicated in crawler:
 * Batch & Streaming & batch-in-streaming-out: the input/output could be in HDFS & Kafka & Mongo
 * Normal Crawling & Depth Crawling

 | normal crawling | depth crawling
 | --------------- | --------------
Batch |   |  	 
streaming | 	√ | √
batch-streaming |	| 

### Trouble Shooting

Griffin will mark and record all the unmatched rows, so that the further trouble shooting could start with this.
Get back to streaming case, the retention time have to be extended so that trouble shooting can go with it.

### Solution

#### Streaming + normal crawling
In such a case, all the input URLs are submitted into Kafka, and all the responses are written back to Kafka (different topic). 
So the Data Completeness of this case is pretty easy to define:

1.	for a given time window, 
2.	every URL submitted into kafka
3.	should be able to have an response in a certain duration.
4.	The ratio: number_of_URLs_without_response / number_of_all_URLs

#### Griffin will work in this way:
1.	create 2 connector, input/output consumer, which read data from kafka
2.	in a certain time window, for any given URL of input,
	* griffin searches the corresponding response in output topic of kafka
	* if found, pick next one
	* if not found, try again later, until a given time duration is out.
	* calculate the ratio, markdown the unmapped URLs
3.	output consumer will persist the response data to HDFS. This is to optimize the memory usage, since we don’t want to keep a giant number of data in memory.
4.	push the DQ results back to griffin DB, so that the service can offer retrieve service, and front end can show the metrics.

#### Crawler integration

Crawler should have its own dashboard, which call the griffin service and render the metrics.
 

DQ framework:  Leveraging Apache Griffin - data quality solution for validating streaming data.  Open sourced by Data Services CCOE team on 2017 Jan. 
End-to-end data completeness metrics for crawler streaming jobs. It’s calculated against input urls and corresponding output for each steaming job.
dq=#(output) / #(input) * 100%   Output is: user receives output,  Input is: the number of urls which user submitted     Our Target DQ is: 95%
   
Griffin compares input data with output data dumped from Kafka topics every 10 seconds, if the data is found, we mark it as matched data, if not found even after 24 hours, we mark it as unmatched data and stops the comparison for these input.




