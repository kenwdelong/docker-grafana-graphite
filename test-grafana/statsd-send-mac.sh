#!/bin/bash

while :
do
	echo -n "example.statsd.counter.changed:$((((RANDOM %10)+1)*3))|c"| nc -w 1 -u $(boot2docker ip) 8125
done
